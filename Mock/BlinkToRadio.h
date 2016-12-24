// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
    ANS_MAX = 4997,
    ANS_MIN = 4,
    ANS_SUM = 4999792,
    ANS_AVERAGE = 2499,
    ANS_MEDIAN = 2484,
    AM_BLINKTORADIO = 0
};

typedef nx_struct ack {
    nx_uint8_t group_id;
} ack_t;

typedef nx_struct answer {
    nx_uint8_t group_id;
    nx_uint32_t max;
    nx_uint32_t min;
    nx_uint32_t sum;
    nx_uint32_t average;
    nx_uint32_t median;
} answer_t;

#endif
