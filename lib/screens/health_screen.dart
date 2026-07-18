import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/brut_widgets.dart';

class HealthScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const HealthScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _tab = 0;

  // BMI
  final _heightCm = TextEditingController();
  final _weightKg = TextEditingController();
  double? _bmi;
  String _bmiCategory = '';

  // BMR
  final _bmrAge = TextEditingController();
  final _bmrHeight = TextEditingController();
  final _bmrWeight = TextEditingController();
  bool _isMale = true;
  double? _bmr;
  Map<String, double>? _tdee;

  // Calories burned
  final _cbWeight = TextEditingController();
  final _cbDuration = TextEditingController();
  int _activityIndex = 0;

  static const _activities = [
    ('Walking (slow)', 3.5),
    ('Walking (fast)', 5.0),
    ('Running (moderate)', 9.0),
    ('Running (fast)', 11.5),
    ('Cycling (moderate)', 8.0),
    ('Swimming', 7.0),
    ('Yoga', 2.5),
    ('Weight Training', 5.5),
    ('HIIT', 10.0),
    ('Dancing', 5.0),
  ];

  @override
  void dispose() {
    _heightCm.dispose();
    _weightKg.dispose();
    _bmrAge.dispose();
    _bmrHeight.dispose();
    _bmrWeight.dispose();
    _cbWeight.dispose();
    _cbDuration.dispose();
    super.dispose();
  }

  void _calcBmi() {
    final h = double.tryParse(_heightCm.text);
    final w = double.tryParse(_weightKg.text);
    if (h == null || w == null || h <= 0 || w <= 0) {
      setState(() => _bmi = null);
      return;
    }
    final hm = h / 100;
    final bmi = w / (hm * hm);
    setState(() {
      _bmi = bmi;
      _bmiCategory = bmi < 18.5
          ? 'Underweight'
          : bmi < 25.0
              ? 'Normal weight'
              : bmi < 30.0
                  ? 'Overweight'
                  : 'Obese';
    });
  }

  void _calcBmr() {
    final a = double.tryParse(_bmrAge.text);
    final h = double.tryParse(_bmrHeight.text);
    final w = double.tryParse(_bmrWeight.text);
    if (a == null || h == null || w == null) {
      setState(() { _bmr = null; _tdee = null; });
      return;
    }
    // Harris-Benedict equation
    final bmr = _isMale
        ? 88.362 + (13.397 * w) + (4.799 * h) - (5.677 * a)
        : 447.593 + (9.247 * w) + (3.098 * h) - (4.330 * a);
    setState(() {
      _bmr = bmr;
      _tdee = {
        'Sedentary (little/no exercise)': bmr * 1.2,
        'Light (1-3 days/week)': bmr * 1.375,
        'Moderate (3-5 days/week)': bmr * 1.55,
        'Active (6-7 days/week)': bmr * 1.725,
        'Very Active (athlete)': bmr * 1.9,
      };
    });
  }

  double get _caloriesBurned {
    final w = double.tryParse(_cbWeight.text);
    final d = double.tryParse(_cbDuration.text);
    if (w == null || d == null || w <= 0 || d <= 0) return 0;
    final met = _activities[_activityIndex].$2;
    return met * w * d / 60;
  }

  Color _bmiColor() {
    if (_bmi == null) return Colors.transparent;
    if (_bmi! < 18.5) return const Color(0xFF4FC3F7);
    if (_bmi! < 25) return const Color(0xFF81C784);
    if (_bmi! < 30) return const Color(0xFFFFB74D);
    return const Color(0xFFE57373);
  }

  String _f(double v) => v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: surface,
                border: Border(bottom: BorderSide(color: borderColor, width: 3)),
              ),
              child: Row(
                children: [
                  HomeButton(isDark: widget.isDark),
                  const SizedBox(width: 12),
                  Text('HEALTH',
                      style: GoogleFonts.spaceMono(
                          color: textColor, fontSize: 18,
                          fontWeight: FontWeight.bold, letterSpacing: 3)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: BrutSegment(
                options: const ['BMI', 'BMR', 'CALORIES'],
                selected: _tab,
                isDark: widget.isDark,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _tab == 0
                    ? _buildBmi()
                    : _tab == 1
                        ? _buildBmr()
                        : _buildCalories(textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmi() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'BMI Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutField(label: 'Height', controller: _heightCm,
              isDark: widget.isDark, hint: '170', suffix: 'cm', onChanged: _calcBmi),
          const SizedBox(height: 12),
          BrutField(label: 'Weight', controller: _weightKg,
              isDark: widget.isDark, hint: '70', suffix: 'kg', onChanged: _calcBmi),
          const SizedBox(height: 20),
          BrutButton(label: 'Calculate BMI', onTap: _calcBmi, isDark: widget.isDark),
          if (_bmi != null) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bmiColor(),
                border: Border.all(
                    color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    width: 2.5),
                boxShadow: [
                  BoxShadow(
                      color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                      offset: const Offset(4, 4), blurRadius: 0)
                ],
              ),
              child: Column(
                children: [
                  Text(_f(_bmi!),
                      style: GoogleFonts.spaceMono(
                          color: AppColors.deepest, fontSize: 48, fontWeight: FontWeight.bold, height: 1)),
                  Text(_bmiCategory,
                      style: GoogleFonts.spaceMono(
                          color: AppColors.deepest, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // BMI scale reference
            _BmiScale(bmi: _bmi!, isDark: widget.isDark),
            const SizedBox(height: 12),
            BrutResult(label: 'Healthy BMI Range', value: '18.5 — 24.9', isDark: widget.isDark),
          ],
        ],
      );

  Widget _buildBmr() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'BMR Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutSegment(
            options: const ['Male', 'Female'],
            selected: _isMale ? 0 : 1,
            isDark: widget.isDark,
            onSelect: (i) => setState(() { _isMale = i == 0; _calcBmr(); }),
          ),
          const SizedBox(height: 12),
          BrutField(label: 'Age', controller: _bmrAge,
              isDark: widget.isDark, hint: '25', suffix: 'years', onChanged: _calcBmr),
          const SizedBox(height: 12),
          BrutField(label: 'Height', controller: _bmrHeight,
              isDark: widget.isDark, hint: '170', suffix: 'cm', onChanged: _calcBmr),
          const SizedBox(height: 12),
          BrutField(label: 'Weight', controller: _bmrWeight,
              isDark: widget.isDark, hint: '70', suffix: 'kg', onChanged: _calcBmr),
          const SizedBox(height: 20),
          BrutButton(label: 'Calculate BMR', onTap: _calcBmr, isDark: widget.isDark),
          if (_bmr != null) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Basal Metabolic Rate', isDark: widget.isDark),
            const SizedBox(height: 10),
            BrutResult(label: 'BMR (calories/day)', value: '${_f(_bmr!)} kcal',
                isDark: widget.isDark, highlight: true),
            const SizedBox(height: 16),
            BrutSection(title: 'Daily Calorie Needs (TDEE)', isDark: widget.isDark),
            const SizedBox(height: 10),
            for (final e in _tdee!.entries) ...[
              BrutResult(label: e.key, value: '${_f(e.value)} kcal', isDark: widget.isDark),
              const SizedBox(height: 8),
            ],
          ],
        ],
      );

  Widget _buildCalories(Color textColor) {
    final burned = _caloriesBurned;
    final bg = widget.isDark ? AppColors.darkButton : AppColors.lightSurface;
    final border = widget.isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'Calories Burned', isDark: widget.isDark),
        const SizedBox(height: 14),
        BrutField(label: 'Body Weight', controller: _cbWeight,
            isDark: widget.isDark, hint: '70', suffix: 'kg',
            onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        BrutField(label: 'Duration', controller: _cbDuration,
            isDark: widget.isDark, hint: '30', suffix: 'minutes',
            onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        Text('ACTIVITY'.toUpperCase(),
            style: GoogleFonts.spaceMono(
                color: textColor.withAlpha(180), fontSize: 10,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 2.5),
            boxShadow: [BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<int>(
            value: _activityIndex,
            isExpanded: true,
            dropdownColor: bg,
            underline: const SizedBox(),
            icon: Icon(Icons.expand_more, color: textColor),
            style: GoogleFonts.spaceMono(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
            items: _activities.asMap().entries.map((e) =>
              DropdownMenuItem(value: e.key,
                child: Text(e.value.$1,
                    style: GoogleFonts.spaceMono(color: textColor, fontSize: 13)))).toList(),
            onChanged: (i) => setState(() { if (i != null) _activityIndex = i; }),
          ),
        ),
        const SizedBox(height: 20),
        BrutResult(
          label: 'Calories Burned',
          value: burned > 0 ? '${burned.toStringAsFixed(1)} kcal' : '—',
          isDark: widget.isDark,
          highlight: true,
        ),
        if (burned > 0) ...[
          const SizedBox(height: 8),
          BrutResult(label: 'MET Value', value: _activities[_activityIndex].$2.toString(), isDark: widget.isDark),
          const SizedBox(height: 8),
          BrutResult(label: 'Activity', value: _activities[_activityIndex].$1, isDark: widget.isDark),
        ],
      ],
    );
  }
}

