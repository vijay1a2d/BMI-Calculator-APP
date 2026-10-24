// widgets/bmi_gauge.dart
// Animated semicircular BMI gauge using CustomPainter.
// Shows colored segments for Underweight / Normal / Overweight / Obesity.
// Needle animates from start to the actual BMI value.

import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';

class BmiGauge extends StatefulWidget {
  final double bmi;
  final bool animate;

  const BmiGauge({super.key, required this.bmi, this.animate = true});

  @override
  State<BmiGauge> createState() => _BmiGaugeState();
}

class _BmiGaugeState extends State<BmiGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bmiAnim;

  static const double _minBmi = 10.0;
  static const double _maxBmi = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _bmiAnim = Tween<double>(begin: _minBmi, end: widget.bmi.clamp(_minBmi, _maxBmi))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BmiGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _bmiAnim = Tween<double>(
              begin: _bmiAnim.value, end: widget.bmi.clamp(_minBmi, _maxBmi))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _bmiAnim,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 2.0,
              child: CustomPaint(
                painter: _GaugePainter(
                  animatedBmi: _bmiAnim.value,
                  isDark: isDark,
                  primaryColor: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Segment legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                    label: BmiCategories.underweight,
                    color: AppTheme.bmiCategoryColor(BmiCategories.underweight,
                        dark: isDark)),
                const SizedBox(width: 12),
                _LegendDot(
                    label: BmiCategories.normal,
                    color: AppTheme.bmiCategoryColor(BmiCategories.normal,
                        dark: isDark)),
                const SizedBox(width: 12),
                _LegendDot(
                    label: BmiCategories.overweight,
                    color: AppTheme.bmiCategoryColor(BmiCategories.overweight,
                        dark: isDark)),
                const SizedBox(width: 12),
                _LegendDot(
                    label: BmiCategories.obesity,
                    color: AppTheme.bmiCategoryColor(BmiCategories.obesity,
                        dark: isDark)),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Legend dot widget
// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

class _GaugePainter extends CustomPainter {
  final double animatedBmi;
  final bool isDark;
  final Color primaryColor;

  static const double _minBmi = 10.0;
  static const double _maxBmi = 40.0;
  static const double _totalRange = _maxBmi - _minBmi;

  // Fraction boundaries for each category
  static const double _normalStart = (18.5 - _minBmi) / _totalRange;    // 0.2833
  static const double _overweightStart = (25.0 - _minBmi) / _totalRange; // 0.5
  static const double _obesityStart = (30.0 - _minBmi) / _totalRange;    // 0.6667

  _GaugePainter({
    required this.animatedBmi,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gauge center at the bottom-center of the canvas.
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 * 0.88;
    final strokeWidth = radius * 0.22;

    // The arc goes from π (9 o'clock) clockwise through top to 0 (3 o'clock).
    // startAngle = π, sweepAngle = π (positive = clockwise in Flutter canvas)
    const startAngle = pi;
    const totalSweep = pi;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Segment colors
    final colors = [
      isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8), // Underweight: blue
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D), // Normal: green
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309), // Overweight: amber
      isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), // Obesity: red
    ];

    // Segment fractions [start, end]
    final segments = [
      [0.0, _normalStart],
      [_normalStart, _overweightStart],
      [_overweightStart, _obesityStart],
      [_obesityStart, 1.0],
    ];

    final segmentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw background track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    // Draw colored segments
    for (int i = 0; i < segments.length; i++) {
      final segStart = startAngle + segments[i][0] * totalSweep;
      final segSweep = (segments[i][1] - segments[i][0]) * totalSweep;
      segmentPaint.color = colors[i].withValues(alpha: 0.85);
      canvas.drawArc(rect, segStart, segSweep - 0.02, false, segmentPaint);
    }

    // Needle
    final fraction = ((animatedBmi.clamp(_minBmi, _maxBmi)) - _minBmi) / _totalRange;
    final needleAngle = startAngle + fraction * totalSweep;
    final needleLength = radius * 0.72;
    final needleEnd = Offset(
      center.dx + cos(needleAngle) * needleLength,
      center.dy + sin(needleAngle) * needleLength,
    );

    // Needle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(center.dx + 1, center.dy + 1),
        Offset(needleEnd.dx + 1, needleEnd.dy + 1),
        shadowPaint);

    // Needle body
    final needlePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1E293B)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center pivot circle
    final pivotPaint = Paint()..color = isDark ? Colors.white : const Color(0xFF1E293B);
    canvas.drawCircle(center, 7, pivotPaint);
    canvas.drawCircle(
        center, 4, Paint()..color = isDark ? const Color(0xFF0F172A) : Colors.white);

    // BMI scale ticks at category boundaries
    _drawTick(canvas, center, radius, startAngle + _normalStart * totalSweep,
        isDark, '18.5');
    _drawTick(canvas, center, radius, startAngle + _overweightStart * totalSweep,
        isDark, '25');
    _drawTick(canvas, center, radius, startAngle + _obesityStart * totalSweep,
        isDark, '30');
  }

  void _drawTick(Canvas canvas, Offset center, double radius, double angle,
      bool isDark, String label) {
    final innerR = radius - 18;
    final outerR = radius + 18;
    final tickColor = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4);

    final p1 = Offset(center.dx + cos(angle) * innerR, center.dy + sin(angle) * innerR);
    final p2 = Offset(center.dx + cos(angle) * outerR, center.dy + sin(angle) * outerR);

    canvas.drawLine(p1, p2, Paint()..color = tickColor..strokeWidth = 1.5);

    // Label
    final labelOffset = Offset(
      center.dx + cos(angle) * (outerR + 14),
      center.dy + sin(angle) * (outerR + 14),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        labelOffset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.animatedBmi != animatedBmi || old.isDark != isDark;
}
