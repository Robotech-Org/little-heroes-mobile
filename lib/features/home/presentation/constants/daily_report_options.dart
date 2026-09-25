// class DailyReportOptions {
//   DailyReportOptions._();

//   // ═══════════════════════════════════════════════════════════
//   // 1. DAILY ACTIVITIES & NOTES
//   // ═══════════════════════════════════════════════════════════

//   // ───────────────────────────────────────────────────────────
//   // Meals & Snacks
//   // ───────────────────────────────────────────────────────────
//   static const String mealAteAll = 'Ate All';
//   static const String mealAteMost = 'Ate Most';
//   static const String mealAteSome = 'Ate Some';
//   static const String mealAteVeryLittle = 'Ate Very Little';
//   static const String mealRefused = 'Refused / Did Not Eat';
//   static const String mealNotApplicable = 'Not Applicable';

//   static const List<String> meals = [
//     mealAteAll,
//     mealAteMost,
//     mealAteSome,
//     mealAteVeryLittle,
//     mealRefused,
//     mealNotApplicable,
//   ];

//   // ───────────────────────────────────────────────────────────
//   // Nap Time
//   // ───────────────────────────────────────────────────────────
//   static const String napSleptWell = 'Slept Well (1-2+ Hours)';
//   static const String napShort = 'Short Nap (<1 Hour)';
//   static const String napRestOnly = 'Rest Only (No Sleep)';
//   static const String napDidNotSleep = 'Did Not Sleep';
//   static const String napNotApplicable = 'Not Applicable';

//   static const List<String> naps = [
//     napSleptWell,
//     napShort,
//     napRestOnly,
//     napDidNotSleep,
//     napNotApplicable,
//   ];

//   // ───────────────────────────────────────────────────────────
//   // Mood & Behavior
//   // ───────────────────────────────────────────────────────────
//   static const String moodHappy = 'Happy & Engaged';
//   static const String moodCalm = 'Calm & Content';
//   static const String moodEnergetic = 'Energetic & Playful';
//   static const String moodFussy = 'Fussy / Crying';
//   static const String moodTired = 'Tired / Sensitive';
//   static const String moodChallenging = 'Challenging / Needed Support';

//   static const List<String> moods = [
//     moodHappy,
//     moodCalm,
//     moodEnergetic,
//     moodFussy,
//     moodTired,
//     moodChallenging,
//   ];

//   // ───────────────────────────────────────────────────────────
//   // Learning & Play Activities  👈 NEW
//   // ───────────────────────────────────────────────────────────
//   static const String activityStoryTime = 'Story Time';
//   static const String activityMusicDance = 'Music & Dance';
//   static const String activityArtCraft = 'Art & Craft';
//   static const String activityOutdoorPlay = 'Outdoor Play';

//   static const List<String> activities = [
//     activityStoryTime,
//     activityMusicDance,
//     activityArtCraft,
//     activityOutdoorPlay,
//   ];

//   // ═══════════════════════════════════════════════════════════
//   // 2. HEALTH & HYGIENE
//   // ═══════════════════════════════════════════════════════════

//   // ───────────────────────────────────────────────────────────
//   // Diaper Changes / Toilet Training  👈 NEW
//   // ───────────────────────────────────────────────────────────
//   static const String diaperNoIssues = 'No issues';
//   static const String diaperFrequentChanges = 'Frequent Changes';
//   static const String diaperPottyAccident = 'Potty accident';

//   static const List<String> diaperOptions = [
//     diaperNoIssues,
//     diaperFrequentChanges,
//     diaperPottyAccident,
//   ];

//   // ───────────────────────────────────────────────────────────
//   // Health Check  👈 SIMPLIFIED to match the paper form
//   // ───────────────────────────────────────────────────────────
//   static const String healthNoConcerns = 'No Concerns';
//   static const String healthRunnyNose = 'Runny nose';
//   static const String healthCough = 'Cough';
//   static const String healthFever = 'Fever';
//   static const String healthRash = 'Rash';

//   /// Replaces the old extended health list. Use this from now on.
//   static const List<String> healthChecks = [
//     healthNoConcerns,
//     healthRunnyNose,
//     healthCough,
//     healthFever,
//     healthRash,
//   ];

//   /// ⚠️ Deprecated — kept only for legacy file reads. Do not use in new UI.
//   static const List<String> health = healthChecks;

//   // ═══════════════════════════════════════════════════════════
//   // 3. DEFAULTS
//   // ═══════════════════════════════════════════════════════════
//   static const String defaultMeal = mealAteAll;
//   static const String defaultNap = napSleptWell;
//   static const String defaultMood = moodHappy;
//   static const String defaultHealth = healthNoConcerns;
//   static const String defaultDiaper = diaperNoIssues;

