import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
import 'package:flutter/material.dart';
import 'indexpreference.dart';
import 'indexpage.dart';
import 'History.dart';
import 'Me.dart';
import 'data_generator.dart'; // Re-enable the utility file import
import 'splash_screen.dart'; // Re-enable the splash screen import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase

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
  double stressIndex = 0.5; // Initialize stress index
  Map<String, double> preferences = {
    'Noise Level': 0.0,
    'Air Quality': 0.0,
    'Weather': 0.0,
    'Light Exposure': 0.0,
    'Physical Activity': 0.0,
  };
  Map<String, bool> visibility = {
    'noise': true,
    'light': true,
    'motion': true,
    'airquality': true,
    'weather': true,
  };

  @override
  void initState() {
    super.initState();
    // Subscribe to sensor data
    getSensorData().listen((mainpageData) {
      setState(() {
        preferences.addAll(mainpageData);
        stressIndex = calculateStressIndex(
          noiseLevel: mainpageData['Noise Level'] ?? 0.0,
          lightExposure: mainpageData['Light Exposure'] ?? 0.0,
          physicalActivity: mainpageData['Physical Activity'] ?? 0.0,
          airQuality: mainpageData['Air Quality'] ?? 0.0,
          weatherLevel: mainpageData['Weather'] ?? 0.0,
        ); // Update stress index
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (visibility['airquality']!)
                                Flexible(
                                  child: SizedBox(
                                    height: 150,
                                    child: IndexCard(
                                      label: 'Air Quality',
                                      value: preferences['Air Quality'] ?? 0.0,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => IndexDetailPage(
                                                  label: 'Air Quality',
                                                  value:
                                                      preferences['Air Quality'] ??
                                                      0.0,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (visibility['weather']!)
                                Flexible(
                                  child: SizedBox(
                                    height: 150,
                                    child: IndexCard(
                                      label: 'Weather',
                                      value: preferences['Weather'] ?? 0.0,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => IndexDetailPage(
                                                  label: 'Weather',
                                                  value:
                                                      ((preferences['Temperature'] ??
                                                              0.0) +
                                                          (preferences['Humidity'] ??
                                                              0.0)) /
                                                      2,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (visibility['noise']!)
                                Flexible(
                                  child: SizedBox(
                                    height: 150,
                                    child: IndexCard(
                                      label: 'Noise',
                                      value: preferences['Noise Level'] ?? 0.0,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => IndexDetailPage(
                                                  label: 'Noise',
                                                  value:
                                                      preferences['Noise Level'] ??
                                                      0.0,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (visibility['light']!)
                                Flexible(
                                  child: SizedBox(
                                    height: 150,
                                    child: IndexCard(
                                      label: 'Light',
                                      value:
                                          preferences['Light Exposure'] ?? 0.0,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => IndexDetailPage(
                                                  label: 'Light',
                                                  value:
                                                      preferences['Light Exposure'] ??
                                                      0.0,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              if (visibility['motion']!)
                                Flexible(
                                  child: SizedBox(
                                    height: 150,
                                    child: IndexCard(
                                      label: 'Motion',
                                      value:
                                          preferences['Physical Activity'] ??
                                          0.0,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => IndexDetailPage(
                                                  label: 'Motion',
                                                  value:
                                                      preferences['Physical Activity'] ??
                                                      0.0,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
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
          mainAxisAlignment:
              MainAxisAlignment.start, // Align content to the top
          children: [
            // Title at the very top
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(), // Push content to the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Color dot to the left of the percentage
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        value > 0.7
                            ? Colors.red
                            : value > 0.4
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8), // Add spacing at the bottom
          ],
        ),
      ),
    );
  }
}
