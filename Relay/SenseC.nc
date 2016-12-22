#include "AM.h"
#include "SenseMote.h"
#include "Timer.h"

module SenseC @safe() {
  uses {
    interface Boot;
    interface SplitControl as RadioControl;

    interface AMSend as RadioSend[am_id_t id];
    interface Receive as RadioReceive[am_id_t id];
    interface Receive as RadioSnoop[am_id_t id];
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;

    interface Leds;
    interface Timer<TMilli> as Timer;
    interface Read<uint16_t> as ReadLight;
    interface Read<uint16_t> as ReadTemperature;
    interface Read<uint16_t> as ReadHumidity;
  }
}

implementation
{
  enum {
    RADIO_QUEUE_LEN = 128,
  };

  message_t  radioQueueBufs[RADIO_QUEUE_LEN];
  message_t  * ONE_NOK radioQueue[RADIO_QUEUE_LEN];
  uint8_t    radioIn, radioOut;
  bool       radioBusy, radioFull;
  // uint8_t    radioError;

  oscilloscope_t node;
  message_t node_msg;
  // bool node_ack;

  task void radioSendTask();
  /*
  void fixError() {
    radioError++;
    if (radioError == 10)
    {
      radioIn = radioOut = radioError = 0;
      radioBusy = radioFull = FALSE;
    }
  }
  */
  void report_problem() { call Leds.led0Toggle(); }

  void report_sent() { call Leds.led1Toggle(); }

  void report_received() { call Leds.led0Toggle(); }

  void dropBlink() {
    call Leds.led2Toggle();
    // fixError();
  }

  void failBlink() {
    call Leds.led2Toggle();
    // fixError();
  }

  event void Boot.booted() {
    uint8_t i;

    for (i = 0; i < RADIO_QUEUE_LEN; i++)
      radioQueue[i] = &radioQueueBufs[i];
    radioIn = radioOut = 0;
    radioBusy = FALSE;
    radioFull = TRUE;
    // radioError = 0;

    node.id = TOS_NODE_ID;
    node.count = -1;
    node.version = 0;
    // node_ack = TRUE;
    node.interval = DEFAULT_INTERVAL;
    node.token = TOKEN_SECRET;
    // node.total_time = 0;
    // call Timer0.startPeriodic(node.time_period);

    call RadioControl.start();
  }

  void startTimer() {
    // 设置采样定时器
    call Timer.startPeriodic(node.interval);
    // reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
    if (error == SUCCESS) {
      radioFull = FALSE;
      startTimer();
    }
  }

  event void RadioControl.stopDone(error_t error) {}

  event void Timer.fired()
  {
    message_t *ret;
    oscilloscope_t *btrpkt;

      node.count++;
      /*
      if (call ReadLight.read() != SUCCESS)
        report_problem();
      if (call ReadTemperature.read() != SUCCESS)
        report_problem();
      if (call ReadHumidity.read() != SUCCESS)
        report_problem();
      */
      call ReadLight.read();
      call ReadTemperature.read();
      call ReadHumidity.read();
      node.current_time = call Timer.getNow();

      // reading++;

      // node.total_time += node.time_period;

      btrpkt = (oscilloscope_t*)(call RadioPacket.getPayload(&node_msg, sizeof(oscilloscope_t)));
      btrpkt->id = node.id;
      btrpkt->count = node.count;
      btrpkt->temperature = node.temperature;
      btrpkt->humidity = node.humidity;
      btrpkt->light = node.light;
      btrpkt->version = node.version;
      btrpkt->token = node.token;
      btrpkt->interval = node.interval;
      btrpkt->current_time = node.current_time;

      call RadioPacket.setPayloadLength(&node_msg, sizeof(oscilloscope_t));
      call RadioAMPacket.setType(&node_msg, AM_OSCILLOSCOPE);
      call RadioAMPacket.setSource(&node_msg, node.id);

      /*
      if (node.nodeid == NODE1)
        call RadioAMPacket.setDestination(&node_msg, NODE0);
      else
        call RadioAMPacket.setDestination(&node_msg, NODE1);
      */

      atomic {
          if (!radioFull)
    	  {
    	      ret = radioQueue[radioIn];
              // truly copy the packet
    	      *radioQueue[radioIn] = node_msg;
    	      radioIn = (radioIn + 1) % RADIO_QUEUE_LEN;

    	      if (radioIn == radioOut)
    	        radioFull = TRUE;

    	      if (!radioBusy)
    	      {
    	          post radioSendTask();
    	          radioBusy = TRUE;
    	      }
    	  }
          else
    	  dropBlink();
      }
  }

  message_t* ONE receive(message_t* ONE msg, void* payload, uint8_t len);

  event message_t *RadioSnoop.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) {
    return receive(msg, payload, len);
  }

  event message_t *RadioReceive.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) {
    return receive(msg, payload, len);
  }

  message_t* receive(message_t *msg, void *payload, uint8_t len) {
    message_t *ret = msg;

    oscilloscope_t *omsg = payload;

    /* If we receive a newer version, update our interval.
       If we hear from a future count, jump ahead but suppress our own change
    */
    if (omsg->version > node.version)
    {
	    node.version = omsg->version;
	    node.interval = omsg->interval;
        // restart timer
	    startTimer();
        report_received();
        return msg;
    }

    // not the message from our node
    if (len != sizeof(oscilloscope_t) || (omsg)->token != TOKEN_SECRET) {
        return msg;
    }

    // we need to send the message to basestation for out partner
    // 原子操作，不可被打断
    atomic {
        report_received();
        if (!radioFull)
    	{
          // 把 msg 即将侵占的 packet 放入 ret
    	  ret = radioQueue[radioIn];
          // msg 进入 packet 队列
    	  radioQueue[radioIn] = msg;

          // uartIn 指向下一个包的位置
    	  radioIn = (radioIn + 1) % RADIO_QUEUE_LEN;

    	  if (radioIn == radioOut)
    	    radioFull = TRUE;

    	  if (!radioBusy)
    	    {
    	      post radioSendTask();
    	      radioBusy = TRUE;
    	    }
    	}
        else
    	dropBlink();
        // 一个原本等待发向串口数据包被新进来的数据包挤掉，出现了包丢失的现象
    }
    return ret;
  }

  task void radioSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr,source;
    message_t* msg;

    atomic
    {
      if (radioIn == radioOut && !radioFull)
	{
	  radioBusy = FALSE;
	  return;
	}

      msg = radioQueue[radioOut];
      len = call RadioPacket.payloadLength(msg);
      addr = call RadioAMPacket.destination(msg);
      source = call RadioAMPacket.source(msg);
      id = call RadioAMPacket.type(msg);

      if (call RadioSend.send[id](addr, msg, len) == SUCCESS)
        report_sent();
      else
      {
	failBlink();
	post radioSendTask();
      }
    }
  }

  event void RadioSend.sendDone[am_id_t id](message_t* msg, error_t error) {
    if (error != SUCCESS)
      failBlink();
    else
      atomic
	if (msg == radioQueue[radioOut])
	  {
        // 更新 radioOut
	    if (++radioOut >= RADIO_QUEUE_LEN)
	      radioOut = 0;
	    if (radioFull)
	      radioFull = FALSE;
	  }
    post radioSendTask();
  }

  event void ReadTemperature.readDone(error_t result, uint16_t data)
  {
    if (result != SUCCESS)
    {
  	    data = 0xffff;
  	    report_problem();
    }
    // 存储读到的数据
    node.temperature = data;
  }

  event void ReadHumidity.readDone(error_t result, uint16_t data)
  {
    if (result != SUCCESS)
    {
        data = 0xffff;
        report_problem();
    }
    // 存储读到的数据
    node.humidity = data;
  }

  event void ReadLight.readDone(error_t result, uint16_t data)
  {
    if (result != SUCCESS)
    {
  	    data = 0xffff;
  	    report_problem();
    }
    // 存储读到的数据
    node.light = data;
  }
}
