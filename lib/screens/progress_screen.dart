// screens/progress_screen.dart
// Real progress chart from saved BMI history using fl_chart.
// Shows BMI trend, weight change, and full history list.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/bmi_record.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/bmi_history_tile.dart';
import '../widgets/empty_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final history = appState.history; // newest first
    final useMetric = appState.useMetric;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: history.isEmpty
          ? EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'No records yet',
              message:
                  'Save your first BMI result to start tracking your progress.',
              actionLabel: 'Calculate BMI',
              onAction: () =>
                  appState.setSelectedTab(NavIndex.calculator),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // ─── Summary stats ─────────────────────────────────────
                _SummaryCard(history: history, useMetric: useMetric),
                const SizedBox(height: 16),

                // ─── BMI trend chart ───────────────────────────────────
                if (history.length >= 2) ...[
                  _SectionHeader(title: 'BMI Trend'),
                  _BmiChart(history: history),
                  const SizedBox(height: 16),
                ],

                // ─── Full history ──────────────────────────────────────
                _SectionHeader(
                    title: 'All Records (${history.length})'),
                ...history.map(
                    (r) => BmiHistoryTile(record: r, useMetric: useMetric)),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary stats card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final List<BmiRecord> history;
  final bool useMetric;

  const _SummaryCard({required this.history, required this.useMetric});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final latest = history.first;
    final oldest = history.last;
    final bmiChange = latest.bmi - oldest.bmi;
    final weightChange = latest.weightKg - oldest.weightKg;

    Color changeColor(double change) {
      if (change.abs() < 0.1) return cs.onSurface;
      return change < 0 ? const Color(0xFF15803D) : const Color(0xFFDC2626);
    }

    String signedBmi(double v) =>
        '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)}';
    String signedWeight(double kg) {
      final display =
          useMetric ? kg : kg * 2.20462;
      final unit = useMetric ? 'kg' : 'lb';
      return '${display >= 0 ? '+' : ''}${display.toStringAsFixed(1)} $unit';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview',
                style:
                    tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatItem(
                  label: 'Current BMI',
                  value: Helpers.formatBmi(latest.bmi),
                  color: cs.primary,
                ),
                _StatItem(
                  label: 'Starting BMI',
                  value: Helpers.formatBmi(oldest.bmi),
                  color: cs.onSurfaceVariant,
                ),
                _StatItem(
                  label: 'BMI Change',
                  value: signedBmi(bmiChange),
                  color: changeColor(bmiChange),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _StatItem(
                  label: 'Current Weight',
                  value: Helpers.formatWeight(latest.weightKg, useMetric),
                  color: cs.primary,
                ),
                _StatItem(
                  label: 'Starting Weight',
                  value: Helpers.formatWeight(oldest.weightKg, useMetric),
                  color: cs.onSurfaceVariant,
                ),
                _StatItem(
                  label: 'Weight Change',
                  value: signedWeight(weightChange),
                  color: changeColor(weightChange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BMI trend chart
// ---------------------------------------------------------------------------

class _BmiChart extends StatelessWidget {
  final List<BmiRecord> history;
  const _BmiChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Chart uses oldest→newest order
    final chronological = history.reversed.toList();
    final spots = chronological
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bmi))
        .toList();

    final bmis = spots.map((s) => s.y).toList();
    final minY = (bmis.reduce((a, b) => a < b ? a : b) - 2).clamp(10.0, 100.0);
    final maxY = (bmis.reduce((a, b) => a > b ? a : b) + 2).clamp(0.0, 100.0);

    // How many x-axis labels to show
    final labelStep = (chronological.length / 5).ceil().clamp(1, 999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 5,
                    getTitlesWidget: (value, _) => Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: labelStep.toDouble(),
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= chronological.length) {
                        return const SizedBox.shrink();
                      }
                      if (idx % labelStep != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          Helpers.formatDateShort(
                              chronological[idx].dateTime),
                          style: TextStyle(
                            fontSize: 9,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            'BMI ${s.y.toStringAsFixed(1)}\n',
                            TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: Helpers.formatDate(
                                    chronological[s.x.toInt()].dateTime),
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: cs.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, _, _) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: cs.primary,
                          strokeWidth: 2,
                          strokeColor: cs.surface,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withValues(alpha: 0.2),
                        cs.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
