import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_data.dart';

class PrayerCache {
  static const _keyPrayerTimes = 'prayer_times';
  static const _keyPrayerDate = 'prayer_date';

  static Future<void> cachePrayerTimes(PrayerTimesData data) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toLocal().toIso8601String().substring(
      0,
      10,
    ); // YYYY-MM-DD
    await prefs.setString(_keyPrayerTimes, jsonEncode(data.toJson()));
    await prefs.setString(_keyPrayerDate, today);
  }

  static Future<PrayerTimesData?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toLocal().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyPrayerDate);

    if (savedDate == today) {
      final json = prefs.getString(_keyPrayerTimes);
      if (json != null) {
        final decoded = jsonDecode(json);
        return PrayerTimesData.fromJson(decoded);
      }
    }

    return null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrayerTimes);
    await prefs.remove(_keyPrayerDate);
  }
}
