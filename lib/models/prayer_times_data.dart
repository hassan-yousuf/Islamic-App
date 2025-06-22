import 'package:adhan/adhan.dart';

class PrayerTimesData {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimesData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimesData.fromPrayerTimes(PrayerTimes times) {
    return PrayerTimesData(
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
    );
  }

  Map<String, dynamic> toJson() => {
    'fajr': fajr.toIso8601String(),
    'sunrise': sunrise.toIso8601String(),
    'dhuhr': dhuhr.toIso8601String(),
    'asr': asr.toIso8601String(),
    'maghrib': maghrib.toIso8601String(),
    'isha': isha.toIso8601String(),
  };

  factory PrayerTimesData.fromJson(Map<String, dynamic> json) {
    return PrayerTimesData(
      fajr: DateTime.parse(json['fajr']),
      sunrise: DateTime.parse(json['sunrise']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
    );
  }
}
