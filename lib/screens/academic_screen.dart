import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';

class AcademicScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const AcademicScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  int _tab = 0;

  // ── GPA Calculator ────────────────────────────────────────────────────────
  final List<_Subject> _subjects = [_Subject()];
  int _scaleIndex = 0; // 0=4.0 Pak/US, 1=5.0

  // ── CGPA Calculator ───────────────────────────────────────────────────────
  final List<_Semester> _semesters = [_Semester()];

  // ── Target GPA ────────────────────────────────────────────────────────────
  final _currentCgpa = TextEditingController();
  final _completedCredits = TextEditingController();
  final _targetCgpa = TextEditingController();
  final _remainingCredits = TextEditingController();

  // ── Grade Converter ───────────────────────────────────────────────────────
  final _marksCtrl = TextEditingController();
  int _convScaleIndex = 0;

  @override
  void dispose() {
    for (final s in _subjects) { s.name.dispose(); s.credits.dispose(); }
    for (final s in _semesters) { s.gpa.dispose(); s.credits.dispose(); }
    _currentCgpa.dispose();
    _completedCredits.dispose();
    _targetCgpa.dispose();
    _remainingCredits.dispose();
    _marksCtrl.dispose();
    super.dispose();
  }

  static const _scales = ['4.0 Scale (Pak/US)', '5.0 Scale'];

  // Pakistani 4.0 grading
  static const _gradesPak = [
    ('A+', 4.0, 90.0),
    ('A', 4.0, 85.0),
    ('A-', 3.7, 80.0),
    ('B+', 3.3, 75.0),
    ('B', 3.0, 70.0),
    ('B-', 2.7, 65.0),
    ('C+', 2.3, 60.0),
    ('C', 2.0, 55.0),
    ('C-', 1.7, 50.0),
    ('D', 1.0, 45.0),
    ('F', 0.0, 0.0),
  ];

  static const _grades5 = [
    ('O', 5.0, 90.0),
    ('A+', 4.5, 85.0),
    ('A', 4.0, 80.0),
    ('B+', 3.5, 70.0),
    ('B', 3.0, 60.0),
    ('C+', 2.5, 55.0),
    ('C', 2.0, 50.0),
    ('D', 1.0, 40.0),
    ('F', 0.0, 0.0),
  ];

  List<(String, double, double)> get _grades =>
      _scaleIndex == 0 ? _gradesPak : _grades5;
  List<(String, double, double)> get _convGrades =>
      _convScaleIndex == 0 ? _gradesPak : _grades5;

  // ── GPA calculation ───────────────────────────────────────────────────────
  double get _gpa {
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in _subjects) {
      final cr = double.tryParse(s.credits.text) ?? 0;
      final gp = _grades[s.gradeIndex].$2;
      totalPoints += gp * cr;
      totalCredits += cr;
    }
    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  double get _totalCredits =>
      _subjects.fold(0, (sum, s) => sum + (double.tryParse(s.credits.text) ?? 0));

  // ── CGPA calculation ──────────────────────────────────────────────────────
  double get _cgpa {
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in _semesters) {
      final cr = double.tryParse(s.credits.text) ?? 0;
      final gpa = double.tryParse(s.gpa.text) ?? 0;
      totalPoints += gpa * cr;
      totalCredits += cr;
    }
    if (totalCredits == 0) return 0;
    return totalPoints / totalCredits;
  }

  double get _cgpaTotalCredits =>
      _semesters.fold(0, (sum, s) => sum + (double.tryParse(s.credits.text) ?? 0));

  // ── Target GPA calculation ────────────────────────────────────────────────
  String get _requiredGpa {
    final current = double.tryParse(_currentCgpa.text);
    final completed = double.tryParse(_completedCredits.text);
    final target = double.tryParse(_targetCgpa.text);
    final remaining = double.tryParse(_remainingCredits.text);
    if (current == null || completed == null || target == null || remaining == null) {
      return '—';
    }
    if (remaining <= 0) return '—';
    final maxScale = _scaleIndex == 0 ? 4.0 : 5.0;
    final required = (target * (completed + remaining) - current * completed) / remaining;
    if (required > maxScale) return 'Not possible (> ${maxScale.toStringAsFixed(1)})';
    if (required < 0) return 'Already achieved!';
    return required.toStringAsFixed(2);
  }

  // ── Marks → Grade conversion ──────────────────────────────────────────────
  (String grade, double gpa, String remarks) get _convResult {
    final marks = double.tryParse(_marksCtrl.text);
    if (marks == null || marks < 0 || marks > 100) return ('—', 0, '');
    for (final g in _convGrades) {
      if (marks >= g.$3) {
        final rem = marks >= 80
            ? 'Excellent'
            : marks >= 70
                ? 'Good'
                : marks >= 60
                    ? 'Average'
                    : marks >= 50
                        ? 'Pass'
                        : 'Fail';
        return (g.$1, g.$2, rem);
      }
    }
    return ('F', 0.0, 'Fail');
  }

  String _letterColor(double gpa, double maxScale) {
    final pct = gpa / maxScale;
    if (pct >= 0.9) return 'Excellent ★★★';
    if (pct >= 0.75) return 'Good ★★';
    if (pct >= 0.6) return 'Average ★';
    if (pct > 0) return 'Pass';
    return 'Fail';
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: BannerAdBar(isDark: widget.isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Text('GPA',
                      style: GoogleFonts.spaceMono(
                          color: textColor, fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 3)),
                ],
              ),
            ),

            // Scale selector
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: BrutSegment(
                options: _scales,
                selected: _scaleIndex,
                isDark: widget.isDark,
                onSelect: (i) => setState(() => _scaleIndex = i),
              ),
            ),

            // Tab selector
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: BrutSegment(
                options: const ['GPA', 'CGPA', 'TARGET', 'CONVERT'],
                selected: _tab,
                isDark: widget.isDark,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: _tab == 0
                    ? _buildGpa(textColor)
                    : _tab == 1
                        ? _buildCgpa(textColor)
                        : _tab == 2
                            ? _buildTarget(textColor)
                            : _buildConvert(textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GPA Tab ───────────────────────────────────────────────────────────────
  Widget _buildGpa(Color textColor) {
    final maxScale = _scaleIndex == 0 ? 4.0 : 5.0;
    final gpa = _gpa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'Semester GPA', isDark: widget.isDark),
        const SizedBox(height: 12),

        // Subject rows
        for (int i = 0; i < _subjects.length; i++) ...[
          _SubjectRow(
            index: i,
            subject: _subjects[i],
            grades: _grades,
            isDark: widget.isDark,
            onRemove: _subjects.length > 1
                ? () => setState(() {
                      final removed = _subjects.removeAt(i);
                      removed.name.dispose();
                      removed.credits.dispose();
                    })
                : null,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 8),
        ],

        // Add subject
        BrutButton(
          label: '+ Add Subject',
          onTap: () => setState(() => _subjects.add(_Subject())),
          isDark: widget.isDark,
          primary: false,
        ),

        const SizedBox(height: 20),

        // GPA Result
        if (_totalCredits > 0) ...[
          BrutSection(title: 'Result', isDark: widget.isDark),
          const SizedBox(height: 10),
          _GpaDisplay(
            gpa: gpa,
            maxScale: maxScale,
            label: 'Semester GPA',
            remarks: _letterColor(gpa, maxScale),
            isDark: widget.isDark,
          ),
          const SizedBox(height: 8),
          BrutResult(
              label: 'Total Credit Hours',
              value: _totalCredits.toInt().toString(),
              isDark: widget.isDark),
          const SizedBox(height: 8),
          BrutResult(
              label: 'Subjects',
              value: _subjects.length.toString(),
              isDark: widget.isDark),
        ],

        const SizedBox(height: 20),
        // Grade reference table
        _GradeTable(grades: _grades, isDark: widget.isDark),
      ],
    );
  }

  // ── CGPA Tab ──────────────────────────────────────────────────────────────
  Widget _buildCgpa(Color textColor) {
    final maxScale = _scaleIndex == 0 ? 4.0 : 5.0;
    final cgpa = _cgpa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'CGPA Calculator', isDark: widget.isDark),
        const SizedBox(height: 12),

        for (int i = 0; i < _semesters.length; i++) ...[
          _SemesterRow(
            index: i,
            semester: _semesters[i],
            isDark: widget.isDark,
            maxScale: maxScale,
            onRemove: _semesters.length > 1
                ? () => setState(() {
                      final removed = _semesters.removeAt(i);
                      removed.gpa.dispose();
                      removed.credits.dispose();
                    })
                : null,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 8),
        ],

        BrutButton(
          label: '+ Add Semester',
          onTap: () => setState(() => _semesters.add(_Semester())),
          isDark: widget.isDark,
          primary: false,
        ),

        if (_cgpaTotalCredits > 0) ...[
          const SizedBox(height: 20),
          BrutSection(title: 'Result', isDark: widget.isDark),
          const SizedBox(height: 10),
          _GpaDisplay(
            gpa: cgpa,
            maxScale: maxScale,
            label: 'Cumulative GPA (CGPA)',
            remarks: _letterColor(cgpa, maxScale),
            isDark: widget.isDark,
          ),
          const SizedBox(height: 8),
          BrutResult(
              label: 'Total Credit Hours',
              value: _cgpaTotalCredits.toInt().toString(),
              isDark: widget.isDark),
          const SizedBox(height: 8),
          BrutResult(
              label: 'Semesters',
              value: _semesters.length.toString(),
              isDark: widget.isDark),
        ],
      ],
    );
  }

  // ── Target Tab ────────────────────────────────────────────────────────────
  Widget _buildTarget(Color textColor) {
    final req = _requiredGpa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'Target CGPA Calculator', isDark: widget.isDark),
        const SizedBox(height: 12),
        BrutField(
            label: 'Current CGPA',
            controller: _currentCgpa,
            isDark: widget.isDark,
            hint: '3.20',
            onChanged: () => setState(() {})),
        const SizedBox(height: 10),
        BrutField(
            label: 'Completed Credit Hours',
            controller: _completedCredits,
            isDark: widget.isDark,
            hint: '60',
            suffix: 'cr',
            onChanged: () => setState(() {})),
        const SizedBox(height: 10),
        BrutField(
            label: 'Target CGPA',
            controller: _targetCgpa,
            isDark: widget.isDark,
            hint: '3.50',
            onChanged: () => setState(() {})),
        const SizedBox(height: 10),
        BrutField(
            label: 'Remaining Credit Hours',
            controller: _remainingCredits,
            isDark: widget.isDark,
            hint: '60',
            suffix: 'cr',
            onChanged: () => setState(() {})),
        const SizedBox(height: 20),
        BrutSection(title: 'Required GPA per Semester', isDark: widget.isDark),
        const SizedBox(height: 10),
        BrutResult(
            label: 'Required GPA',
            value: req,
            isDark: widget.isDark,
            highlight: true),
        const SizedBox(height: 8),
        BrutResult(
            label: 'Current CGPA',
            value: _currentCgpa.text.isEmpty ? '—' : _currentCgpa.text,
            isDark: widget.isDark),
        const SizedBox(height: 8),
        BrutResult(
            label: 'Target CGPA',
            value: _targetCgpa.text.isEmpty ? '—' : _targetCgpa.text,
            isDark: widget.isDark),
      ],
    );
  }

  // ── Convert Tab ───────────────────────────────────────────────────────────
  Widget _buildConvert(Color textColor) {
    final result = _convResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'Marks → Grade Converter', isDark: widget.isDark),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BrutSegment(
            options: _scales,
            selected: _convScaleIndex,
            isDark: widget.isDark,
            onSelect: (i) => setState(() => _convScaleIndex = i),
          ),
        ),
        BrutField(
            label: 'Marks / Percentage',
            controller: _marksCtrl,
            isDark: widget.isDark,
            hint: '85',
            suffix: '%',
            onChanged: () => setState(() {})),
        const SizedBox(height: 20),
        if (_marksCtrl.text.isNotEmpty) ...[
          BrutSection(title: 'Result', isDark: widget.isDark),
          const SizedBox(height: 10),
          BrutResult(
              label: 'Letter Grade',
              value: result.$1,
              isDark: widget.isDark,
              highlight: true),
          const SizedBox(height: 8),
          BrutResult(
              label: 'Grade Points',
              value: result.$2.toStringAsFixed(1),
              isDark: widget.isDark),
          const SizedBox(height: 8),
          BrutResult(
              label: 'Remarks',
              value: result.$3,
              isDark: widget.isDark),
          const SizedBox(height: 20),
        ],
        _GradeTable(grades: _convGrades, isDark: widget.isDark),
      ],
    );
  }
}

