configuration OscilloscopeAppC { }
implementation
{
  components OscilloscopeC, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(), new AMSenderC(AM_OSCILLOSCOPE), new AMReceiverC(AM_OSCILLOSCOPE);
  components new HamamatsuS1087ParC() as LightSensor;
  components new SensirionSht11C() as TmpHumSensor;
  components PrintfC;
  components SerialStartC;

  OscilloscopeC.Boot -> MainC;
  OscilloscopeC.RadioControl -> ActiveMessageC;
  OscilloscopeC.AMSend -> AMSenderC;
  OscilloscopeC.Receive -> AMReceiverC;
  OscilloscopeC.Timer -> TimerMilliC;
  OscilloscopeC.ReadLight -> LightSensor.Read;
  OscilloscopeC.ReadTemperature->TmpHumSensor.Temperature;
  OscilloscopeC.ReadHumidity -> TmpHumSensor.Humidity;
  OscilloscopeC.Leds -> LedsC;
}
