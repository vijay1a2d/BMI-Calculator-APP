// test/bmi_service_test.dart
// Unit tests for BmiService — all core calculations tested.
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_plus/services/bmi_service.dart';
import 'package:bmi_plus/services/unit_service.dart';

void main() {
  // ─── BMI calculation ────────────────────────────────────────────────────────

  group('BmiService.calculateBmi', () {
    test('Normal BMI — 70 kg, 175 cm → ~22.9', () {
      final bmi = BmiService.calculateBmi(70, 175);
      expect(bmi, closeTo(22.86, 0.1));
    });

    test('Underweight — 45 kg, 175 cm → ~14.7', () {
      final bmi = BmiService.calculateBmi(45, 175);
      expect(bmi, closeTo(14.69, 0.1));
    });

    test('Overweight — 85 kg, 175 cm → ~27.8', () {
      final bmi = BmiService.calculateBmi(85, 175);
      expect(bmi, closeTo(27.76, 0.1));
    });

    test('Obesity — 110 kg, 175 cm → ~35.9', () {
      final bmi = BmiService.calculateBmi(110, 175);
      expect(bmi, closeTo(35.92, 0.1));
    });

    test('Zero height returns 0', () {
      expect(BmiService.calculateBmi(70, 0), equals(0));
    });

    test('Zero weight returns 0', () {
      expect(BmiService.calculateBmi(0, 175), equals(0));
    });
  });

  // ─── BMI category ───────────────────────────────────────────────────────────

  group('BmiService.getBmiCategory', () {
    test('BMI 17.5 → Underweight', () {
      expect(BmiService.getBmiCategory(17.5), equals('Underweight'));
    });

    test('BMI 18.5 → Normal (boundary)', () {
      expect(BmiService.getBmiCategory(18.5), equals('Normal'));
    });

    test('BMI 22.0 → Normal', () {
      expect(BmiService.getBmiCategory(22.0), equals('Normal'));
    });

    test('BMI 24.9 → Normal (boundary)', () {
      expect(BmiService.getBmiCategory(24.9), equals('Normal'));
    });

    test('BMI 25.0 → Overweight (boundary)', () {
      expect(BmiService.getBmiCategory(25.0), equals('Overweight'));
    });

    test('BMI 27.5 → Overweight', () {
      expect(BmiService.getBmiCategory(27.5), equals('Overweight'));
    });

    test('BMI 30.0 → Obesity (boundary)', () {
      expect(BmiService.getBmiCategory(30.0), equals('Obesity'));
    });

    test('BMI 35.0 → Obesity', () {
      expect(BmiService.getBmiCategory(35.0), equals('Obesity'));
    });
  });

  // ─── Healthy weight range ───────────────────────────────────────────────────

  group('BmiService healthy weight range', () {
    test('Min healthy weight for 175 cm → ~56.7 kg', () {
      final min = BmiService.calculateMinHealthyWeightKg(175);
      expect(min, closeTo(56.67, 0.1)); // 18.5 × 1.75²
    });

    test('Max healthy weight for 175 cm → ~76.3 kg', () {
      final max = BmiService.calculateMaxHealthyWeightKg(175);
      expect(max, closeTo(76.26, 0.1)); // 24.9 × 1.75²
    });

    test('Zero height returns 0', () {
      expect(BmiService.calculateMinHealthyWeightKg(0), equals(0));
      expect(BmiService.calculateMaxHealthyWeightKg(0), equals(0));
    });
  });

  // ─── BMR (Mifflin-St Jeor) ─────────────────────────────────────────────────

  group('BmiService.calculateBmr', () {
    test('Male 70 kg, 175 cm, 30 yr → ~1673.75', () {
      // 10×70 + 6.25×175 − 5×30 + 5 = 700 + 1093.75 − 150 + 5 = 1648.75
      final bmr = BmiService.calculateBmr(70, 175, 30, 'male');
      expect(bmr, closeTo(1648.75, 0.5));
    });

    test('Female 60 kg, 165 cm, 25 yr → ~1383.75', () {
      // 10×60 + 6.25×165 − 5×25 − 161 = 600 + 1031.25 − 125 − 161 = 1345.25
      final bmr = BmiService.calculateBmr(60, 165, 25, 'female');
      expect(bmr, closeTo(1345.25, 0.5));
    });

    test('Zero age returns 0', () {
      expect(BmiService.calculateBmr(70, 175, 0, 'male'), equals(0));
    });
  });

  // ─── TDEE ───────────────────────────────────────────────────────────────────

  group('BmiService.calculateTdee', () {
    test('Sedentary multiplier 1.2', () {
      final tdee = BmiService.calculateTdee(2000, 'Sedentary');
      expect(tdee, closeTo(2400, 1));
    });

    test('Lightly Active multiplier 1.375', () {
      final tdee = BmiService.calculateTdee(2000, 'Lightly Active');
      expect(tdee, closeTo(2750, 1));
    });

    test('Very Active multiplier 1.725', () {
      final tdee = BmiService.calculateTdee(2000, 'Very Active');
      expect(tdee, closeTo(3450, 1));
    });

    test('Unknown activity level defaults to 1.2', () {
      final tdee = BmiService.calculateTdee(2000, 'Unknown Level');
      expect(tdee, closeTo(2400, 1));
    });
  });

  // ─── Water intake ────────────────────────────────────────────────────────────

  group('BmiService.calculateWaterLiters', () {
    test('70 kg → ~2.275 L', () {
      final water = BmiService.calculateWaterLiters(70);
      expect(water, closeTo(2.275, 0.01)); // 70 × 32.5 / 1000
    });

    test('Zero weight returns 0', () {
      expect(BmiService.calculateWaterLiters(0), equals(0));
    });
  });

  // ─── Unit conversions ────────────────────────────────────────────────────────

  group('UnitService conversions', () {
    test('70 kg → ~154.3 lb', () {
      expect(UnitService.kgToLb(70), closeTo(154.32, 0.1));
    });

    test('154.32 lb → ~70 kg', () {
      expect(UnitService.lbToKg(154.32), closeTo(70.0, 0.1));
    });

    test('175 cm → 5 ft 9 in (approximately)', () {
      final (:feet, :inches) = UnitService.cmToFtIn(175);
      expect(feet, equals(5));
      expect(inches, equals(9)); // 175/2.54 ≈ 68.9 inches → 5ft 9in
    });

    test('5 ft 9 in → ~175.26 cm', () {
      final cm = UnitService.ftInToCm(5, 9);
      expect(cm, closeTo(175.26, 0.1));
    });

    test('Round-trip kg → lb → kg', () {
      const original = 85.5;
      final roundTrip = UnitService.lbToKg(UnitService.kgToLb(original));
      expect(roundTrip, closeTo(original, 0.01));
    });

    test('Round-trip cm → ft/in → cm', () {
      const original = 168.0;
      final (:feet, :inches) = UnitService.cmToFtIn(original);
      final roundTrip = UnitService.ftInToCm(feet.toDouble(), inches);
      expect(roundTrip, closeTo(original, 1.0)); // Within 1cm due to rounding
    });
  });

  // ─── Full calculate() integration ───────────────────────────────────────────

  group('BmiService.calculate', () {
    test('Returns correct BmiResult for known inputs', () {
      final result = BmiService.calculate(
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: 'male',
        activityLevel: 'Sedentary',
      );
      expect(result.bmi, closeTo(22.86, 0.1));
      expect(result.category, equals('Normal'));
      expect(result.bmr, closeTo(1648.75, 0.5));
      expect(result.tdee, closeTo(1648.75 * 1.2, 1));
      expect(result.waterLiters, closeTo(2.275, 0.01));
      expect(result.minHealthyWeightKg, closeTo(56.67, 0.1));
      expect(result.maxHealthyWeightKg, closeTo(76.26, 0.1));
    });

    test('toRecord() creates valid BmiRecord', () {
      final result = BmiService.calculate(
        weightKg: 70,
        heightCm: 175,
        age: 30,
        gender: 'male',
        activityLevel: 'Sedentary',
      );
      final record = result.toRecord();
      expect(record.weightKg, equals(70));
      expect(record.heightCm, equals(175));
      expect(record.bmi, closeTo(22.86, 0.1));
      expect(record.id, isNotEmpty);
      expect(record.dateTime, isA<DateTime>());
    });
  });
}
