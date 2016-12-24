#ifndef __util__HeaderFile__
#define __util__HeaderFile__

typedef nx_struct source {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
}
source_t;

typedef nx_struct response {
    nx_uint8_t group_id;
    nx_uint32_t max;
    nx_uint32_t min;
    nx_uint32_t sum;
    nx_uint32_t average;
    nx_uint32_t median;
}
response_t;

implementation {
    enum { array_size = 2000, group_id = 31 };
    uint8_t m_flag[array_size];
    uint32_t m_data[array_size];
    response_t m_resp;
    uint16_t m_len = 0;
    bool check_bit(int offset) {
        return *(m_flag + offset / 8) & (1 << (7 - offset % 8));
    }
    void set_bit(int offset) {
        *(m_flag + offset / 8) |= (1 << (7 - offset % 8));
    }
    void clear_bit(int offset) {
        *(m_flag + offset / 8) &= ~(1 << (7 - offset % 8));
    }
    void commit_source(source_t src) {
        *(m_data + src.sequence_number) = src.random_integer;
        set_bit(src.sequence_number);
        m_len += 1;
        /*
        if (m_len == array_size)
                post sort_task();
         */
    }
    task void gen_response() {
        uint32_t c, d, swap;
        m_resp.sum = 0;
        for (c = 0; c < (m_len - 1); c++) {
            m_resp.sum += m_data[c];
            for (d = 0; d < m_len - c - 1; d++) {
                if (m_data[d] > m_data[d + 1]) /* For decreasing order use < */
                {
                    swap = m_data[d];
                    m_data[d] = m_data[d + 1];
                    m_data[d + 1] = swap;
                }
            }
        }
        m_resp.average = m_resp.sum / m_len;
        m_resp.min = m_data[0];
        m_resp.max = m_data[m_len - 1];
        m_resp.median = m_data[m_len / 2];
        m_resp.group_id = group_id;
    }
}

#endif
