import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'app_config.dart';

class VoiceChatbotScreen extends StatefulWidget {
  const VoiceChatbotScreen({super.key});

  @override
  State<VoiceChatbotScreen> createState() => _VoiceChatbotScreenState();
}

class _VoiceChatbotScreenState extends State<VoiceChatbotScreen> with SingleTickerProviderStateMixin {
  // Speech and TTS instances
  late stt.SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  late AnimationController _animationController;

  // State flags
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechEnabled = false;
  bool _isProcessing = false;
  String _lastWords = '';
  String _statusMessage = 'Tap to start talking';
  String _apiError = '';

  static const String _assistantInstruction =
      'You are a supportive mental wellness assistant. Reply in the language the user uses (Marathi or English). IMPORTANT: If you respond in Marathi, use only Marathi Devanagari script. Do not provide translations, transliterations, or explanations in English. Keep responses concise for voice conversation.';

  // Structured conversation history for AI context
  final List<Map<String, String>> _messages = [];

  // Sound visualization data
  final List<double> _audioLevels = List.filled(20, 0.0);
  Timer? _levelTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _speechToText = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => setState(() {
        _apiError = 'Speech error: ${error.errorMsg}';
        _isListening = false;
        _stopLevelAnimation();
      }),
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' && _isListening) {
          _stopListening();
        }
      },
    );
    setState(() {});
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setSharedInstance(true);

    if (Platform.isAndroid) {
      // Google TTS engine is highly recommended for Marathi (mr-IN) support
      await _flutterTts.setEngine('com.google.android.tts');
    }

    await _flutterTts.setLanguage('en-US'); // Default, will auto-switch
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _statusMessage = 'Tap to start talking';
        _stopLevelAnimation();
      });
    });

    _flutterTts.setErrorHandler((error) {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _apiError = 'TTS error: $error';
        _stopLevelAnimation();
      });
    });
  }

  void _startLevelAnimation() {
    if (!_animationController.isAnimating) {
      _animationController.repeat();
    }
    
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isListening && !_isSpeaking) {
        timer.cancel();
        _resetAudioLevels();
        return;
      }

      if (!mounted) return;
      setState(() {
        if (_isListening) {
          // Random levels for listening (simulated)
          for (int i = 0; i < _audioLevels.length; i++) {
            _audioLevels[i] = Random().nextDouble() * 0.8 + 0.2;
          }
        } else if (_isSpeaking) {
          // Smooth wave for speaking
          final time = DateTime.now().millisecondsSinceEpoch / 200.0;
          for (int i = 0; i < _audioLevels.length; i++) {
            final wave = sin(time + i * 0.5) * 0.5 + 0.5;
            _audioLevels[i] = wave * 0.7;
          }
        }
      });
    });
  }

  void _stopLevelAnimation() {
    _levelTimer?.cancel();
    _animationController.stop();
    _animationController.reset();
    _resetAudioLevels();
  }

  void _resetAudioLevels() {
    setState(() {
      for (int i = 0; i < _audioLevels.length; i++) {
        _audioLevels[i] = 0.1;
      }
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else if (_isSpeaking) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _statusMessage = 'Tap to start talking';
      });
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initializeSpeech();
      if (!_speechEnabled) {
        if (!mounted) return;
        _showPermissionDialog();
        return;
      }
    }

    if (!mounted) return;

    // Stop TTS if speaking
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    setState(() {
      _isListening = true;
      _lastWords = '';
      _apiError = '';
      _statusMessage = 'Listening... Speak now';
    });

    _startLevelAnimation();

    // Dynamically find Marathi locale to support both languages during recognition
    final locales = await _speechToText.locales();
    String localeId = 'en-US';
    try {
      // Find Marathi (India) if available
      final mrLocale = locales.firstWhere((l) => l.localeId.contains('mr'));
      localeId = mrLocale.localeId;
    } catch (_) {
      // Fallback to system default or English
      final systemLocale = await _speechToText.systemLocale();
      localeId = systemLocale?.localeId ?? 'en-US';
    }

    await _speechToText.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _stopLevelAnimation();
            if (_lastWords.isNotEmpty) {
              _processUserMessage(_lastWords);
            } else {
              _statusMessage = 'Tap to start talking';
            }
          }
        });
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _stopLevelAnimation();
  }

  Future<void> _processUserMessage(String message) async {
    if (!mounted) return;

    if (!AppConfig.hasOpenRouterApiKey) {
      setState(() {
        _apiError =
            'OpenRouter API key is missing.';
        _statusMessage = 'AI assistant is not configured';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing...';
      _apiError = '';
    });

    // Add user message to context
    _messages.add({'role': 'user', 'content': message});
    
    // Keep history manageable (last 10 turns)
    if (_messages.length > 21) {
      _messages.removeRange(1, 3); // Remove oldest user/assistant pair, keep system prompt
    }

    try {
      final response = await _callOpenRouter();
      _messages.add({'role': 'assistant', 'content': response});

      if (!mounted) return;
      setState(() {
        _statusMessage = 'AI is responding...';
      });

      await _speak(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString().replaceFirst('Exception: ', '').replaceFirst('Failed to get response: ', '');
        _statusMessage = 'Tap to try again';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<String> _callOpenRouter() async {
    final requestMessages = <Map<String, String>>[
      {
        'role': 'user',
        'content': 'Instruction: $_assistantInstruction',
      },
      ..._messages,
    ];

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://manoveda.app',
        'X-Title': 'Manoveda Voice Assistant',
      },
      body: jsonEncode({
        'model': 'google/gemma-3-4b-it:free',
        'messages': requestMessages,
        'temperature': 0.7,
        'max_tokens': 200,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final apiMessage =
          data['error']?['message']?.toString() ?? 'Unknown OpenRouter API error';
      throw Exception(apiMessage);
    }

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenRouter returned an empty response.');
    }

    final message = choices.first['message']?['content']?.toString().trim() ?? '';
    if (message.isEmpty) {
      throw Exception('OpenRouter returned an empty message.');
    }

    return message;
  }


  Future<void> _speak(String text) async {
    if (text.isEmpty) return;

    try {
      // Detect language
      final language = _detectLanguage(text);
      
      // Filter text to speak: if Marathi is detected, extract only the segments containing Devanagari script
      String textToSpeak = text;
      if (language == 'mr-IN') {
        final marathiSegmentRegex = RegExp(r'[\u0900-\u097F\s\d.,?!।:;-]+');
        final matches = marathiSegmentRegex.allMatches(text);
        textToSpeak = matches
            .map((m) => m.group(0))
            .where((s) => s != null && s.trim().isNotEmpty && RegExp(r'[\u0900-\u097F]').hasMatch(s))
            .join(' ')
            .trim();
      }

      // Check if the specific language is available/installed on the device
      final isAvailable = await _flutterTts.isLanguageAvailable(language);
      if (isAvailable) {
        await _flutterTts.setLanguage(language);
      } else {
        // Fallback to English if Marathi language pack is missing
        await _flutterTts.setLanguage('en-US');
      }

      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
        _statusMessage = 'Speaking...';
      });

      _startLevelAnimation();
      
      // Ensure we stop any current playback to prevent engine service errors
      await _flutterTts.stop();
      await _flutterTts.speak(textToSpeak.isNotEmpty ? textToSpeak : text);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _apiError = 'TTS Error: ${e.toString()}';
        });
      }
    }
  }

  String _detectLanguage(String text) {
    final marathiRegex = RegExp(r'[\u0900-\u097F]');
    if (marathiRegex.hasMatch(text)) {
      return 'mr-IN';
    }
    return 'en-US';
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs microphone and speech recognition permissions to enable voice conversations. '
          'Please grant these permissions in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    _animationController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF0D1B2A), // Dark blue
              Color(0xFF1B263B), // Medium blue
              Color(0xFF2E4A6D), // Lighter blue
              Color(0xFF415A77), // Muted blue-gray
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background shooting stars animation
            _buildBackgroundAnimation(),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status text
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Floating robot animation
                  _buildRobotAnimation(),
                  const SizedBox(height: 60),
                  // Talk button below
                  _buildTalkButton(),
                  const SizedBox(height: 30),
                  // API error display
                  if (_apiError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _apiError,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                        textAlign: TextAlign.center,
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

  Widget _buildBackgroundAnimation() {
    return SizedBox.expand(
      child: Lottie.asset(
        'assets/lottie/Background_shooting_star.json',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRobotAnimation() {
    return SizedBox(
      width: 400,
      height: 400,
      child: Lottie.asset(
        'assets/lottie/robo.json',
        controller: _animationController,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTalkButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _toggleListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: _isListening
                  ? Colors.red.withValues(alpha: 0.6)
                  : Colors.blue.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          gradient: RadialGradient(
            colors: _isListening
                ? [Colors.red.shade400, Colors.red.shade700]
                : _isProcessing
                    ? [Colors.grey.shade500, Colors.grey.shade700]
                    : [Colors.blue.shade400, Colors.indigo.shade700],
          ),
        ),
        child: Icon(
          _isListening
              ? Icons.mic
              : _isProcessing
                  ? Icons.hourglass_empty
                  : Icons.mic_none,
          size: 35,
          color: Colors.white,
        ),
      ),
    );
  }
}
