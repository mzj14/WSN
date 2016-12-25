#include "Timer.h"
#include "printf.h"
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
  message_t sendBuf;
  bool sendBusy;

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); printf("can not read data from senser\n");}
  void report_sent() { call Leds.led1Toggle(); printf("sent packet\n"); }
  void report_received() { call Leds.led2Toggle(); }
  void dropBlink() { call Leds.led0Toggle(); printf("drop packet\n"); }

  event void Boot.booted() {
    local.interval = DEFAULT_INTERVAL;
    local.id = TOS_NODE_ID;
    local.count = -1;
    local.version = 0;
    local.token = TOKEN_SECRET_MOTE;
    sendBusy = FALSE;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  void startTimer() {
    call Timer.startPeriodic(local.interval);
    reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {}

  // receive message from radio
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    oscilloscope_t *omsg = payload;

    /* If we receive a newer version, update our interval.*/
    if (len == sizeof(oscilloscope_t) && omsg->token == TOKEN_SECRET_PC && omsg->version > local.version) {
      local.version = omsg->version;
      local.interval = omsg->interval;
       // restart timer
      startTimer();
      // report_problem();
      report_received();
    }

    return msg;
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    if (reading == NREADINGS) {
      if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength()) {
        // Don't need to check for null because we've already checked length
        // 将 local 信息转存到发送信息中
        memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
        if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS) {
          sendBusy = TRUE;
        }
      }
      if (!sendBusy) {
        report_problem();
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
    if (error == SUCCESS) {
      report_sent();
    } else {
      report_problem();
    }
    sendBusy = FALSE;
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
