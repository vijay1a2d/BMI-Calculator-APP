// utils/helpers.dart
// Formatting helpers used across screens and widgets.
// No business logic here — only display/formatting utilities.

import 'package:intl/intl.dart';

import 'constants.dart';
import '../services/unit_service.dart';

class Helpers {
  Helpers._();

  // ---------------------------------------------------------------------------
  // BMI
  // ---------------------------------------------------------------------------

  static String formatBmi(double bmi) => bmi.toStringAsFixed(1);

  // ---------------------------------------------------------------------------
  // Weight & height display
  // ---------------------------------------------------------------------------

  static String formatWeight(double kg, bool useMetric) {
    if (useMetric) {
      return '${kg.toStringAsFixed(1)} ${UnitLabels.kg}';
    }
    return '${UnitService.kgToLb(kg).toStringAsFixed(1)} ${UnitLabels.lb}';
  }

  static String formatHeight(double cm, bool useMetric) {
    if (useMetric) {
      return '${cm.toStringAsFixed(0)} ${UnitLabels.cm}';
    }
    final (:feet, :inches) = UnitService.cmToFtIn(cm);
    return '$feet${UnitLabels.ft} $inches${UnitLabels.inches}';
  }

  // ---------------------------------------------------------------------------
  // Health values
  // ---------------------------------------------------------------------------

  static String formatCalories(double kcal) =>
      '${kcal.toStringAsFixed(0)} ${UnitLabels.kcal}';

  static String formatWater(double liters) =>
      '${liters.toStringAsFixed(1)} ${UnitLabels.liters}';

  static String formatBmr(double bmr) => '${bmr.toStringAsFixed(0)} kcal/day';

  // ---------------------------------------------------------------------------
  // Dates
  // ---------------------------------------------------------------------------

  static String formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt);

  static String formatDateShort(DateTime dt) =>
      DateFormat('MMM d').format(dt);

  static String formatDateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy • h:mm a').format(dt);

  // ---------------------------------------------------------------------------
  // Greeting
  // ---------------------------------------------------------------------------

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  static String genderLabel(String gender) =>
      gender == 'male' ? 'Male' : 'Female';

  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