// ── Subject row ───────────────────────────────────────────────────────────────

class _Subject {
  final name = TextEditingController();
  final credits = TextEditingController(text: '3');
  int gradeIndex = 0;
}

class _SubjectRow extends StatelessWidget {
  final int index;
  final _Subject subject;
  final List<(String, double, double)> grades;
  final bool isDark;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _SubjectRow({
    required this.index,
    required this.subject,
    required this.grades,
    required this.isDark,
    required this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(3, 3), blurRadius: 0)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Subject ${index + 1}',
                  style: GoogleFonts.spaceMono(
                      color: textColor.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const Spacer(),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.close, color: textColor.withAlpha(150), size: 16),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Subject name
              Expanded(
                flex: 3,
                child: TextField(
                  controller: subject.name,
                  onChanged: (_) => onChanged(),
                  style: GoogleFonts.spaceMono(
                      color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Subject name',
                    hintStyle: GoogleFonts.spaceMono(
                        color: textColor.withAlpha(60), fontSize: 12),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Credits
              SizedBox(
                width: 40,
                child: TextField(
                  controller: subject.credits,
                  onChanged: (_) => onChanged(),
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.spaceMono(
                      color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '3',
                    hintStyle: GoogleFonts.spaceMono(
                        color: textColor.withAlpha(60), fontSize: 12),
                    contentPadding: EdgeInsets.zero,
                    suffixText: 'cr',
                    suffixStyle: GoogleFonts.spaceMono(
                        color: textColor.withAlpha(120), fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Grade dropdown
              DropdownButton<int>(
                value: subject.gradeIndex,
                dropdownColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                underline: const SizedBox(),
                icon: Icon(Icons.expand_more, color: textColor, size: 16),
                style: GoogleFonts.spaceMono(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                items: grades
                    .asMap()
                    .entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                            '${e.value.$1} (${e.value.$2.toStringAsFixed(1)})',
                            style: GoogleFonts.spaceMono(
                                color: textColor, fontSize: 12))))
                    .toList(),
                onChanged: (i) {
                  if (i != null) {
                    subject.gradeIndex = i;
                    onChanged();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Semester row ──────────────────────────────────────────────────────────────

class _Semester {
  final gpa = TextEditingController();
  final credits = TextEditingController(text: '18');
}

class _SemesterRow extends StatelessWidget {
  final int index;
  final _Semester semester;
  final bool isDark;
  final double maxScale;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _SemesterRow({
    required this.index,
    required this.semester,
    required this.isDark,
    required this.maxScale,
    required this.onChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(3, 3), blurRadius: 0)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('Semester ${index + 1}',
                style: GoogleFonts.spaceMono(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              controller: semester.gpa,
              onChanged: (_) => onChanged(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.spaceMono(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              cursorColor: textColor,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '3.50',
                hintStyle: GoogleFonts.spaceMono(
                    color: textColor.withAlpha(60), fontSize: 12),
                contentPadding: EdgeInsets.zero,
                suffixText: 'GPA',
                suffixStyle: GoogleFonts.spaceMono(
                    color: textColor.withAlpha(120), fontSize: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: TextField(
              controller: semester.credits,
              onChanged: (_) => onChanged(),
              keyboardType: TextInputType.number,
              style: GoogleFonts.spaceMono(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              cursorColor: textColor,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '18',
                hintStyle: GoogleFonts.spaceMono(
                    color: textColor.withAlpha(60), fontSize: 12),
                contentPadding: EdgeInsets.zero,
                suffixText: 'cr',
                suffixStyle: GoogleFonts.spaceMono(
                    color: textColor.withAlpha(120), fontSize: 10),
              ),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child:
                  Icon(Icons.close, color: textColor.withAlpha(150), size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

// ── GPA display card ──────────────────────────────────────────────────────────

class _GpaDisplay extends StatelessWidget {
  final double gpa;
  final double maxScale;
  final String label;
  final String remarks;
  final bool isDark;

  const _GpaDisplay({
    required this.gpa,
    required this.maxScale,
    required this.label,
    required this.remarks,
    required this.isDark,
  });

  Color get _color {
    final pct = gpa / maxScale;
    if (pct >= 0.9) return const Color(0xFF81C784);
    if (pct >= 0.75) return const Color(0xFF4FC3F7);
    if (pct >= 0.6) return const Color(0xFFFFB74D);
    if (pct > 0) return const Color(0xFFFF8A65);
    return const Color(0xFFE57373);
  }

  @override
  Widget build(BuildContext context) {
    final border =
        isDark ? AppColors.darkShadow : AppColors.lightShadow;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: _color,
        border: Border.all(color: border, width: 2.5),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
        ],
      ),
      child: Column(
        children: [
          Text(gpa.toStringAsFixed(2),
              style: GoogleFonts.spaceMono(
                  color: AppColors.deepest,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          Text('/ $maxScale  •  $label',
              style: GoogleFonts.spaceMono(
                  color: AppColors.deepest.withAlpha(180),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(remarks,
              style: GoogleFonts.spaceMono(
                  color: AppColors.deepest,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Grade reference table ─────────────────────────────────────────────────────

class _GradeTable extends StatelessWidget {
  final List<(String, double, double)> grades;
  final bool isDark;

  const _GradeTable({required this.grades, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;
    final headerBg = isDark ? AppColors.dark : AppColors.medium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'Grade Scale Reference', isDark: isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: border, width: 2.5),
            boxShadow: [
              BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                color: headerBg,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: ['Grade', 'GPA', 'Min %'].map((h) => Expanded(
                    child: Text(h,
                        style: GoogleFonts.spaceMono(
                            color: AppColors.cream,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  )).toList(),
                ),
              ),
              for (int i = 0; i < grades.length; i++)
                Container(
                  color: i.isEven ? bg : bg.withAlpha(180),
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text(grades[i].$1,
                          style: GoogleFonts.spaceMono(
                              color: textColor, fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(child: Text(grades[i].$2.toStringAsFixed(1),
                          style: GoogleFonts.spaceMono(color: textColor, fontSize: 13))),
                      Expanded(child: Text('${grades[i].$3.toInt()}%',
                          style: GoogleFonts.spaceMono(color: textColor.withAlpha(180), fontSize: 13))),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
