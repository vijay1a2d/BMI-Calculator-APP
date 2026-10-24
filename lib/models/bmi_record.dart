// models/bmi_record.dart
// A single saved BMI measurement with all associated health data.
// All physical measurements stored in SI units (kg, cm).

import 'dart:convert';

class BmiRecord {
  final String id;
  final DateTime dateTime;
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender; // 'male' | 'female'
  final String activityLevel;
  final double bmi;
  final String category;
  final double bmr;
  final double tdee;
  final double waterLiters;

  const BmiRecord({
    required this.id,
    required this.dateTime,
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
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'age': age,
        'gender': gender,
        'activityLevel': activityLevel,
        'bmi': bmi,
        'category': category,
        'bmr': bmr,
        'tdee': tdee,
        'waterLiters': waterLiters,
      };

  factory BmiRecord.fromJson(Map<String, dynamic> json) => BmiRecord(
        id: (json['id'] as String?) ?? '',
        dateTime: DateTime.tryParse(
                (json['dateTime'] as String?) ?? '') ??
            DateTime.now(),
        weightKg: ((json['weightKg'] as num?) ?? 0).toDouble(),
        heightCm: ((json['heightCm'] as num?) ?? 0).toDouble(),
        age: (json['age'] as int?) ?? 0,
        gender: (json['gender'] as String?) ?? 'male',
        activityLevel: (json['activityLevel'] as String?) ?? 'Sedentary',
        bmi: ((json['bmi'] as num?) ?? 0).toDouble(),
        category: (json['category'] as String?) ?? '',
        bmr: ((json['bmr'] as num?) ?? 0).toDouble(),
        tdee: ((json['tdee'] as num?) ?? 0).toDouble(),
        waterLiters: ((json['waterLiters'] as num?) ?? 0).toDouble(),
      );

  String toJsonString() => jsonEncode(toJson());

  static List<BmiRecord> listFromJson(List<dynamic> list) =>
      list
          .whereType<Map<String, dynamic>>()
          .map(BmiRecord.fromJson)
          .toList();

  static String listToJsonString(List<BmiRecord> records) =>
      jsonEncode(records.map((r) => r.toJson()).toList());

  @override
  String toString() =>
      'BmiRecord(id: $id, bmi: $bmi, category: $category, date: $dateTime)';
}
