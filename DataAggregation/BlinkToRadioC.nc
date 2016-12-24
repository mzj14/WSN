// $Id: BlinkToRadioC.nc,v 1.5 2007/09/13 23:10:23 scipio Exp $

/*
 * "Copyright (c) 2000-2006 The Regents of the University  of California.
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Implementation of the BlinkToRadio application.  A counter is
 * incremented and a radio message is sent whenever a timer fires.
 * Whenever a radio message is received, the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
 */
#include <Timer.h>
#include "BlinkToRadio.h"
#include "printf.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {
  uint8_t m_flag[ARRAY_SIZE / 8 + 1] = {};
  uint32_t m_data[ARRAY_SIZE] = {};
  answer_t m_ans;
  uint16_t m_len = 0;

  bool check_bit(int offset) {
      return (*(m_flag + offset / 8) & (1 << (7 - offset % 8))) != 0;
  }
  void set_bit(int offset) {
      *(m_flag + offset / 8) |= (1 << (7 - offset % 8));
  }
  void clear_bit(int offset) {
      *(m_flag + offset / 8) &= ~(1 << (7 - offset % 8));
  }
  bool received_everything() {
      return m_len == ARRAY_SIZE;
  }
  void commit_source(source_t src) {
      uint16_t i;
if(src.sequence_number % 100 == 0) printf("SEQ %d: %ld\r\n", src.sequence_number, src.random_integer);
printfflush();
      if (check_bit(src.sequence_number))
          return;

      for (i = 0; i < m_len; i++)
          if (*(m_data + i) > src.random_integer)
              break;
      memmove(m_data + i + 1, m_data + i, (m_len - i) * sizeof(uint32_t));
      m_len += 1;
      *(m_data + i) = src.random_integer;
      set_bit(src.sequence_number);
      /*
      if (m_len == ARRAY_SIZE)
              post sort_task();
       */
  }
  void gen_response() {
      uint16_t i = 0;
      if (m_len != ARRAY_SIZE)
          return;

      m_ans.sum = 0;
      for (; i < m_len; ++i)
          m_ans.sum += m_data[i];
      m_ans.average = m_ans.sum / m_len;
      m_ans.min = m_data[0];
      m_ans.max = m_data[m_len - 1];
      m_ans.median = (m_data[m_len / 2] + m_data[m_len / 2 - 1]) / 2;
      m_ans.group_id = GROUP_ID;
  }

  bool answer_acked = FALSE;
  bool busy = FALSE;

  event void Boot.booted() {    
	call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }


  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&m_ans == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){\
if (len == sizeof(source_t)) {
      source_t* pkt_source = (source_t*)payload;
      commit_source(*pkt_source);

      if(answer_acked == FALSE && received_everything()){
          if (!busy) {
answer_acked = TRUE;
            gen_response();
printf("max=%ld, min=%ld, median=%ld, average=%ld, sum=%ld\n", m_ans.max, m_ans.min, m_ans.median, m_ans.average, m_ans.sum);
            if (call AMSend.send(AM_BROADCAST_ADDR, &m_ans, sizeof(answer_t)) == SUCCESS) {
              busy = TRUE;
            }
          }

      }
    } else if (len == sizeof(ack_t)) {
        ack_t* pkt_ack = (ack_t*)payload;
        if(pkt_ack->group_id == GROUP_ID){
            answer_acked = TRUE;
        }
    }
    return msg;
  }






}
