import 'package:flutter/material.dart';
import 'voice_service_stub.dart'
    if (dart.library.js) 'voice_service_web.dart' as impl;

class KarmaVoice {
  static bool get isMuted => impl.KarmaVoiceImpl.isMuted;
  static set isMuted(bool val) => impl.KarmaVoiceImpl.isMuted = val;

  static String get currentLanguage => impl.KarmaVoiceImpl.currentLanguage;
  static set currentLanguage(String val) => impl.KarmaVoiceImpl.currentLanguage = val;

  static void speak(String key, {String? directText, BuildContext? context}) {
    impl.KarmaVoiceImpl.speak(key, directText: directText, context: context);
  }

  static String getTranslation(String key, {String defaultValue = ''}) {
    return impl.KarmaVoiceImpl.getTranslation(key, defaultValue: defaultValue);
  }
}
