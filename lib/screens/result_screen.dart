// screens/result_screen.dart
// Animated result screen showing BMI, gauge, and all health metrics.
// Provides Save / Recalculate / View Progress actions.

import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import '../services/bmi_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/bmi_category_chip.dart';
import '../widgets/bmi_gauge.dart';
import '../widgets/health_stat_card.dart';

class ResultScreen extends StatefulWidget {
  final BmiResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saved) return;
    final appState = AppStateScope.read(context);
    await appState.addRecord(widget.result.toRecord());
    if (mounted) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result saved to history ✓'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _viewProgress() {
    final appState = AppStateScope.read(context);
    Navigator.of(context).pop();
    appState.setSelectedTab(NavIndex.progress);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final useMetric = AppStateScope.of(context).useMetric;
    final r = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // ─── BMI Hero card ───────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Your BMI', style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatBmi(r.bmi),
                      style: tt.displayMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BmiCategoryChip(category: r.category, large: true),
                    const SizedBox(height: 24),
                    BmiGauge(bmi: r.bmi),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Body measurements ───────────────────────────────────────
            _SectionHeader(title: 'Body Measurements'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: [
                HealthStatCard(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: Helpers.formatWeight(r.weightKg, useMetric),
                  iconColor: cs.primary,
                ),
                HealthStatCard(
                  icon: Icons.height,
                  label: 'Height',
                  value: Helpers.formatHeight(r.heightCm, useMetric),
                  iconColor: cs.secondary,
                ),
                HealthStatCard(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: '${r.age} yrs',
                  iconColor: cs.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Healthy weight range ─────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF15803D).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.favorite_outlined,
                          color: Color(0xFF15803D), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Healthy Weight Range',
                              style: tt.labelMedium
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(
                            '${r.minHealthyWeightKg.toStringAsFixed(1)} – '
                            '${r.maxHealthyWeightKg.toStringAsFixed(1)} kg',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                          Text(
                            'for your height (BMI 18.5–24.9)',
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Energy & hydration ───────────────────────────────────────
            _SectionHeader(title: 'Energy & Hydration'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                HealthStatCard(
                  icon: Icons.local_fire_department_outlined,
                  label: 'BMR',
                  value: r.bmr.toStringAsFixed(0),
                  unit: 'kcal/day (at rest)',
                  iconColor: Colors.orange,
                ),
                HealthStatCard(
                  icon: Icons.bolt_outlined,
                  label: 'Daily Calories',
                  value: r.tdee.toStringAsFixed(0),
                  unit: 'kcal/day (${r.activityLevel})',
                  iconColor: Colors.deepOrange,
                ),
                HealthStatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Water Intake',
                  value: '${r.waterLiters.toStringAsFixed(1)} L',
                  unit: 'General estimate',
                  iconColor: Colors.blue,
                ),
                HealthStatCard(
                  icon: Icons.directions_run_outlined,
                  label: 'Activity',
                  value: r.activityLevel,
                  iconColor: cs.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Medical disclaimer ───────────────────────────────────────
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.medicalDisclaimer,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _saved ? null : _save,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved!' : 'Save Result'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recalculate'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _viewProgress,
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Progress'),
                    ),
                  ),
                ],
              ),
            ],
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
