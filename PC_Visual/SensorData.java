public class SensorData {

	public int temperature;
	public int humidity;
	public int light;
	public long current_time;

	public SensorData(int temperature, int humidity, int light, long current_time) {
		this.temperature = temperature;
		this.humidity = humidity;
		this.light = light;
		this.current_time = current_time;
	}

  // transfer to Celcius * 10
	public double getPhysicalTemp() {
		int SOT = this.temperature & 16383;
	  return (-39.6 + 0.01 * SOT) * 10;
	}

  // transfer to Relatively Humidity * 10
	public double getPhysicalHumid() {
		int SORH = this.humidity & 4095;
		double temp = this.getPhysicalTemp();
		double linear = -4 + 0.0405 * SORH - 2.8e-6 * SORH * SORH;
		return linear * 10;
	}

  // putout raw value
	public double getPhysicalLight() {
		return this.light;
	}
}
