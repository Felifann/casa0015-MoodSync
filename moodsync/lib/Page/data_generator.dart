import 'dart:async';
import 'package:noise_meter/noise_meter.dart';

Stream<Map<String, double>> getSensorData() async* {
  NoiseMeter noiseMeter = NoiseMeter();
  NoiseReading? latestNoiseReading;
  StreamSubscription<NoiseReading>? noiseSubscription;

  try {
    // 启动噪声检测
    noiseSubscription = noiseMeter.noiseStream.listen(
      (NoiseReading noiseReading) {
        latestNoiseReading = noiseReading; // 保存最新的噪声数据
      },
      onError: (error) {
        print('Error in noiseStream: $error');
      },
      cancelOnError: true,
    );

    while (true) {
      await Future.delayed(Duration(minutes: 1)); // Update interval to 1 second

      // 获取当前噪声级别
      final noiseLevel = latestNoiseReading?.meanDecibel ?? 0.0;
      print(noiseLevel);

      // 通常人耳痛觉阈值是 120 dB，正常谈话是 60 dB左右，所以我们可以归一化处理：
      final normalizedNoiseLevel = (noiseLevel / 120.0).clamp(0.0, 1.0);

      final sensorData = {
        'Noise Level': normalizedNoiseLevel, // Normalize to 0-1 range
        'Air Quality': 0.5, // Placeholder data
        'Temperature': 0.5, // Placeholder data
        'Humidity': 0.5, // Placeholder data
        'Light Exposure': 0.5, // Placeholder data
        'Locational Density': 0.5, // Placeholder data
        'Sleep Quality': 0.5, // Placeholder data
        'Physical Activity': 0.5, // Placeholder data
      };

      // Log sensor data for monitoring
      print('Sensor Data: $normalizedNoiseLevel');

      yield sensorData;
    }
  } catch (e) {
    print('Error in getSensorData: $e');
  } finally {
    noiseSubscription?.cancel();
  }
}
