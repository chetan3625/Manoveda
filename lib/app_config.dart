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

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProvider = prefs.getString(_providerKey);
    selectedProvider = savedProvider == AiProvider.openRouter.name
        ? AiProvider.openRouter
        : AiProvider.gemini;
    geminiApiKey = prefs.getString(_geminiApiKeyKey)?.trim() ?? '';
    openRouterApiKey = prefs.getString(_openRouterApiKeyKey)?.trim() ?? '';
  }

  static Future<void> saveAiSettings({
    required AiProvider provider,
    String? geminiKey,
    String? openRouterKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    selectedProvider = provider;
    if (geminiKey != null) {
      geminiApiKey = geminiKey.trim();
      await prefs.setString(_geminiApiKeyKey, geminiApiKey);
    }
    if (openRouterKey != null) {
      openRouterApiKey = openRouterKey.trim();
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
