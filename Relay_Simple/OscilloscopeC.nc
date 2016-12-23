/*
 * Copyright (c) 2006 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA,
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Oscilloscope demo application. See README.txt file in this directory.
 *
 * @author David Gay
 */
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
  enum {
    RADIO_QUEUE_LEN = 64,
  };

  message_t  radioQueueBufs[RADIO_QUEUE_LEN];
  message_t  * ONE_NOK radioQueue[RADIO_QUEUE_LEN];

  message_t sendBuf;   /* for sensor data */
  message_t sendBuf_1; /* for partner message */

  uint8_t    radioIn, radioOut;
  bool       radioBusy, radioFull;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0On(); }
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

  // bool sendBusy;
  task void radioSendTask();

  task void radioSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr,source;
    message_t* msg;

    // call Leds.led1Toggle();

    atomic
    {

      if (radioIn == radioOut && !radioFull)
	{
	  radioBusy = FALSE;
	  return;
	}

      msg = radioQueue[radioOut];
      // len = call RadioPacket.payloadLength(msg);
      // addr = call RadioAMPacket.destination(msg);
      // source = call RadioAMPacket.source(msg);
      // id = call RadioAMPacket.type(msg);
      // call Leds.led1Toggle();
      /*
      if (sizeof(*msg) != sizeof(oscilloscope_t)) {
          return;
      }
      */

      if (call AMSend.send(AM_BROADCAST_ADDR, msg, sizeof(oscilloscope_t)) == SUCCESS)
        report_sent();
      else
      {
	failBlink();
    post radioSendTask();
      }
    }
  }

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */

  /* When we head an Oscilloscope message, we check it's sample count. If
     it's ahead of ours, we "jump" forwards (set our count to the received
     count). However, we must then suppress our next count increment. This
     is a very simple form of "time" synchronization (for an abstract
     notion of time). */
  // bool suppressCountChange;

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
    // sendBusy = FALSE;
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

  event void RadioControl.stopDone(error_t error) {
  }

  // receive message from radio

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    message_t *ret = msg;

    oscilloscope_t *omsg = payload;

    // report_received();

    /* If we receive a newer version, update our interval.
       If we hear from a future count, jump ahead but suppress our own change
    */

    if (omsg->version > local.version)
      {
	// local.version = omsg->version;
	// local.interval = omsg->interval;
    // restart timer
	// startTimer();
    // report_problem();
        report_received();
        return msg;
      }

    if (len != sizeof(oscilloscope_t) || omsg->token != TOKEN_SECRET_MOTE) {
       return msg;
    }

    omsg->token = TOKEN_SECRET_RELAY;

       // we need to send the message to basestation for out partner
    // 原子操作，不可被打断
    atomic {
        if (!radioFull)
    	{
          call Leds.led0Toggle();
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
    }

    // send packet to basestation for our partner
	// if (!sendBusy)
	  // {
	    // Don't need to check for null because we've already checked length
	    // above
        // 将 local 信息转存到发送信息中
        // omsg->token = TOKEN_SECRET_RELAY;
	    // memcpy(call AMSend.getPayload(&sendBuf_1, sizeof(oscilloscope_t)), omsg, sizeof local);
	    // if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf_1, sizeof(oscilloscope_t)) == SUCCESS)
	      // sendBusy = TRUE;
        // call AMSend.send(AM_BROADCAST_ADDR, &sendBuf_1, sizeof(oscilloscope_t));
	  // }
	// if (!sendBusy) {
        // report_problem();
    // }


    return msg;
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    message_t *ret;
    if (reading == NREADINGS)
      {
    // 如果说这个时候已经集齐了一定数量的传感数据
	// if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	  // {
	    // Don't need to check for null because we've already checked length
	    // above
        // 将 local 信息转存到发送信息中
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
	    // if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
	      // sendBusy = TRUE;
        // call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local);
	  // }
    /*
	if (!sendBusy)
	  report_problem();
    */

    atomic {
      if (!radioFull)
	  {
	      ret = radioQueue[radioIn];
          // truly copy the packet
	      *radioQueue[radioIn] = sendBuf;
	      radioIn = (radioIn + 1) % RADIO_QUEUE_LEN;

	      if (radioIn == radioOut)
	        radioFull = TRUE;

	      if (!radioBusy)
	      {
	          post radioSendTask();
	          radioBusy = TRUE;
	      }
	  }
      else {
        dropBlink();
      }
    }

	reading = 0;
	/* Part 2 of cheap "time sync": increment our count if we didn't
	   jump ahead. */
	  // if (!suppressCountChange)
	  // suppressCountChange = FALSE;
    }
    local.count++;
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
    local.current_time = call Timer.getNow();
    reading++;
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
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
    /*
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();
    */
    // sendBusy = FALSE;
  }

  event void ReadTemperature.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
	data = 0xffff;
	report_problem();
      }
    // 存储读到的数据
    local.temperature = data;
  }

  event void ReadHumidity.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
	data = 0xffff;
	report_problem();
      }
    // 存储读到的数据
    local.humidity = data;
  }

  event void ReadLight.readDone(error_t result, uint16_t data) {
    if (result != SUCCESS)
      {
	data = 0xffff;
	report_problem();
      }
    // 存储读到的数据
    local.light = data;
  }
}
