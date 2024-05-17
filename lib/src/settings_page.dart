import 'package:flutter/material.dart';
import 'package:tracker/src/tracker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _trackMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _trackMode = Settings.instance.totalTrackMode;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            SwitchListTile(
              title: const Text('Total Tracking Mode'),
              value: _trackMode,
              onChanged: (bool value) {
                setState(() {
                  _trackMode = value;
                  Settings.instance.totalTrackMode = value;
                });
              },
            ),
            // Add more ListTile widgets for more settings
          ],
        ).toList(),
      ),
    );
  }
}
