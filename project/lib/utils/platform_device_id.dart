import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Provides a persistent unique ID per app installation.
class PlatformDeviceId {
  static const _prefsKey = 'unique_device_id';

  /// Returns a persistent unique ID
  static Future<String> get getDeviceId async {
    final prefs = await SharedPreferences.getInstance();

    // Return cached ID if it exists
    String? cachedId = prefs.getString(_prefsKey);
    if (cachedId != null && cachedId.isNotEmpty) return cachedId;

    // Generate a new UUID and store it
    final newId = const Uuid().v4();
    await prefs.setString(_prefsKey, newId);
    return newId;
  }
}
