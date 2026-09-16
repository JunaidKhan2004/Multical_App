import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';

class DateScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const DateScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<DateScreen> createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  int _tab = 0;

  // Age calculator
  DateTime? _dob;
  // Date difference
  DateTime? _date1;
  DateTime? _date2;
  // Add/subtract days
  DateTime? _baseDate;
  final _daysCtrl = TextEditingController();
  bool _addMode = true;

  @override
  void dispose() {
    _daysCtrl.dispose();
    super.dispose();
  }

  ThemeData _datePickerTheme(bool isDark) {
    const cream = Color(0xFFFFF0C4);
    const deepest = Color(0xFF3E0703);
    const dark = Color(0xFF660B05);
    const medium = Color(0xFF8C1007);
    const dialogBgDark = Color(0xFF3E0703);
    const dialogBgLight = cream;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SpaceMono',
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: cream,                          // selected day circle
              onPrimary: deepest,                      // text on selected day
              primaryContainer: dark,                  // header bg
              onPrimaryContainer: cream,               // header text
              surface: dialogBgDark,                   // dialog surface
              onSurface: cream,                        // day numbers, arrows
              onSurfaceVariant: cream.withAlpha(160),  // unselected month/year
              surfaceContainerHigh: dialogBgDark,      // M3 dialog bg
              outline: dark,                           // dividers
              outlineVariant: dark.withAlpha(120),
            )
          : ColorScheme.light(
              primary: medium,
              onPrimary: cream,
              primaryContainer: medium,
              onPrimaryContainer: cream,
              surface: dialogBgLight,
              onSurface: deepest,
              onSurfaceVariant: deepest.withAlpha(160),
              surfaceContainerHigh: dialogBgLight,
              outline: medium,
              outlineVariant: medium.withAlpha(120),
            ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? cream : medium,
          textStyle: const TextStyle(
            fontFamily: 'SpaceMono',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      iconTheme: IconThemeData(color: isDark ? cream : deepest),
    );
  }

  Future<DateTime?> _pickDate(DateTime? initial) async {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: _datePickerTheme(widget.isDark),
        child: child!,
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // Age calculation result
  Map<String, String> get _ageResult {
    if (_dob == null) return {};
    final now = DateTime.now();
    int years = now.year - _dob!.year;
    int months = now.month - _dob!.month;
    int days = now.day - _dob!.day;
    if (days < 0) { months--; days += _daysInMonth(now.year, now.month - 1); }
    if (months < 0) { years--; months += 12; }
    final totalDays = now.difference(_dob!).inDays;
    final totalWeeks = totalDays ~/ 7;
    final totalMonths = years * 12 + months;
    return {
      'Age': '$years years, $months months, $days days',
      'Total Days': totalDays.toString(),
      'Total Weeks': totalWeeks.toString(),
      'Total Months': totalMonths.toString(),
      'Next Birthday': _nextBirthday(now),
    };
  }

  String _nextBirthday(DateTime now) {
    if (_dob == null) return '';
    var next = DateTime(now.year, _dob!.month, _dob!.day);
    if (!next.isAfter(now)) next = DateTime(now.year + 1, _dob!.month, _dob!.day);
    final diff = next.difference(now).inDays;
    return '$diff days away (${_fmtDate(next)})';
  }

  // Date difference result
  Map<String, String> get _diffResult {
    if (_date1 == null || _date2 == null) return {};
    final d1 = _date1!.isBefore(_date2!) ? _date1! : _date2!;
    final d2 = _date1!.isBefore(_date2!) ? _date2! : _date1!;
    final totalDays = d2.difference(d1).inDays;
    int years = d2.year - d1.year;
    int months = d2.month - d1.month;
    int days = d2.day - d1.day;
    if (days < 0) { months--; days += _daysInMonth(d2.year, d2.month - 1); }
    if (months < 0) { years--; months += 12; }
    return {
      'Difference': '$years years, $months months, $days days',
      'Total Days': totalDays.toString(),
      'Total Weeks': '${totalDays ~/ 7} weeks, ${totalDays % 7} days',
      'Total Hours': '${totalDays * 24}',
      'Working Days (~)': '${(totalDays * 5 / 7).round()}',
    };
  }

  // Add/subtract result
  String get _addResult {
    if (_baseDate == null) return '—';
    final d = int.tryParse(_daysCtrl.text);
    if (d == null) return '—';
    final result = _baseDate!.add(Duration(days: _addMode ? d : -d));
    return _fmtDate(result);
  }

  int _daysInMonth(int year, int month) {
    if (month <= 0) { month += 12; year--; }
    return DateTime(year, month + 1, 0).day;
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
                  Text('DATE & TIME',
                      style: GoogleFonts.spaceMono(
                          color: textColor, fontSize: 18,
                          fontWeight: FontWeight.bold, letterSpacing: 3)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: BrutSegment(
                options: const ['AGE', 'DIFF', 'ADD/SUB'],
                selected: _tab,
                isDark: widget.isDark,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _tab == 0
                    ? _buildAge(textColor)
                    : _tab == 1
                        ? _buildDiff(textColor)
                        : _buildAdd(textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAge(Color textColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Age Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          _DatePicker(
            label: 'Date of Birth',
            date: _dob,
            isDark: widget.isDark,
            onPick: () async {
              final d = await _pickDate(_dob);
              if (d != null) setState(() => _dob = d);
            },
          ),
          if (_ageResult.isNotEmpty) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 10),
            for (final e in _ageResult.entries) ...[
              BrutResult(
                label: e.key,
                value: e.value,
                isDark: widget.isDark,
                highlight: e.key == 'Age',
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      );

  Widget _buildDiff(Color textColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Date Difference', isDark: widget.isDark),
          const SizedBox(height: 14),
          _DatePicker(
            label: 'Start Date',
            date: _date1,
            isDark: widget.isDark,
            onPick: () async {
              final d = await _pickDate(_date1);
              if (d != null) setState(() => _date1 = d);
            },
          ),
          const SizedBox(height: 12),
          _DatePicker(
            label: 'End Date',
            date: _date2,
            isDark: widget.isDark,
            onPick: () async {
              final d = await _pickDate(_date2);
              if (d != null) setState(() => _date2 = d);
            },
          ),
          if (_diffResult.isNotEmpty) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 10),
            for (final e in _diffResult.entries) ...[
              BrutResult(
                label: e.key,
                value: e.value,
                isDark: widget.isDark,
                highlight: e.key == 'Difference',
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      );

  Widget _buildAdd(Color textColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Add / Subtract Days', isDark: widget.isDark),
          const SizedBox(height: 14),
          _DatePicker(
            label: 'Start Date',
            date: _baseDate,
            isDark: widget.isDark,
            onPick: () async {
              final d = await _pickDate(_baseDate);
              if (d != null) setState(() => _baseDate = d);
            },
          ),
          const SizedBox(height: 12),
          BrutSegment(
            options: const ['Add Days', 'Subtract Days'],
            selected: _addMode ? 0 : 1,
            isDark: widget.isDark,
            onSelect: (i) => setState(() => _addMode = i == 0),
          ),
          const SizedBox(height: 12),
          BrutField(
            label: 'Number of Days',
            controller: _daysCtrl,
            isDark: widget.isDark,
            hint: '30',
            suffix: 'days',
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 20),
          BrutResult(
            label: 'Result Date',
            value: _addResult,
            isDark: widget.isDark,
            highlight: true,
          ),
        ],
      );
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDark;
  final VoidCallback onPick;

  const _DatePicker({
    required this.label,
    required this.date,
    required this.isDark,
    required this.onPick,
  });

  String get _display => date == null
      ? 'Tap to select'
      : '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}';

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.spaceMono(
                color: textColor.withAlpha(180),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border, width: 2.5),
              boxShadow: [
                BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_display,
                    style: GoogleFonts.spaceMono(
                        color: date == null
                            ? textColor.withAlpha(80)
                            : textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Icon(Icons.calendar_month, color: textColor.withAlpha(180), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
