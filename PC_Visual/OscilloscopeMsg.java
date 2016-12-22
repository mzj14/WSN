/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'OscilloscopeMsg'
 * message type.
 */

public class OscilloscopeMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 22;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 147;

    /** Create a new OscilloscopeMsg of size 22. */
    public OscilloscopeMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new OscilloscopeMsg of the given data_length. */
    public OscilloscopeMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new OscilloscopeMsg with the given data_length
     * and base offset.
     */
    public OscilloscopeMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new OscilloscopeMsg using the given byte array
     * as backing store.
     */
    public OscilloscopeMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new OscilloscopeMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public OscilloscopeMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new OscilloscopeMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public OscilloscopeMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new OscilloscopeMsg embedded in the given message
     * at the given base offset.
     */
    public OscilloscopeMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new OscilloscopeMsg embedded in the given message
     * at the given base offset and length.
     */
    public OscilloscopeMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <OscilloscopeMsg> \n";
      try {
        s += "  [version=0x"+Long.toHexString(get_version())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [interval=0x"+Long.toHexString(get_interval())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [id=0x"+Long.toHexString(get_id())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [count=0x"+Long.toHexString(get_count())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [temperature=0x"+Long.toHexString(get_temperature())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [humidity=0x"+Long.toHexString(get_humidity())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [light=0x"+Long.toHexString(get_light())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [current_time=0x"+Long.toHexString(get_current_time())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [token=0x"+Long.toHexString(get_token())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: version
    //   Field type: int, unsigned
    //   Offset (bits): 0
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'version' is signed (false).
     */
    public static boolean isSigned_version() {
        return false;
    }

    /**
     * Return whether the field 'version' is an array (false).
     */
    public static boolean isArray_version() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'version'
     */
    public static int offset_version() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'version'
     */
    public static int offsetBits_version() {
        return 0;
    }

    /**
     * Return the value (as a int) of the field 'version'
     */
    public int get_version() {
        return (int)getUIntBEElement(offsetBits_version(), 16);
    }

    /**
     * Set the value of the field 'version'
     */
    public void set_version(int value) {
        setUIntBEElement(offsetBits_version(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'version'
     */
    public static int size_version() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'version'
     */
    public static int sizeBits_version() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: interval
    //   Field type: int, unsigned
    //   Offset (bits): 16
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'interval' is signed (false).
     */
    public static boolean isSigned_interval() {
        return false;
    }

    /**
     * Return whether the field 'interval' is an array (false).
     */
    public static boolean isArray_interval() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'interval'
     */
    public static int offset_interval() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'interval'
     */
    public static int offsetBits_interval() {
        return 16;
    }

    /**
     * Return the value (as a int) of the field 'interval'
     */
    public int get_interval() {
        return (int)getUIntBEElement(offsetBits_interval(), 16);
    }

    /**
     * Set the value of the field 'interval'
     */
    public void set_interval(int value) {
        setUIntBEElement(offsetBits_interval(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'interval'
     */
    public static int size_interval() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'interval'
     */
    public static int sizeBits_interval() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: id
    //   Field type: int, unsigned
    //   Offset (bits): 32
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'id' is signed (false).
     */
    public static boolean isSigned_id() {
        return false;
    }

    /**
     * Return whether the field 'id' is an array (false).
     */
    public static boolean isArray_id() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'id'
     */
    public static int offset_id() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'id'
     */
    public static int offsetBits_id() {
        return 32;
    }

    /**
     * Return the value (as a int) of the field 'id'
     */
    public int get_id() {
        return (int)getUIntBEElement(offsetBits_id(), 16);
    }

    /**
     * Set the value of the field 'id'
     */
    public void set_id(int value) {
        setUIntBEElement(offsetBits_id(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'id'
     */
    public static int size_id() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'id'
     */
    public static int sizeBits_id() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: count
    //   Field type: int, unsigned
    //   Offset (bits): 48
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'count' is signed (false).
     */
    public static boolean isSigned_count() {
        return false;
    }

    /**
     * Return whether the field 'count' is an array (false).
     */
    public static boolean isArray_count() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'count'
     */
    public static int offset_count() {
        return (48 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'count'
     */
    public static int offsetBits_count() {
        return 48;
    }

    /**
     * Return the value (as a int) of the field 'count'
     */
    public int get_count() {
        return (int)getUIntBEElement(offsetBits_count(), 16);
    }

    /**
     * Set the value of the field 'count'
     */
    public void set_count(int value) {
        setUIntBEElement(offsetBits_count(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'count'
     */
    public static int size_count() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'count'
     */
    public static int sizeBits_count() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: temperature
    //   Field type: int, unsigned
    //   Offset (bits): 64
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'temperature' is signed (false).
     */
    public static boolean isSigned_temperature() {
        return false;
    }

    /**
     * Return whether the field 'temperature' is an array (false).
     */
    public static boolean isArray_temperature() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'temperature'
     */
    public static int offset_temperature() {
        return (64 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'temperature'
     */
    public static int offsetBits_temperature() {
        return 64;
    }

    /**
     * Return the value (as a int) of the field 'temperature'
     */
    public int get_temperature() {
        return (int)getUIntBEElement(offsetBits_temperature(), 16);
    }

    /**
     * Set the value of the field 'temperature'
     */
    public void set_temperature(int value) {
        setUIntBEElement(offsetBits_temperature(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'temperature'
     */
    public static int size_temperature() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'temperature'
     */
    public static int sizeBits_temperature() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: humidity
    //   Field type: int, unsigned
    //   Offset (bits): 80
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'humidity' is signed (false).
     */
    public static boolean isSigned_humidity() {
        return false;
    }

    /**
     * Return whether the field 'humidity' is an array (false).
     */
    public static boolean isArray_humidity() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'humidity'
     */
    public static int offset_humidity() {
        return (80 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'humidity'
     */
    public static int offsetBits_humidity() {
        return 80;
    }

    /**
     * Return the value (as a int) of the field 'humidity'
     */
    public int get_humidity() {
        return (int)getUIntBEElement(offsetBits_humidity(), 16);
    }

    /**
     * Set the value of the field 'humidity'
     */
    public void set_humidity(int value) {
        setUIntBEElement(offsetBits_humidity(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'humidity'
     */
    public static int size_humidity() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'humidity'
     */
    public static int sizeBits_humidity() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: light
    //   Field type: int, unsigned
    //   Offset (bits): 96
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'light' is signed (false).
     */
    public static boolean isSigned_light() {
        return false;
    }

    /**
     * Return whether the field 'light' is an array (false).
     */
    public static boolean isArray_light() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'light'
     */
    public static int offset_light() {
        return (96 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'light'
     */
    public static int offsetBits_light() {
        return 96;
    }

    /**
     * Return the value (as a int) of the field 'light'
     */
    public int get_light() {
        return (int)getUIntBEElement(offsetBits_light(), 16);
    }

    /**
     * Set the value of the field 'light'
     */
    public void set_light(int value) {
        setUIntBEElement(offsetBits_light(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'light'
     */
    public static int size_light() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'light'
     */
    public static int sizeBits_light() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: current_time
    //   Field type: long, unsigned
    //   Offset (bits): 112
    //   Size (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'current_time' is signed (false).
     */
    public static boolean isSigned_current_time() {
        return false;
    }

    /**
     * Return whether the field 'current_time' is an array (false).
     */
    public static boolean isArray_current_time() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'current_time'
     */
    public static int offset_current_time() {
        return (112 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'current_time'
     */
    public static int offsetBits_current_time() {
        return 112;
    }

    /**
     * Return the value (as a long) of the field 'current_time'
     */
    public long get_current_time() {
        return (long)getUIntBEElement(offsetBits_current_time(), 32);
    }

    /**
     * Set the value of the field 'current_time'
     */
    public void set_current_time(long value) {
        setUIntBEElement(offsetBits_current_time(), 32, value);
    }

    /**
     * Return the size, in bytes, of the field 'current_time'
     */
    public static int size_current_time() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of the field 'current_time'
     */
    public static int sizeBits_current_time() {
        return 32;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: token
    //   Field type: long, unsigned
    //   Offset (bits): 144
    //   Size (bits): 32
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'token' is signed (false).
     */
    public static boolean isSigned_token() {
        return false;
    }

    /**
     * Return whether the field 'token' is an array (false).
     */
    public static boolean isArray_token() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'token'
     */
    public static int offset_token() {
        return (144 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'token'
     */
    public static int offsetBits_token() {
        return 144;
    }

    /**
     * Return the value (as a long) of the field 'token'
     */
    public long get_token() {
        return (long)getUIntBEElement(offsetBits_token(), 32);
    }

    /**
     * Set the value of the field 'token'
     */
    public void set_token(long value) {
        setUIntBEElement(offsetBits_token(), 32, value);
    }

    /**
     * Return the size, in bytes, of the field 'token'
     */
    public static int size_token() {
        return (32 / 8);
    }

    /**
     * Return the size, in bits, of the field 'token'
     */
    public static int sizeBits_token() {
        return 32;
    }

}