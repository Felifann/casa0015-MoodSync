import 'dart:io'; // Add this import for platform checks
import 'package:permission_handler/permission_handler.dart'; // Add this package for permissions
import 'package:flutter/material.dart';
import 'indexpreference.dart';
import 'indexpage.dart';
import 'History.dart';
import 'Me.dart';
import 'data_generator.dart'; // Re-enable the utility file import
import 'splash_screen.dart'; // Re-enable the splash screen import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized

  if (Platform.isIOS) {
    // Request microphone permission on iOS
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      print("麦克风权限已授予");
    } else if (status.isDenied) {
      print("麦克风权限被拒绝，请再次尝试请求权限。");
    } else if (status.isPermanentlyDenied) {
      print("麦克风权限被永久拒绝，请在设置中启用权限。");
      openAppSettings(); // Redirect user to app settings
    }
  }

  runApp(const MoodSyncApp());
}

class MoodSyncApp extends StatelessWidget {
  const MoodSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track the selected tab
  double stressIndex = 0.5; // Example stress index
  Map<String, double> preferences = {
    'Noise Level': 0.0,
    'Air Quality': 0.0,
    'Temperature': 0.0,
    'Humidity': 0.0,
    'Light Exposure': 0.0,
    'Locational Density': 0.0,
    'Sleep Quality': 0.0,
    'Physical Activity': 0.0,
  };
  Map<String, bool> visibility = {
    'Noise Level': true,
    'Air Quality': true,
    'Temperature': true,
    'Humidity': true,
    'Light Exposure': true,
    'Locational Density': true,
    'Motion Activity': true,
    'Sleep Quality': true,
    'Physical Activity': true,
  };

  @override
  void initState() {
    super.initState();
    // Subscribe to sensor data
    getSensorData().listen((sensorData) {
      setState(() {
        preferences.addAll(sensorData);
      });
    });
  }

  String getEmoji(double index) {
    if (index < 0.3) return '😄';
    if (index < 0.6) return '😊';
    if (index < 0.8) return '😐';
    return '😠';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('MoodSync'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Preference') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => IndexPreferencePage(
                          visibilityPrefs: visibility,
                          onSave: (updatedVisibility) {
                            setState(() {
                              visibility = updatedVisibility;
                            });
                          },
                        ),
                  ),
                );
              } else if (value == 'Settings') {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //   builder: (context) => SettingsPage(),
                //   ),
                // );
              } else if (value == 'Help') {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //   builder: (context) => HelpPage(),
                //   ),
                // );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Preference', child: Text('Preference')),
                PopupMenuItem(value: 'Settings', child: Text('Settings')),
                PopupMenuItem(value: 'Help', child: Text('Help')),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji Display
                    Text(
                      getEmoji(stressIndex),
                      style: TextStyle(fontSize: 150),
                    ),
                    Text(
                      'Stress Index:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(stressIndex * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            stressIndex > 0.7
                                ? Colors.red
                                : stressIndex > 0.4
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Stress Index Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: LinearProgressIndicator(
                        value: stressIndex,
                        color:
                            stressIndex > 0.7
                                ? Colors.red
                                : stressIndex > 0.4
                                ? Colors.orange
                                : Colors.green,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Add statement for abnormal values with improved styling
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Text(
                        _getAbnormalityStatement(),
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Directly display the list
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          // Environment Section
                          Text(
                            'Environment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              if (visibility['Noise Level']!)
                                IndexCard(
                                  label: 'Noise Level',
                                  value:
                                      preferences['Noise Level'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Noise Level',
                                              value:
                                                  preferences['Noise Level'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              if (visibility['Air Quality']!)
                                IndexCard(
                                  label: 'Air Quality',
                                  value:
                                      preferences['Air Quality'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Air Quality',
                                              value:
                                                  preferences['Air Quality'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              if (visibility['Temperature']!)
                                IndexCard(
                                  label: 'Temperature',
                                  value:
                                      preferences['Temperature'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Temperature',
                                              value:
                                                  preferences['Temperature'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              if (visibility['Humidity']!)
                                IndexCard(
                                  label: 'Humidity',
                                  value:
                                      preferences['Humidity'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Humidity',
                                              value:
                                                  preferences['Humidity'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              if (visibility['Light Exposure']!)
                                IndexCard(
                                  label: 'Light Exposure',
                                  value:
                                      preferences['Light Exposure'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Light Exposure',
                                              value:
                                                  preferences['Light Exposure'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              if (visibility['Locational Density']!)
                                IndexCard(
                                  label: 'Locational Density',
                                  value:
                                      preferences['Locational Density'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Locational Density',
                                              value:
                                                  preferences['Locational Density'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),

                          // Personal Section
                          SizedBox(height: 16),
                          Text(
                            'Personal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              // if (visibility['Motion Activity']!)
                              //   IndexCard(
                              //     label: 'Motion Activity',
                              //     value: preferences['Motion Activity']!,
                              //     onTap: () {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder:
                              //               (context) => IndexDetailPage(
                              //                 label: 'Motion Activity',
                              //                 value:
                              //                     preferences['Motion Activity']!,
                              //               ),
                              //         ),
                              //       );
                              //     },
                              //   ),
                              if (visibility['Sleep Quality']!)
                                IndexCard(
                                  label: 'Sleep Quality',
                                  value:
                                      preferences['Sleep Quality'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Sleep Quality',
                                              value:
                                                  preferences['Sleep Quality'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              if (visibility['Physical Activity']!)
                                IndexCard(
                                  label: 'Physical Activity',
                                  value:
                                      preferences['Physical Activity'] ??
                                      0.0, // Ensure null safety
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => IndexDetailPage(
                                              label: 'Physical Activity',
                                              value:
                                                  preferences['Physical Activity'] ??
                                                  0.0, // Ensure null safety
                                            ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                HistoryPage(),
                MePage(
                  visibility: visibility,
                  onSave: (updatedVisibility) {
                    setState(() {
                      visibility = updatedVisibility;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  String _getAbnormalityStatement() {
    final buffer = StringBuffer();
    preferences.forEach((key, value) {
      if (value > 0.7) {
        buffer.writeln('$key is high. Consider reducing exposure.');
      }
    });
    return buffer.isEmpty
        ? 'All indicators are within normal ranges.'
        : buffer.toString().trim();
  }
}

class IndexCard extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onTap;

  const IndexCard({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(label),
              subtitle: LinearProgressIndicator(
                value: value,
                color:
                    value > 0.7
                        ? Colors.red
                        : value > 0.4
                        ? Colors.orange
                        : Colors.green,
              ),
              trailing: Text('${(value * 100).toStringAsFixed(0)}%'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'High',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
