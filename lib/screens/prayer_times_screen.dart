import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer_times/models/prayer_times_data.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  PrayerTimesData? shafiPrayerTimesData;
  PrayerTimesData? hanafiPrayerTimesData;
  PrayerTimesData? prayerTimesData;

  String nextPrayerName = '';
  Duration timeUntilNextPrayer = Duration.zero;
  Duration totalDuration = Duration.zero;
  Timer? _timer;
  Position? _position;
  String locationStatus = 'Getting location...';

  Madhab selectedMadhab = Madhab.shafi;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadSelectedMadhab();
      await _determinePosition();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSelectedMadhab() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_madhab') ?? 'shafi';
    setState(() {
      selectedMadhab = saved == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    });
  }

  Future<void> _saveSelectedMadhab(Madhab madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'selected_madhab',
      madhab == Madhab.hanafi ? 'hanafi' : 'shafi',
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => locationStatus = 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => locationStatus = 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(
        () => locationStatus = 'Location permissions are permanently denied.',
      );
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = pos;
        locationStatus = 'Location found';
      });
      _loadPrayerTimes();
    } catch (e) {
      setState(() => locationStatus = 'Failed to get location: $e');
    }
  }

  void _loadPrayerTimes() async {
    if (_position == null) return;

    final coordinates = Coordinates(_position!.latitude, _position!.longitude);
    final date = DateComponents.from(DateTime.now().toLocal());

    final shafiParams = CalculationMethod.muslim_world_league.getParameters();
    shafiParams.madhab = Madhab.shafi;
    final shafiTimes = PrayerTimes(coordinates, date, shafiParams);
    shafiPrayerTimesData = PrayerTimesData.fromPrayerTimes(shafiTimes);

    final hanafiParams = CalculationMethod.muslim_world_league.getParameters();
    hanafiParams.madhab = Madhab.hanafi;
    final hanafiTimes = PrayerTimes(coordinates, date, hanafiParams);
    hanafiPrayerTimesData = PrayerTimesData.fromPrayerTimes(hanafiTimes);

    setState(() {
      prayerTimesData = selectedMadhab == Madhab.shafi
          ? shafiPrayerTimesData
          : hanafiPrayerTimesData;
    });

    _updateNextPrayer();
    _startCountdown();
  }

  void _updateNextPrayer() {
    if (prayerTimesData == null || _position == null) {
      debugPrint('Cannot update next prayer: Missing data');
      return;
    }

    DateTime now = DateTime.now().toLocal();
    final prayers = {
      'Fajr': prayerTimesData!.fajr,
      'Sunrise': prayerTimesData!.sunrise,
      'Dhuhr': prayerTimesData!.dhuhr,
      'Asr': prayerTimesData!.asr,
      'Maghrib': prayerTimesData!.maghrib,
      'Isha': prayerTimesData!.isha,
    };

    DateTime? next;
    String? name;

    prayers.forEach((key, time) {
      if (time.isAfter(now)) {
        if (next == null || time.isBefore(next!)) {
          next = time;
          name = key;
        }
      }
    });

    if (next == null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = selectedMadhab;
      final coordinates = Coordinates(
        _position!.latitude,
        _position!.longitude,
      );
      final tomorrowPrayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        params,
      );
      final nextP = tomorrowPrayerTimes.nextPrayer();
      next = tomorrowPrayerTimes.timeForPrayer(nextP);
      name = nextP.name;
    }

    final previousTime = prayers.entries
        .where((entry) => entry.value.isBefore(now))
        .map((e) => e.value)
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

    setState(() {
      nextPrayerName = name ?? '';
      timeUntilNextPrayer = next!.difference(now);
      totalDuration = previousTime != null
          ? next!.difference(previousTime)
          : timeUntilNextPrayer;
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final newDuration = timeUntilNextPrayer - const Duration(seconds: 1);
      if (newDuration.isNegative) {
        _loadPrayerTimes();
      } else {
        setState(() {
          timeUntilNextPrayer = newDuration;
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = totalDuration.inSeconds > 0
        ? 1 - (timeUntilNextPrayer.inSeconds / totalDuration.inSeconds)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times', style: GoogleFonts.poppins()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadPrayerTimes();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Prayers Refreshed',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.green,
                  shape: ContinuousRectangleBorder(),
                ),
                snackBarAnimationStyle: AnimationStyle(
                  curve: ElasticInCurve(),
                  duration: Duration(milliseconds: 500),
                  reverseCurve: ElasticInOutCurve(),
                  reverseDuration: Duration(milliseconds: 500),
                ),
              );
            },
          ),
          PopupMenuButton<Madhab>(
            onSelected: (value) async {
              await _saveSelectedMadhab(value);
              setState(() {
                selectedMadhab = value;
                _loadPrayerTimes();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: Madhab.shafi, child: Text("Shafi")),
              PopupMenuItem(value: Madhab.hanafi, child: Text("Hanafi")),
            ],
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _position == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      locationStatus,
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _determinePosition,
                      child: Text('Retry', style: GoogleFonts.poppins()),
                    ),
                  ],
                ),
              )
            : prayerTimesData == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 12.0,
                    percent: percent.clamp(0.0, 1.0),
                    animation: true,
                    animateFromLastPercent: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Next Prayer",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                        Text(
                          nextPrayerName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDuration(timeUntilNextPrayer),
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                      ],
                    ),
                    progressColor: theme.primaryColor,
                    backgroundColor: theme.primaryColorLight.withOpacity(0.2),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: shafiPrayerTimesData!.toJson().entries.map((
                        entry,
                      ) {
                        final name = entry.key;
                        final shafiTime = DateTime.tryParse(entry.value);
                        final hanafiTime = DateTime.tryParse(
                          hanafiPrayerTimesData!.toJson()[name] ?? '',
                        );
                        if (shafiTime == null || hanafiTime == null) {
                          return const SizedBox.shrink();
                        }

                        final isNext =
                            name.toLowerCase() == nextPrayerName.toLowerCase();

                        final formattedShafi = TimeOfDay.fromDateTime(
                          shafiTime,
                        ).format(context);
                        final formattedHanafi = TimeOfDay.fromDateTime(
                          hanafiTime,
                        ).format(context);

                        final selectedTime = selectedMadhab == Madhab.shafi
                            ? formattedShafi
                            : formattedHanafi;

                        return Card(
                          elevation: isNext ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: isNext
                              ? Colors.greenAccent.shade100
                              : theme.cardColor,
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  name[0].toUpperCase() + name.substring(1),
                                  style: GoogleFonts.poppins(fontSize: 18),
                                ),
                                (name.toLowerCase() == 'asr')
                                    ? _madhabText()
                                    : const SizedBox.shrink(),
                              ],
                            ),
                            subtitle: isNext
                                ? Text(
                                    'Starts in ${_formatDuration(timeUntilNextPrayer)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  )
                                : null,
                            trailing: Text(
                              selectedTime,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: isNext ? Colors.green : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Text _madhabText() {
    return Text(
      selectedMadhab == Madhab.shafi ? ' (Shafi)' : ' (Hanafi)',
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
