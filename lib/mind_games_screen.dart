import 'dart:async';

import 'package:flutter/material.dart';

class MindGamesScreen extends StatelessWidget {
  const MindGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Games'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                'Short, psychology-friendly brain breaks. These games follow the same calm theme as the rest of Manoveda and focus on memory and attention instead of high-pressure play.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _GameCard(
              title: 'Memory Match',
              subtitle: 'Flip cards and pair the calming symbols.',
              icon: Icons.grid_view_rounded,
              colors: [Colors.deepPurple.shade400, Colors.indigo.shade700],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MemoryMatchGameScreen(),
                  ),
                );
              },
            ),
            _GameCard(
              title: 'Focus Grid',
              subtitle: 'Tap 1 to 16 in order to train concentration.',
              icon: Icons.filter_1_rounded,
              colors: [Colors.teal.shade400, Colors.cyan.shade700],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FocusGridGameScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MemoryMatchGameScreen extends StatefulWidget {
  const MemoryMatchGameScreen({super.key});

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  final List<_MemorySymbol> _symbols = const [
    _MemorySymbol(id: 'leaf', icon: Icons.spa_rounded, color: Colors.green),
    _MemorySymbol(
      id: 'heart',
      icon: Icons.favorite_rounded,
      color: Colors.pink,
    ),
    _MemorySymbol(
      id: 'sun',
      icon: Icons.wb_sunny_rounded,
      color: Colors.orange,
    ),
    _MemorySymbol(
      id: 'water',
      icon: Icons.water_drop_rounded,
      color: Colors.lightBlue,
    ),
    _MemorySymbol(id: 'star', icon: Icons.star_rounded, color: Colors.amber),
    _MemorySymbol(
      id: 'moon',
      icon: Icons.nightlight_round,
      color: Colors.indigo,
    ),
  ];

  late List<_MemoryTile> _tiles;
  int _moves = 0;
  int _matches = 0;
  int? _firstPick;
  int? _secondPick;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    final tiles = [
      for (final symbol in _symbols) _MemoryTile(symbol: symbol),
      for (final symbol in _symbols) _MemoryTile(symbol: symbol),
    ]..shuffle();

    setState(() {
      _tiles = tiles;
      _moves = 0;
      _matches = 0;
      _firstPick = null;
      _secondPick = null;
      _busy = false;
    });
  }

  Future<void> _tapTile(int index) async {
    final tile = _tiles[index];
    if (_busy || tile.isFaceUp || tile.isMatched) {
      return;
    }

    setState(() {
      tile.isFaceUp = true;
    });

    if (_firstPick == null) {
      _firstPick = index;
      return;
    }

    _secondPick = index;
    _moves++;
    final first = _tiles[_firstPick!];
    final second = _tiles[_secondPick!];

    if (first.symbol.id == second.symbol.id) {
      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        _matches++;
      });
      _clearTurn();
      if (_matches == _symbols.length && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All pairs matched in $_moves moves.')),
        );
      }
      return;
    }

    _busy = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    setState(() {
      first.isFaceUp = false;
      second.isFaceUp = false;
      _busy = false;
    });
    _clearTurn();
  }

  void _clearTurn() {
    _firstPick = null;
    _secondPick = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'Moves', value: '$_moves'),
                  _StatChip(
                    label: 'Pairs',
                    value: '$_matches / ${_symbols.length}',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Flip two cards at a time and match the calming symbols.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 4
                      : 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemCount: _tiles.length,
                itemBuilder: (context, index) {
                  final tile = _tiles[index];
                  final visible = tile.isFaceUp || tile.isMatched;
                  final tileColors = visible
                      ? [tile.symbol.color.shade300, tile.symbol.color.shade700]
                      : [Colors.white, Colors.blue.shade50];

                  return GestureDetector(
                    onTap: () => _tapTile(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: tileColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          visible
                              ? tile.symbol.icon
                              : Icons.question_mark_rounded,
                          size: 40,
                          color: visible
                              ? Colors.white
                              : Colors.indigo.shade400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Shuffle Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FocusGridGameScreen extends StatefulWidget {
  const FocusGridGameScreen({super.key});

  @override
  State<FocusGridGameScreen> createState() => _FocusGridGameScreenState();
}

class _FocusGridGameScreenState extends State<FocusGridGameScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  late List<int> _numbers;
  final Set<int> _completed = <int>{};
  int _next = 1;
  int _mistakes = 0;
  int? _wrongTile;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _stopwatch.isRunning) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _resetGame() {
    _stopwatch
      ..reset()
      ..stop();

    setState(() {
      _numbers = List<int>.generate(16, (index) => index + 1)..shuffle();
      _completed.clear();
      _next = 1;
      _mistakes = 0;
      _wrongTile = null;
      _finished = false;
    });
  }

  Future<void> _tapNumber(int value) async {
    if (_finished || _completed.contains(value)) {
      return;
    }

    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }

    if (value == _next) {
      setState(() {
        _completed.add(value);
        _next++;
      });

      if (_next > 16) {
        _stopwatch.stop();
        setState(() {
          _finished = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Completed in ${_formatTime(_stopwatch.elapsed)} with $_mistakes mistakes.',
              ),
            ),
          );
        }
      }
      return;
    }

    setState(() {
      _mistakes++;
      _wrongTile = value;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }

    setState(() {
      if (_wrongTile == value) {
        _wrongTile = null;
      }
    });
  }

  String _formatTime(Duration duration) {
    final seconds = (duration.inMilliseconds / 1000).floor();
    final tenths = ((duration.inMilliseconds % 1000) / 100).floor();
    return '$seconds.$tenths s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Grid'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(
                    label: 'Time',
                    value: _formatTime(_stopwatch.elapsed),
                  ),
                  _StatChip(label: 'Mistakes', value: '$_mistakes'),
                  _StatChip(
                    label: 'Next',
                    value: _finished ? 'Done' : 'Tap $_next',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tap the numbers from 1 to 16 in order. This is a simple 2D focus and attention exercise.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemCount: _numbers.length,
                itemBuilder: (context, index) {
                  final value = _numbers[index];
                  final done = _completed.contains(value);
                  final target = value == _next;
                  final wrong = value == _wrongTile;
                  final colors = done
                      ? [Colors.green.shade300, Colors.green.shade700]
                      : wrong
                      ? [Colors.red.shade300, Colors.red.shade700]
                      : target
                      ? [Colors.deepPurple.shade300, Colors.indigo.shade700]
                      : [Colors.white, Colors.blue.shade50];

                  final textColor = done || wrong || target
                      ? Colors.white
                      : Colors.indigo.shade700;

                  return GestureDetector(
                    onTap: () => _tapNumber(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Restart Focus Grid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 34),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemorySymbol {
  const _MemorySymbol({
    required this.id,
    required this.icon,
    required this.color,
  });

  final String id;
  final IconData icon;
  final MaterialColor color;
}

class _MemoryTile {
  _MemoryTile({required this.symbol});

  final _MemorySymbol symbol;
  bool isFaceUp = false;
  bool isMatched = false;
}
