import 'package:flutter/material.dart';

enum IndiaPillar {
  humanCapital('Human Capital', '🧠', Colors.blue, 'Education, skills, mentorship & drop-out prevention (30%)'),
  healthDignity('Health & Dignity', '❤️', Colors.red, 'Healthcare, blood, water, sanitation & CPR (20%)'),
  environment('Environment', '🌱', Colors.green, 'Waste, water, ecosystems, energy & forest conservation (20%)'),
  economicEmpowerment('Economic Empowerment', '💼', Colors.amber, 'Employment, livelihoods, job skills & internships (20%)'),
  civicSocial('Civic & Social Capital', '🏛️', Colors.purple, 'Governance, volunteering, public spaces & social cohesion (10%)');

  final String label;
  final String icon;
  final Color color;
  final String description;

  const IndiaPillar(this.label, this.icon, this.color, this.description);
}

class IndiaMissionPreset {
  final int rank;
  final String title;
  final IndiaPillar pillar;
  final String justification;
  final String activityPresetId;

  const IndiaMissionPreset({
    required this.rank,
    required this.title,
    required this.pillar,
    required this.justification,
    required this.activityPresetId,
  });
}

const List<IndiaMissionPreset> india30Presets = [
  IndiaMissionPreset(
    rank: 1,
    title: 'Mentor a disadvantaged student for 6+ months',
    pillar: IndiaPillar.humanCapital,
    justification: 'Builds human capital and breaks cycles of poverty',
    activityPresetId: 'act_076',
  ),
  IndiaMissionPreset(
    rank: 2,
    title: 'Teach literacy to an adult who cannot read',
    pillar: IndiaPillar.humanCapital,
    justification: 'Directly increases independence and opportunity',
    activityPresetId: 'act_073',
  ),
  IndiaMissionPreset(
    rank: 3,
    title: 'Help an unemployed person find legitimate employment',
    pillar: IndiaPillar.economicEmpowerment,
    justification: 'Converts support into sustainable income',
    activityPresetId: 'act_092',
  ),
  IndiaMissionPreset(
    rank: 4,
    title: 'Teach someone a valuable professional skill for free',
    pillar: IndiaPillar.economicEmpowerment,
    justification: 'Improves employability and earning capacity',
    activityPresetId: 'act_074',
  ),
  IndiaMissionPreset(
    rank: 5,
    title: 'Provide free education to a child who lacks access to it',
    pillar: IndiaPillar.humanCapital,
    justification: 'Long-term generational impact',
    activityPresetId: 'act_071',
  ),
  IndiaMissionPreset(
    rank: 6,
    title: 'Help prevent a child from dropping out of school',
    pillar: IndiaPillar.humanCapital,
    justification: "Protects India's future workforce",
    activityPresetId: 'act_105',
  ),
  IndiaMissionPreset(
    rank: 7,
    title: 'Teach digital literacy',
    pillar: IndiaPillar.humanCapital,
    justification: 'Essential for participation in the modern economy',
    activityPresetId: 'act_083',
  ),
  IndiaMissionPreset(
    rank: 8,
    title: 'Help someone obtain government benefits they legitimately qualify for',
    pillar: IndiaPillar.civicSocial,
    justification: 'Connects citizens with resources already available to them',
    activityPresetId: 'act_126',
  ),
  IndiaMissionPreset(
    rank: 9,
    title: 'Provide free career guidance to a student',
    pillar: IndiaPillar.humanCapital,
    justification: 'Helps young people make better education/career decisions',
    activityPresetId: 'act_077',
  ),
  IndiaMissionPreset(
    rank: 10,
    title: 'Offer an internship to someone from an underserved background',
    pillar: IndiaPillar.economicEmpowerment,
    justification: 'Bridges education and employment',
    activityPresetId: 'act_093',
  ),
  IndiaMissionPreset(
    rank: 11,
    title: 'Organize a community health camp',
    pillar: IndiaPillar.healthDignity,
    justification: 'Preventive healthcare can reach large populations',
    activityPresetId: 'act_045',
  ),
  IndiaMissionPreset(
    rank: 12,
    title: 'Donate blood when medically eligible',
    pillar: IndiaPillar.healthDignity,
    justification: 'Direct, measurable life-saving impact',
    activityPresetId: 'act_004',
  ),
  IndiaMissionPreset(
    rank: 13,
    title: 'Learn CPR and emergency first aid',
    pillar: IndiaPillar.healthDignity,
    justification: 'Creates a distributed emergency-response capability',
    activityPresetId: 'act_006',
  ),
  IndiaMissionPreset(
    rank: 14,
    title: 'Provide free professional medical care to someone who cannot afford it',
    pillar: IndiaPillar.healthDignity,
    justification: 'Directly improves health and productivity',
    activityPresetId: 'act_036',
  ),
  IndiaMissionPreset(
    rank: 15,
    title: 'Help provide clean drinking water',
    pillar: IndiaPillar.healthDignity,
    justification: 'Fundamental to health and dignity',
    activityPresetId: 'act_057',
  ),
  IndiaMissionPreset(
    rank: 16,
    title: 'Support sanitation infrastructure',
    pillar: IndiaPillar.healthDignity,
    justification: 'Major multiplier for public health',
    activityPresetId: 'act_059',
  ),
  IndiaMissionPreset(
    rank: 17,
    title: 'Organize a neighborhood waste-segregation program',
    pillar: IndiaPillar.environment,
    justification: 'Addresses a systemic urban/environmental problem',
    activityPresetId: 'act_162',
  ),
  IndiaMissionPreset(
    rank: 18,
    title: 'Establish community composting',
    pillar: IndiaPillar.environment,
    justification: 'Reduces waste while creating useful resources',
    activityPresetId: 'act_163',
  ),
  IndiaMissionPreset(
    rank: 19,
    title: 'Safely dispose of electronic waste',
    pillar: IndiaPillar.environment,
    justification: "Tackles India's rapidly growing e-waste problem",
    activityPresetId: 'act_166',
  ),
  IndiaMissionPreset(
    rank: 20,
    title: 'Protect a local waterway',
    pillar: IndiaPillar.environment,
    justification: 'Creates long-term environmental value',
    activityPresetId: 'act_144',
  ),
  IndiaMissionPreset(
    rank: 21,
    title: 'Restore native forests using appropriate local species',
    pillar: IndiaPillar.environment,
    justification: 'Biodiversity, soil, water and climate benefits',
    activityPresetId: 'act_139',
  ),
  IndiaMissionPreset(
    rank: 22,
    title: 'Reduce unnecessary water consumption',
    pillar: IndiaPillar.environment,
    justification: 'Water security is strategically important',
    activityPresetId: 'act_183',
  ),
  IndiaMissionPreset(
    rank: 23,
    title: 'Help someone switch to renewable energy where practical',
    pillar: IndiaPillar.environment,
    justification: 'Reduces costs and environmental impact',
    activityPresetId: 'act_179',
  ),
  IndiaMissionPreset(
    rank: 24,
    title: 'Clean a neglected public space',
    pillar: IndiaPillar.civicSocial,
    justification: 'Improves civic environment and community ownership',
    activityPresetId: 'act_223',
  ),
  IndiaMissionPreset(
    rank: 25,
    title: 'Report a dangerous public hazard through the proper civic channel',
    pillar: IndiaPillar.civicSocial,
    justification: 'Turns citizens into active participants in governance',
    activityPresetId: 'act_277',
  ),
  IndiaMissionPreset(
    rank: 26,
    title: 'Create an open-source solution for a humanitarian problem',
    pillar: IndiaPillar.civicSocial,
    justification: 'One solution can scale far beyond one individual',
    activityPresetId: 'act_304',
  ),
  IndiaMissionPreset(
    rank: 27,
    title: 'Volunteer professional expertise to a nonprofit',
    pillar: IndiaPillar.civicSocial,
    justification: 'Makes existing organizations substantially more effective',
    activityPresetId: 'act_299',
  ),
  IndiaMissionPreset(
    rank: 28,
    title: 'Help a nonprofit improve its operational efficiency',
    pillar: IndiaPillar.civicSocial,
    justification: "Strengthens India's grassroots infrastructure",
    activityPresetId: 'act_298',
  ),
  IndiaMissionPreset(
    rank: 29,
    title: 'Rescue surplus food before it becomes waste',
    pillar: IndiaPillar.environment,
    justification: 'Converts waste into nutrition',
    activityPresetId: 'act_175',
  ),
  IndiaMissionPreset(
    rank: 30,
    title: 'Bring together different groups to work on a common project',
    pillar: IndiaPillar.civicSocial,
    justification: 'Builds social cohesion and collective problem-solving',
    activityPresetId: 'act_248',
  ),
];
