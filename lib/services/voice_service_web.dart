import 'package:flutter/material.dart';
import 'dart:js' as js;

class KarmaVoiceImpl {
  static bool isMuted = false;
  static String currentLanguage = 'English';

  static const Map<String, String> _langCodes = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Bengali': 'bn-IN',
    'Tamil': 'ta-IN',
    'Telugu': 'te-IN',
    'Marathi': 'mr-IN',
    'Gujarati': 'gu-IN',
    'Kannada': 'kn-IN',
    'Malayalam': 'ml-IN',
    'Punjabi': 'pa-IN',
    'Hebrew': 'he-IL',
  };

  static const Map<String, Map<String, String>> _translations = {
    'do_good': {
      'English': 'Do Good.',
      'Hindi': 'अच्छा काम करें।',
      'Bengali': 'ভালো কাজ করুন।',
      'Tamil': 'நல்லது செய்யுங்கள்.',
      'Telugu': 'మంచి చేయండి.',
      'Marathi': 'चांगले काम करा.',
      'Gujarati': 'સારું કામ કરો.',
      'Kannada': 'ಒள்ளೆಯದನ್ನು ಮಾಡಿ.',
      'Malayalam': 'നല്ലത് ചെയ്യുക.',
      'Punjabi': 'ਚੰਗਾ ਕੰਮ ਕਰੋ।',
      'Hebrew': 'עשה טוב.',
    },
    'report': {
      'English': 'Report a Problem.',
      'Hindi': 'समस्या की रिपोर्ट करें।',
      'Bengali': 'समস্যার रिपोर्ट करें।',
      'Tamil': 'பிரச்சனையை புகார் செய்.',
      'Telugu': 'సమస్యను నివేדించండి.',
      'Marathi': 'समस्येची तक्रार करा.',
      'Gujarati': 'સમસ્યાની જાણ કરો.',
      'Kannada': 'ಸమस्यೆಯನ್ನು ವರದಿ ಮಾಡಿ.',
      'Malayalam': 'പ്രശ്നം റിപ്പോർട്ട് ചെയ്യുക.',
      'Punjabi': 'ਸਮੱਸਿਆ ਦੀ ਰਿਪੋਰਟ ਕਰੋ।',
      'Hebrew': 'דווח על בעיה.',
    },
    'make_wish': {
      'English': 'Tell us what you wish for.',
      'Hindi': 'हमें बताएं कि आपकी क्या इच्छा है।',
      'Bengali': 'আপনার কি ইচ্ছে আমাদের জানান।',
      'Tamil': 'உங்கள் ஆசை என்னவென்று சொல்லுங்கள்.',
      'Telugu': 'మీ కోరిక ఏమిటో మాకు చెప్పండి.',
      'Marathi': 'तुमची काय इच्छा आहे ते आम्हाला सांगा.',
      'Gujarati': 'તમારી ઈચ્છा અમને જણાવો.',
      'Kannada': 'ನಿಮ್ಮ ಆಸೆ ಏನೆಂದು ನಮಗೆ ತಿಳಿಸಿ.',
      'Malayalam': 'നിങ്ങളുടെ ആഗ്രഹം എന്താണെന്ന് ഞങ്ങളോട് പറയുക.',
      'Punjabi': 'ਸਾਨੂੰ ਦੱਸੋ ਕਿ ਤੁਹਾਡੀ ਕੀ ਇੱਛਾ ਹੈ।',
      'Hebrew': 'ספר לנו מה המשאלה שלך.',
    },
    'before_proof': {
      'English': 'Take a photo of how things are now.',
      'Hindi': 'अभी जैसी स्थिति है, उसकी एक फोटो लें।',
      'Bengali': 'এখনকার পরিস্থিতির একটি ছবি তুলুন।',
      'Tamil': 'இப்போது 어떻게 יציב אלא אם כעת.',
      'Telugu': 'ప్రస్తుతం ఉన్న పరిస్థితిని ఫోటో తీయండి.',
      'Marathi': 'आताची परिस्थिती दर्शवणारा फोटो घ्या.',
      'Gujarati': 'અત્યારની સ્થિતિનો ફોટો લો.',
      'Kannada': 'ಈಗ ಹೇಗಿದೆ ಎಂಬುದರ ਫೋಟೋ ತೆಗೆದುಕೊಳ್ಳಿ.',
      'Malayalam': 'ഇപ്പോഴത്തെ അവസ്ഥയുടെ ফোটো எடுக்கவும்.',
      'Punjabi': 'ਹੁਣ ਦੀ ਸਥਿਤੀ ਦੀ ਇੱਕ ਫੋਟੋ ਲਓ।',
      'Hebrew': 'צלם תמונה של המצב כעת.',
    },
    'action_in_progress': {
      'English': 'Complete the activity.',
      'Hindi': 'गतिविधि को पूरा करें।',
      'Bengali': 'কাজটি সম্পন্ন করুন।',
      'Tamil': 'செயலை முடித்துவிடுங்கள்.',
      'Telugu': 'కార్యక్రమాన్ని పూర్తి చేయండి.',
      'Marathi': 'कृती पूर्ण करा.',
      'Gujarati': 'પ્રવૃત્તિ પૂર્ણ કરો.',
      'Kannada': 'ಚಟುವטಿಕೆಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ.',
      'Malayalam': 'പ്രവർത്തി പൂർത്തിയാക്കുക.',
      'Punjabi': 'ਗਤੀਵਿਧੀ ਪੂਰੀ ਕਰੋ।',
      'Hebrew': 'השלם את הפעילות.',
    },
    'after_proof': {
      'English': 'Take a photo showing what changed.',
      'Hindi': 'क्या बदलाव आया है, उसकी एक फोटो लें।',
      'Bengali': 'কি পরিবর্তন হয়েছে তার একটি ছবি তুলুন।',
      'Tamil': 'என்ன மாற்றம் ஏற்பட்டது என்பதைக் காட்டும் படம் எடுக்கவும்.',
      'Telugu': 'ఏ మార్పు వచ్చిందో చూపే ఫోటో తీయండి.',
      'Marathi': 'काय बदल झाला आहे हे दर्शवणारा फोटो घ्या.',
      'Gujarati': 'શું બદલાવ આવ્યો છે તેનો ફોટો લો.',
      'Kannada': 'ಏನು ಬದಲಾವಣೆ ಆಗಿದೆ ಎಂಬುದರ ಫೋಟೋ ತೆಗೆದುಕೊಳ್ಳಿ.',
      'Malayalam': 'എന്ത് മാറ്റമാണ് ഉണ്ടായതെന്ന് കാണിക്കുന്ന ഫോട്ടോ എടുക്കുക.',
      'Punjabi': 'ਕੀ ਬਦਲਾਅ ਆਇਆ ਹੈ, ਉਸਦੀ ਇੱਕ ਫੋਟੋ ਲਓ।',
      'Hebrew': 'צלם תמונה שמראה מה השתנה.',
    },
    'my_wish': {
      'English': 'My Wish.',
      'Hindi': 'मेरी इच्छा।',
      'Bengali': 'আমার ইচ্ছে।',
      'Tamil': 'என் ஆசை.',
      'Telugu': 'నా కోరిక.',
      'Marathi': 'माझी इच्छा.',
      'Gujarati': 'મારી ઈચ્છા.',
      'Kannada': 'ನನ್ನ ಆಸೆ.',
      'Malayalam': 'എന്റെ ആഗ്രഹം.',
      'Punjabi': 'ਮੇਰੀ ਇੱਛא।',
      'Hebrew': 'המשאלה שלי.',
    },
    'help_someone': {
      'English': 'Help someone else\'s wish.',
      'Hindi': 'किसी और की इच्छा पूरी करने में मदद करें।',
      'Bengali': 'অন্য কারোর ইচ্ছেপূরণে সাহায্য করুন।',
      'Tamil': 'மற்றொருவரின் ஆசைக்கு உதவுங்கள்.',
      'Telugu': 'ఇతרוల కోరికకు సహాయం చేయండి.',
      'Marathi': 'दुसऱ्या कोणाच्या इच्छेला मदत करा.',
      'Gujarati': 'બીજા કોઈની ઈચ્છામાં મદદ કરો.',
      'Kannada': 'ಬೇರೆಯವರ ಆಸೆಗೆ ಸಹಾಯ ಮಾಡಿ.',
      'Malayalam': 'മറ്റൊരാളുടെ ആഗ്രഹത്തിന് സഹായിക്കുക.',
      'Punjabi': 'ਕਿਸੇ ਹੋਰ ਦੀ ਇੱਛਾ ਪੂਰੀ ਕਰਨ ਵਿੱਚ ਮਦਦ ਕਰੋ।',
      'Hebrew': 'עזור למשאלה של מישהו אחר.',
    },
    'verification': {
      'English': 'Submit evidence for verification.',
      'Hindi': 'सत्यापन के लिए प्रमाण भेजें।',
      'Bengali': 'যাচাইকরণের लिए प्रमाण भेजें।',
      'Tamil': 'சரிபார்ப்பתற்கான ஆதாரத்தை சமர்ப்பிக்கவும்.',
      'Telugu': 'ధృవీకరణ కొరకు ఆధారాన్ని సమర్పించండి.',
      'Marathi': 'פדताळणीसाठी पुरावा सादर करा.',
      'Gujarati': 'ચકાસણી માટે પુરાવા મોકલો.',
      'Kannada': 'ಪರಿಶೀಲನೆಗಾಗಿ ಪುರಾವೆಯನ್ನು ಸಲ್ಲಿಸಿ.',
      'Malayalam': 'സ്ഥിരീകരണത്തിനായി തെളിവ് സമർപ്പിക്കുക.',
      'Punjabi': 'ਤਸਦੀਕ ਲਈ ਸਬੂਤ ਭੇਜੋ।',
      'Hebrew': 'שלח ראיות לאימות.',
    },
    'feedback_like': {
      'English': '❤️ I LIKE THIS',
      'Hindi': '❤️ मुझे यह पसंद है',
      'Hebrew': '❤️ אהבתי את זה',
    },
    'feedback_dont_understand': {
      'English': '😕 I DON\'T UNDERSTAND',
      'Hindi': '😕 मुझे समझ नहीं आया',
      'Hebrew': '😕 לא הבנתי',
    },
    'feedback_broken': {
      'English': '🐛 SOMETHING IS WRONG',
      'Hindi': '🐛 कुछ गड़बड़ है',
      'Hebrew': '🐛 משהו לא בסדר',
    },
    'feedback_idea': {
      'English': '💡 I HAVE AN IDEA',
      'Hindi': '💡 मेरे पास एक विचार है',
      'Hebrew': '💡 יש לי רעיון',
    },
  };

  static String getTranslation(String key, {String defaultValue = ''}) {
    if (_translations.containsKey(key)) {
      return _translations[key]![currentLanguage] ?? _translations[key]!['English'] ?? defaultValue;
    }
    return defaultValue;
  }

  static void speak(String key, {String? directText, BuildContext? context}) {
    if (isMuted) return;

    String text = directText ?? '';
    if (key.isNotEmpty && _translations.containsKey(key)) {
      text = _translations[key]![currentLanguage] ?? _translations[key]!['English']!;
    }

    if (text.isEmpty) return;

    if (context != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🔊 "$text" ($currentLanguage)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF00B074),
        ),
      );
    }

    try {
      final utterance = js.context.callMethod('SpeechSynthesisUtterance', [text]);
      final utteranceObj = js.JsObject.fromBrowserObject(utterance);
      utteranceObj['lang'] = _langCodes[currentLanguage] ?? 'en-US';
      utteranceObj['rate'] = 0.95;
      js.context.callMethod(['speechSynthesis', 'speak'], [utteranceObj]);
    } catch (e) {
      debugPrint('Web Speech Synthesis Exception: $e');
    }
  }
}
