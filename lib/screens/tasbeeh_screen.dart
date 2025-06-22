import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbeehCounterScreen extends StatefulWidget {
  const TasbeehCounterScreen({super.key});

  @override
  State<TasbeehCounterScreen> createState() => _TasbeehCounterScreenState();
}

class _TasbeehCounterScreenState extends State<TasbeehCounterScreen> {
  List<String> _tasbeehList = [];
  String _selectedTasbeeh = '';
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadTasbeehList();
  }

  Future<void> _loadTasbeehList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList =
        prefs.getStringList('tasbeeh_list') ??
        ['Subhan-Allah', 'Alhamd-u-lillah', 'Allah-u-Akbar'];

    setState(() {
      _tasbeehList = savedList;
      _selectedTasbeeh = savedList.first;
    });

    _loadCount();
  }

  Future<void> _saveTasbeehList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasbeeh_list', _tasbeehList);
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt('tasbeeh_$_selectedTasbeeh') ?? 0;
    });
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_$_selectedTasbeeh', _count);
  }

  void _increment() {
    setState(() => _count++);
    _saveCount();
  }

  void _reset() {
    setState(() => _count = 0);
    _saveCount();
  }

  void _onTasbeehChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _selectedTasbeeh = newValue;
    });
    _loadCount();
  }

  void _addTasbeeh() async {
    final newTasbeeh = await _showInputDialog(context, 'Add Tasbeeh');
    if (newTasbeeh != null && newTasbeeh.trim().isNotEmpty) {
      setState(() {
        _tasbeehList.add(newTasbeeh);
        _selectedTasbeeh = newTasbeeh;
        _count = 0;
      });
      await _saveTasbeehList();
      await _saveCount();
    }
  }

  void _editTasbeeh(String oldTasbeeh) async {
    final newTasbeeh = await _showInputDialog(
      context,
      'Edit Tasbeeh',
      oldTasbeeh,
    );
    if (newTasbeeh != null && newTasbeeh.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final oldCount = prefs.getInt('tasbeeh_$oldTasbeeh') ?? 0;

      setState(() {
        final index = _tasbeehList.indexOf(oldTasbeeh);
        _tasbeehList[index] = newTasbeeh;
        if (_selectedTasbeeh == oldTasbeeh) {
          _selectedTasbeeh = newTasbeeh;
          _count = oldCount;
        }
      });

      await prefs.remove('tasbeeh_$oldTasbeeh');
      await prefs.setInt('tasbeeh_$newTasbeeh', oldCount);
      await _saveTasbeehList();
    }
  }

  Future<String?> _showInputDialog(
    BuildContext context,
    String title, [
    String? initialValue,
  ]) {
    final controller = TextEditingController(text: initialValue ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter Tasbeeh'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasbeeh Counter')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          children: [
            // Dropdown + Add/Edit Buttons
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTasbeeh,
                    decoration: InputDecoration(
                      labelText: 'Select Tasbeeh',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    items: _tasbeehList
                        .map(
                          (phrase) => DropdownMenuItem(
                            value: phrase,
                            child: Text(phrase),
                          ),
                        )
                        .toList(),
                    onChanged: _onTasbeehChanged,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _addTasbeeh,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  tooltip: 'Add Tasbeeh',
                ),
                IconButton(
                  onPressed: () => _editTasbeeh(_selectedTasbeeh),
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit Tasbeeh',
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Counter Display
            Text(
              '$_count',
              style: const TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),

            // Count / Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _increment,
                  icon: const Icon(Icons.add),
                  label: const Text('Count'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 30),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
