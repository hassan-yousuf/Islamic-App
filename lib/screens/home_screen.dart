import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prayer_times/screens/daily_quote_screen.dart';
import 'package:prayer_times/screens/quran_screen.dart';
import 'package:prayer_times/utils/ad_banner.dart';
import 'prayer_times_screen.dart';
import 'qibla_screen.dart';
import 'tasbeeh_screen.dart';
import 'hijri_calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _HomeCard(
        title: 'Prayer Times',
        icon: Icons.access_time,
        color: Colors.green,
        destination: const PrayerTimesScreen(),
      ),
      _HomeCard(
        title: 'Qibla Direction',
        icon: Icons.explore,
        color: Colors.indigo,
        destination: const QiblaDirectionScreen(),
      ),
      _HomeCard(
        title: 'Tasbeeh Counter',
        icon: Icons.fingerprint,
        color: Colors.deepPurple,
        destination: const TasbeehCounterScreen(),
      ),
      _HomeCard(
        title: 'Hijri Calendar',
        icon: Icons.calendar_today,
        color: Colors.brown,
        destination: const HijriCalendarScreen(),
      ),
      _HomeCard(
        title: 'Daily Islamic Quotes',
        icon: Icons.format_quote,
        color: Colors.teal,
        destination: const DailyQuoteScreen(),
      ),
      _HomeCard(
        title: 'Holy Quran',
        icon: Icons.menu_book,
        color: Colors.orange,
        destination: const QuranScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Islamic Utility App', style: GoogleFonts.poppins()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: cards,
            ),
          ),
          AdBanner(),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget destination;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
