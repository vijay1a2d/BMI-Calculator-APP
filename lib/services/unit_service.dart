// services/unit_service.dart
// Accurate kg↔lb and cm↔ft/in conversion utilities.
// Internal calculations always use kg and cm.
// These functions are used only for display and user-input conversion.

class UnitService {
  UnitService._();

  // ---------------------------------------------------------------------------
  // Weight conversions
  // ---------------------------------------------------------------------------

  static const double _lbsPerKg = 2.20462262185;

  static double kgToLb(double kg) => kg * _lbsPerKg;
  static double lbToKg(double lb) => lb / _lbsPerKg;

  // ---------------------------------------------------------------------------
  // Height conversions
  // ---------------------------------------------------------------------------

  static const double _cmPerInch = 2.54;
  static const double _inchesPerFoot = 12.0;

  static double cmToInches(double cm) => cm / _cmPerInch;
  static double inchesToCm(double inches) => inches * _cmPerInch;

  /// Convert cm to feet (whole) and inches (whole), e.g. 170 cm → (5, 7)
  static ({int feet, int inches}) cmToFtIn(double cm) {
    final totalInches = cmToInches(cm);
    final feet = totalInches ~/ _inchesPerFoot;
    final inches = (totalInches % _inchesPerFoot).round();
    // Handle rounding overflow
    if (inches == 12) {
      return (feet: feet + 1, inches: 0);
    }
    return (feet: feet, inches: inches);
  }

  /// Convert feet + inches to cm.
  static double ftInToCm(double feet, int inches) {
    final totalInches = feet * _inchesPerFoot + inches;
    return inchesToCm(totalInches);
  }

  // ---------------------------------------------------------------------------
  // Formatted strings for display
  // ---------------------------------------------------------------------------

  static String weightDisplay(double kg, bool useMetric) {
    if (useMetric) {
      return '${kg.toStringAsFixed(1)} kg';
    }
    return '${kgToLb(kg).toStringAsFixed(1)} lb';
  }

  static String heightDisplay(double cm, bool useMetric) {
    if (useMetric) {
      return '${cm.toStringAsFixed(0)} cm';
    }
    final (:feet, :inches) = cmToFtIn(cm);
    return '${feet}ft ${inches}in';
  }

  // ---------------------------------------------------------------------------
  // Input → internal (always kg / cm)
  // ---------------------------------------------------------------------------

  /// Convert user-entered weight string to kg.
  /// [useMetric] = true → already in kg, false → input is lb.
  static double? parseWeightToKg(String input, bool useMetric) {
    final val = double.tryParse(input.trim());
    if (val == null) return null;
    return useMetric ? val : lbToKg(val);
  }

  /// Convert user-entered height to cm (metric mode: single cm value).
  static double? parseHeightCmFromCm(String input) {
    return double.tryParse(input.trim());
  }

  /// Convert user-entered feet and inches to cm (imperial mode).
  static double? parseHeightCmFromFtIn(String feetInput, String inchesInput) {
    final feet = double.tryParse(feetInput.trim());
    final inches = int.tryParse(inchesInput.trim());
    if (feet == null || inches == null) return null;
    return ftInToCm(feet, inches);
  }
}