class _BmiScale extends StatelessWidget {
  final double bmi;
  final bool isDark;
  const _BmiScale({required this.bmi, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const ranges = [
      (0.0, 18.5, Color(0xFF4FC3F7), 'Under'),
      (18.5, 25.0, Color(0xFF81C784), 'Normal'),
      (25.0, 30.0, Color(0xFFFFB74D), 'Over'),
      (30.0, 40.0, Color(0xFFE57373), 'Obese'),
    ];
    final clamped = math.min(math.max(bmi, 10.0), 40.0);
    final pct = (clamped - 10.0) / 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ranges.map((r) => Expanded(
            child: Container(height: 12, color: r.$3),
          )).toList(),
        ),
        const SizedBox(height: 2),
        LayoutBuilder(builder: (ctx, constraints) {
          return Stack(
            children: [
              const SizedBox(height: 20, width: double.infinity),
              Positioned(
                left: (constraints.maxWidth * pct).clamp(0, constraints.maxWidth - 12),
                child: Container(
                  width: 4, height: 20,
                  color: isDark ? AppColors.cream : AppColors.deepest,
                ),
              ),
            ],
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ranges.map((r) => Text(r.$4,
              style: GoogleFonts.spaceMono(
                  color: r.$3, fontSize: 9, fontWeight: FontWeight.bold))).toList(),
        ),
      ],
    );
  }
}
