import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'app_config.dart';
import 'api_service.dart';

class VoiceChatbotScreen extends StatefulWidget {
  const VoiceChatbotScreen({super.key});

  @override
  State<VoiceChatbotScreen> createState() => _VoiceChatbotScreenState();
}

class _VoiceChatbotScreenState extends State<VoiceChatbotScreen>
    with SingleTickerProviderStateMixin {
  static const String _assistantBusyMessage =
      'The AI provider is busy right now. Please try again in a moment.';
  static const List<String> _geminiModelFallbacks = [
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-1.5-flash-latest',
  ];

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
  bool _isLoadingSettings = true;

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
    _loadAiSettings();
    _initializeSpeech();
    _initializeTts();
  }

  Future<void> _loadAiSettings() async {
    await AppConfig.init();
    if (!mounted) return;
    setState(() {
      _isLoadingSettings = false;
      if (!AppConfig.hasActiveApiKey) {
        _statusMessage = 'Add an API key to start talking';
      }
    });
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
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
      ),
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

    if (!AppConfig.hasActiveApiKey) {
      setState(() {
        _apiError =
            'Add a ${AppConfig.activeProviderLabel} API key to continue.';
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
      _messages.removeRange(
        1,
        3,
      ); // Remove oldest user/assistant pair, keep system prompt
    }

    try {
      final response = await _callAiProvider();
      _messages.add({'role': 'assistant', 'content': response});

      if (!mounted) return;
      setState(() {
        _statusMessage = 'AI is responding...';
      });

      await _speak(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = _humanizeApiError(
          e
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('Failed to get response: ', ''),
        );
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

  Future<String> _callAiProvider() {
    return switch (AppConfig.selectedProvider) {
      AiProvider.gemini => _callGemini(),
      AiProvider.openRouter => _callOpenRouter(),
    };
  }

  Future<String> _callOpenRouter() async {
    final requestMessages = <Map<String, String>>[
      {'role': 'system', 'content': _assistantInstruction},
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
        'model': 'google/gemini-2.5-flash-lite',
        'messages': requestMessages,
        if (ApiService.userId?.trim().isNotEmpty == true)
          'user': ApiService.userId,
        'temperature': 0.7,
        'max_tokens': 200,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final apiMessage =
          data['error']?['message']?.toString() ??
          'Unknown OpenRouter API error';
      throw Exception(apiMessage);
    }

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenRouter returned an empty response.');
    }

    final message =
        choices.first['message']?['content']?.toString().trim() ?? '';
    if (message.isEmpty) {
      throw Exception('OpenRouter returned an empty message.');
    }

    return message;
  }

  Future<String> _callGemini() async {
    final conversation = StringBuffer()
      ..writeln(_assistantInstruction)
      ..writeln()
      ..writeln('Conversation so far:');

    for (final entry in _messages) {
      final role = entry['role'] ?? 'user';
      final content = entry['content'] ?? '';
      if (content.trim().isEmpty) continue;
      conversation.writeln('${role.toUpperCase()}: $content');
    }

    conversation.writeln();
    conversation.writeln(
      'Reply naturally, keep it concise, and match the user language.',
    );

    String? lastError;

    for (final model in _geminiModelFallbacks) {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${AppConfig.geminiApiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': conversation.toString()},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200},
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        lastError =
            data['error']?['message']?.toString() ??
            'Unknown Gemini API error';
        final normalizedError = lastError.toLowerCase();
        final shouldTryAnotherModel =
            normalizedError.contains('not found for api version') ||
            normalizedError.contains('is not found') ||
            normalizedError.contains('not supported for generatecontent') ||
            normalizedError.contains('unsupported model');

        if (shouldTryAnotherModel) {
          continue;
        }

        throw Exception(lastError);
      }

      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      final parts = candidates.first['content']?['parts'];
      if (parts is! List || parts.isEmpty) {
        throw Exception('Gemini returned an empty message.');
      }

      final message = parts
          .map((part) => part['text']?.toString() ?? '')
          .join(' ')
          .trim();
      if (message.isNotEmpty) {
        return message;
      }

      throw Exception('Gemini returned an empty message.');
    }

    throw Exception(
      lastError ??
          'No supported Gemini model is available for this API key right now.',
    );
  }

  String _humanizeApiError(String error) {
    final normalized = error.trim().toLowerCase();
    if (normalized.contains('user not found') ||
        normalized.contains('invalid api key') ||
        normalized.contains('api key not valid') ||
        normalized.contains('api_key_invalid') ||
        normalized.contains('unauthorized')) {
      return '${AppConfig.activeProviderLabel} rejected the API key. Please update it and try again.';
    }
    if (normalized.contains('provider returned error') ||
        normalized.contains('temporarily rate-limited upstream') ||
        normalized.contains('too many requests') ||
        normalized.contains('rate limit') ||
        normalized.contains('429')) {
      return _assistantBusyMessage;
    }
    if (normalized.contains('socketexception') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('host lookup') ||
        normalized.contains('no address associated with hostname') ||
        normalized.contains('connection failed') ||
        normalized.contains('network is unreachable')) {
      return 'Your device could not reach the ${AppConfig.activeProviderLabel} server. Please check Wi-Fi/mobile data, DNS, VPN/firewall settings, then try again.';
    }
    if (normalized.contains('not found for api version') ||
        normalized.contains('not supported for generatecontent') ||
        normalized.contains('unsupported model')) {
      return 'The selected Gemini model is not available for this API key right now. Please try again, or switch provider in the API key settings.';
    }
    return error;
  }

  Future<void> _showApiKeyBottomSheet() async {
    final geminiController = TextEditingController(
      text: AppConfig.geminiApiKey,
    );
    final openRouterController = TextEditingController(
      text: AppConfig.openRouterApiKey,
    );
    AiProvider selectedProvider = AppConfig.selectedProvider;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10233A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeController = selectedProvider == AiProvider.gemini
                ? geminiController
                : openRouterController;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Voice Assistant API Key',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose the provider and save the key you want the chatbot to use.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CupertinoSlidingSegmentedControl<AiProvider>(
                      backgroundColor: Colors.transparent,
                      thumbColor: Colors.blueAccent,
                      groupValue: selectedProvider,
                      children: const {
                        AiProvider.gemini: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Text(
                            'Gemini',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        AiProvider.openRouter: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Text(
                            'OpenRouter',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {
                          selectedProvider = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: activeController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText:
                          '${selectedProvider == AiProvider.gemini ? 'Gemini' : 'OpenRouter'} API Key',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'Paste your API key here',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final activeKey = activeController.text.trim();
                        if (activeKey.isEmpty) {
                          setState(() {
                            _apiError =
                                'Please enter a ${selectedProvider == AiProvider.gemini ? 'Gemini' : 'OpenRouter'} API key.';
                          });
                          return;
                        }

                        await AppConfig.saveAiSettings(
                          provider: selectedProvider,
                          geminiKey: geminiController.text,
                          openRouterKey: openRouterController.text,
                        );

                        if (!mounted) return;
                        setState(() {
                          _apiError = '';
                          _statusMessage = 'Tap to start talking';
                        });
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    geminiController.dispose();
    openRouterController.dispose();
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
            .where(
              (s) =>
                  s != null &&
                  s.trim().isNotEmpty &&
                  RegExp(r'[\u0900-\u097F]').hasMatch(s),
            )
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 0),
                    child: Row(
                      children: [
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _showApiKeyBottomSheet,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.key_outlined, size: 18),
                          label: Text(
                            _isLoadingSettings
                                ? 'Loading...'
                                : AppConfig.hasActiveApiKey
                                ? AppConfig.activeProviderLabel
                                : 'Add API Key',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const Spacer(),
                  if (!_isLoadingSettings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: Text(
                        'Current provider: ${AppConfig.activeProviderLabel}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
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
