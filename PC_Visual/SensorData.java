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

	public int getPhysicalTemp() {
		// int SOT = this.temp & 16383;
		// return (-39.6 + 0.01 * SOT);
		return this.temperature;
	}

	public int getPhysicalHumid() {
		// int SORH = this.humid & 4095;
		// double temp = this.getPhysicalTemp();
		// double linear = -4 + 0.0405 * SORH - 2.8e-6 * SORH * SORH;
		// return ((temp - 25) * (0.01 + 0.00008 * SORH) + linear);
		return this.humidity;
	}

	public int getPhysicalLight() {
		// return (0.085 * this.light);
		return this.light;
	}
}
