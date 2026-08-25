import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'nav_home': 'Home',
      'nav_do_good': 'Do Good',
      'nav_create': 'Create',
      'nav_wishes': 'Wishes',
      'nav_me': 'Me',
      'login_title': 'Karma Grid — Proof of Good',
      'login_subtitle': 'Do good. Prove it. Create impact. Make wishes possible.',
      'login_access': 'Access Passport',
      'login_create': 'Create Passport',
      'login_display_name': 'Display Name',
      'login_email': 'Email Address',
      'login_password': 'Password',
      'login_submit_access': 'Access Passport',
      'login_submit_create': 'Create Passport',
      'login_role_label': 'Account Role / Type',
      'role_individual': 'Individual 👤',
      'role_group': 'Community Group 👥',
      'role_school': 'Institution / School 🏫',
      'role_ngo': 'NGO / Impact Org 🤝',
      'role_corporate': 'Business / Corporate 🏢',
      'role_government': 'Government / Civic 🏛️',
      'role_partner': 'Impact Partner 🌐',
      'dash_welcome': 'Welcome back',
      'dash_metrics': 'Ecosystem metrics',
      'dash_karma': 'Karma',
      'dash_impact': 'Impact',
      'dash_trust': 'Trust Score',
      'dash_action_do': '🌱 DO GOOD',
      'dash_action_report': '🔎 REPORT',
      'dash_action_wish': '✨ MAKE WISH',
      'dash_opportunities': 'Opportunities nearby',
      'dash_ripples': 'Active Ripples',
      'dash_talk_mic': '🎙️ TALK TO KARMA',
      'dash_talk_desc': 'Tap and speak to ask what to do, or report garbage',
      'step_before': 'BEFORE 📸',
      'step_before_desc': 'Take a photo of how things are now.',
      'step_action': 'DO / FIX ⚡',
      'step_action_desc': 'Complete the activity.',
      'step_after': 'AFTER 📸',
      'step_after_desc': 'Take a photo showing what changed.',
      'step_verified': 'VERIFIED ✓',
      'step_verified_desc': 'AI screening is comparing the scenes.',
      'step_impact': 'IMPACT 🌍',
      'step_impact_desc': 'Verified impact is calculated.',
      'step_karma': 'KARMA ✨',
      'step_karma_desc': 'Karma credits successfully awarded.',
      'fb_title': 'Improve Karma Grid',
      'fb_easy': 'Was this step easy?',
      'fb_easy_yes': '👍 Easy',
      'fb_easy_ok': '😐 Okay',
      'fb_easy_no': '👎 Difficult',
      'fb_category': 'Feedback Category',
      'fb_voice_note': '🎙️ Record Voice Feedback',
      'fb_text_hint': 'Describe your experience...',
      'fb_submit': 'Submit Feedback',
      'rep_title': 'Report a Problem',
      'rep_category': 'Problem Category',
      'rep_evidence': 'Attach photo evidence',
      'rep_details': 'Details (text or speak)',
      'rep_submit': 'Submit Report',
      'wish_title': 'Wish Plan',
      'wish_category': 'Wish Category',
      'wish_milestones': 'Milestones',
      'wish_sponsor': 'Sponsor this wish',
      'wish_custom_help': 'Offer custom support / materials',
      'wish_retailer': 'Funds routed to verified retailer',
    },
    'hi': {
      'nav_home': 'होम',
      'nav_do_good': 'अच्छा काम',
      'nav_create': 'बनाएं',
      'nav_wishes': 'इच्छाएं',
      'nav_me': 'प्रोफ़ाइल',
      'login_title': 'कर्म ग्रिड — अच्छाई का प्रमाण',
      'login_subtitle': 'अच्छा करें। इसे साबित करें। प्रभाव बनाएं। इच्छाओं को पूरा करें।',
      'login_access': 'पासपोर्ट एक्सेस करें',
      'login_create': 'पासपोर्ट बनाएं',
      'login_display_name': 'नाम दिखाएं',
      'login_email': 'ईमेल पता',
      'login_password': 'पासवर्ड',
      'login_submit_access': 'पासपोर्ट एक्सेस करें',
      'login_submit_create': 'पासपोर्ट बनाएं',
      'login_role_label': 'खाता भूमिका / प्रकार',
      'role_individual': 'व्यक्तिगत 👤',
      'role_group': 'सामुदायिक समूह 👥',
      'role_school': 'संस्थान / स्कूल 🏫',
      'role_ngo': 'एनजीओ / सामाजिक संस्था 🤝',
      'role_corporate': 'व्यवसाय / कॉर्पोरेट 🏢',
      'role_government': 'सरकार / नागरिक निकाय 🏛️',
      'role_partner': 'प्रभाव भागीदार 🌐',
      'dash_welcome': 'स्वागत है',
      'dash_metrics': 'पारिस्थितिकी तंत्र मेट्रिक्स',
      'dash_karma': 'कर्म',
      'dash_impact': 'प्रभाव',
      'dash_trust': 'विश्वास स्कोर',
      'dash_action_do': '🌱 अच्छा करें',
      'dash_action_report': '🔎 रिपोर्ट करें',
      'dash_action_wish': '✨ इच्छा व्यक्त करें',
      'dash_opportunities': 'आस-पास के अवसर',
      'dash_ripples': 'सक्रिय तरंगें (Ripples)',
      'dash_talk_mic': '🎙️ कर्म से बात करें',
      'dash_talk_desc': 'क्या करना है, या कचरे की रिपोर्ट करने के लिए टैप करें और बोलें',
      'step_before': 'पहले 📸',
      'step_before_desc': 'अभी कैसी स्थिति है, उसकी एक फोटो लें।',
      'step_action': 'करें / सुधारें ⚡',
      'step_action_desc': 'गतिविधि को पूरा करें।',
      'step_after': 'बाद में 📸',
      'step_after_desc': 'क्या बदलाव आया है, उसकी एक फोटो लें।',
      'step_verified': 'सत्यापित ✓',
      'step_verified_desc': 'एआई स्क्रीनिंग दृश्यों की तुलना कर रही है।',
      'step_impact': 'प्रभाव 🌍',
      'step_impact_desc': 'सत्यापित प्रभाव की गणना की जाती है।',
      'step_karma': 'कर्म ✨',
      'step_karma_desc': 'कर्म क्रेडिट सफलतापूर्वक प्रदान किया गया।',
      'fb_title': 'कर्म ग्रिड में सुधार करें',
      'fb_easy': 'क्या यह कदम आसान था?',
      'fb_easy_yes': '👍 आसान',
      'fb_easy_ok': '😐 ठीक',
      'fb_easy_no': '👎 कठिन',
      'fb_category': 'फीडबैक श्रेणी',
      'fb_voice_note': '🎙️ वॉयस फीडबैक रिकॉर्ड करें',
      'fb_text_hint': 'अपना अनुभव बताएं...',
      'fb_submit': 'फीडबैक भेजें',
      'rep_title': 'समस्या की रिपोर्ट करें',
      'rep_category': 'समस्या श्रेणी',
      'rep_evidence': 'फोटो प्रमाण संलग्न करें',
      'rep_details': 'विवरण (लिखें या बोलें)',
      'rep_submit': 'रिपोर्ट सबमिट करें',
      'wish_title': 'इच्छा योजना',
      'wish_category': 'इच्छा श्रेणी',
      'wish_milestones': 'मील के पत्थर (Milestones)',
      'wish_sponsor': 'इस इच्छा को प्रायोजित करें',
      'wish_custom_help': 'कस्टम सहायता / सामग्री प्रदान करें',
      'wish_retailer': 'धन सत्यापित विक्रेता को भेजा गया',
    },
    'he': {
      'nav_home': 'בית',
      'nav_do_good': 'עשה טוב',
      'nav_create': 'יצירה',
      'nav_wishes': 'משאלות',
      'nav_me': 'אני',
      'login_title': 'קארמה גריד — הוכחה לטוב',
      'login_subtitle': 'עשה טוב. הוכח זאת. צור אימפקט. הגשם משאלות.',
      'login_access': 'כניסה לדרכון',
      'login_create': 'יצירת דרכון',
      'login_display_name': 'שם תצוגה',
      'login_email': 'כתובת אימייל',
      'login_password': 'סיסמה',
      'login_submit_access': 'כניסה לדרכון',
      'login_submit_create': 'יצירת דרכון',
      'login_role_label': 'תפקיד / סוג חשבון',
      'role_individual': 'אינדיבידואלי 👤',
      'role_group': 'קבוצה קהילתית 👥',
      'role_school': 'מוסד / בית ספר 🏫',
      'role_ngo': 'עמותה / ארגון אימפקט 🤝',
      'role_corporate': 'עסק / תאגיד 🏢',
      'role_government': 'ממשלה / עירוני 🏛️',
      'role_partner': 'שותף אימפקט 🌐',
      'dash_welcome': 'ברוך הבא',
      'dash_metrics': 'מדדי מערכת',
      'dash_karma': 'קארמה',
      'dash_impact': 'אימפקט',
      'dash_trust': 'מדד אמון',
      'dash_action_do': '🌱 עשה טוב',
      'dash_action_report': '🔎 דווח',
      'dash_action_wish': '✨ בקש משאלה',
      'dash_opportunities': 'הזדמנויות בקרבת מקום',
      'dash_ripples': 'קארמה ריפלס פעילים',
      'dash_talk_mic': '🎙️ דבר לקארמה',
      'dash_talk_desc': 'לחץ ודבר כדי לשאול מה לעשות, או לדווח על מפגע',
      'step_before': 'לפני 📸',
      'step_before_desc': 'צלם תמונה של המצב כעת.',
      'step_action': 'בצע / תקן ⚡',
      'step_action_desc': 'השלם את הפעילות.',
      'step_after': 'אחרי 📸',
      'step_after_desc': 'צלם תמונה שמראה מה השתנה.',
      'step_verified': 'מאומת ✓',
      'step_verified_desc': 'סריקת AI משווה בין התמונות.',
      'step_impact': 'אימפקט 🌍',
      'step_impact_desc': 'האימפקט המאומת מחושב.',
      'step_karma': 'קארמה ✨',
      'step_karma_desc': 'נקודות קארמה הוענקו בהצלחה.',
      'fb_title': 'שפר את קארמה גריד',
      'fb_easy': 'האם שלב זה היה קל?',
      'fb_easy_yes': '👍 קל',
      'fb_easy_ok': '😐 בסדר',
      'fb_easy_no': '👎 קשה',
      'fb_category': 'קטגוריית משוב',
      'fb_voice_note': '🎙️ הקלט משוב קולי',
      'fb_text_hint': 'תאר את החוויה שלך...',
      'fb_submit': 'שלח משוב',
      'rep_title': 'דווח על בעיה',
      'rep_category': 'קטגוריית בעיה',
      'rep_evidence': 'צרף תמונת הוכחה',
      'rep_details': 'פרטים (כתוב או דבר)',
      'rep_submit': 'שלח דיווח',
      'wish_title': 'תוכנית משאלה',
      'wish_category': 'קטגוריית משאלה',
      'wish_milestones': 'אבני דרך',
      'wish_sponsor': 'תן חסות למשאלה זו',
      'wish_custom_help': 'הצע תמיכה מותאמת אישית / חומרים',
      'wish_retailer': 'הכספים יועברו ישירות לספק מורשה',
    }
  };

  final String locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final activeLanguage = _resolveActiveLanguage(context);
    return AppLocalizations(activeLanguage);
  }

  static String _resolveActiveLanguage(BuildContext context) {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final pref = auth.currentUser?.preferredLanguage ?? auth.currentLanguage;
      return _mapLanguageToLocale(pref);
    } catch (_) {
      return 'en';
    }
  }

  static String _mapLanguageToLocale(String lang) {
    final lower = lang.toLowerCase();
    if (lower == 'hindi' || lower == 'hi') return 'hi';
    if (lower == 'hebrew' || lower == 'he') return 'he';
    return 'en';
  }

  String translate(String key, {String defaultValue = ''}) {
    final languageKey = _mapLanguageToLocale(locale);
    final map = _localizedValues[languageKey] ?? _localizedValues['en']!;
    return map[key] ?? defaultValue;
  }

  static String translateWithContext(BuildContext context, String key, {String defaultValue = ''}) {
    final activeLanguage = _resolveActiveLanguage(context);
    final map = _localizedValues[activeLanguage] ?? _localizedValues['en']!;
    return map[key] ?? defaultValue;
  }
}
