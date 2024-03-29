// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
    ARRAY_SIZE = 2000,
    GROUP_ID = 6,
    AM_BLINKTORADIO = 0,
    MIN_MYID = 17,
    MAX_MYID = 18,
    SERVER_ID = 1000
};

typedef nx_struct ack {
    nx_uint8_t group_id;
}
ack_t;

typedef nx_struct source {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
}
source_t;

typedef nx_struct answer {
    nx_uint8_t group_id;
    nx_uint32_t max;
    nx_uint32_t min;
    nx_uint32_t sum;
    nx_uint32_t average;
    nx_uint32_t median;
}
answer_t;

typedef nx_struct request {
    nx_uint16_t index;
}
request_t;

#endif
