// screens/profile_screen.dart
// User profile: name, age, gender, height, weight, activity level.
// Persists to SharedPreferences via AppState.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
import '../services/unit_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCmCtrl = TextEditingController();
  final _heightFtCtrl = TextEditingController();
  final _heightInCtrl = TextEditingController();

  String _gender = 'male';
  String _activityLevel = ActivityLevel.sedentary;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  void _loadProfile() {
    final appState = AppStateScope.read(context);
    final p = appState.profile;
    final useMetric = appState.useMetric;
    _nameCtrl.text = p.name;
    _ageCtrl.text = p.age > 0 ? p.age.toString() : '';
    _gender = p.gender;
    _activityLevel = p.activityLevel;

    if (useMetric) {
      _weightCtrl.text = p.weightKg > 0 ? p.weightKg.toStringAsFixed(1) : '';
      _heightCmCtrl.text = p.heightCm > 0 ? p.heightCm.toStringAsFixed(0) : '';
    } else {
      if (p.weightKg > 0) {
        _weightCtrl.text = UnitService.kgToLb(p.weightKg).toStringAsFixed(1);
      }
      if (p.heightCm > 0) {
        final (:feet, :inches) = UnitService.cmToFtIn(p.heightCm);
        _heightFtCtrl.text = feet.toString();
        _heightInCtrl.text = inches.toString();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final appState = AppStateScope.read(context);
    final useMetric = appState.useMetric;

    double weightKg = 0;
    double heightCm = 0;

    final wRaw = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    weightKg = useMetric ? wRaw : UnitService.lbToKg(wRaw);

    if (useMetric) {
      heightCm = double.tryParse(_heightCmCtrl.text.trim()) ?? 0;
    } else {
      final ft = double.tryParse(_heightFtCtrl.text.trim()) ?? 0;
      final inc = int.tryParse(_heightInCtrl.text.trim()) ?? 0;
      heightCm = UnitService.ftInToCm(ft, inc);
    }

    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      gender: _gender,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: _activityLevel,
    );

    await appState.saveProfile(profile);

    if (mounted) {
      setState(() {
        _saving = false;
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved ✓')),
      );
    }
  }

  void _cancelEdit() {
    setState(() => _editing = false);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCmCtrl.dispose();
    _heightFtCtrl.dispose();
    _heightInCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final useMetric = appState.useMetric;
    final profile = appState.profile;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editing = true),
              tooltip: 'Edit profile',
            )
          else ...[
            TextButton(onPressed: _cancelEdit, child: const Text('Cancel')),
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: tt.headlineLarge?.copyWith(
                          color: cs.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_editing) ...[
              // ─── Read-only view ─────────────────────────────────────
              _ProfileField(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: profile.name.isNotEmpty ? profile.name : '—'),
              _ProfileField(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: profile.age > 0 ? '${profile.age} years' : '—'),
              _ProfileField(
                  icon: Icons.wc,
                  label: 'Gender',
                  value: Helpers.genderLabel(profile.gender)),
              _ProfileField(
                  icon: Icons.height,
                  label: 'Height',
                  value: profile.heightCm > 0
                      ? Helpers.formatHeight(profile.heightCm, useMetric)
                      : '—'),
              _ProfileField(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: profile.weightKg > 0
                      ? Helpers.formatWeight(profile.weightKg, useMetric)
                      : '—'),
              _ProfileField(
                  icon: Icons.directions_run_outlined,
                  label: 'Activity Level',
                  value: profile.activityLevel),
            ] else ...[
              // ─── Edit form ──────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Name (optional)'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validators.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    _Label('Gender'),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'male',
                            icon: Icon(Icons.male),
                            label: Text('Male')),
                        ButtonSegment(
                            value: 'female',
                            icon: Icon(Icons.female),
                            label: Text('Female')),
                      ],
                      selected: {_gender},
                      onSelectionChanged: (s) =>
                          setState(() => _gender = s.first),
                    ),
                    const SizedBox(height: 16),
                    _Label('Age'),
                    TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Age (years)',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: Validators.age,
                    ),
                    const SizedBox(height: 16),
                    _Label('Height'),
                    if (useMetric)
                      TextFormField(
                        controller: _heightCmCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        validator: Validators.heightCm,
                      )
                    else
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightFtCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Feet',
                              prefixIcon: Icon(Icons.height),
                            ),
                            validator: Validators.heightFeet,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _heightInCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'Inches'),
                            validator: Validators.heightInches,
                          ),
                        ),
                      ]),
                    const SizedBox(height: 16),
                    _Label('Weight'),
                    TextFormField(
                      controller: _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                      ],
                      decoration: InputDecoration(
                        labelText: useMetric ? 'Weight (kg)' : 'Weight (lb)',
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      ),
                      validator: useMetric ? Validators.weightKg : Validators.weightLb,
                    ),
                    const SizedBox(height: 16),
                    _Label('Activity Level'),
                    DropdownButtonFormField<String>(
                      initialValue: _activityLevel,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.directions_run_outlined),
                      ),
                      items: ActivityLevel.levels
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _activityLevel = v ?? _activityLevel),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52)),
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileField(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: cs.primary),
        title: Text(label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        subtitle: Text(value,
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}
