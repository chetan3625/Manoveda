import 'package:flutter/material.dart';
import 'package:manoveda/widgets/app_scaffold.dart';
import 'dbhelper.dart';
import 'package:intl/intl.dart';

import 'wellness_repository.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _textController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _journalEntries;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _journalEntries = DatabaseHelper().getEntries();
    });
  }

  void _saveEntry() async {
    String entryText = _textController.text;
    if (entryText.isNotEmpty) {
      Map<String, dynamic> entry = {
        'content': entryText,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper().insertEntry(entry);
      await WellnessRepository.instance.logEvent(
        taskKey: 'writing_journal',
        title: 'Writing Journal',
        details: entryText,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry saved!')),
        );
        _textController.clear();
        _loadEntries();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something to save.')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'How are you feeling today?',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: _saveEntry,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "My Entries",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Expanded( //
                flex: 2,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _journalEntries,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No entries found. Start by writing one!', style: TextStyle(color: Colors.white70)));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var entry = snapshot.data![index];
                          String formattedDate = DateFormat.yMMMd().add_jm().format(DateTime.parse(entry['timestamp']));
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            color: Colors.black.withOpacity(0.3),
                            child: ListTile(
                              title: Text(entry['content'], style: const TextStyle(fontSize: 16, color: Colors.white)),
                              subtitle: Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
