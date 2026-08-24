import 'karma_category.dart';

enum FrequencyLimit {
  daily('Once Daily'),
  weekly('Once Weekly'),
  monthly('Once Monthly'),
  yearly('Once Yearly'),
  onceLifetime('Once per Lifetime'),
  unlimited('Unlimited');

  final String label;
  const FrequencyLimit(this.label);
}

enum VerificationMethod {
  standard('Standard Verification (Text/Witness)'),
  imageRequired('Photo/Image Proof Required'),
  gpsAndImage('GPS Location & Image Required'),
  securePrivate('Confidential/Secure Verification');

  final String label;
  const VerificationMethod(this.label);
}

class KarmaActivity {
  final String id;
  final String title;
  final int tier;
  final KarmaCategory category;
  final int baseImpact;
  final String effortRating;
  final VerificationMethod verificationMethod;
  final FrequencyLimit frequencyLimit;

  const KarmaActivity({
    required this.id,
    required this.title,
    required this.tier,
    required this.category,
    required this.baseImpact,
    required this.effortRating,
    required this.verificationMethod,
    required this.frequencyLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tier': tier,
      'category': category.name,
      'baseImpact': baseImpact,
      'effortRating': effortRating,
      'verificationMethod': verificationMethod.name,
      'frequencyLimit': frequencyLimit.name,
    };
  }

  factory KarmaActivity.fromJson(Map<String, dynamic> json) {
    return KarmaActivity(
      id: json['id'],
      title: json['title'],
      tier: json['tier'],
      category: KarmaCategory.fromJson(json['category']),
      baseImpact: json['baseImpact'],
      effortRating: json['effortRating'],
      verificationMethod: VerificationMethod.values.firstWhere(
        (e) => e.name == json['verificationMethod'],
        orElse: () => VerificationMethod.standard,
      ),
      frequencyLimit: FrequencyLimit.values.firstWhere(
        (e) => e.name == json['frequencyLimit'],
        orElse: () => FrequencyLimit.unlimited,
      ),
    );
  }
}
