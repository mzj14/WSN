// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
    ARRAY_SIZE = 2000,
    GROUP_ID = 6,
    AM_BLINKTORADIO = 0
};

typedef nx_struct source {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
}
source_t;

typedef nx_struct request {
    nx_uint16_t index;
}
request_t;

#endif
