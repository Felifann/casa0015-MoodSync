import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_sensors/flutter_sensors.dart'; // Updated import for flutter_sensors
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // Import Geolocator package

const MethodChannel _microphoneChannel = MethodChannel('microphone_data');

Future<void> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();
  if (status.isGranted) {
    print("麦克风权限已授予");
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

Future<Position> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return Future.error('Location services are disabled.');
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permissions are denied.');
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied.');
    return Future.error('Location permissions are permanently denied.');
  }

  // Get the current position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

Future<Map<String, double>> _fetchOpenWeatherData() async {
  const apiKey =
      'ac70491a2a4f4bb34d6f977f9f777767'; // Replace with your OpenWeather API key

  try {
    final position = await _getCurrentLocation(); // Shared location function
    final latitude = position.latitude;
    final longitude = position.longitude;

    final url1 =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url1));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return {
        'Temperature': ((data['main']['temp'] ?? 0) as num).toDouble(),
        'Humidity': ((data['main']['humidity'] ?? 0) as num).toDouble(),
        'Rain':
            ((data['rain']?['1h'] ?? 0) as num).toDouble(), // Rain in last hour
        'Cloudiness':
            ((data['clouds']?['all'] ?? 0) as num).toDouble(), // Cloud cover
        'Wind Speed':
            ((data['wind']?['speed'] ?? 0) as num).toDouble(), // Wind speed
      };
    } else {
      print('Error fetching OpenWeather data: ${response.statusCode}');
    }
  } catch (err) {
    print('Error fetching OpenWeather data: $err');
  }
  return {
    'Temperature': 0.0,
    'Humidity': 0.0,
    'Rain': 0.0,
    'Cloudiness': 0.0,
    'Wind Speed': 0.0,
  }; // Default values
}

Future<Map<String, double>> _fetchOpenWeatherData2() async {
  const apiKey =
      'ac70491a2a4f4bb34d6f977f9f777767'; // Replace with your OpenWeather API key
  try {
    final position = await _getCurrentLocation(); // Shared location function
    final latitude = position.latitude;
    final longitude = position.longitude;

    final url2 =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    final response2 = await http.get(Uri.parse(url2));
    if (response2.statusCode == 200) {
      final data2 = json.decode(response2.body);
      return {
        'Air Quality':
            ((data2['list'][0]['main']['aqi'] ?? 0) as num).toDouble(),
        'PM2.5':
            ((data2['list'][0]['components']['pm2_5'] ?? 0) as num).toDouble(),
        'PM10':
            ((data2['list'][0]['components']['pm10'] ?? 0) as num).toDouble(),
        'CO': ((data2['list'][0]['components']['co'] ?? 0) as num).toDouble(),
      };
    } else {
      print('Error fetching OpenWeather data: ${response2.statusCode}');
    }
  } catch (err) {
    print('Error fetching OpenWeather data: $err');
  }
  return {
    'Air Quality': 0.0,
    'PM2.5': 0.0,
    'PM10': 0.0,
    'CO': 0.0,
  }; // Default values
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(); // Initialize Firebase
}