//   // ═══════════════════════════════════════════════════════════
//   // 4. LEGACY → NEW VALUE MAPPING
//   // ═══════════════════════════════════════════════════════════
//   static const Map<String, String> legacyMealMap = {
//     'Ate Well': mealAteAll,
//     'Ate Most': mealAteMost,
//     'Ate Some': mealAteSome,
//     'Ate Very Little': mealAteVeryLittle,
//     'Refused': mealRefused,
//     'Not Applicable': mealNotApplicable,
//   };

//   static const Map<String, String> legacyNapMap = {
//     'Slept Well': napSleptWell,
//     'Short Nap': napShort,
//     'Rest Only': napRestOnly,
//     'Did Not Sleep': napDidNotSleep,
//     'Not Applicable': napNotApplicable,
//   };

//   static const Map<String, String> legacyMoodMap = {
//     'Happy': moodHappy,
//     'Playful': moodEnergetic,
//     'Quiet': moodCalm,
//     'Fussy': moodFussy,
//     'Tired': moodTired,
//     'Challenging': moodChallenging,
//   };

//   /// Maps old extended health values (and legacy keys) onto the new ones.
//   static const Map<String, String> legacyHealthMap = {
//     'Good / Normal': healthNoConcerns,
//     'No Concerns': healthNoConcerns,
//     'Potty / Diaper Normal': healthNoConcerns,
//     'Medication Administered': healthNoConcerns, // no direct match → default
//     'Minor Symptoms (Runny nose/Cough)': healthRunnyNose,
//     'Needs Monitoring / Parent Contact': healthFever,
//     'Runny Nose': healthRunnyNose,
//     'Cough': healthCough,
//     'Fever': healthFever,
//     'Rash': healthRash,
//     'Good': healthNoConcerns,
//     'Normal': healthNoConcerns,
//   };
// }

class DailyReportOptions {
  DailyReportOptions._();

  // ── Meals ────────────────────────────────────────────
  static const List<String> meals = [
    'Ate Well',
    'Ate Some',
    'Refused food',
    'Ate All',
    'Ate Most',
    'Ate Very Little',
    'Refused / Did Not Eat',
    'Not Applicable',
  ];
  static const String defaultMeal = 'Ate All';

  static const Map<String, String> legacyMealMap = {
    'Ate Well': 'Ate All',
    'Ate Some': 'Ate Very Little',
    'Refused food': 'Refused / Did Not Eat',
  };

  // ── Nap ──────────────────────────────────────────────
  static const List<String> naps = [
    'Slept Well',
    'Short nap',
    'Did not Sleep',
    'Rest Only (No Sleep)',
    'Not Applicable',
    'Slept Well (1-2+ Hours)',
    'Short Nap (< 1 Hour)',
  ];
  static const String defaultNap = 'Slept Well (1-2+ Hours)';

  static const Map<String, String> legacyNapMap = {
    'Slept Well': 'Slept Well (1-2+ Hours)',
    'Short nap': 'Short Nap (< 1 Hour)',
    'Did not Sleep': 'Rest Only (No Sleep)',
  };

  // ── Mood ─────────────────────────────────────────────
  static const List<String> moods = [
    'Happy',
    'Playful',
    'Quiet',
    'Fussy',
    'Tired',
    'Happy & Engaged',
    'Calm & Content',
    'Energetic & Playful',
    'Fussy / Crying',
    'Tired / Sensitive',
    'Challenging / Needed Support',
  ];
  static const String defaultMood = 'Happy & Engaged';

  static const Map<String, String> legacyMoodMap = {
    'Happy': 'Happy & Engaged',
    'Playful': 'Energetic & Playful',
    'Quiet': 'Calm & Content',
    'Fussy': 'Fussy / Crying',
    'Tired': 'Tired / Sensitive',
  };

  // ── Health ───────────────────────────────────────────
  static const List<String> healthChecks = [
    'No Concerns',
    'Runny nose',
    'Cough',
    'Fever',
    'Rash',
    'Minor Symptoms (Runny nose/Cough)',
    'Needs Monitoring / Parent Contact',
    'Good / Normal',
    'Potty / Diaper Normal',
    'Medication Administered',
  ];
  static const String defaultHealth = 'Good / Normal';

  static const Map<String, String> legacyHealthMap = {
    'No Concerns': 'Good / Normal',
    'Good': 'Good / Normal',
    'Normal': 'Good / Normal',
    'Runny Nose': 'Minor Symptoms (Runny nose/Cough)',
    'Cough': 'Minor Symptoms (Runny nose/Cough)',
    'Fever': 'Needs Monitoring / Parent Contact',
  };

  // ── Learning & Play ──────────────────────────────────
  static const List<String> activities = [
    'Story Time',
    'Music & Dance',
    'Art & Craft',
    'Outdoor Play',
    'Multiple Activities',
    'Not Applicable',
  ];
  static const String defaultActivity = 'Not Applicable';

  // ── Diaper / Toilet ──────────────────────────────────
  static const List<String> diaperOptions = [
    'No issues',
    'Frequent Changes',
    'Potty accident',
    'Not Applicable',
  ];
  static const String defaultDiaper = 'No issues';
}
