import 'package:package_info/package_info.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracker/src/hive_ids.dart';

// part 'settings.g.dart'; // This is the part directive

@HiveType(typeId: HiveTypeId.settings)
class Settings extends HiveObject {
  // bool _totalTrackMode;

  Settings();

  //bool get totalTrackMode => _totalTrackMode;

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
