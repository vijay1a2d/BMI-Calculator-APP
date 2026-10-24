// screens/calculator_screen.dart
// Professional BMI calculator with metric/imperial unit switching,
// gender selection, activity level, and full validation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/app_state.dart';
import '../services/bmi_service.dart';
import '../services/unit_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'result_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCmCtrl = TextEditingController();
  final _heightFtCtrl = TextEditingController();
  final _heightInCtrl = TextEditingController();

  // State
  String _gender = 'male';
  String _activityLevel = ActivityLevel.sedentary;
  bool _useMetric = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromProfile());
  }

  void _prefillFromProfile() {
    final appState = AppStateScope.of(context);
    _useMetric = appState.useMetric;
    final p = appState.profile;
    if (p.hasData) {
      _gender = p.gender;
      _activityLevel = p.activityLevel;
      _ageCtrl.text = p.age > 0 ? p.age.toString() : '';
      if (_useMetric) {
        _weightCtrl.text =
            p.weightKg > 0 ? p.weightKg.toStringAsFixed(1) : '';
        _heightCmCtrl.text =
            p.heightCm > 0 ? p.heightCm.toStringAsFixed(0) : '';
      } else {
        if (p.weightKg > 0) {
          _weightCtrl.text =
              UnitService.kgToLb(p.weightKg).toStringAsFixed(1);
        }
        if (p.heightCm > 0) {
          final (:feet, :inches) = UnitService.cmToFtIn(p.heightCm);
          _heightFtCtrl.text = feet.toString();
          _heightInCtrl.text = inches.toString();
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCmCtrl.dispose();
    _heightFtCtrl.dispose();
    _heightInCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageCtrl.text.trim());

    // Weight → kg
    double weightKg;
    if (_useMetric) {
      weightKg = double.parse(_weightCtrl.text.trim());
    } else {
      weightKg = UnitService.lbToKg(double.parse(_weightCtrl.text.trim()));
    }

    // Height → cm
    double heightCm;
    if (_useMetric) {
      heightCm = double.parse(_heightCmCtrl.text.trim());
    } else {
      final feet = double.parse(_heightFtCtrl.text.trim());
      final inches = int.parse(_heightInCtrl.text.trim());
      heightCm = UnitService.ftInToCm(feet, inches);
    }

    final result = BmiService.calculate(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: result),
      ),
    );
  }

  void _switchUnits(bool metric) {
    if (_useMetric == metric) return;
    setState(() {
      // Convert current input values to the new unit system
      if (!metric) {
        // metric → imperial
        final w = double.tryParse(_weightCtrl.text);
        if (w != null) {
          _weightCtrl.text = UnitService.kgToLb(w).toStringAsFixed(1);
        }
        final h = double.tryParse(_heightCmCtrl.text);
        if (h != null) {
          final (:feet, :inches) = UnitService.cmToFtIn(h);
          _heightFtCtrl.text = feet.toString();
          _heightInCtrl.text = inches.toString();
        }
      } else {
        // imperial → metric
        final w = double.tryParse(_weightCtrl.text);
        if (w != null) {
          _weightCtrl.text = UnitService.lbToKg(w).toStringAsFixed(1);
        }
        final ft = double.tryParse(_heightFtCtrl.text) ?? 0;
        final inc = int.tryParse(_heightInCtrl.text) ?? 0;
        final cm = UnitService.ftInToCm(ft, inc);
        if (cm > 0) {
          _heightCmCtrl.text = cm.toStringAsFixed(0);
        }
      }
      _useMetric = metric;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BMI Calculator'),
          actions: [
            TextButton(
              onPressed: _clearForm,
              child: Text('Clear', style: TextStyle(color: cs.primary)),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              // Unit toggle
              _SectionLabel(label: 'Units'),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Metric (kg/cm)')),
                  ButtonSegment(value: false, label: Text('Imperial (lb/ft)')),
                ],
                selected: {_useMetric},
                onSelectionChanged: (s) => _switchUnits(s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: cs.primaryContainer,
                ),
              ),
              const SizedBox(height: 24),

              // Gender
              _SectionLabel(label: 'Gender'),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'male',
                    icon: Icon(Icons.male),
                    label: Text('Male'),
                  ),
                  ButtonSegment(
                    value: 'female',
                    icon: Icon(Icons.female),
                    label: Text('Female'),
                  ),
                ],
                selected: {_gender},
                onSelectionChanged: (s) => setState(() => _gender = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: cs.primaryContainer,
                ),
              ),
              const SizedBox(height: 24),

              // Age
              _SectionLabel(label: 'Age'),
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
              const SizedBox(height: 24),

              // Height
              _SectionLabel(label: 'Height'),
              if (_useMetric)
                TextFormField(
                  controller: _heightCmCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightFtCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Inches',
                        ),
                        validator: Validators.heightInches,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Weight
              _SectionLabel(label: 'Weight'),
              TextFormField(
                controller: _weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                ],
                decoration: InputDecoration(
                  labelText: _useMetric ? 'Weight (kg)' : 'Weight (lb)',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
                validator: _useMetric ? Validators.weightKg : Validators.weightLb,
              ),
              const SizedBox(height: 24),

              // Activity level
              _SectionLabel(label: 'Activity Level'),
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
              const SizedBox(height: 8),
              Text(
                'Used to estimate your daily calorie needs.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate BMI'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _ageCtrl.clear();
    _weightCtrl.clear();
    _heightCmCtrl.clear();
    _heightFtCtrl.clear();
    _heightInCtrl.clear();
    setState(() {
      _gender = 'male';
      _activityLevel = ActivityLevel.sedentary;
    });
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
