import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times/models/verse.dart';
import 'package:prayer_times/screens/chapter_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List quranData = [];

  @override
  void initState() {
    super.initState();
    loadQuran();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Al-Qur'an")),
      body: quranData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (c, i) {
                final chap = chapters[i];
                return ListTile(
                  title: Text('${chap.id}. ${chap.transliteration}'),
                  subtitle: Text('Verses: ${chap.totalVerses} • ${chap.type}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterScreen(chapter: chap),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  List<Chapter> chapters = [];

  Future<void> loadQuran() async {
    try {
      final data = jsonDecode(await rootBundle.loadString('assets/quran.json'));
      chapters = (data as List).map((c) => Chapter.fromJson(c)).toList();
      setState(() {
        quranData = data;
      });
    } catch (e) {
      print('Quran loading error: $e');
    }
  }
}
