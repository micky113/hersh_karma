import 'package:flutter/material.dart';

enum KarmaCategory {
  environment('Environment', '🌱', Colors.green),
  animalWelfare('Animal Welfare', '🐕', Colors.orange),
  humanKindness('Human Kindness', '❤️', Colors.red),
  education('Education', '📚', Colors.blue),
  healthcare('Healthcare', '🩺', Colors.teal),
  innovation('Innovation', '🧠', Colors.purple),
  communityService('Community Service', '🏛', Colors.indigo),
  artsAndCulture('Arts & Culture', '🎨', Colors.pink),
  peaceBuilding('Peace Building', '🕊', Colors.lightBlue),
  openSource('Open Source', '💡', Colors.blueGrey);

  final String label;
  final String icon;
  final Color color;

  const KarmaCategory(this.label, this.icon, this.color);

  String toJson() => name;

  static KarmaCategory fromJson(String name) {
    return KarmaCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => KarmaCategory.humanKindness,
    );
  }
}
