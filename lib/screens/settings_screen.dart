// screens/settings_screen.dart
// App settings: theme, units, data management, about, disclaimer.
// All buttons are functional — destructive actions show confirmation dialogs.

import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ─── Appearance ─────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                _ThemeTile(
                  title: 'System Default',
                  subtitle: 'Follows your device theme',
                  icon: Icons.phone_android,
                  value: ThemeMode.system,
                  selected: appState.themeMode,
                  onTap: () => appState.setThemeMode(ThemeMode.system),
                ),
                const Divider(height: 1, indent: 56),
                _ThemeTile(
                  title: 'Light Mode',
                  subtitle: 'Always use light theme',
                  icon: Icons.light_mode_outlined,
                  value: ThemeMode.light,
                  selected: appState.themeMode,
                  onTap: () => appState.setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1, indent: 56),
                _ThemeTile(
                  title: 'Dark Mode',
                  subtitle: 'Always use dark theme',
                  icon: Icons.dark_mode_outlined,
                  value: ThemeMode.dark,
                  selected: appState.themeMode,
                  onTap: () => appState.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),

          // ─── Units ──────────────────────────────────────────────────
          _SectionHeader(title: 'Units'),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                _RadioTile<bool>(
                  title: 'Metric',
                  subtitle: 'Kilograms & centimetres',
                  icon: Icons.straighten,
                  value: true,
                  groupValue: appState.useMetric,
                  onTap: () => appState.setUseMetric(true),
                ),
                const Divider(height: 1, indent: 56),
                _RadioTile<bool>(
                  title: 'Imperial',
                  subtitle: 'Pounds & feet/inches',
                  icon: Icons.swap_horiz,
                  value: false,
                  groupValue: appState.useMetric,
                  onTap: () => appState.setUseMetric(false),
                ),
              ],
            ),
          ),

          // ─── Data management ─────────────────────────────────────────
          _SectionHeader(title: 'Data'),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete_outline, color: cs.error),
                  title: Text('Clear BMI History',
                      style: TextStyle(color: cs.error)),
                  subtitle: Text(
                    '${appState.history.length} record(s) saved',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  onTap: () => _confirmClearHistory(context, appState),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.person_remove_outlined, color: cs.error),
                  title: Text('Reset Profile',
                      style: TextStyle(color: cs.error)),
                  subtitle: Text(
                    'Clears your saved personal data',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  onTap: () => _confirmResetProfile(context, appState),
                ),
              ],
            ),
          ),

          // ─── About ──────────────────────────────────────────────────
          _SectionHeader(title: 'About'),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: cs.primary),
                  title: const Text('About BMI+'),
                  subtitle: const Text('Version 1.0.0'),
                  onTap: () => _showAbout(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
                  title: const Text('Privacy & Data'),
                  subtitle: const Text('All data stored locally on device'),
                  onTap: () => _showPrivacy(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(Icons.medical_information_outlined,
                      color: cs.primary),
                  title: const Text('Health Disclaimer'),
                  onTap: () => _showDisclaimer(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmation dialogs
  // ---------------------------------------------------------------------------

  Future<void> _confirmClearHistory(
      BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'This will permanently delete all saved BMI records. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await appState.clearHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('BMI history cleared.')),
        );
      }
    }
  }

  Future<void> _confirmResetProfile(
      BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text(
            'This will clear your name, age, height, weight, and activity level.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await appState.clearProfile();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile reset.')),
        );
      }
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.monitor_weight_outlined, size: 48),
      children: [
        Text(AppStrings.appSubtitle),
        const SizedBox(height: 8),
        Text(AppStrings.appTagline),
      ],
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy & Data'),
        content: const Text(
          'BMI+ stores all your data locally on your device using '
          'SharedPreferences. No data is sent to any server, cloud, '
          'or third-party service. Your health information never leaves your device.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK')),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Health Disclaimer'),
        content: Text(AppStrings.medicalDisclaimer),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared tile widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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

class _ThemeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = value == selected;
    return ListTile(
      leading: Icon(icon, color: isSelected ? cs.primary : cs.onSurfaceVariant),
      title: Text(title,
          style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400)),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final T value;
  final T groupValue;
  final VoidCallback onTap;

  const _RadioTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = value == groupValue;
    return ListTile(
      leading: Icon(icon, color: isSelected ? cs.primary : cs.onSurfaceVariant),
      title: Text(title,
          style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400)),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: cs.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: onTap,
    );
  }
}
