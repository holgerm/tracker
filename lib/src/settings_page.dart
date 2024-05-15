import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              title: Text('Setting 1'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Setting 1 details page
              },
            ),
            ListTile(
              title: Text('Setting 2'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Setting 2 details page
              },
            ),
            // Add more ListTile widgets for more settings
          ],
        ).toList(),
      ),
    );
  }
}
