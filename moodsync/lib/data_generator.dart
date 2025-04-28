import 'dart:async';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

const MethodChannel _microphoneChannel = MethodChannel('microphone_data');

Future<void> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();
  if (status.isGranted) {
    print("麦克风权限已授予");
  } else {
    print("麦克风权限被拒绝");
  }
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

    double noiseLevel = 0.0;
    double lightExposure = 0.0;
    try {
      // Fetch noise level from microphone channel
      final noiseResult = await _microphoneChannel.invokeMethod(
        'getNoiseLevel',
      );
      final actualDB = (noiseResult + 160) * 0.625 - 20;
      if (noiseResult != null) {
        noiseLevel = actualDB.toDouble();
        noiseLevel = noiseLevel.clamp(0, 100) / 100; // Normalize to 0-1
        print('Noise Level: $noiseLevel');
      }

      // Fetch screen brightness as an indirect measure of light exposure
      lightExposure = await ScreenBrightness.current;
      lightExposure = lightExposure.clamp(0, 1); // Normalize to 0-1
      print('Light Exposure: $lightExposure');
    } catch (err) {
      print('Error capturing sensor data: $err');
    }

    yield {
      'Noise Level': noiseLevel,
      'Air Quality': Random().nextDouble(),
      'Temperature': Random().nextDouble(),
      'Humidity': Random().nextDouble(),
      'Light Exposure': lightExposure,
      'Locational Density': Random().nextDouble(),
      'Sleep Quality': Random().nextDouble(),
      'Physical Activity': Random().nextDouble(),
    };
  }

  await controller.close();
}
