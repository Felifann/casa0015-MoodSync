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
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Me')),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('../Pic/Avatar.png'),
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
    );
  }
}