Stream<Map<String, double>> getSensorData() async* {
  await initializeFirebase(); // Ensure Firebase is initialized
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
    final openWeatherData1 = await _fetchOpenWeatherData();
    final openWeatherData2 = await _fetchOpenWeatherData2();

    final sensorData = {
      'Noise Level': noiseLevel,
      'Light Exposure': lightExposure,
      'Physical Activity': physicalActivity,
    };
    final apiData = {
      'Air Quality': openWeatherData2['Air Quality']!,
      'PM2.5': openWeatherData2['PM2.5']!, // New pollutant
      'PM10': openWeatherData2['PM10']!, // New pollutant
      'CO': openWeatherData2['CO']!, // New pollutant
      'Temperature': openWeatherData1['Temperature']!,
      'Humidity': openWeatherData1['Humidity']!,
      'Rain': openWeatherData1['Rain']!,
      'Cloudiness': openWeatherData1['Cloudiness']!,
      'Wind Speed': openWeatherData1['Wind Speed']!,
    };

    double weatherLevel = calculateWeatherBadness(
      temperature: openWeatherData1['Temperature']!,
      humidity: openWeatherData1['Humidity']!,
      rain: openWeatherData1['Rain']!,
      cloudiness: openWeatherData1['Cloudiness']!,
      windSpeed: openWeatherData1['Wind Speed']!,
    );
    double airQuality = openWeatherData2['Air Quality']! / 5;

    final mainpageData = {
      'Noise Level': noiseLevel,
      'Light Exposure': lightExposure,
      'Physical Activity': physicalActivity,
      'Air Quality': airQuality,
      'Weather': weatherLevel,
    };

    // Calculate stress index
    final stressIndex = calculateStressIndex(
      noiseLevel: noiseLevel,
      lightExposure: lightExposure,
      physicalActivity: physicalActivity,
      airQuality: airQuality,
      weatherLevel: weatherLevel,
    );

    // Upload data to Firebase
    try {
      // Upload sensorData to 'sensor_data' collection
      await FirebaseFirestore.instance.collection('sensor_data').add({
        'timestamp': FieldValue.serverTimestamp(),
        ...sensorData,
      });

      // Upload apiData to 'api_data' collection
      await FirebaseFirestore.instance.collection('api_data').add({
        'timestamp': FieldValue.serverTimestamp(),
        ...apiData,
      });

      // Upload stressIndex and related data to 'index' collection
      await FirebaseFirestore.instance.collection('index').add({
        'timestamp': FieldValue.serverTimestamp(),
        'Stress Index': stressIndex,
        'Noise Level': noiseLevel,
        'Light Exposure': lightExposure,
        'Physical Activity': physicalActivity,
        'Air Quality': airQuality,
        'Weather': weatherLevel,
      });
    } catch (err) {
      print('Error uploading data to Firebase: $err');
    }

    yield {
      ...mainpageData,
      'Stress Index': stressIndex, // Include stress index in the stream
    };
  }

  await controller.close();
}

double calculateWeatherBadness({
  required double temperature,
  required double humidity,
  required double rain,
  required double cloudiness,
  required double windSpeed,
}) {
  // 温度糟糕度
  double tempBad = ((temperature - 20).abs() / 20).clamp(0, 1); // 离20°C越远越糟糕

  // 湿度糟糕度
  double humidityBad = ((humidity - 50).abs() / 50).clamp(0, 1); // 离50%越远越糟糕

  // 降雨糟糕度
  double rainBad = (rain / 10).clamp(0, 1); // 10mm以上很糟糕

  // 云量糟糕度
  double cloudBad = ((cloudiness - 25).abs() / 50).clamp(0, 1); // 25%左右最舒服

  // 风速糟糕度
  double windBad = (windSpeed / 10).clamp(0, 1); // 10m/s以上很糟糕

  // 权重分配（根据你的需求可以自己调）
  double badness =
      (tempBad * 0.3) +
      (humidityBad * 0.2) +
      (rainBad * 0.2) +
      (cloudBad * 0.1) +
      (windBad * 0.2);

  // 最后输出一个 0~1 的 badness 值
  return badness.clamp(0, 1);
}

double calculateStressIndex({
  required double noiseLevel,
  required double lightExposure,
  required double physicalActivity,
  required double airQuality,
  required double weatherLevel,
}) {
  double noiseStress = noiseLevel.clamp(0, 1);

  double lightStress = (2 * (lightExposure - 0.5).abs()).clamp(0, 1);

  double activityStress;
  if (physicalActivity <= 0.3) {
    activityStress = 0.0;
  } else if (physicalActivity <= 0.7) {
    activityStress = (physicalActivity - 0.3) / 0.4;
  } else {
    activityStress = 1.0;
  }

  double airStress = airQuality.clamp(0, 1);

  double weatherStress = weatherLevel.clamp(0, 1);

  double stressIndex =
      (noiseStress * 0.25) +
      (lightStress * 0.15) +
      (activityStress * 0.15) +
      (airStress * 0.25) +
      (weatherStress * 0.20);

  return stressIndex.clamp(0, 1);
}
