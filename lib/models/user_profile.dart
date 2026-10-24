// models/user_profile.dart
// Stores the user's personal profile. All physical measurements in SI units (kg, cm).

import 'dart:convert';

import '../utils/constants.dart';

class UserProfile {
  final String name;
  final int age;
  final String gender; // 'male' | 'female'
  final double heightCm;
  final double weightKg;
  final String activityLevel;

  const UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
  });

  /// Default empty profile — used before the user sets up their details.
  factory UserProfile.empty() => const UserProfile(
        name: '',
        age: 0,
        gender: 'male',
        heightCm: 0,
        weightKg: 0,
        activityLevel: ActivityLevel.sedentary,
      );

  /// Returns true when enough data is present to pre-fill the calculator.
  bool get hasData => age > 0 && heightCm > 0 && weightKg > 0;

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? activityLevel,
  }) =>
      UserProfile(
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        activityLevel: activityLevel ?? this.activityLevel,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activityLevel': activityLevel,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: (json['name'] as String?) ?? '',
        age: (json['age'] as int?) ?? 0,
        gender: (json['gender'] as String?) ?? 'male',
        heightCm: ((json['heightCm'] as num?) ?? 0).toDouble(),
        weightKg: ((json['weightKg'] as num?) ?? 0).toDouble(),
        activityLevel:
            (json['activityLevel'] as String?) ?? ActivityLevel.sedentary,
      );

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String raw) =>
      UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserProfile(name: $name, age: $age, gender: $gender, '
      'heightCm: $heightCm, weightKg: $weightKg, activityLevel: $activityLevel)';
}
