import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart'; // Added import for calendar
import 'dart:math';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<double> stressIndex = List.generate(
    24,
    (index) => 0.3 + 0.7 * Random().nextDouble(),
  );
  final Map<String, List<double>> indexData = {
    'Noise Level': List.generate(24, (i) => 0.2 + 0.8 * Random().nextDouble()),
    'Air Quality': List.generate(24, (i) => 0.3 + 0.6 * Random().nextDouble()),
    'Temperature': List.generate(24, (i) => 0.4 + 0.5 * Random().nextDouble()),
    'Humidity': List.generate(24, (i) => 0.3 + 0.7 * Random().nextDouble()),
    'Light Exposure': List.generate(
      24,
      (i) => 0.1 + 0.9 * Random().nextDouble(),
    ),
    'Locational Density': List.generate(
      24,
      (i) => 0.2 + 0.8 * Random().nextDouble(),
    ),
  };

  DateTime _selectedDate = DateTime.now(); // Selected date state
  DateTime _focusedDate = DateTime.now(); // Add a focused date state
  final bool _isOverallExpanded =
      true; // Default expanded state for Overall Stress Index

  List<double> _getCurrentHourData(List<double> data) {
    int currentHour = DateTime.now().hour + 1; // Include the current hour
    return data.sublist(0, currentHour);
  }

  final Map<DateTime, Map<String, dynamic>> _dailyAssessments =
      {}; // Store assessments

  final List<String> _emojis = ['😄', '🙂', '😐', '😟']; // Emoji options
  String? _selectedMood; // Selected mood emoji
  String? _selectedStress; // Selected stress emoji
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stress History')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TableCalendar(
            firstDay: DateTime(2023, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _focusedDate, // Use _focusedDate here
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDate = focusedDay; // Update _focusedDate as well
              });
              // Load assessment for the selected day
              final assessment = _dailyAssessments[_selectedDate];
              if (assessment != null) {
                _selectedMood = assessment['mood'];
                _selectedStress = assessment['stress'];
                _descriptionController.text = assessment['description'] ?? '';
              } else {
                _selectedMood = null;
                _selectedStress = null;
                _descriptionController.clear();
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDate =
                    focusedDay; // Update _focusedDate when the page changes
              });
            },
            calendarFormat: CalendarFormat.week, // Show only the current week
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 16),
          if (!_dailyAssessments.containsKey(_selectedDate)) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showAssessmentModal(isEdit: false),
                child: Text('Edit', style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
          ],
          if (_dailyAssessments.containsKey(_selectedDate)) ...[
            SizedBox(height: 16),
            Text(
              'Assessment for ${_selectedDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Mood: ${_dailyAssessments[_selectedDate]!['mood']}'),
            Text('Stress: ${_dailyAssessments[_selectedDate]!['stress']}'),
            if (_dailyAssessments[_selectedDate]!['description'] != null &&
                _dailyAssessments[_selectedDate]!['description']!.isNotEmpty)
              Text(
                'Description: ${_dailyAssessments[_selectedDate]!['description']}',
              ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showAssessmentModal(isEdit: true),
                child: Text('Edit', style: TextStyle(color: Colors.deepPurple)),
              ),
            ),
          ],
          SizedBox(height: 16),
          Text(
            '24h Stress History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          ExpansionTile(
            title: Text(
              'Overall Stress Index',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            initiallyExpanded: _isOverallExpanded, // Set default expanded state
            children: [
              SizedBox(
                height: 200,
                child: LineChart(
                  _buildLineChartData(_getCurrentHourData(stressIndex)),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Show Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            children:
                indexData.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: LineChart(
                          _buildLineChartData(_getCurrentHourData(entry.value)),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(List<double> data) {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(show: true),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots:
              data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
          isCurved: true,
          barWidth: 3,
          color: Colors.deepPurple,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.deepPurple.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  void _showAssessmentModal({required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'Edit Assessment' : 'Create Assessment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('How do you feel?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _emojis.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = emoji;
                          });
                        },
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: 32,
                            color:
                                _selectedMood == emoji
                                    ? Colors.deepPurple
                                    : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              Text('How stressed are you?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _emojis.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStress = emoji;
                          });
                        },
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: 32,
                            color:
                                _selectedStress == emoji
                                    ? Colors.deepPurple
                                    : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Optional description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_selectedMood != null && _selectedStress != null) {
                    setState(() {
                      _dailyAssessments[_selectedDate] = {
                        'mood': _selectedMood,
                        'stress': _selectedStress,
                        'description': _descriptionController.text,
                      };
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? 'Assessment updated!'
                              : 'Assessment created!',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select mood and stress levels.'),
                      ),
                    );
                  }
                },
                child: Text(isEdit ? 'Save Changes' : 'Save Assessment'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
