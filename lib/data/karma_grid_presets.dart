import '../models/karma_activity.dart';
import '../models/karma_category.dart';

final List<KarmaActivity> karmaGridPresets = _rawPresets.map((m) {
  return KarmaActivity(
    id: m['id'] as String,
    title: m['title'] as String,
    tier: m['tier'] as int,
    category: m['category'] as KarmaCategory,
    baseImpact: m['baseImpact'] as int,
    effortRating: m['effort'] as String,
    verificationMethod: m['verification'] as VerificationMethod,
    frequencyLimit: m['frequency'] as FrequencyLimit,
  );
}).toList();

final List<Map<String, dynamic>> _rawPresets = [
  // TIER 1 — LIFE, HUMANITY & CIVILIZATION (35)
  {
    'id': 'act_001',
    'title': "Save a person's life during an emergency.",
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 100,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_002',
    'title': 'Donate a kidney or other eligible organ to save another person\'s life.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 100,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_003',
    'title': 'Become a registered organ donor.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_004',
    'title': 'Donate blood when medically eligible.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_005',
    'title': 'Donate platelets or plasma when eligible.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_006',
    'title': 'Learn CPR and emergency first aid.',
    'tier': 1,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_007',
    'title': 'Perform CPR during a cardiac emergency.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 95,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_008',
    'title': 'Help someone reach emergency medical care safely.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_009',
    'title': 'Rescue a person from immediate physical danger.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 90,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_010',
    'title': 'Prevent a suicide or serious self-harm incident by getting someone immediate help.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 95,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_011',
    'title': 'Rescue someone from drowning.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 90,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_012',
    'title': 'Rescue someone from a fire or dangerous accident when safely possible.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 90,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_013',
    'title': 'Provide first aid to an injured stranger.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 55,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_014',
    'title': 'Become a trained emergency responder.',
    'tier': 1,
    'category': KarmaCategory.education,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_015',
    'title': 'Volunteer regularly with emergency-response organizations.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_016',
    'title': 'Donate essential medical supplies to underserved communities.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_017',
    'title': 'Sponsor life-saving medical treatment for someone unable to afford it.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_018',
    'title': 'Help a vulnerable person obtain essential medication.',
    'tier': 1,
    'category': KarmaCategory.healthcare,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_019',
    'title': 'Arrange emergency shelter for a person facing immediate danger.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_020',
    'title': 'Protect a child from abuse or exploitation through appropriate authorities.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 90,
    'effort': 'Critical',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_021',
    'title': 'Report credible human trafficking to the appropriate authorities.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 90,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_022',
    'title': 'Help locate a missing vulnerable person through legitimate channels.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_023',
    'title': 'Help a domestic-violence survivor reach a safe place.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_024',
    'title': 'Help an elderly person in immediate danger.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_025',
    'title': 'Help a person with a disability safely navigate an emergency.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_026',
    'title': 'Become trained in disaster response.',
    'tier': 1,
    'category': KarmaCategory.education,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_027',
    'title': 'Volunteer during a natural disaster.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_028',
    'title': 'Help evacuate people during a disaster.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 90,
    'effort': 'Critical',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_029',
    'title': 'Provide food and clean water during an emergency.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_030',
    'title': 'Help rebuild a community after a disaster.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_031',
    'title': 'Donate to a verified disaster-relief effort.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_032',
    'title': 'Provide temporary accommodation to a displaced person.',
    'tier': 1,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_033',
    'title': 'Help a refugee or displaced person access legitimate services.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_034',
    'title': 'Translate essential emergency information for people who cannot understand it.',
    'tier': 1,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_035',
    'title': 'Develop or share a reliable emergency-resource guide.',
    'tier': 1,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },

  // TIER 2 — HEALTH & HUMAN WELL-BEING (35)
  {
    'id': 'act_036',
    'title': 'Provide free professional medical care to someone who cannot afford it.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_037',
    'title': 'Provide free mental-health support within your professional qualifications.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_038',
    'title': 'Volunteer at a hospital or hospice.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_039',
    'title': 'Volunteer at a palliative-care organization.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_040',
    'title': 'Help someone obtain necessary healthcare.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_041',
    'title': 'Help an elderly person attend a medical appointment.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_042',
    'title': 'Help a disabled person access healthcare.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_043',
    'title': 'Pay for essential medical treatment for someone in need.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_044',
    'title': 'Donate to a verified medical charity.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_045',
    'title': 'Organize a community health camp.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_046',
    'title': 'Organize a blood-donation drive.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_047',
    'title': 'Recruit verified blood donors for an urgent need.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_048',
    'title': 'Register as a bone-marrow donor where available.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 60,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_049',
    'title': 'Donate breast milk where medically appropriate and through a legitimate program.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_050',
    'title': 'Donate essential maternal-health supplies.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_051',
    'title': 'Support maternal healthcare in an underserved community.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_052',
    'title': 'Support neonatal healthcare.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_053',
    'title': 'Help provide vaccines through legitimate public-health programs.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_054',
    'title': 'Volunteer in public-health education.',
    'tier': 2,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_055',
    'title': 'Teach basic hygiene to an underserved community.',
    'tier': 2,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_056',
    'title': 'Help provide safe menstrual-hygiene products.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_057',
    'title': 'Help provide clean drinking water.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_058',
    'title': 'Help install or maintain a community water purification system.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_059',
    'title': 'Support sanitation infrastructure.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_060',
    'title': 'Help prevent disease through verified community-health work.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_061',
    'title': 'Help someone access addiction-recovery services.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_062',
    'title': 'Support a person recovering from addiction without enabling harmful behavior.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_063',
    'title': 'Visit and support isolated elderly people.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_064',
    'title': 'Regularly check on an elderly person who lives alone.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_065',
    'title': 'Help a disabled person with everyday tasks.',
    'tier': 2,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_066',
    'title': 'Teach someone basic first aid.',
    'tier': 2,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_067',
    'title': 'Teach someone how to recognize medical emergencies.',
    'tier': 2,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_068',
    'title': 'Donate mobility equipment to someone who needs it.',
    'tier': 2,
    'category': KarmaCategory.healthcare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_069',
    'title': 'Repair a wheelchair or mobility device for someone in need.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_070',
    'title': 'Make a public place more accessible to people with disabilities.',
    'tier': 2,
    'category': KarmaCategory.communityService,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },

  // TIER 3 — EDUCATION & HUMAN POTENTIAL (37)
  {
    'id': 'act_071',
    'title': 'Provide free education to a child who lacks access to it.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_072',
    'title': 'Sponsor a child\'s education.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.yearly
  },
  {
    'id': 'act_073',
    'title': 'Teach literacy to an adult who cannot read.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_074',
    'title': 'Teach someone a valuable professional skill for free.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_075',
    'title': 'Mentor a disadvantaged student.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_076',
    'title': 'Mentor a young person for at least six months.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_077',
    'title': 'Provide free career guidance to a student.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_078',
    'title': 'Help a student obtain a scholarship.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_079',
    'title': 'Donate books to an underserved school.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_080',
    'title': 'Build or support a community library.',
    'tier': 3,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_081',
    'title': 'Donate a computer to a student who needs one.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_082',
    'title': 'Donate educational equipment to a school.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_083',
    'title': 'Teach digital literacy.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_084',
    'title': 'Teach coding for free.',
    'tier': 3,
    'category': KarmaCategory.openSource,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_085',
    'title': 'Teach financial literacy.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_086',
    'title': 'Teach critical thinking.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_087',
    'title': 'Teach scientific reasoning.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_088',
    'title': 'Teach a language for free.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_089',
    'title': 'Teach practical vocational skills.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_090',
    'title': 'Help someone prepare for a job interview.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_091',
    'title': 'Help someone create their first professional résumé.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_092',
    'title': 'Help an unemployed person find legitimate employment.',
    'tier': 3,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_093',
    'title': 'Offer an internship to someone from an underserved background.',
    'tier': 3,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_094',
    'title': 'Provide free tutoring to a disadvantaged child.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_095',
    'title': 'Create free educational material.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_096',
    'title': 'Translate educational material into an underserved language.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_097',
    'title': 'Make educational content accessible to people with disabilities.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_098',
    'title': 'Record free educational lessons for public use.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_099',
    'title': 'Open-source an educational resource.',
    'tier': 3,
    'category': KarmaCategory.openSource,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_100',
    'title': 'Create a free course that can help thousands of people.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_101',
    'title': 'Donate educational software or licenses where permitted.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_102',
    'title': 'Help a school establish a science or technology program.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_103',
    'title': 'Support girls\' access to education.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_104',
    'title': 'Support education for children with disabilities.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_105',
    'title': 'Help prevent a child from dropping out of school.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_106',
    'title': 'Create a mentorship network for disadvantaged youth.',
    'tier': 3,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_107',
    'title': 'Help someone learn a skill that increases their earning potential.',
    'tier': 3,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },

  // TIER 4 — POVERTY, FOOD & BASIC NEEDS (27)
  {
    'id': 'act_108',
    'title': 'Provide a nutritious meal to someone experiencing hunger.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_109',
    'title': 'Regularly support a verified food-distribution program.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_110',
    'title': 'Donate surplus edible food safely.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_111',
    'title': 'Organize a community food drive.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_112',
    'title': 'Establish a community kitchen.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_113',
    'title': 'Volunteer at a community kitchen.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_114',
    'title': 'Provide clean drinking water to people in need.',
    'tier': 4,
    'category': KarmaCategory.healthcare,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_115',
    'title': 'Provide essential clothing to someone experiencing hardship.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_116',
    'title': 'Donate winter clothing to people facing extreme cold.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_117',
    'title': 'Donate essential hygiene products.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_118',
    'title': 'Provide diapers to a family experiencing hardship.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_119',
    'title': 'Provide school supplies to a child who needs them.',
    'tier': 4,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_120',
    'title': 'Help a homeless person access shelter services.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_121',
    'title': 'Help a homeless person obtain identification documents through legal channels.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_122',
    'title': 'Help someone experiencing homelessness access employment services.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_123',
    'title': 'Support a verified homeless shelter.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_124',
    'title': 'Provide temporary accommodation through a safe, legitimate program.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_125',
    'title': 'Help a family avoid eviction through verified assistance.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_126',
    'title': 'Help someone obtain government benefits they legitimately qualify for.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_127',
    'title': 'Help someone navigate public-service systems.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_128',
    'title': 'Donate essential household items to a family in need.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_129',
    'title': 'Repair essential household equipment for someone who cannot afford replacement.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_130',
    'title': 'Donate a working phone to someone who needs one.',
    'tier': 4,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_131',
    'title': 'Provide internet access for a student who lacks it.',
    'tier': 4,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_132',
    'title': 'Create a community resource-sharing program.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_133',
    'title': 'Give away useful items instead of throwing them away.',
    'tier': 4,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_134',
    'title': 'Organize a community free-exchange event.',
    'tier': 4,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },

  // TIER 5 — ENVIRONMENT & CLIMATE (57)
  {
    'id': 'act_135',
    'title': 'Restore a degraded ecosystem.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_136',
    'title': 'Protect a threatened natural habitat.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_137',
    'title': 'Restore a wetland.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_138',
    'title': 'Restore a mangrove ecosystem.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_139',
    'title': 'Restore native forests using appropriate local species.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_140',
    'title': 'Plant native trees where ecologically appropriate.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_141',
    'title': 'Care for newly planted trees until established.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_142',
    'title': 'Remove invasive plant species responsibly.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_143',
    'title': 'Restore native grasslands.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_144',
    'title': 'Protect a local waterway.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_145',
    'title': 'Organize a river cleanup.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_146',
    'title': 'Organize a lake cleanup.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_147',
    'title': 'Organize a beach cleanup.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_148',
    'title': 'Remove plastic pollution from a natural ecosystem.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_149',
    'title': 'Remove abandoned fishing gear where safely possible.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 55,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_150',
    'title': 'Participate in wildlife-habitat restoration.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_151',
    'title': 'Create or maintain pollinator habitat.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_152',
    'title': 'Plant native flowers for pollinators.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_153',
    'title': 'Protect nesting areas for birds.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_154',
    'title': 'Create safe urban habitat for wildlife.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_155',
    'title': 'Build or install appropriate bird shelters.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_156',
    'title': 'Provide safe water sources for wildlife during extreme heat where appropriate.',
    'tier': 5,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_157',
    'title': 'Help protect endangered species through a verified organization.',
    'tier': 5,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_158',
    'title': 'Support wildlife rehabilitation.',
    'tier': 5,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_159',
    'title': 'Volunteer at a wildlife rescue center.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_160',
    'title': 'Report illegal wildlife exploitation to appropriate authorities.',
    'tier': 5,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 60,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_161',
    'title': 'Help prevent illegal dumping.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_162',
    'title': 'Organize a neighborhood waste-segregation program.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_163',
    'title': 'Establish community composting.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_164',
    'title': 'Compost organic waste instead of sending it to landfill.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_165',
    'title': 'Recycle difficult-to-process materials through authorized facilities.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_166',
    'title': 'Safely dispose of electronic waste.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_167',
    'title': 'Help a community establish an e-waste collection point.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_168',
    'title': 'Repair electronics instead of replacing them.',
    'tier': 5,
    'category': KarmaCategory.openSource,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_169',
    'title': 'Repair furniture instead of discarding it.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_170',
    'title': 'Reuse materials creatively instead of purchasing new ones.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_171',
    'title': 'Reduce unnecessary single-use plastic consumption.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_172',
    'title': 'Organize a reusable-container campaign.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_173',
    'title': 'Help businesses reduce packaging waste.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_174',
    'title': 'Help a community reduce food waste.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_175',
    'title': 'Rescue surplus food before it becomes waste.',
    'tier': 5,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_176',
    'title': 'Use public transportation instead of unnecessary private-car travel.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_177',
    'title': 'Walk or cycle for a trip that would otherwise require a vehicle.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_178',
    'title': 'Organize a community cycling initiative.',
    'tier': 5,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_179',
    'title': 'Help someone switch to renewable energy where practical.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_180',
    'title': 'Install or support community solar projects.',
    'tier': 5,
    'category': KarmaCategory.innovation,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_181',
    'title': 'Improve energy efficiency in a building.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_182',
    'title': 'Help a household reduce electricity consumption.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_183',
    'title': 'Reduce unnecessary water consumption.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 25,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_184',
    'title': 'Repair a leaking water system.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_185',
    'title': 'Install water-saving equipment.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_186',
    'title': 'Harvest rainwater where legal and environmentally appropriate.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_187',
    'title': 'Help restore groundwater-recharge areas.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_188',
    'title': 'Protect a local spring or natural water source.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_189',
    'title': 'Participate in citizen-science environmental monitoring.',
    'tier': 5,
    'category': KarmaCategory.openSource,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_190',
    'title': 'Avoid buying brand new plastic objects.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 20,
    'effort': 'Low',
    'frequency': FrequencyLimit.daily,
    'verification': VerificationMethod.imageRequired
  },
  {
    'id': 'act_191',
    'title': 'Conduct minor ecosystem check-up audit in local area.',
    'tier': 5,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'frequency': FrequencyLimit.weekly,
    'verification': VerificationMethod.gpsAndImage
  },

  // TIER 6 — ANIMAL WELFARE (30)
  {
    'id': 'act_192',
    'title': 'Rescue an animal from immediate danger.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_193',
    'title': 'Take an injured animal to a qualified veterinarian or rescue organization.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_194',
    'title': 'Sponsor treatment for an injured stray animal.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_195',
    'title': 'Adopt an abandoned animal responsibly.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.onceLifetime
  },
  {
    'id': 'act_196',
    'title': 'Foster an abandoned animal until adoption.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_197',
    'title': 'Help reunite a lost pet with its owner.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_198',
    'title': 'Support an animal shelter.',
    'tier': 6,
    'category': KarmaCategory.communityService,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_199',
    'title': 'Volunteer at an animal shelter.',
    'tier': 6,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_200',
    'title': 'Provide food responsibly to animals in need.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_201',
    'title': 'Provide clean drinking water for animals during extreme heat.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_202',
    'title': 'Help sterilization programs for stray animals.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_203',
    'title': 'Support responsible vaccination programs for community animals.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_204',
    'title': 'Report animal cruelty to appropriate authorities.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 55,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_205',
    'title': 'Help prevent illegal animal trafficking.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_206',
    'title': 'Help rescue animals from unsafe conditions.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_207',
    'title': 'Create safe temporary shelter for vulnerable animals.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_208',
    'title': 'Build appropriate nesting boxes for birds.',
    'tier': 6,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_209',
    'title': 'Protect bird nests from avoidable disturbance.',
    'tier': 6,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_210',
    'title': 'Remove dangerous plastic or waste from an area used by animals.',
    'tier': 6,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_211',
    'title': 'Help an injured bird reach a wildlife rehabilitator.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_212',
    'title': 'Support marine-animal rescue.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_213',
    'title': 'Volunteer for wildlife rehabilitation.',
    'tier': 6,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_214',
    'title': 'Support ethical animal welfare organizations.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_215',
    'title': 'Educate others about responsible pet ownership.',
    'tier': 6,
    'category': KarmaCategory.education,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_216',
    'title': 'Help someone afford essential veterinary care.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_217',
    'title': 'Prevent abandonment of a pet by helping its owner find a responsible solution.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_218',
    'title': 'Help reduce human-wildlife conflict.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_219',
    'title': 'Protect wildlife crossings or report dangerous road areas.',
    'tier': 6,
    'category': KarmaCategory.environment,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_220',
    'title': 'Create a wildlife-friendly garden.',
    'tier': 6,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_221',
    'title': 'Never purchase products derived from illegally exploited wildlife.',
    'tier': 6,
    'category': KarmaCategory.animalWelfare,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },

  // TIER 7 — COMMUNITY SERVICE (30)
  {
    'id': 'act_222',
    'title': 'Volunteer regularly in your local community.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_223',
    'title': 'Clean a neglected public space.',
    'tier': 7,
    'category': KarmaCategory.environment,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_224',
    'title': 'Repair damaged community infrastructure where legally permitted.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_225',
    'title': 'Paint or restore a neglected community facility with permission.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_226',
    'title': 'Organize a neighborhood cleanup.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_227',
    'title': 'Help maintain a public garden.',
    'tier': 7,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_228',
    'title': 'Help maintain a community park.',
    'tier': 7,
    'category': KarmaCategory.environment,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_229',
    'title': 'Plant and maintain trees in public spaces with permission.',
    'tier': 7,
    'category': KarmaCategory.environment,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_230',
    'title': 'Help elderly neighbors with essential errands.',
    'tier': 7,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_231',
    'title': 'Help a neighbor during an emergency.',
    'tier': 7,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_232',
    'title': 'Check on vulnerable neighbors during extreme weather.',
    'tier': 7,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_233',
    'title': 'Organize a community emergency-preparedness program.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_234',
    'title': 'Create a local emergency contact network.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_235',
    'title': 'Organize a community recycling drive.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_236',
    'title': 'Organize a community donation drive.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_237',
    'title': 'Organize a community blood drive.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_238',
    'title': 'Organize a community health-awareness event.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_239',
    'title': 'Organize a free skills-sharing event.',
    'tier': 7,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_240',
    'title': 'Organize a community educational workshop.',
    'tier': 7,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_241',
    'title': 'Create a free community library.',
    'tier': 7,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_242',
    'title': 'Donate time to a local school.',
    'tier': 7,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_243',
    'title': 'Mentor young people in your neighborhood.',
    'tier': 7,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_244',
    'title': 'Help newcomers integrate into the community.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_245',
    'title': 'Translate important community information.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_246',
    'title': 'Help someone navigate a public service.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_247',
    'title': 'Help resolve a community problem peacefully.',
    'tier': 7,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_248',
    'title': 'Bring together different groups to work on a common project.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_249',
    'title': 'Organize an intergenerational community activity.',
    'tier': 7,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_250',
    'title': 'Create a community tool-sharing program.',
    'tier': 7,
    'category': KarmaCategory.openSource,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_251',
    'title': 'Create a community resource-sharing network.',
    'tier': 7,
    'category': KarmaCategory.openSource,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },

  // TIER 8 — PEACE, KINDNESS & SOCIAL COHESION (25)
  {
    'id': 'act_252',
    'title': 'Mediate a conflict peacefully when qualified and appropriate.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_253',
    'title': 'Help two people resolve a disagreement respectfully.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_254',
    'title': 'Prevent bullying by intervening safely or reporting it.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_255',
    'title': 'Support someone experiencing bullying.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_256',
    'title': 'Stand up safely against discrimination.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_257',
    'title': 'Help someone being harassed reach safety.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_258',
    'title': 'Welcome someone who is isolated into a community.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_259',
    'title': 'Befriend someone who is socially isolated.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_260',
    'title': 'Visit someone who has no regular visitors.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_261',
    'title': 'Listen attentively to someone going through a difficult time.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_262',
    'title': 'Offer practical help to someone experiencing hardship.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_263',
    'title': 'Give sincere appreciation to someone whose work is often overlooked.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_264',
    'title': 'Publicly recognize a person\'s positive contribution.',
    'tier': 8,
    'category': KarmaCategory.communityService,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_265',
    'title': 'Help repair a damaged relationship through respectful communication.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_266',
    'title': 'Apologize sincerely when you have caused harm.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_267',
    'title': 'Forgive someone when doing so is healthy and appropriate.',
    'tier': 8,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_268',
    'title': 'Refuse to spread unverified harmful information.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_269',
    'title': 'Correct misinformation when you can provide reliable evidence.',
    'tier': 8,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_270',
    'title': 'Report dangerous misinformation on a platform.',
    'tier': 8,
    'category': KarmaCategory.communityService,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_271',
    'title': 'Share reliable information during a crisis.',
    'tier': 8,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_272',
    'title': 'Help people from opposing groups collaborate on a constructive project.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_273',
    'title': 'Organize a dialogue between communities.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_274',
    'title': 'Participate in peace-building initiatives.',
    'tier': 8,
    'category': KarmaCategory.peaceBuilding,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_275',
    'title': 'Support nonviolent conflict-resolution education.',
    'tier': 8,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_276',
    'title': 'Learn how to communicate across cultural differences.',
    'tier': 8,
    'category': KarmaCategory.education,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.onceLifetime
  },

  // TIER 9 — CIVIC RESPONSIBILITY (25)
  {
    'id': 'act_277',
    'title': 'Report a dangerous public hazard through the proper civic channel.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_278',
    'title': 'Report a broken streetlight.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 25,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_279',
    'title': 'Report an unsafe road condition.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_280',
    'title': 'Report an overflowing waste site.',
    'tier': 9,
    'category': KarmaCategory.environment,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_281',
    'title': 'Report a dangerous open electrical installation.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_282',
    'title': 'Report a blocked emergency route.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_283',
    'title': 'Help keep public spaces clean.',
    'tier': 9,
    'category': KarmaCategory.environment,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_284',
    'title': 'Participate in a legitimate civic-improvement project.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_285',
    'title': 'Help elderly or disabled citizens access civic services.',
    'tier': 9,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_286',
    'title': 'Help someone obtain legitimate identity or civic documents.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_287',
    'title': 'Educate people about lawful civic processes.',
    'tier': 9,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_288',
    'title': 'Participate constructively in local community meetings.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_289',
    'title': 'Volunteer for legitimate election-awareness or voter-education programs.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_290',
    'title': 'Help someone understand publicly available government information.',
    'tier': 9,
    'category': KarmaCategory.education,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_291',
    'title': 'Contribute useful information to an open civic-data project.',
    'tier': 9,
    'category': KarmaCategory.openSource,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_292',
    'title': 'Participate in citizen-science projects.',
    'tier': 9,
    'category': KarmaCategory.openSource,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_293',
    'title': 'Report environmental violations through legitimate channels.',
    'tier': 9,
    'category': KarmaCategory.environment,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_294',
    'title': 'Help document accessibility problems in public spaces.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_295',
    'title': 'Propose a practical improvement to a public system.',
    'tier': 9,
    'category': KarmaCategory.innovation,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_296',
    'title': 'Help test a civic service and provide constructive feedback.',
    'tier': 9,
    'category': KarmaCategory.innovation,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_297',
    'title': 'Create an open-source tool that improves civic access.',
    'tier': 9,
    'category': KarmaCategory.openSource,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_298',
    'title': 'Help a nonprofit improve its operational efficiency.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_299',
    'title': 'Volunteer professional expertise to a nonprofit.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_300',
    'title': 'Help a local organization become more transparent.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_301',
    'title': 'Help a community organization measure its social impact.',
    'tier': 9,
    'category': KarmaCategory.communityService,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },

  // TIER 10 — INNOVATION & SYSTEM IMPROVEMENT (25)
  {
    'id': 'act_302',
    'title': 'Invent or develop a solution to a major social problem.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 95,
    'effort': 'Critical',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_303',
    'title': 'Develop an affordable technology that improves access to essential services.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 90,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_304',
    'title': 'Create an open-source solution for a humanitarian problem.',
    'tier': 10,
    'category': KarmaCategory.openSource,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_305',
    'title': 'Develop technology that improves accessibility for disabled people.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 85,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_306',
    'title': 'Develop a tool that helps prevent food waste.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_307',
    'title': 'Develop a tool that improves waste management.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_308',
    'title': 'Develop a tool that improves disaster response.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_309',
    'title': 'Develop a tool that improves access to education.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_310',
    'title': 'Develop a tool that improves healthcare access.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 75,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_311',
    'title': 'Develop a tool that helps protect wildlife.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_312',
    'title': 'Develop technology that reduces pollution.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 80,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_313',
    'title': 'Improve an existing system so it serves people more efficiently.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_314',
    'title': 'Identify a major community problem and develop a practical solution.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_315',
    'title': 'Share an invention openly when appropriate and safe.',
    'tier': 10,
    'category': KarmaCategory.openSource,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_316',
    'title': 'Publish useful research openly.',
    'tier': 10,
    'category': KarmaCategory.education,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_317',
    'title': 'Contribute meaningful code to an open-source humanitarian project.',
    'tier': 10,
    'category': KarmaCategory.openSource,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_318',
    'title': 'Fix a critical bug in an open-source public-interest project.',
    'tier': 10,
    'category': KarmaCategory.openSource,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_319',
    'title': 'Create free software for an NGO.',
    'tier': 10,
    'category': KarmaCategory.openSource,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_320',
    'title': 'Donate professional expertise to a social-impact project.',
    'tier': 10,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_321',
    'title': 'Help a local organization use technology more effectively.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_322',
    'title': 'Create a free database that helps people access useful information.',
    'tier': 10,
    'category': KarmaCategory.openSource,
    'baseImpact': 60,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_323',
    'title': 'Make public-interest information easier to understand.',
    'tier': 10,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_324',
    'title': 'Create an accessibility tool for people with disabilities.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_325',
    'title': 'Create a low-cost assistive device.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_326',
    'title': 'Improve an existing product to make it safer or more sustainable.',
    'tier': 10,
    'category': KarmaCategory.innovation,
    'baseImpact': 65,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },

  // TIER 11 — KNOWLEDGE & CULTURE (25)
  {
    'id': 'act_327',
    'title': 'Discover and responsibly document valuable knowledge.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_328',
    'title': 'Preserve endangered cultural knowledge with community consent.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 70,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_329',
    'title': 'Digitize historical material with permission.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_330',
    'title': 'Translate important knowledge into another language.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_331',
    'title': 'Create a free educational encyclopedia or knowledge resource.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 75,
    'effort': 'High',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_332',
    'title': 'Correct an important factual error in a public resource.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 30,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_333',
    'title': 'Contribute reliable information to an open knowledge project.',
    'tier': 11,
    'category': KarmaCategory.openSource,
    'baseImpact': 35,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_334',
    'title': 'Teach someone how to distinguish reliable sources from misinformation.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_335',
    'title': 'Preserve local oral histories with consent.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_336',
    'title': 'Document disappearing traditional crafts.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_337',
    'title': 'Support indigenous artists and cultural practitioners fairly.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 45,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_338',
    'title': 'Teach traditional skills to younger generations.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_339',
    'title': 'Create free educational material about cultural heritage.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_340',
    'title': 'Help preserve an endangered language.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 65,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_341',
    'title': 'Donate cultural or historical materials to an appropriate institution.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 55,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_342',
    'title': 'Organize a free public educational event.',
    'tier': 11,
    'category': KarmaCategory.communityService,
    'baseImpact': 60,
    'effort': 'High',
    'verification': VerificationMethod.gpsAndImage,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_343',
    'title': 'Give a free public lecture on your area of expertise.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.monthly
  },
  {
    'id': 'act_344',
    'title': 'Mentor an aspiring researcher.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_345',
    'title': 'Make your research data publicly available when ethically appropriate.',
    'tier': 11,
    'category': KarmaCategory.openSource,
    'baseImpact': 50,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_346',
    'title': 'Reproduce or verify important scientific findings.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 55,
    'effort': 'High',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_347',
    'title': 'Volunteer for legitimate scientific research.',
    'tier': 11,
    'category': KarmaCategory.communityService,
    'baseImpact': 40,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_348',
    'title': 'Participate in responsible citizen-science research.',
    'tier': 11,
    'category': KarmaCategory.openSource,
    'baseImpact': 45,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_349',
    'title': 'Teach scientific literacy to your community.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.weekly
  },
  {
    'id': 'act_350',
    'title': 'Help children develop curiosity and love of learning.',
    'tier': 11,
    'category': KarmaCategory.education,
    'baseImpact': 40,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_351',
    'title': 'Create something that inspires constructive curiosity about humanity and the world.',
    'tier': 11,
    'category': KarmaCategory.artsAndCulture,
    'baseImpact': 50,
    'effort': 'Medium',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },

  // TIER 12 — EVERYDAY POSITIVE ACTIONS (16)
  {
    'id': 'act_352',
    'title': 'Help a stranger carry something heavy.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_353',
    'title': 'Give your seat to someone who needs it more.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_354',
    'title': 'Help someone safely cross a difficult road.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_355',
    'title': 'Return a lost item to its owner.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 25,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_356',
    'title': 'Return money that someone accidentally lost.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 25,
    'effort': 'Low',
    'verification': VerificationMethod.securePrivate,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_357',
    'title': 'Pay for a stranger\'s essential meal.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_358',
    'title': 'Leave a useful item for someone who needs it.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_359',
    'title': 'Donate unused but useful possessions.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 25,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_360',
    'title': 'Give away a book you have finished to someone who wants it.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.unlimited
  },
  {
    'id': 'act_361',
    'title': 'Help someone learn something you know.',
    'tier': 12,
    'category': KarmaCategory.education,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_362',
    'title': 'Spend meaningful time with someone who feels lonely.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 25,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_363',
    'title': 'Thank a person whose work benefits you.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_364',
    'title': 'Give a genuine compliment without expecting anything in return.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_365',
    'title': 'Pick up litter you encounter in a public place.',
    'tier': 12,
    'category': KarmaCategory.environment,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.imageRequired,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_366',
    'title': 'Perform an unexpected helpful act for another person.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 15,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  },
  {
    'id': 'act_367',
    'title': 'Inspire another person to perform a verified act of good.',
    'tier': 12,
    'category': KarmaCategory.humanKindness,
    'baseImpact': 20,
    'effort': 'Low',
    'verification': VerificationMethod.standard,
    'frequency': FrequencyLimit.daily
  }
];
