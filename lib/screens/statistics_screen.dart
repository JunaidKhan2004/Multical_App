import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const StatisticsScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _input = TextEditingController();
  _Stats? _stats;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _input.text.trim();
    if (text.isEmpty) {
      setState(() { _stats = null; _error = 'Please enter at least one number.'; });
      return;
    }
    final parts = text.split(RegExp(r'[,\s]+'));
    final nums = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p.trim());
      if (v == null) {
        setState(() { _stats = null; _error = 'Invalid number: "$p"'; });
        return;
      }
      nums.add(v);
    }
    if (nums.isEmpty) return;
    setState(() { _stats = _Stats(nums); _error = null; });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;
    final errColor = const Color(0xFFFF6B6B);

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
                  Text('STATISTICS',
                      style: GoogleFonts.spaceMono(
                          color: textColor, fontSize: 18,
                          fontWeight: FontWeight.bold, letterSpacing: 3)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrutSection(title: 'Enter Numbers', isDark: widget.isDark),
                    const SizedBox(height: 8),
                    // Multi-line input
                    Container(
                      decoration: BoxDecoration(
                        color: widget.isDark ? AppColors.darkButton : AppColors.lightSurface,
                        border: Border.all(
                            color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                            width: 2.5),
                        boxShadow: [
                          BoxShadow(
                              color: widget.isDark ? AppColors.darkShadow : AppColors.lightShadow,
                              offset: const Offset(4, 4), blurRadius: 0)
                        ],
                      ),
                      child: TextField(
                        controller: _input,
                        maxLines: 4,
                        style: GoogleFonts.spaceMono(
                            color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                        cursorColor: textColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          hintText: '10, 20, 30, 40, 50\nor one per line',
                          hintStyle: GoogleFonts.spaceMono(
                              color: textColor.withAlpha(80), fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Separate numbers with commas or spaces',
                        style: GoogleFonts.spaceMono(
                            color: textColor.withAlpha(100), fontSize: 10)),
                    const SizedBox(height: 16),
                    BrutButton(label: 'Calculate Statistics', onTap: _calculate, isDark: widget.isDark),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: GoogleFonts.spaceMono(color: errColor, fontSize: 13)),
                    ],

                    if (_stats != null) ...[
                      const SizedBox(height: 20),
                      BrutSection(title: 'Results (n = ${_stats!.count})', isDark: widget.isDark),
                      const SizedBox(height: 10),
                      BrutResult(label: 'Mean (Average)', value: _f(_stats!.mean),
                          isDark: widget.isDark, highlight: true),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Median', value: _f(_stats!.median), isDark: widget.isDark),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Mode', value: _stats!.modeStr, isDark: widget.isDark),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Std Deviation (σ)', value: _f(_stats!.stdDev),
                          isDark: widget.isDark, highlight: true),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Variance (σ²)', value: _f(_stats!.variance), isDark: widget.isDark),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Sum', value: _f(_stats!.sum), isDark: widget.isDark),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Min', value: _f(_stats!.min), isDark: widget.isDark),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Max', value: _f(_stats!.max), isDark: widget.isDark),
                      const SizedBox(height: 8),
                      BrutResult(label: 'Range (Max - Min)', value: _f(_stats!.range), isDark: widget.isDark),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _f(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _Stats {
  final List<double> data;
  late final int count;
  late final double sum, mean, median, variance, stdDev, min, max, range;
  late final String modeStr;

  _Stats(List<double> raw) : data = List.from(raw)..sort() {
    count = data.length;
    sum = data.fold(0, (a, b) => a + b);
    mean = sum / count;
    median = count.isOdd
        ? data[count ~/ 2]
        : (data[count ~/ 2 - 1] + data[count ~/ 2]) / 2;
    variance = data.map((x) => math.pow(x - mean, 2).toDouble()).fold(0.0, (a, b) => a + b) / count;
    stdDev = math.sqrt(variance);
    min = data.first;
    max = data.last;
    range = max - min;

    final freq = <double, int>{};
    for (final v in data) { freq[v] = (freq[v] ?? 0) + 1; }
    final maxFreq = freq.values.reduce((a, b) => a > b ? a : b);
    if (maxFreq == 1) {
      modeStr = 'No mode';
    } else {
      final modes = freq.entries.where((e) => e.value == maxFreq).map((e) => e.key).toList()..sort();
      modeStr = modes.map((v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2)).join(', ');
    }
  }
}
