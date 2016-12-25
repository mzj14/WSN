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
  message_t sendBuf;   /* for sensor data */
  message_t sendBuf_1; /* for partner message */
  bool sendBusy;

  /* Current local state - interval, version and accumulated readings */
  oscilloscope_t local;

  uint8_t reading; /* 0 to NREADINGS */

  /* When we head an Oscilloscope message, we check it's sample count. If
     it's ahead of ours, we "jump" forwards (set our count to the received
     count). However, we must then suppress our next count increment. This
     is a very simple form of "time" synchronization (for an abstract
     notion of time). */
  // bool suppressCountChange;

  // Use LEDs to report various status issues.
  void report_problem() { call Leds.led0Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }
  void report_received() { call Leds.led2Toggle(); }

  event void Boot.booted() {
    // 设置采样频率
    local.interval = DEFAULT_INTERVAL;
    // 设置节点id
    local.id = TOS_NODE_ID;
    local.count = -1;
    local.version = 0;
    local.token = TOKEN_SECRET_RELAY;
    sendBusy = FALSE;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
  }

  void startTimer() {
    // 设置采样定时器
    call Timer.startPeriodic(local.interval);
    reading = 0;
  }

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  // receive message from radio

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    oscilloscope_t *omsg = payload;

    // report_received();

    /* If we receive a newer version, update our interval.
       If we hear from a future count, jump ahead but suppress our own change
    */

    if (len == sizeof(oscilloscope_t) && omsg->token == TOKEN_SECRET_PC && omsg->version > local.version)
      {
	local.version = omsg->version;
	local.interval = omsg->interval;
    // restart timer
	startTimer();
    // report_problem();
        report_received();
        return msg;
      }

    if (len != sizeof(oscilloscope_t) || omsg->token != TOKEN_SECRET_MOTE) {
       return msg;
    }

    // send packet to basestation for our partner
	if (!sendBusy)
	  {
	    // Don't need to check for null because we've already checked length
	    // above
        // 将 local 信息转存到发送信息中
        omsg->token = TOKEN_SECRET_RELAY;
	    memcpy(call AMSend.getPayload(&sendBuf_1, sizeof(oscilloscope_t)), omsg, sizeof local);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf_1, sizeof(oscilloscope_t)) == SUCCESS)
	      sendBusy = TRUE;
	  }
	if (!sendBusy)
	  report_problem();

    return msg;
  }

  /* At each sample period:
     - if local sample buffer is full, send accumulated samples
     - read next sample
  */
  event void Timer.fired() {
    if (reading == NREADINGS)
      {
    // 如果说这个时候已经集齐了一定数量的传感数据
	if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
	  {
	    // Don't need to check for null because we've already checked length
	    // above
        // 将 local 信息转存到发送信息中
	    memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
	    if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
	      sendBusy = TRUE;
	  }
	if (!sendBusy)
	  report_problem();

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
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();

    sendBusy = FALSE;
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
