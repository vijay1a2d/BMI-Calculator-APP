// screens/home_screen.dart
// Dashboard: greeting, BMI summary card, health stats, quick actions, recent history.

import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/bmi_category_chip.dart';
import '../widgets/bmi_gauge.dart';
import '../widgets/bmi_history_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/health_stat_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final latest = appState.latestRecord;
    final profile = appState.profile;
    final useMetric = appState.useMetric;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Helpers.getGreeting(),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              profile.name.isNotEmpty ? profile.name : AppStrings.appName,
              style: tt.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ─── BMI Summary Card ──────────────────────────────────────────
          if (latest != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current BMI',
                                  style: tt.labelMedium
                                      ?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                Helpers.formatBmi(latest.bmi),
                                style: tt.displaySmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              BmiCategoryChip(category: latest.category),
                              const SizedBox(height: 6),
                              Text(
                                'Updated ${Helpers.formatDate(latest.dateTime)}',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BmiGauge(bmi: latest.bmi, animate: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Health Summary ────────────────────────────────────────
            _SectionHeader(title: 'Health Summary'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                HealthStatCard(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: Helpers.formatWeight(latest.weightKg, useMetric),
                  iconColor: cs.primary,
                ),
                HealthStatCard(
                  icon: Icons.height,
                  label: 'Height',
                  value: Helpers.formatHeight(latest.heightCm, useMetric),
                  iconColor: cs.secondary,
                ),
                HealthStatCard(
                  icon: Icons.local_fire_department_outlined,
                  label: 'BMR',
                  value: latest.bmr.toStringAsFixed(0),
                  unit: 'kcal/day',
                  iconColor: Colors.orange,
                ),
                HealthStatCard(
                  icon: Icons.bolt_outlined,
                  label: 'Daily Calories',
                  value: latest.tdee.toStringAsFixed(0),
                  unit: 'kcal/day',
                  iconColor: Colors.deepOrange,
                ),
                HealthStatCard(
                  icon: Icons.water_drop_outlined,
                  label: 'Water',
                  value: '${latest.waterLiters.toStringAsFixed(1)} L',
                  unit: 'General estimate',
                  iconColor: Colors.blue,
                ),
                HealthStatCard(
                  icon: Icons.bar_chart,
                  label: 'Records',
                  value: appState.history.length.toString(),
                  unit: 'saved measurements',
                  iconColor: cs.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Quick Actions ─────────────────────────────────────────
            _SectionHeader(title: 'Quick Actions'),
            _QuickActions(appState: appState),
            const SizedBox(height: 24),

            // ─── Recent History ────────────────────────────────────────
            _SectionHeader(title: 'Recent History'),
            ...appState.history
                .take(5)
                .map((r) => BmiHistoryTile(record: r, useMetric: useMetric)),
            if (appState.history.length > 5)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View all records'),
                  onPressed: () => appState.setSelectedTab(NavIndex.progress),
                ),
              ),
          ] else ...[
            // ─── Empty state ───────────────────────────────────────────
            const SizedBox(height: 60),
            EmptyState(
              icon: Icons.monitor_weight_outlined,
              title: 'No data yet',
              message:
                  'Calculate your BMI to see your health summary here.',
              actionLabel: 'Calculate BMI',
              onAction: () => appState.setSelectedTab(NavIndex.calculator),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick action buttons
// ---------------------------------------------------------------------------

class _QuickActions extends StatelessWidget {
  final AppState appState;
  const _QuickActions({required this.appState});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _ActionButton(
          icon: Icons.calculate,
          label: 'Calculate',
          color: cs.primary,
          onTap: () => appState.setSelectedTab(NavIndex.calculator),
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: Icons.bar_chart,
          label: 'Progress',
          color: cs.secondary,
          onTap: () => appState.setSelectedTab(NavIndex.progress),
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: Icons.person_outline,
          label: 'Profile',
          color: cs.tertiary,
          onTap: () => appState.setSelectedTab(NavIndex.profile),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
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
