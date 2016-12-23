configuration SenseAppC {
}

implementation {
  components MainC, SenseC, LedsC;
  components ActiveMessageC as Radio;
  components new TimerMilliC() as Timer;
  components new HamamatsuS1087ParC() as LightSensor;
  components new SensirionSht11C() as TmpHumSensor;
  components new AMSenderC(AM_OSCILLOSCOPE), new AMReceiverC(AM_OSCILLOSCOPE);

  MainC.Boot <- SenseC;

  SenseC.RadioControl -> Radio;

  // SenseC.RadioSend -> Radio;
  SenseC.RadioSend -> AMSenderC;
  SenseC.RadioReceive -> AMReceiverC;
  SenseC.RadioSnoop -> Radio.Snoop;
  SenseC.RadioPacket -> Radio;
  SenseC.RadioAMPacket -> Radio;

  SenseC.Leds -> LedsC;
  SenseC.Timer -> Timer;
  SenseC.ReadLight -> LightSensor.Read;
  SenseC.ReadTemperature->TmpHumSensor.Temperature;
  SenseC.ReadHumidity -> TmpHumSensor.Humidity;
}
