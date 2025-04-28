import 'dart:async';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_sensors/flutter_sensors.dart'; // Updated import for flutter_sensors

const MethodChannel _microphoneChannel = MethodChannel('microphone_data');

Future<void> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();
  if (status.isGranted) {
    print("麦克风权限已授予");
  } else {
    print("麦克风权限被拒绝");
  }
}

Future<double> _fetchNoiseLevel() async {
  try {
    final noiseResult = await _microphoneChannel.invokeMethod('getNoiseLevel');
    if (noiseResult != null) {
      final actualDB = (noiseResult + 160) * 0.625 - 20;
      return actualDB.toDouble().clamp(0, 100) / 100; // Normalize to 0-1
    }
  } catch (err) {
    print('Error fetching noise level: $err');
  }
  return 0.0; // Default value if an error occurs
}

Future<double> _fetchLightExposure() async {
  try {
    final brightness = await ScreenBrightness.current;
    return brightness.clamp(0, 1); // Normalize to 0-1
  } catch (err) {
    print('Error fetching light exposure: $err');
  }
  return 0.0; // Default value if an error occurs
}

Future<double> _fetchPhysicalActivity() async {
  try {
    if (await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER)) {
      final sensorStream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: Sensors.SENSOR_DELAY_NORMAL,
      );
      final event = await sensorStream.first;
      final accelerometerValues = event.data;
      final normalizedValue =
          (accelerometerValues[0].abs() +
                  accelerometerValues[1].abs() +
                  accelerometerValues[2].abs())
              .clamp(0, 10) /
          10; // Normalize to 0-1
      final adjustedValue = (normalizedValue - 0.1).abs();
      return double.parse(
        adjustedValue.toStringAsFixed(1),
      ); // Round to 1 decimal
    }
  } catch (err) {
    print('Error fetching physical activity: $err');
  }
  return 0.0; // Default value if an error occurs
}

Stream<Map<String, double>> getSensorData() async* {
  await requestMicrophonePermission(); // Request microphone permission

  bool isRunning = true;
  StreamController<void> controller = StreamController<void>();
  controller.stream.listen((_) {
    isRunning = false;
  });

  while (isRunning) {
    await Future.delayed(
      Duration(seconds: 1),
    ); // Simulate data generation delay

    final noiseLevel = await _fetchNoiseLevel();
    final lightExposure = await _fetchLightExposure();
    final physicalActivity = await _fetchPhysicalActivity();

    print(
      'Noise Level: $noiseLevel, Light Exposure: $lightExposure, Physical Activity: $physicalActivity',
    );

    yield {
      'Noise Level': noiseLevel,
      'Air Quality': Random().nextDouble(),
      'Temperature': Random().nextDouble(),
      'Humidity': Random().nextDouble(),
      'Light Exposure': lightExposure,
      'Physical Activity': physicalActivity,
    };
  }

  await controller.close();
}
