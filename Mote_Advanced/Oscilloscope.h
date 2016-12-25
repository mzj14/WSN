#ifndef OSCILLOSCOPE_H
#define OSCILLOSCOPE_H

enum {
  /* Number of readings per message. If you increase this, you may have to
     increase the message_t size. */
  NREADINGS = 1,

  /* Default sampling period. */
  DEFAULT_INTERVAL = 100,

  AM_OSCILLOSCOPE = 0x93,

  TOKEN_SECRET_MOTE = 0xd7b5c6a0,

  TOKEN_SECRET_PC = 0x10101010
};

typedef nx_struct oscilloscope {
  nx_uint16_t version; /* Version of the interval. */
  nx_uint16_t interval; /* Samping period. */
  nx_uint16_t id; /* Mote id of sending mote. */
  nx_uint16_t count; /* The readings are samples count * NREADINGS onwards */
  nx_uint16_t temperature;
  nx_uint16_t humidity;
  nx_uint16_t light;
  nx_uint32_t current_time;
  nx_uint32_t token;
} oscilloscope_t;

#endif
