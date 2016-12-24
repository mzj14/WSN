#ifndef __util__HeaderFile__
#define __util__HeaderFile__

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
    nx_uint32_t token;
}
answer_t;

typedef nx_struct request {
    nx_uint32_t token;
    nx_uint16_t index;
}
request_t;

typedef nx_struct response {
    nx_uint16_t sequence_number;
    nx_uint32_t random_integer;
    nx_uint32_t token;
}
response_t;

implementation {
    enum { array_size = 2000, group_id = 31 };
    uint8_t m_flag[array_size / 8 + 1] = {};
    uint32_t m_data[array_size] = {};
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
        int i = 0;
        for (; i < array_size / 8; ++i)
            if (m_flag[i] != (uint8_t)(-1))
                return FALSE;
        for (i = array_size / 8 * 8; i < array_size - array_size / 8 * 8; ++i)
            if (!check_bit(i))
                return FALSE;
        return TRUE;
    }
    void commit_source(source_t src) {
        if (check_bit(src.sequence_number))
            return;
        uint16_t i;
        for (i = 0; i < m_len; i++)
            if (*(m_data + i) > src.random_integer)
                break;
        memmove(m_data + i + 1, m_data + i, (m_len - i) * sizeof(int));
        m_len += 1;
        *(m_data + i) = src.random_integer;
        set_bit(src.sequence_number);
        /*
        if (m_len == array_size)
                post sort_task();
         */
    }
    task void gen_response() {
        if (m_len != array_size)
            return;
        uint16_t i = 0;
        m_ans.sum = 0;
        for (; i < (m_len - 1); ++i)
            m_ans.sum += m_data[i];
        m_ans.average = m_ans.sum / m_len;
        m_ans.min = m_data[0];
        m_ans.max = m_data[m_len - 1];
        m_ans.median = (m_data[m_len / 2] + m_data[m_len / 2 - 1]) / 2;
        m_ans.group_id = group_id;
    }
}

#endif
