// widgets/bmi_category_chip.dart
// Color-coded BMI category pill — used in result screen, home, and history tiles.

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BmiCategoryChip extends StatelessWidget {
  final String category;
  final bool large;

  const BmiCategoryChip({super.key, required this.category, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = AppTheme.bmiCategoryColor(category, dark: isDark);
    final bg = AppTheme.bmiCategoryBackground(category, dark: isDark);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 18 : 12,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: fg,
          fontSize: large ? 15 : 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
