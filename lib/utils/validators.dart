// validators.dart — BMI+ centralized input validation logic
// All validation functions return a String? (null = valid, non-null = error message).

import 'constants.dart';

class Validators {
  Validators._();

  // ---------------------------------------------------------------------------
  // Age
  // ---------------------------------------------------------------------------

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Age must be a whole number.';
    }
    if (parsed < ValidationLimits.ageMin) {
      return 'Age must be at least ${ValidationLimits.ageMin}.';
    }
    if (parsed > ValidationLimits.ageMax) {
      return 'Please enter a realistic age (max ${ValidationLimits.ageMax}).';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Weight
  // ---------------------------------------------------------------------------

  static String? weightKg(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your weight.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Weight must be a number.';
    }
    if (parsed < ValidationLimits.weightKgMin) {
      return 'Weight seems too low (min ${ValidationLimits.weightKgMin} kg).';
    }
    if (parsed > ValidationLimits.weightKgMax) {
      return 'Please enter a realistic weight (max ${ValidationLimits.weightKgMax} kg).';
    }
    return null;
  }

  static String? weightLb(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your weight.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Weight must be a number.';
    }
    if (parsed < ValidationLimits.weightLbMin) {
      return 'Weight seems too low (min ${ValidationLimits.weightLbMin} lb).';
    }
    if (parsed > ValidationLimits.weightLbMax) {
      return 'Please enter a realistic weight (max ${ValidationLimits.weightLbMax} lb).';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Height — metric
  // ---------------------------------------------------------------------------

  static String? heightCm(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your height.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Height must be a number.';
    }
    if (parsed < ValidationLimits.heightCmMin) {
      return 'Height seems too low (min ${ValidationLimits.heightCmMin.toInt()} cm).';
    }
    if (parsed > ValidationLimits.heightCmMax) {
      return 'Please enter a realistic height (max ${ValidationLimits.heightCmMax.toInt()} cm).';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Height — imperial feet + inches
  // ---------------------------------------------------------------------------

  static String? heightFeet(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter feet.';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Feet must be a number.';
    }
    if (parsed < ValidationLimits.heightFtMin) {
      return 'Height seems too low.';
    }
    if (parsed > ValidationLimits.heightFtMax) {
      return 'Please enter a realistic height (max ${ValidationLimits.heightFtMax} ft).';
    }
    return null;
  }

  static String? heightInches(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter inches.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Inches must be a whole number.';
    }
    if (parsed < ValidationLimits.inchesMin || parsed > ValidationLimits.inchesMax) {
      return 'Inches must be between 0 and 11.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Name (profile — optional field, only validate if non-empty)
  // ---------------------------------------------------------------------------

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Name is optional
    }
    if (value.trim().length > 50) {
      return 'Name must be 50 characters or fewer.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Combined height validation for imperial (feet + inches together)
  // Returns error if combined height is outside realistic cm range.
  // ---------------------------------------------------------------------------

  static String? heightImperial(double feet, int inches) {
    final totalInches = feet * 12 + inches;
    final cm = totalInches * 2.54;
    if (cm < ValidationLimits.heightCmMin) {
      return 'Height is too low. Please check your values.';
    }
    if (cm > ValidationLimits.heightCmMax) {
      return 'Height is too high. Please check your values.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Generic required field
  // ---------------------------------------------------------------------------

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName.';
    }
    return null;
  }
}
