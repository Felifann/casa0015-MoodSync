import 'package:flutter/material.dart';

class IndexPreferencePage extends StatefulWidget {
  final Map<String, bool> visibilityPrefs;
  final Function(Map<String, bool>) onSave;

  const IndexPreferencePage({
    super.key,
    required this.visibilityPrefs,
    required this.onSave,
  });

  @override
  _IndexPreferencePageState createState() => _IndexPreferencePageState();
}

class _IndexPreferencePageState extends State<IndexPreferencePage> {
  late Map<String, bool> _visibilityPrefs;

  @override
  void initState() {
    super.initState();
    _visibilityPrefs = Map<String, bool>.from(widget.visibilityPrefs);
    // Ensure only the 5 specific indices are included
    _visibilityPrefs = {
      'noise': _visibilityPrefs['noise'] ?? true,
      'light': _visibilityPrefs['light'] ?? true,
      'motion': _visibilityPrefs['motion'] ?? true,
      'airquality': _visibilityPrefs['airquality'] ?? true,
      'weather': _visibilityPrefs['weather'] ?? true,
    };
  }

  void _updateVisibility(String label, bool isVisible) {
    if (_visibilityPrefs[label] != isVisible) {
      setState(() {
        _visibilityPrefs[label] = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Adjust Index Preferences'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children:
            _visibilityPrefs.keys.map((label) {
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    label,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  trailing: Switch(
                    value: _visibilityPrefs[label]!,
                    onChanged: (value) => _updateVisibility(label, value),
                  ),
                ),
              );
            }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            widget.onSave(_visibilityPrefs);
            Navigator.pop(context);
          },
          child: Text('Save Preferences'),
        ),
      ),
    );
  }
}
