import 'package:flutter/material.dart';
import 'indexpreference.dart';

class MePage extends StatelessWidget {
  final Map<String, bool> visibility;
  final Function(Map<String, bool>) onSave;

  const MePage({required this.visibility, required this.onSave, super.key});

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ListView(
            padding: EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 70, // Increased radius
                backgroundImage: AssetImage('assets/images/Avatar.png'),
                backgroundColor:
                    Colors.grey.shade200, // Optional: Add a background color
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Avatar.png',
                    fit:
                        BoxFit
                            .cover, // Ensure the image fits the circular frame
                    width: 140, // Adjust width to match the increased radius
                    height: 140, // Adjust height to match the increased radius
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Hello, User 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
              _buildCard(
                icon: Icons.insights,
                iconColor: Colors.deepPurple,
                title: 'Average Stress Level',
                subtitle: 'Medium (45%)',
              ),
              SizedBox(height: 12),
              _buildCard(
                icon: Icons.favorite,
                iconColor: Colors.pink,
                title: 'Lifestyle Score',
                subtitle: '7.5 / 10 - You’re doing well!',
              ),
              SizedBox(height: 12),
              _buildCard(
                icon: Icons.settings,
                iconColor: Colors.grey[700]!,
                title: 'Preferences',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => IndexPreferencePage(
                            visibilityPrefs: visibility,
                            onSave: onSave,
                          ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              _buildCard(
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                title: 'About MoodSync',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // Show about dialog or navigate
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
