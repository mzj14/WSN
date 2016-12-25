
#include "BlinkToRadio.h"
#include "printf.h"
#include <Timer.h>

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
    message_t resppkt;
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
    bool received_everything() { return m_len == ARRAY_SIZE; }
    void commit_source(source_t src) {
        uint16_t i;
        if (src.sequence_number % 100 == 0) {
            printf("SEQ %d: %ld\r\n", src.sequence_number, src.random_integer);
            printfflush();
        }
        if (check_bit(src.sequence_number - 1))
            return;
        m_len += 1;
        *(m_data + src.sequence_number - 1) = src.random_integer;
        set_bit(src.sequence_number - 1);
    }
    bool busy = FALSE;

    event void Boot.booted() { call AMControl.start(); }

    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) {
        } else {
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err) {}

    event void AMSend.sendDone(message_t * msg, error_t err) {
        if (&resppkt == msg) {
            busy = FALSE;
        }
    }

    void dump_package(void *pkt, uint8_t len) {
        uint8_t i;
        unsigned char *c = (unsigned char *)pkt;
        for (i = 0; i < len; i++) {
            printf("%02x ", c[i]);
        }
        printf("\r\n");
    }
    event message_t *Receive.receive(message_t * msg, void *payload,
                                     uint8_t len) {
        source_t *resp;
        am_addr_t id = call source(payload);
        if (id != SERVER_ID && id != MY_BOSS)
            return;
        if (len == sizeof(source_t)) {
            source_t *pkt_source = (source_t *)payload;
            commit_source(*pkt_source);
        } else if (len == sizeof(request_t)) {
            request_t *pkt_request = (request_t *)payload;
            uint16_t seq = pkt_request->index;
            if (check_bit(seq - 1)) {
                resp = (source_t *)(call Packet.getPayload(&resppkt,
                                                           sizeof(source_t)));
                resp->random_integer = m_data[seq - 1];
                resp->sequence_number = seq;
                if (call AMSend.send(AM_BROADCAST_ADDR, &resppkt,
                                     sizeof(source_t)) == SUCCESS) {
                    busy = TRUE;
                }
            } else {
                printf(", MISS=====\n");
            }
            printfflush();
        }
        return msg;
    }
}
