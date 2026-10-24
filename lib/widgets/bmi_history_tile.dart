// widgets/bmi_history_tile.dart
// List tile for a single BMI record in the history list.

import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import 'bmi_category_chip.dart';

class BmiHistoryTile extends StatelessWidget {
  final BmiRecord record;
  final bool useMetric;

  const BmiHistoryTile({
    super.key,
    required this.record,
    required this.useMetric,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = AppTheme.bmiCategoryColor(record.category, dark: isDark);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // BMI value circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.bmiCategoryBackground(record.category, dark: isDark),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  Helpers.formatBmi(record.bmi),
                  style: tt.titleMedium?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BmiCategoryChip(category: record.category),
                      const Spacer(),
                      Text(
                        Helpers.formatDate(record.dateTime),
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoBit(
                        label: 'Weight',
                        value: Helpers.formatWeight(record.weightKg, useMetric),
                      ),
                      const SizedBox(width: 16),
                      _InfoBit(
                        label: 'Height',
                        value: Helpers.formatHeight(record.heightCm, useMetric),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBit extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBit({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
