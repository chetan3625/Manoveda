import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicTherapyScreen extends StatefulWidget {
  const MusicTherapyScreen({super.key});

  @override
  State<MusicTherapyScreen> createState() => _MusicTherapyScreenState();
}

class _Track {
  final String title;
  final String asset;

  const _Track({required this.title, required this.asset});
}

class _MusicTherapyScreenState extends State<MusicTherapyScreen> {
  final List<_Track> _tracks = const [
    _Track(title: 'Meditation 1', asset: 'audio/Meditation1.mpeg'),
    _Track(title: 'Meditation 2', asset: 'audio/Meditation2.mpeg'),
    _Track(title: 'Meditation 3', asset: 'audio/Meditation3.mpeg'),
    _Track(title: 'Meditation 4', asset: 'audio/Meditation4.mpeg'),
    _Track(title: 'Meditation 5', asset: 'audio/Meditation5.mpeg'),
    _Track(title: 'Meditation 6', asset: 'audio/Meditation6.mpeg'),
    _Track(title: 'Meditation 7', asset: 'audio/Meditation7.mpeg'),
    _Track(title: 'Meditation 8', asset: 'audio/Meditation8.mpeg'),
    _Track(title: 'Soft Bell', asset: 'audio/music2.mp3'),
  ];

  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  String? _currentAsset;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
        if (state == PlayerState.completed) {
          _position = Duration.zero;
        }
      });
    });
    _player.onDurationChanged.listen((dur) {
      setState(() {
        _duration = dur;
      });
    });
    _player.onPositionChanged.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
    _player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.completed;
        _position = Duration.zero;
      });
    });
  }

  bool _isCurrent(_Track track) => _currentAsset == track.asset;

  Future<void> _playTrack(_Track track) async {
    if (_isCurrent(track) && _playerState == PlayerState.playing) {
      await _player.pause();
      return;
    }
    if (_isCurrent(track) && _playerState == PlayerState.paused) {
      await _player.resume();
      return;
    }
    setState(() {
      _currentAsset = track.asset;
      _position = Duration.zero;
    });
    await _player.stop();
    await _player.setSource(AssetSource(track.asset));
    await _player.resume();
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Music Therapy'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Music Therapy',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Listen to calming tracks curated to ease stress.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _tracks.length,
                itemBuilder: (context, index) {
                  final track = _tracks[index];
                  final isCurrent = _isCurrent(track);
                  final isPlaying = isCurrent && _playerState == PlayerState.playing;
                  final progress = isCurrent && _duration.inMilliseconds > 0
                      ? _position.inMilliseconds / _duration.inMilliseconds
                      : 0.0;

                  return GestureDetector(
                    onTap: () => _playTrack(track),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(3, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isPlaying
                                          ? 'Playing now'
                                          : isCurrent && _playerState == PlayerState.paused
                                              ? 'Paused'
                                              : 'Tap to play',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                size: 48,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          if (isCurrent) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0).toDouble(),
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_position),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_currentAsset != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _stopPlayback,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
