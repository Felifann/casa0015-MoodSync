import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class IndexDetailPage extends StatelessWidget {
  final String label;
  final double value;

  const IndexDetailPage({super.key, required this.label, required this.value});

  List<FlSpot> _generateTrendData(double baseValue) {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final hour = now.subtract(Duration(hours: 3 - index)).hour.toDouble();
      final value = (baseValue + Random().nextDouble() * 0.1 - 0.05).clamp(
        0.0,
        1.0,
      ); // Add small random fluctuation
      return FlSpot(hour, value);
    });
  }

  Future<Map<String, dynamic>> _fetchAirQualityData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('api_data')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (err) {
      print('Error fetching air quality data: $err');
    }
    return {};
  }

  Future<Map<String, dynamic>> _fetchWeatherData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('api_data')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (err) {
      print('Error fetching weather data: $err');
    }
    return {};
  }

  Future<Map<String, dynamic>> _fetchNoiseData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('sensor_data')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
    } catch (err) {
      print('Error fetching noise data: $err');
    }
    return {'Noise Level': 0.0}; // Default value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('$label Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  label,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                subtitle: LinearProgressIndicator(
                  value: value,
                  color:
                      value > 0.7
                          ? Colors.red
                          : value > 0.4
                          ? Colors.orange
                          : Colors.green,
                ),
                trailing: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 32),
            if (label == 'Air Quality' ||
                label == 'Weather' ||
                label == 'Noise') ...[
              FutureBuilder<Map<String, dynamic>>(
                future:
                    label == 'Air Quality'
                        ? _fetchAirQualityData()
                        : label == 'Weather'
                        ? _fetchWeatherData()
                        : _fetchNoiseData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text('Error fetching data.'));
                  }

                  final data = snapshot.data!;
                  if (label == 'Air Quality') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          height: 200,
                          color: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Air Quality Index: ${data['Air Quality'] ?? 'N/A'}',
                                ),
                                Text('PM2.5: ${data['PM2.5'] ?? 'N/A'} µg/m³'),
                                Text('PM10: ${data['PM10'] ?? 'N/A'} µg/m³'),
                                Text('CO: ${data['CO'] ?? 'N/A'} ppm'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Trend (Last 4 Hours):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _generateTrendData(
                                    data['Air Quality'] ?? 0.5,
                                  ), // Replace with updated method
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (label == 'Weather') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          height: 200,
                          color: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Temperature: ${data['Temperature'] ?? 'N/A'} °C',
                                ),
                                Text(
                                  'Humidity: ${data['Humidity'] ?? 'N/A'} %',
                                ),
                                Text('Rain: ${data['Rain'] ?? 'N/A'} mm'),
                                Text(
                                  'Cloudiness: ${data['Cloudiness'] ?? 'N/A'} %',
                                ),
                                Text(
                                  'Wind Speed: ${data['Wind Speed'] ?? 'N/A'} m/s',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Trend (Last 4 Hours):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _generateTrendData(
                                    data['Temperature'] ?? 0.5,
                                  ), // Replace with updated method
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (label == 'Noise') {
                    final noiseLevel =
                        (data['Noise Level'] ?? 0.0) *
                        100; // Convert to decibels
                    return Container(
                      margin: EdgeInsets.only(top: 16),
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Noise Level: ${noiseLevel.toStringAsFixed(1)} dB',
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
            Text(
              'Description (Placeholder):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Here we explain what this index measures, how it affects stress, and possible steps to manage it.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
