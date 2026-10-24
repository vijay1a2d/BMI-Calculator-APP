// services/bmi_service.dart
// Centralised BMI, BMR, TDEE, water and healthy-weight calculations.
// All formulas live here — never duplicated in screens or widgets.

import '../models/bmi_record.dart';
import '../utils/constants.dart';

/// Immutable result object passed from CalculatorScreen to ResultScreen.
/// Also converts to BmiRecord for persistent storage.
class BmiResult {
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender;
  final String activityLevel;
  final double bmi;
  final String category;
  final double bmr;
  final double tdee;
  final double waterLiters;
  final double minHealthyWeightKg;
  final double maxHealthyWeightKg;

  const BmiResult({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.bmi,
    required this.category,
    required this.bmr,
    required this.tdee,
    required this.waterLiters,
    required this.minHealthyWeightKg,
    required this.maxHealthyWeightKg,
  });

  /// Converts this result to a BmiRecord for persistent storage.
  BmiRecord toRecord() => BmiRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        bmi: bmi,
        category: category,
        bmr: bmr,
        tdee: tdee,
        waterLiters: waterLiters,
      );
}

/// Provides all health calculations as pure static functions.
class BmiService {
  BmiService._();

  // ---------------------------------------------------------------------------
  // BMI
  // ---------------------------------------------------------------------------

  /// Standard BMI formula: weight(kg) / height(m)²
  static double calculateBmi(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// WHO adult BMI categories.
  static String getBmiCategory(double bmi) {
    if (bmi < BmiThresholds.underweightMax) return BmiCategories.underweight;
    if (bmi <= BmiThresholds.normalMax) return BmiCategories.normal;
    if (bmi <= BmiThresholds.overweightMax) return BmiCategories.overweight;
    return BmiCategories.obesity;
  }

  // ---------------------------------------------------------------------------
  // BMR — Mifflin-St Jeor equation
  // ---------------------------------------------------------------------------

  /// Male:   BMR = 10×weight + 6.25×height − 5×age + 5
  /// Female: BMR = 10×weight + 6.25×height − 5×age − 161
  static double calculateBmr(
      double weightKg, double heightCm, int age, String gender) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) return 0;
    final base = 10.0 * weightKg + 6.25 * heightCm - 5.0 * age;
    return gender == 'male' ? base + 5 : base - 161;
  }

  // ---------------------------------------------------------------------------
  // TDEE
  // ---------------------------------------------------------------------------

  /// Estimated total daily energy expenditure = BMR × activity multiplier.
  static double calculateTdee(double bmr, String activityLevel) {
    final multiplier =
        ActivityLevel.multipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  // ---------------------------------------------------------------------------
  // Water
  // ---------------------------------------------------------------------------

  /// General hydration estimate: ~32.5 ml per kg body weight.
  static double calculateWaterLiters(double weightKg) {
    if (weightKg <= 0) return 0;
    return (weightKg * HydrationConstants.mlPerKg) / 1000.0;
  }

  // ---------------------------------------------------------------------------
  // Healthy weight range (BMI 18.5–24.9)
  // ---------------------------------------------------------------------------

  static double calculateMinHealthyWeightKg(double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return HealthyBmi.minBmi * heightM * heightM;
  }

  static double calculateMaxHealthyWeightKg(double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return HealthyBmi.maxBmi * heightM * heightM;
  }

  // ---------------------------------------------------------------------------
  // Full calculation — single entry point used by CalculatorScreen
  // ---------------------------------------------------------------------------

  static BmiResult calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmi = calculateBmi(weightKg, heightCm);
    final category = getBmiCategory(bmi);
    final bmr = calculateBmr(weightKg, heightCm, age, gender);
    final tdee = calculateTdee(bmr, activityLevel);
    final waterLiters = calculateWaterLiters(weightKg);
    final minHealthy = calculateMinHealthyWeightKg(heightCm);
    final maxHealthy = calculateMaxHealthyWeightKg(heightCm);

    return BmiResult(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      bmi: bmi,
      category: category,
      bmr: bmr,
      tdee: tdee,
      waterLiters: waterLiters,
      minHealthyWeightKg: minHealthy,
      maxHealthyWeightKg: maxHealthy,
    );
  }
}
