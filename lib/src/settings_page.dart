import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
    _trackMode = Hive.box('tracker').get('totalTrackMode', defaultValue: false);
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
            FutureBuilder<String>(
              future: Settings.getAppVersion(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading version number...'),
                  );
                } else {
                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                          'App Version: ${snapshot.data}'), // Version number
                    );
                  }
                }
              },
            ),
            SwitchListTile(
              title: const Text('Total Tracking Mode'),
              value: _trackMode,
              onChanged: (bool value) {
                setState(() {
                  _trackMode = value;
                  Hive.box('tracker').put('totalTrackMode', value);
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
