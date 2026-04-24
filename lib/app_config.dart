import 'package:shared_preferences/shared_preferences.dart';

enum AiProvider { gemini, openRouter }

class AppConfig {
  static const String _providerKey = 'voice_assistant_provider';
  static const String _geminiApiKeyKey = 'voice_assistant_gemini_api_key';
  static const String _openRouterApiKeyKey =
      'voice_assistant_openrouter_api_key';

  static AiProvider selectedProvider = AiProvider.gemini;
  static String geminiApiKey = '';
  static String openRouterApiKey = '';

  static String _sanitizeApiKey(String value) {
    return value
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProvider = prefs.getString(_providerKey);
    selectedProvider = savedProvider == AiProvider.openRouter.name
        ? AiProvider.openRouter
        : AiProvider.gemini;
    geminiApiKey = _sanitizeApiKey(
      prefs.getString(_geminiApiKeyKey) ?? '',
    );
    openRouterApiKey = _sanitizeApiKey(
      prefs.getString(_openRouterApiKeyKey) ?? '',
    );
  }

  static Future<void> saveAiSettings({
    required AiProvider provider,
    String? geminiKey,
    String? openRouterKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    selectedProvider = provider;
    if (geminiKey != null) {
      geminiApiKey = _sanitizeApiKey(geminiKey);
      await prefs.setString(_geminiApiKeyKey, geminiApiKey);
    }
    if (openRouterKey != null) {
      openRouterApiKey = _sanitizeApiKey(openRouterKey);
      await prefs.setString(_openRouterApiKeyKey, openRouterApiKey);
    }

    await prefs.setString(_providerKey, provider.name);
  }

  static String get activeApiKey => switch (selectedProvider) {
    AiProvider.gemini => geminiApiKey,
    AiProvider.openRouter => openRouterApiKey,
  };

  static bool get hasActiveApiKey => activeApiKey.trim().isNotEmpty;

  static String get activeProviderLabel => switch (selectedProvider) {
    AiProvider.gemini => 'Gemini',
    AiProvider.openRouter => 'OpenRouter',
  };
}
