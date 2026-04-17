import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BhagavadGitaScreen extends StatefulWidget {
  const BhagavadGitaScreen({super.key});

  @override
  State<BhagavadGitaScreen> createState() => _BhagavadGitaScreenState();
}

class _BhagavadGitaScreenState extends State<BhagavadGitaScreen>
    with SingleTickerProviderStateMixin {
  final List<int> _verseCounts = [
    47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 35, 27, 20, 24, 28, 78
  ];

  int _chapter = 1;
  int _verse = 1;
  bool _loading = false;
  Map<String, dynamic>? _verseData;
  String _errorMessage = '';

  // For translation author selection
  String _selectedAuthor = 'prabhu';

  @override
  void initState() {
    super.initState();
    _fetchVerse(_chapter, _verse);
  }

  Future<void> _fetchVerse(int ch, int v) async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse('https://vedicscriptures.github.io/slok/$ch/$v'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _verseData = data;
          _chapter = ch;
          _verse = v;
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load verse. Status: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _loading = false;
        });
      }
    }
  }

  void _nextVerse() {
    int maxVerses = _verseCounts[_chapter - 1];
    if (_verse < maxVerses) {
      _fetchVerse(_chapter, _verse + 1);
    } else if (_chapter < 18) {
      _fetchVerse(_chapter + 1, 1);
    }
  }

  void _prevVerse() {
    if (_verse > 1) {
      _fetchVerse(_chapter, _verse - 1);
    } else if (_chapter > 1) {
      int prevChapterMax = _verseCounts[_chapter - 2];
      _fetchVerse(_chapter - 1, prevChapterMax);
    }
  }

  Future<void> _showPicker(BuildContext context, bool isChapter) async {
    int maxVal = isChapter ? 18 : _verseCounts[_chapter - 1];
    int selected = isChapter ? _chapter : _verse;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isChapter ? 'Select Chapter' : 'Select Shloka',
                  style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: maxVal,
                  itemBuilder: (context, index) {
                    final itemVal = index + 1;
                    return ListTile(
                      title: Text(
                        isChapter ? 'Chapter $itemVal' : 'Shloka $itemVal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: itemVal == selected ? Colors.orange : Colors.white70,
                          fontSize: 18,
                          fontWeight: itemVal == selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (isChapter && itemVal != _chapter) {
                          _fetchVerse(itemVal, 1);
                        } else if (!isChapter && itemVal != _verse) {
                          _fetchVerse(_chapter, itemVal);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _pickerButton('Chapter $_chapter', () => _showPicker(context, true)),
          const Text('|', style: TextStyle(color: Colors.orange, fontSize: 20)),
          _pickerButton('Shloka $_verse', () => _showPicker(context, false)),
        ],
      ),
    );
  }

  Widget _pickerButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationContent() {
    if (_verseData == null) return const SizedBox.shrink();

    final Map<String, String> translationKeys = {
      'prabhu': 'Swami Prabhupada (EN)',
      'chinmay': 'Swami Chinmayananda (HI/EN)',
      'siva': 'Swami Sivananda (EN)',
      'rams': 'Swami Ramsukhdas (HI)',
    };

    dynamic getTranslationBody(String authorKey) {
      final authorNode = _verseData?[authorKey];
      if (authorNode == null) return null;
      if (authorNode['et'] != null) return authorNode['et'];
      if (authorNode['ht'] != null) return authorNode['ht'];
      if (authorNode['hc'] != null) return authorNode['hc'];
      if (authorNode['ec'] != null) return authorNode['ec'];
      return authorNode['sc'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            const Text(
              'Meaning / Translation',
              style: TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF2C2C2C),
                value: _selectedAuthor,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAuthor = val);
                },
                items: translationKeys.keys.map((key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(
                      translationKeys[key]!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  );
                }).toList(),
                underline: const SizedBox.shrink(),
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.import_contacts, color: Colors.orangeAccent, size: 20),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Text(
            getTranslationBody(_selectedAuthor) ?? 'Meaning not available for the selected author.',
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: (_chapter == 1 && _verse == 1) ? null : _prevVerse,
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              label: const Text('Previous', style: TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: (_chapter == 18 && _verse == 78) ? null : _nextVerse,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next', style: TextStyle(fontSize: 15)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Bhagavad Gita', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E1901), Color(0xFF1E0A00), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  )
                else if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent))),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    key: ValueKey<int>(_chapter * 1000 + _verse),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Icon(Icons.auto_awesome, color: Colors.orange, size: 36),
                        const SizedBox(height: 16),
                        // Sanskrit Shloka
                        Text(
                          _verseData?['slok'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Transliteration
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _verseData?['transliteration'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        _buildTranslationContent(),
                      ],
                    ),
                  ),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
