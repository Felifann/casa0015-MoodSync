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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Animation controller for shaking
  late Animation<double> _animation; // Animation for rotation

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

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Define rotation animation
    _animation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse(); // Reverse animation
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    super.dispose();
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
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji Display with GestureDetector
                        GestureDetector(
                          onTap: () {
                            if (!_controller.isAnimating) {
                              _controller.forward(); // Start shaking animation
                              Future.delayed(
                                const Duration(milliseconds: 1100),
                                () {
                                  if (mounted) {
                                    setState(
                                      () {},
                                    ); // Reset to vertical after 1.1 seconds
                                  }
                                },
                              );
                            }
                          },
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle:
                                    _controller.isAnimating
                                        ? _animation.value
                                        : 0.0, // Reset to vertical
                                child: child,
                              );
                            },
                            child: Text(
                              getEmoji(stressIndex),
                              style: TextStyle(fontSize: 150),
                            ),
                          ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (visibility['airquality']!)
                                    Flexible(
                                      child: SizedBox(
                                        height: 150,
                                        child: IndexCard(
                                          label: 'Air Quality',
                                          value:
                                              preferences['Air Quality'] ?? 0.0,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) => IndexDetailPage(
                                                      label: 'Air Quality',
                                                      value:
                                                          preferences['Air Quality'] ??
                                                          0.0,
                                                    ),
                                                transitionsBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  const begin = Offset(
                                                    1.0,
                                                    0.0,
                                                  ); // Slide in from the right
                                                  const end = Offset.zero;
                                                  const curve =
                                                      Curves.easeInOut;

                                                  var tween = Tween(
                                                    begin: begin,
                                                    end: end,
                                                  ).chain(
                                                    CurveTween(curve: curve),
                                                  );
                                                  var offsetAnimation =
                                                      animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
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
                                              PageRouteBuilder(
                                                pageBuilder:
                                                    (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) => IndexDetailPage(
                                                      label: 'Weather',
                                                      value:
                                                          preferences['Weather'] ??
                                                          0.0,
                                                    ),
                                                transitionsBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  const begin = Offset(
                                                    1.0,
                                                    0.0,
                                                  ); // Slide in from the right
                                                  const end = Offset.zero;
                                                  const curve =
                                                      Curves.easeInOut;

                                                  var tween = Tween(
                                                    begin: begin,
                                                    end: end,
                                                  ).chain(
                                                    CurveTween(curve: curve),
                                                  );
                                                  var offsetAnimation =
                                                      animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (visibility['noise']!)
                                    Flexible(
                                      child: SizedBox(
                                        height: 150,
                                        child: IndexCard(
                                          label: 'Noise',
                                          value:
                                              preferences['Noise Level'] ?? 0.0,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => IndexDetailPage(
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
                                              preferences['Light Exposure'] ??
                                              0.0,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      context,
                                                    ) => IndexDetailPage(
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
                                                    (
                                                      context,
                                                    ) => IndexDetailPage(
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

  String getEmoji(String label) {
    switch (label) {
      case 'Air Quality':
        return '🌍';
      case 'Weather':
        return '🌦️';
      case 'Noise':
        return '🔊';
      case 'Light':
        return '💡';
      case 'Motion':
        return '🚶';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Text(
              getEmoji(label),
              style: TextStyle(fontSize: 50), // Increase emoji size
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ), // Increase font size
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                SizedBox(width: 12), // Add spacing between elements
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 16), // Increase font size
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
