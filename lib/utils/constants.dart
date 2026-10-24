// constants.dart — BMI+ centralized constants
// No formulas here — only named constants used across the app.

/// BMI category thresholds (standard WHO adult classification)
class BmiThresholds {
  BmiThresholds._();

  static const double underweightMax = 18.5;
  static const double normalMax = 24.9;
  static const double overweightMax = 29.9;
  // >= 30 is Obesity
}

/// Human-readable BMI category labels
class BmiCategories {
  BmiCategories._();

  static const String underweight = 'Underweight';
  static const String normal = 'Normal';
  static const String overweight = 'Overweight';
  static const String obesity = 'Obesity';
}

/// Activity level labels (UI display order matches multiplier order)
class ActivityLevel {
  ActivityLevel._();

  static const String sedentary = 'Sedentary';
  static const String lightlyActive = 'Lightly Active';
  static const String moderatelyActive = 'Moderately Active';
  static const String veryActive = 'Very Active';
  static const String extraActive = 'Extra Active';

  /// Mifflin-St Jeor TDEE activity multipliers
  static const Map<String, double> multipliers = {
    sedentary: 1.2,
    lightlyActive: 1.375,
    moderatelyActive: 1.55,
    veryActive: 1.725,
    extraActive: 1.9,
  };

  static const List<String> levels = [
    sedentary,
    lightlyActive,
    moderatelyActive,
    veryActive,
    extraActive,
  ];
}

/// BMI healthy range boundaries (BMI 18.5 – 24.9)
class HealthyBmi {
  HealthyBmi._();

  static const double minBmi = 18.5;
  static const double maxBmi = 24.9;
}

/// Hydration estimate constant (ml per kg body weight)
class HydrationConstants {
  HydrationConstants._();

  /// Mid-point of 30–35 ml/kg recommendation
  static const double mlPerKg = 32.5;
}

/// Validation limits — realistic human ranges
class ValidationLimits {
  ValidationLimits._();

  // Age
  static const int ageMin = 2;
  static const int ageMax = 120;

  // Weight in kg (internal)
  static const double weightKgMin = 10.0;
  static const double weightKgMax = 500.0;

  // Height in cm (internal)
  static const double heightCmMin = 50.0;
  static const double heightCmMax = 300.0;

  // Weight in lb (for display validation)
  static const double weightLbMin = 22.0;
  static const double weightLbMax = 1100.0;

  // Height in feet
  static const double heightFtMin = 1.6;
  static const double heightFtMax = 9.8;

  // Inches (0–11 only)
  static const int inchesMin = 0;
  static const int inchesMax = 11;
}

/// Unit labels
class UnitLabels {
  UnitLabels._();

  static const String kg = 'kg';
  static const String lb = 'lb';
  static const String cm = 'cm';
  static const String ft = 'ft';
  static const String inches = 'in';
  static const String liters = 'L';
  static const String kcal = 'kcal';
  static const String bmi = 'BMI';
}

/// SharedPreferences storage keys
class StorageKeys {
  StorageKeys._();

  /// Profile stored as a single JSON string
  static const String profileJson = 'profile_json';

  /// BMI history stored as a JSON array string
  static const String bmiHistoryJson = 'bmi_history_json';

  /// Theme preference: 'light' | 'dark' | 'system'
  static const String themeMode = 'theme_mode';

  /// Unit preference: true = metric, false = imperial
  static const String useMetric = 'use_metric';
}

/// App-wide string constants
class AppStrings {
  AppStrings._();

  static const String appName = 'BMI+';
  static const String appSubtitle = 'Smart Health & Fitness Analyzer';
  static const String appTagline = 'Understand your body. Track your progress.';

  static const String medicalDisclaimer =
      'BMI is a screening measure and does not directly measure body fat or '
      'diagnose health conditions. Results are for general informational '
      'purposes and should not replace advice from a qualified healthcare '
      'professional.';

  static const String hydrationDisclaimer =
      'Hydration needs vary depending on activity level, climate, age, and '
      'individual health conditions.';

  static const String calorieDisclaimer =
      'Estimated daily calorie needs are for general informational purposes only '
      'and are not medical or nutritional advice.';
}

/// Navigation tab indices
class NavIndex {
  NavIndex._();

  static const int home = 0;
  static const int calculator = 1;
  static const int progress = 2;
  static const int profile = 3;
}
