import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class IndexDetailPage extends StatelessWidget {
  final String label;
  final double value;

  const IndexDetailPage({super.key, required this.label, required this.value});

  List<FlSpot> _generateRandomTrendData() {
    final random = Random();
    return List.generate(
      24,
      (index) => FlSpot(index.toDouble(), random.nextDouble()),
    );
  }

  bool _isEnvironmentIndex(String label) {
    const environmentIndices = [
      'Noise Level',
      'Air Quality',
      'Temperature',
      'Humidity',
      'Light Exposure',
      'Locational Density',
    ];
    return environmentIndices.contains(label);
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
            Text(
              'Data Source (Placeholder):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              height: 200,
              color: Colors.grey.shade200,
              child: Center(child: Text('Data Source Placeholder')),
            ),
            if (_isEnvironmentIndex(label)) ...[
              SizedBox(height: 32),
              Text(
                'Trend (Past 24 Hours):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                        spots: _generateRandomTrendData(),
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
              SizedBox(height: 32),
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
