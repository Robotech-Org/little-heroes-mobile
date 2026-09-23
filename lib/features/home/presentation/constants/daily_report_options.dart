// class DailyReportOptions {
//   DailyReportOptions._(); // prevent instantiation

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
//   // Health & Hygiene
//   // ───────────────────────────────────────────────────────────
//   static const String healthGood = 'Good / Normal';
//   static const String healthPotty = 'Potty / Diaper Normal';
//   static const String healthMedication = 'Medication Administered';
//   static const String healthMinorSymptoms = 'Minor Symptoms (Runny nose/Cough)';
//   static const String healthNeedsMonitoring =
//       'Needs Monitoring / Parent Contact';

//   static const List<String> health = [
//     healthGood,
//     healthPotty,
//     healthMedication,
//     healthMinorSymptoms,
//     healthNeedsMonitoring,
//   ];

//   // ───────────────────────────────────────────────────────────
//   // Defaults
//   // ───────────────────────────────────────────────────────────
//   static const String defaultMeal = mealAteAll;
//   static const String defaultNap = napSleptWell;
//   static const String defaultMood = moodHappy;
//   static const String defaultHealth = healthGood;

//   // ───────────────────────────────────────────────────────────
//   // Legacy → New value mapping (for editing older reports)
//   // ───────────────────────────────────────────────────────────
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

//   static const Map<String, String> legacyHealthMap = {
//     'No Concerns': healthGood,
//     'Runny Nose': healthMinorSymptoms,
//     'Cough': healthMinorSymptoms,
//     'Fever': healthNeedsMonitoring,
//     'Good': healthGood,
//     'Normal': healthGood,
//   };
// }

class DailyReportOptions {
  DailyReportOptions._();

  // ═══════════════════════════════════════════════════════════
  // 1. DAILY ACTIVITIES & NOTES
  // ═══════════════════════════════════════════════════════════

  // ───────────────────────────────────────────────────────────
  // Meals & Snacks
  // ───────────────────────────────────────────────────────────
  static const String mealAteAll = 'Ate All';
  static const String mealAteMost = 'Ate Most';
  static const String mealAteSome = 'Ate Some';
  static const String mealAteVeryLittle = 'Ate Very Little';
  static const String mealRefused = 'Refused / Did Not Eat';
  static const String mealNotApplicable = 'Not Applicable';

  static const List<String> meals = [
    mealAteAll,
    mealAteMost,
    mealAteSome,
    mealAteVeryLittle,
    mealRefused,
    mealNotApplicable,
  ];

  // ───────────────────────────────────────────────────────────
  // Nap Time
  // ───────────────────────────────────────────────────────────
  static const String napSleptWell = 'Slept Well (1-2+ Hours)';
  static const String napShort = 'Short Nap (<1 Hour)';
  static const String napRestOnly = 'Rest Only (No Sleep)';
  static const String napDidNotSleep = 'Did Not Sleep';
  static const String napNotApplicable = 'Not Applicable';

  static const List<String> naps = [
    napSleptWell,
    napShort,
    napRestOnly,
    napDidNotSleep,
    napNotApplicable,
  ];

  // ───────────────────────────────────────────────────────────
  // Mood & Behavior
  // ───────────────────────────────────────────────────────────
  static const String moodHappy = 'Happy & Engaged';
  static const String moodCalm = 'Calm & Content';
  static const String moodEnergetic = 'Energetic & Playful';
  static const String moodFussy = 'Fussy / Crying';
  static const String moodTired = 'Tired / Sensitive';
  static const String moodChallenging = 'Challenging / Needed Support';

  static const List<String> moods = [
    moodHappy,
    moodCalm,
    moodEnergetic,
    moodFussy,
    moodTired,
    moodChallenging,
  ];

  // ───────────────────────────────────────────────────────────
  // Learning & Play Activities  👈 NEW
  // ───────────────────────────────────────────────────────────
  static const String activityStoryTime = 'Story Time';
  static const String activityMusicDance = 'Music & Dance';
  static const String activityArtCraft = 'Art & Craft';
  static const String activityOutdoorPlay = 'Outdoor Play';

  static const List<String> activities = [
    activityStoryTime,
    activityMusicDance,
    activityArtCraft,
    activityOutdoorPlay,
  ];

  // ═══════════════════════════════════════════════════════════
  // 2. HEALTH & HYGIENE
  // ═══════════════════════════════════════════════════════════

  // ───────────────────────────────────────────────────────────
  // Diaper Changes / Toilet Training  👈 NEW
  // ───────────────────────────────────────────────────────────
  static const String diaperNoIssues = 'No issues';
  static const String diaperFrequentChanges = 'Frequent Changes';
  static const String diaperPottyAccident = 'Potty accident';

  static const List<String> diaperOptions = [
    diaperNoIssues,
    diaperFrequentChanges,
    diaperPottyAccident,
  ];

  // ───────────────────────────────────────────────────────────
  // Health Check  👈 SIMPLIFIED to match the paper form
  // ───────────────────────────────────────────────────────────
  static const String healthNoConcerns = 'No Concerns';
  static const String healthRunnyNose = 'Runny nose';
  static const String healthCough = 'Cough';
  static const String healthFever = 'Fever';
  static const String healthRash = 'Rash';

  /// Replaces the old extended health list. Use this from now on.
  static const List<String> healthChecks = [
    healthNoConcerns,
    healthRunnyNose,
    healthCough,
    healthFever,
    healthRash,
  ];

  /// ⚠️ Deprecated — kept only for legacy file reads. Do not use in new UI.
  static const List<String> health = healthChecks;

  // ═══════════════════════════════════════════════════════════
  // 3. DEFAULTS
  // ═══════════════════════════════════════════════════════════
  static const String defaultMeal = mealAteAll;
  static const String defaultNap = napSleptWell;
  static const String defaultMood = moodHappy;
  static const String defaultHealth = healthNoConcerns;
  static const String defaultDiaper = diaperNoIssues;

  // ═══════════════════════════════════════════════════════════
  // 4. LEGACY → NEW VALUE MAPPING
  // ═══════════════════════════════════════════════════════════
  static const Map<String, String> legacyMealMap = {
    'Ate Well': mealAteAll,
    'Ate Most': mealAteMost,
    'Ate Some': mealAteSome,
    'Ate Very Little': mealAteVeryLittle,
    'Refused': mealRefused,
    'Not Applicable': mealNotApplicable,
  };

  static const Map<String, String> legacyNapMap = {
    'Slept Well': napSleptWell,
    'Short Nap': napShort,
    'Rest Only': napRestOnly,
    'Did Not Sleep': napDidNotSleep,
    'Not Applicable': napNotApplicable,
  };

  static const Map<String, String> legacyMoodMap = {
    'Happy': moodHappy,
    'Playful': moodEnergetic,
    'Quiet': moodCalm,
    'Fussy': moodFussy,
    'Tired': moodTired,
    'Challenging': moodChallenging,
  };

  /// Maps old extended health values (and legacy keys) onto the new ones.
  static const Map<String, String> legacyHealthMap = {
    'Good / Normal': healthNoConcerns,
    'No Concerns': healthNoConcerns,
    'Potty / Diaper Normal': healthNoConcerns,
    'Medication Administered': healthNoConcerns, // no direct match → default
    'Minor Symptoms (Runny nose/Cough)': healthRunnyNose,
    'Needs Monitoring / Parent Contact': healthFever,
    'Runny Nose': healthRunnyNose,
    'Cough': healthCough,
    'Fever': healthFever,
    'Rash': healthRash,
    'Good': healthNoConcerns,
    'Normal': healthNoConcerns,
  };
}
