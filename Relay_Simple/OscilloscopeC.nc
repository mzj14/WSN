#include "Timer.h"
#include "Oscilloscope.h"

module OscilloscopeC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Read<uint16_t> as ReadLight;
    interface Read<uint16_t> as ReadTemperature;
    interface Read<uint16_t> as ReadHumidity;
    interface Leds;
  }
}
implementation
{
  // set packet sequence length
  enum {
    RADIO_QUEUE_LEN = 64,
  };

  message_t  radioQueueBufs[RADIO_QUEUE_LEN];
  message_t  * ONE_NOK radioQueue[RADIO_QUEUE_LEN];

  message_t sendBuf;   /* for sensor data */
  message_t sendBuf_1; /* for partner packet */

  uint8_t    radioIn, radioOut;
  bool       radioBusy, radioFull;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }
  void dropBlink() { call Leds.led0Toggle(); }
  void failBlink() { call Leds.led0Toggle(); }

  // bool sendBusy;
  task void radioSendTask();

  task void radioSendTask() {
    message_t* msg;

    atomic {
      if (radioIn == radioOut && !radioFull) {
          radioBusy = FALSE;
          return;
      }
      msg = radioQueue[radioOut];
      if (call AMSend.send(AM_BROADCAST_ADDR, msg, sizeof(oscilloscope_t)) == SUCCESS) {
        report_sent();
      } else {
        failBlink();
        post radioSendTask();
      }
    }
  }

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */

  event void Boot.booted() {
    uint8_t i;
    for (i = 0; i < RADIO_QUEUE_LEN; i++)
      radioQueue[i] = &radioQueueBufs[i];
    radioIn = radioOut = 0;
    radioBusy = FALSE;
    radioFull = TRUE;

    // 设置采样频率
    local.interval = DEFAULT_INTERVAL;
    // 设置节点id
    local.id = TOS_NODE_ID;
    local.count = -1;
    local.version = 0;
    local.token = TOKEN_SECRET_RELAY;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  void startTimer() {
    // 设置采样定时器
    call Timer.startPeriodic(local.interval);
    reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
    if (error == SUCCESS) {
      radioFull = FALSE;
      startTimer();
    }
  }

  event void RadioControl.stopDone(error_t error) {}

  // receive message from radio
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    message_t *ret = msg;
    oscilloscope_t *omsg = payload;

    /* If we receive a newer version, update our interval. */
    if (len == sizeof(oscilloscope_t) && omsg->token == TOKEN_SECRET_PC && omsg->version > local.version) {
      local.version = omsg->version;
      local.interval = omsg->interval;
      startTimer();
      report_received();
      return msg;
    }

    if (len != sizeof(oscilloscope_t) || omsg->token != TOKEN_SECRET_MOTE) {
       return msg;
    }

    // Now we know that the message is from our partner
    omsg->token = TOKEN_SECRET_RELAY;
    report_received();
    // we need to send the message to basestation for out partner
    // 原子操作，不可被打断
    atomic {
      if (!radioFull) {
        ret = radioQueue[radioIn];
        radioQueue[radioIn] = msg;
        // radioIn 指向下一个包的位置
        radioIn = (radioIn + 1) % RADIO_QUEUE_LEN;
        if (radioIn == radioOut) {
          radioFull = TRUE;
        }
        if (!radioBusy) {
          post radioSendTask();
          radioBusy = TRUE;
        }
      } else {
        dropBlink();
      }
    }
    return msg;
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    message_t *ret;
    if (reading == NREADINGS) {
      memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
      atomic {
        if (!radioFull) {
          ret = radioQueue[radioIn];
          *radioQueue[radioIn] = sendBuf;
          radioIn = (radioIn + 1) % RADIO_QUEUE_LEN;
          if (radioIn == radioOut) {
            radioFull = TRUE;
          }
          if (!radioBusy) {
            post radioSendTask();
            radioBusy = TRUE;
          }
        } else {
          dropBlink();
        }
      }
     reading = 0;
    }
    local.count++;
    if (call ReadLight.read() != SUCCESS)
      report_problem();
    if (call ReadTemperature.read() != SUCCESS)
      report_problem();
    if (call ReadHumidity.read() != SUCCESS)
      report_problem();
    local.current_time = call Timer.getNow();
    reading++;
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error != SUCCESS) {
      failBlink();
    } else {
      atomic
      if (msg == radioQueue[radioOut]) {
        // 更新 radioOut
        if (++radioOut >= RADIO_QUEUE_LEN)
          radioOut = 0;
        if (radioFull)
          radioFull = FALSE;
       }
    }
    post radioSendTask();
  }

  event void ReadTemperature.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS) {
      data = 0xffff;
      report_problem();
    }
    local.temperature = data;
  }

  event void ReadHumidity.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS) {
      data = 0xffff;
      report_problem();
    }
    local.humidity = data;
  }

  event void ReadLight.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS) {
      data = 0xffff;
      report_problem();
    }
    local.light = data;
  }
}
