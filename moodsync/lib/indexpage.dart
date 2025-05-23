import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class IndexDetailPage extends StatelessWidget {
  final String label;
  final double value;

  const IndexDetailPage({super.key, required this.label, required this.value});

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
    return {}; // Return empty map if no data is found
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
      body: Stack(
        children: [
          // Background image with reduced opacity
          Opacity(
            opacity: 0.2, // Adjust transparency
            child: Image.asset(
              'assets/background.jpg', // Replace with your image path
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300), // Animation duration
                    curve: Curves.easeInOut, // Smooth transition curve
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, // Remove gradient, set solid color
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Match card shape
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        label,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: AnimatedContainer(
                        duration: Duration(
                          milliseconds: 300,
                        ), // Animation duration
                        curve: Curves.easeInOut, // Smooth transition curve
                        child: LinearProgressIndicator(
                          value: value,
                          color:
                              value > 0.7
                                  ? Colors.red
                                  : value > 0.4
                                  ? Colors.orange
                                  : Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      trailing: Text(
                        '${(value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 18),
                      ),
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
                              width:
                                  double
                                      .infinity, // Make the text box fit the page width
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center, // Center-align text
                                  children: [
                                    Text(
                                      '🌍 Air Quality Index: ${data['Air Quality'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 20, // Increase font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign:
                                          TextAlign.center, // Center-align text
                                    ),
                                    Text(
                                      'PM2.5: ${data['PM2.5'] ?? 'N/A'} µg/m³',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'PM10: ${data['PM10'] ?? 'N/A'} µg/m³',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'CO: ${data['CO'] ?? 'N/A'} ppm',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
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
                                      sideTitles: SideTitles(
                                        showTitles:
                                            false, // Remove y-axis labels
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final hour =
                                              DateTime.now()
                                                  .subtract(
                                                    Duration(
                                                      hours: 3 - value.toInt(),
                                                    ),
                                                  )
                                                  .hour;
                                          return Text(
                                            '$hour:00', // Display hour labels (e.g., "14:00")
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                        interval:
                                            1, // Ensure titles align with data points
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        4,
                                        (index) => FlSpot(
                                          index.toDouble(),
                                          Random().nextDouble(),
                                        ),
                                      ),
                                      isCurved: true,
                                      color:
                                          Colors
                                              .purple
                                              .shade200, // Change to light purple
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
                              width:
                                  double
                                      .infinity, // Make the text box fit the page width
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center, // Center-align text
                                  children: [
                                    Text(
                                      '🌦️ Temperature: ${data['Temperature'] ?? 'N/A'} °C',
                                      style: TextStyle(
                                        fontSize: 20, // Increase font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign:
                                          TextAlign.center, // Center-align text
                                    ),
                                    Text(
                                      'Humidity: ${data['Humidity'] ?? 'N/A'} %',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Rain: ${data['Rain'] ?? 'N/A'} mm',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Cloudiness: ${data['Cloudiness'] ?? 'N/A'} %',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Wind Speed: ${data['Wind Speed'] ?? 'N/A'} m/s',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ), // Adjust font size
                                      textAlign: TextAlign.center,
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
                                      sideTitles: SideTitles(
                                        showTitles:
                                            false, // Remove y-axis labels
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final hour =
                                              DateTime.now()
                                                  .subtract(
                                                    Duration(
                                                      hours: 3 - value.toInt(),
                                                    ),
                                                  )
                                                  .hour;
                                          return Text(
                                            '$hour:00', // Display hour labels (e.g., "14:00")
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                        interval:
                                            1, // Ensure titles align with data points
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        4,
                                        (index) => FlSpot(
                                          index.toDouble(),
                                          Random().nextDouble(),
                                        ),
                                      ),
                                      isCurved: true,
                                      color:
                                          Colors
                                              .purple
                                              .shade200, // Change to light purple
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              width:
                                  double
                                      .infinity, // Make the text box fit the page width
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center, // Center-align text
                                  children: [
                                    Text(
                                      '🔊 Noise Level: ${noiseLevel.toStringAsFixed(1)} dB',
                                      style: TextStyle(
                                        fontSize: 20, // Increase font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign:
                                          TextAlign.center, // Center-align text
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
                                      sideTitles: SideTitles(
                                        showTitles:
                                            false, // Remove y-axis labels
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final hour =
                                              DateTime.now()
                                                  .subtract(
                                                    Duration(
                                                      hours: 3 - value.toInt(),
                                                    ),
                                                  )
                                                  .hour;
                                          return Text(
                                            '$hour:00', // Display hour labels (e.g., "14:00")
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                        interval:
                                            1, // Ensure titles align with data points
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(
                                        4,
                                        (index) => FlSpot(
                                          index.toDouble(),
                                          Random().nextDouble(),
                                        ),
                                      ),
                                      isCurved: true,
                                      color:
                                          Colors
                                              .purple
                                              .shade200, // Change to light purple
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
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
