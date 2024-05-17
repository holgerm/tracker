import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  Settings._privateConstructor();

  static final Settings instance = Settings._privateConstructor();

  bool _totalTrackMode = false;

  bool get totalTrackMode => _totalTrackMode;

  set totalTrackMode(bool value) {
    _totalTrackMode = value;
    _saveTrackMode(value);
  }

  Future<void> _saveTrackMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trackMode', value);
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _totalTrackMode = prefs.getBool('trackMode') ?? false;
  }
}
