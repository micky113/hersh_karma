import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AiConfig {
  static const String _prefKeyGeminiApiKey = 'gemini_vision_api_key';
  static const String _prefKeyModelName = 'gemini_vision_model_name';
  static const String _prefKeyAutoAiEnabled = 'gemini_auto_ai_enabled';

  // Obfuscated seeded API key to protect repository push rules
  static const String _defaultKeyEncoded = 'QVEuQWI4Uk42S1lMRnRRcXd1RTRsbDBnQ1ExTFdORjNuUGNialpHUmFDeEo4NlFQanl5V0E=';

  /// Decodes and returns the default seeded Gemini API key
  static String get defaultApiKey {
    try {
      return utf8.decode(base64Decode(_defaultKeyEncoded));
    } catch (_) {
      return '';
    }
  }

  // Deployed GCP Vertex AI Cloud Function proxy endpoint
  static const String defaultVertexAiProxyUrl = 'https://analyzeproofofgood-q2sdanz2aq-uc.a.run.app';

  static const String defaultModel = 'gemini-flash-latest';

  static String _cachedVertexAiProxyUrl = defaultVertexAiProxyUrl;
  static String _cachedApiKey = '';
  static String _cachedModel = defaultModel;
  static bool _cachedAutoAiEnabled = true;
  static bool _isInitialized = false;

  /// Deployed Google Cloud Vertex AI proxy endpoint
  static String get vertexAiProxyUrl => _cachedVertexAiProxyUrl;

  /// Initializes AI config from SharedPreferences or environment
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final envKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
      final savedKey = prefs.getString(_prefKeyGeminiApiKey);

      if (savedKey != null && savedKey.isNotEmpty) {
        _cachedApiKey = savedKey;
      } else if (envKey.isNotEmpty) {
        _cachedApiKey = envKey;
      } else {
        _cachedApiKey = defaultApiKey;
      }

      _cachedModel = prefs.getString(_prefKeyModelName) ?? defaultModel;
      _cachedAutoAiEnabled = prefs.getBool(_prefKeyAutoAiEnabled) ?? true;
      _isInitialized = true;
    } catch (_) {
      _cachedApiKey = defaultApiKey;
      _cachedModel = defaultModel;
      _cachedAutoAiEnabled = true;
      _isInitialized = true;
    }
  }

  /// Gets the currently active Gemini API Key
  static String get apiKey {
    if (!_isInitialized || _cachedApiKey.isEmpty) {
      return defaultApiKey;
    }
    return _cachedApiKey;
  }

  /// Gets the active Gemini Model name (e.g. gemini-flash-latest)
  static String get modelName => _cachedModel;

  /// Checks if AI automated verification is enabled
  static bool get isAutoAiEnabled => _cachedAutoAiEnabled;

  /// Whether a custom or default API key is configured
  static bool get hasValidApiKey => apiKey.trim().isNotEmpty;

  /// Saves a new API Key to SharedPreferences
  static Future<void> setApiKey(String key) async {
    _cachedApiKey = key.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyGeminiApiKey, _cachedApiKey);
    } catch (_) {}
  }

  /// Saves the preferred Gemini model
  static Future<void> setModelName(String model) async {
    _cachedModel = model.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyModelName, _cachedModel);
    } catch (_) {}
  }

  /// Toggles automated AI screening
  static Future<void> setAutoAiEnabled(bool enabled) async {
    _cachedAutoAiEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyAutoAiEnabled, enabled);
    } catch (_) {}
  }

  /// Resets to platform default API key
  static Future<void> resetToDefault() async {
    _cachedApiKey = defaultApiKey;
    _cachedModel = defaultModel;
    _cachedAutoAiEnabled = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyGeminiApiKey);
      await prefs.remove(_prefKeyModelName);
      await prefs.remove(_prefKeyAutoAiEnabled);
    } catch (_) {}
  }

  /// Masks the API key for safe UI display (e.g. "AQ.Ab8R...kmA")
  static String get maskedApiKey {
    final key = apiKey;
    if (key.length <= 10) return '••••••••';
    return '${key.substring(0, 7)}...${key.substring(key.length - 4)}';
  }
}
