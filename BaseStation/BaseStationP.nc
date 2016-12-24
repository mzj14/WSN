#include "AM.h"
#include "Serial.h"
#include "Oscilloscope.h"

module BaseStationP @safe() {
  uses {
    interface Boot;
    interface SplitControl as SerialControl;
    interface SplitControl as RadioControl;

    interface AMSend as UartSend[am_id_t id];
    interface Receive as UartReceive[am_id_t id];
    interface Packet as UartPacket;
    interface AMPacket as UartAMPacket;

    interface AMSend as RadioSend[am_id_t id];
    interface Receive as RadioReceive[am_id_t id];
    interface Receive as RadioSnoop[am_id_t id];
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;

    interface Leds;
  }
}

implementation
{
  enum {
    UART_QUEUE_LEN = 120,
    RADIO_QUEUE_LEN = 8,
  };

  message_t  uartQueueBufs[UART_QUEUE_LEN];
  message_t  * ONE_NOK uartQueue[UART_QUEUE_LEN];
  uint8_t    uartIn, uartOut;
  bool       uartBusy, uartFull;

  message_t  radioQueueBufs[RADIO_QUEUE_LEN];
  message_t  * ONE_NOK radioQueue[RADIO_QUEUE_LEN];
  uint8_t    radioIn, radioOut;
  bool       radioBusy, radioFull;

  // 向串口发送
  task void uartSendTask();
  // 向radio发送
  task void radioSendTask();

  void dropBlink() {
    call Leds.led0Toggle();
  }

  void failBlink() {
    call Leds.led0Toggle();
  }

  void report_received() { call Leds.led2Toggle(); }
  void report_sent() { call Leds.led1Toggle(); }

  event void Boot.booted() {
    uint8_t i;


    for (i = 0; i < UART_QUEUE_LEN; i++)
      uartQueue[i] = &uartQueueBufs[i];
    uartIn = uartOut = 0;
    uartBusy = FALSE;
    uartFull = TRUE;

    for (i = 0; i < RADIO_QUEUE_LEN; i++)
      radioQueue[i] = &radioQueueBufs[i];
    radioIn = radioOut = 0;
    radioBusy = FALSE;
    radioFull = TRUE;

    call RadioControl.start();
    call SerialControl.start();
  }

  event void RadioControl.startDone(error_t error) {
    if (error == SUCCESS) {
      radioFull = FALSE;
    }
  }

  event void SerialControl.startDone(error_t error) {
    if (error == SUCCESS) {
      uartFull = FALSE;
    }
  }

  event void SerialControl.stopDone(error_t error) {}
  event void RadioControl.stopDone(error_t error) {}

  uint8_t count = 0;

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

  // 当基站的 radio 接收到包后会发送给串口
  message_t* receive(message_t *msg, void *payload, uint8_t len) {
    message_t *ret = msg;

    // report_received();
    if (len != sizeof(oscilloscope_t) || ((oscilloscope_t*)payload)->token != TOKEN_SECRET_RELAY) {
        return msg;
    }

    // 原子操作，不可被打断
    report_received();
    atomic {
      if (!uartFull)
  {

      // 把 msg 即将侵占的 packet 放入 ret
    ret = uartQueue[uartIn];
      // msg 进入 packet 队列
    uartQueue[uartIn] = msg;

      // uartIn 指向下一个包的位置
    uartIn = (uartIn + 1) % UART_QUEUE_LEN;

    if (uartIn == uartOut)
      uartFull = TRUE;

    if (!uartBusy)
      {
        post uartSendTask();
        uartBusy = TRUE;
      }
  }
      else
  dropBlink();
    }

    return ret;
  }

  uint8_t tmpLen;

  task void uartSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr, src;
    message_t* msg;
    atomic
    // 如果 radio 数据包队列为空，直接返回
      if (uartIn == uartOut && !uartFull)
  {
    uartBusy = FALSE;
    return;
  }

    msg = uartQueue[uartOut];
    // 从待发送的消息中获取所需要的信息
    tmpLen = len = call RadioPacket.payloadLength(msg);
    id = call RadioAMPacket.type(msg);
    addr = call RadioAMPacket.destination(msg);
    src = call RadioAMPacket.source(msg);

    // 清空串口数据包序列中该位置的数据包
    call UartPacket.clear(msg);
    call UartAMPacket.setSource(msg, src);

    if (call UartSend.send[id](addr, uartQueue[uartOut], len) == SUCCESS)
      report_sent();
    else
      {
    // 发送失败后会重新发送
  failBlink();
  post uartSendTask();
      }
  }

  event void UartSend.sendDone[am_id_t id](message_t* msg, error_t error) {
    if (error != SUCCESS)
      failBlink();
    else
      atomic
  if (msg == uartQueue[uartOut])
    {
        // 设置下一个待发送的数据包编号
      if (++uartOut >= UART_QUEUE_LEN)
        uartOut = 0;
      if (uartFull)
        uartFull = FALSE;
    }
    // 继续发送其他数据
    post uartSendTask();
  }

  // 当串口接收到包后会进行广播
  event message_t *UartReceive.receive[am_id_t id](message_t *msg,
               void *payload,
               uint8_t len) {
    message_t *ret = msg;
    bool reflectToken = FALSE;

    if (len != sizeof(oscilloscope_t) || ((oscilloscope_t*)payload)->token != TOKEN_SECRET_PC) {
        return msg;
    }

    report_received();

    atomic
      if (!radioFull)
  {
    reflectToken = TRUE;
    ret = radioQueue[radioIn];
    radioQueue[radioIn] = msg;
      // 更新 radioIn
    if (++radioIn >= RADIO_QUEUE_LEN)
      radioIn = 0;
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

    if (reflectToken) {
      //call UartTokenReceive.ReflectToken(Token);
    }

    return ret;
  }

  task void radioSendTask() {
    uint8_t len;
    am_id_t id;
    am_addr_t addr,source;
    message_t* msg;

    atomic
      if (radioIn == radioOut && !radioFull)
  {
    radioBusy = FALSE;
    return;
  }

    msg = radioQueue[radioOut];
    // 提取 packet 中的常规字段，而不关心 payload 的具体内容
    len = call UartPacket.payloadLength(msg);
    addr = call UartAMPacket.destination(msg);
    source = call UartAMPacket.source(msg);
    id = call UartAMPacket.type(msg);

    call RadioPacket.clear(msg);
    call RadioAMPacket.setSource(msg, source);

    if (call RadioSend.send[id](addr, msg, len) == SUCCESS)
      report_sent();
    else
      {
  failBlink();
  post radioSendTask();
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
}
