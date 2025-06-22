import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prayer_times/utils/quotes.dart';

class DailyQuoteScreen extends StatefulWidget {
  const DailyQuoteScreen({super.key});

  @override
  State<DailyQuoteScreen> createState() => _DailyQuoteScreenState();
}

class _DailyQuoteScreenState extends State<DailyQuoteScreen> {
  List<Map<String, String>> dailyQuotes = [];

  @override
  void initState() {
    super.initState();
    _calculateDailyQuotes();
  }

  void _calculateDailyQuotes() {
    // Get day of year (1-365/366)
    final now = DateTime.now().toLocal();
    final dayOfYear = int.parse(DateFormat("D").format(now));

    // How many quotes per day to show
    const quotesPerDay = 10;

    //static Quotes
    final quotes = Quotes.quotes;

    // Total quotes count
    final totalQuotes = quotes.length;

    // Calculate starting index based on day of year (cycles through list)
    final startIndex = (dayOfYear * quotesPerDay) % totalQuotes;

    // Extract 10 quotes for today, wrap around if needed
    List<Map<String, String>> selectedQuotes = [];

    for (int i = 0; i < quotesPerDay; i++) {
      selectedQuotes.add(quotes[(startIndex + i) % totalQuotes]);
    }

    setState(() {
      dailyQuotes = selectedQuotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Islamic Quotes'),
        centerTitle: true,
      ),
      body: dailyQuotes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isLargeScreen = width > 600;

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: dailyQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = dailyQuotes[index]["quote"]!;
                      final author = dailyQuotes[index]["author"]!;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: isLargeScreen
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.format_quote,
                                      size: 40,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            quote,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[900],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '- $author',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.format_quote,
                                          size: 30,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            quote,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[900],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '- $author',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
