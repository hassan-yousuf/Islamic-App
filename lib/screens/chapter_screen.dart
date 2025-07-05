import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_times/models/verse.dart';

class ChapterScreen extends StatefulWidget {
  final Chapter chapter;
  const ChapterScreen({required this.chapter});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  void jumpTo(int ayahNumber) {
    final idx = widget.chapter.verses.indexWhere((v) => v.id == ayahNumber);
    if (idx >= 0)
      _scrollCtrl.animateTo(
        idx * 90.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
  }

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext ctx) {
    final filteredVerses = widget.chapter.verses.where((v) {
      return v.text.contains(searchQuery);
    }).toList();

    final chap = widget.chapter;
    return Scaffold(
      appBar: AppBar(
        title: Text('${chap.transliteration} (${chap.id})'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final ay = await showDialog<int>(
                context: ctx,
                builder: (_) => AyahDialog(max: chap.verses.length),
              );
              if (ay != null) jumpTo(ay);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Ayah...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[\u0600-\u06FF\s]+'),
                ),
              ],
              textDirection: TextDirection.rtl,
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: filteredVerses.length,
              itemBuilder: (_, i) {
                final v = filteredVerses[i];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${v.id}. ${v.text}',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 24),
                      ),

                      Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AyahDialog extends StatefulWidget {
  final int max;
  AyahDialog({required this.max});
  @override
  _AyahDialogState createState() => _AyahDialogState();
}

class _AyahDialogState extends State<AyahDialog> {
  int? selected;
  @override
  Widget build(BuildContext c) {
    return AlertDialog(
      title: Text('Jump to Ayah'),
      content: DropdownButtonFormField<int>(
        items: List.generate(widget.max, (i) => i + 1)
            .map((n) => DropdownMenuItem(value: n, child: Text(n.toString())))
            .toList(),
        onChanged: (v) => selected = v,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(c, selected),
          child: Text('Go'),
        ),
      ],
    );
  }
}
