import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';

class FinancialScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const FinancialScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  int _tab = 0;

  // EMI
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  double? _emi, _totalInterest, _totalAmount;

  // Interest
  final _iPrincipal = TextEditingController();
  final _iRate = TextEditingController();
  final _iTime = TextEditingController();
  bool _isCompound = false;
  double? _interest, _iAmount;

  // Tax / Percentage
  final _amount = TextEditingController();
  final _percent = TextEditingController();
  double? _taxAmount, _afterTax;

  void _calcEmi() {
    final p = double.tryParse(_principal.text);
    final r = double.tryParse(_rate.text);
    final n = double.tryParse(_tenure.text);
    if (p == null || r == null || n == null || p <= 0 || r <= 0 || n <= 0) {
      setState(() { _emi = null; _totalInterest = null; _totalAmount = null; });
      return;
    }
    final monthly = r / 12 / 100;
    final emi = p * monthly * math.pow(1 + monthly, n) /
        (math.pow(1 + monthly, n) - 1);
    setState(() {
      _emi = emi;
      _totalAmount = emi * n;
      _totalInterest = _totalAmount! - p;
    });
  }

  void _calcInterest() {
    final p = double.tryParse(_iPrincipal.text);
    final r = double.tryParse(_iRate.text);
    final t = double.tryParse(_iTime.text);
    if (p == null || r == null || t == null) {
      setState(() { _interest = null; _iAmount = null; });
      return;
    }
    setState(() {
      if (_isCompound) {
        _iAmount = p * math.pow(1 + r / 100, t);
        _interest = _iAmount! - p;
      } else {
        _interest = p * r * t / 100;
        _iAmount = p + _interest!;
      }
    });
  }

  void _calcTax() {
    final a = double.tryParse(_amount.text);
    final pct = double.tryParse(_percent.text);
    if (a == null || pct == null) {
      setState(() { _taxAmount = null; _afterTax = null; });
      return;
    }
    setState(() {
      _taxAmount = a * pct / 100;
      _afterTax = a + _taxAmount!;
    });
  }

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _tenure.dispose();
    _iPrincipal.dispose();
    _iRate.dispose();
    _iTime.dispose();
    _amount.dispose();
    _percent.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if (v >= 1e7) return v.toStringAsFixed(0);
    if (v >= 1000) {
      final s = v.toStringAsFixed(2);
      return s;
    }
    return v.toStringAsFixed(2);
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
                  Text('FINANCIAL',
                      style: GoogleFonts.spaceMono(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3)),
                ],
              ),
            ),

            // Tab selector
            Padding(
              padding: const EdgeInsets.all(12),
              child: BrutSegment(
                options: const ['EMI', 'INTEREST', 'TAX %'],
                selected: _tab,
                isDark: widget.isDark,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _tab == 0
                    ? _buildEmi()
                    : _tab == 1
                        ? _buildInterest()
                        : _buildTax(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmi() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'EMI Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutField(label: 'Loan Amount (Principal)', controller: _principal,
              isDark: widget.isDark, hint: '500000', suffix: '₨', onChanged: _calcEmi),
          const SizedBox(height: 12),
          BrutField(label: 'Annual Interest Rate', controller: _rate,
              isDark: widget.isDark, hint: '8.5', suffix: '% p.a.', onChanged: _calcEmi),
          const SizedBox(height: 12),
          BrutField(label: 'Loan Tenure', controller: _tenure,
              isDark: widget.isDark, hint: '60', suffix: 'months', onChanged: _calcEmi),
          const SizedBox(height: 20),
          BrutButton(label: 'Calculate EMI', onTap: _calcEmi, isDark: widget.isDark),
          if (_emi != null) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 10),
            BrutResult(label: 'Monthly EMI', value: '₨ ${_fmt(_emi!)}',
                isDark: widget.isDark, highlight: true),
            const SizedBox(height: 8),
            BrutResult(label: 'Total Interest', value: '₨ ${_fmt(_totalInterest!)}', isDark: widget.isDark),
            const SizedBox(height: 8),
            BrutResult(label: 'Total Amount', value: '₨ ${_fmt(_totalAmount!)}', isDark: widget.isDark),
          ],
        ],
      );

  Widget _buildInterest() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Interest Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutSegment(
            options: const ['Simple', 'Compound'],
            selected: _isCompound ? 1 : 0,
            isDark: widget.isDark,
            onSelect: (i) => setState(() { _isCompound = i == 1; _calcInterest(); }),
          ),
          const SizedBox(height: 12),
          BrutField(label: 'Principal Amount', controller: _iPrincipal,
              isDark: widget.isDark, hint: '10000', suffix: '₨', onChanged: _calcInterest),
          const SizedBox(height: 12),
          BrutField(label: 'Rate of Interest', controller: _iRate,
              isDark: widget.isDark, hint: '10', suffix: '% p.a.', onChanged: _calcInterest),
          const SizedBox(height: 12),
          BrutField(label: 'Time Period', controller: _iTime,
              isDark: widget.isDark, hint: '2', suffix: 'years', onChanged: _calcInterest),
          const SizedBox(height: 20),
          BrutButton(label: 'Calculate', onTap: _calcInterest, isDark: widget.isDark),
          if (_interest != null) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 10),
            BrutResult(label: 'Interest Earned', value: '₨ ${_fmt(_interest!)}',
                isDark: widget.isDark, highlight: true),
            const SizedBox(height: 8),
            BrutResult(label: 'Total Amount', value: '₨ ${_fmt(_iAmount!)}', isDark: widget.isDark),
          ],
        ],
      );

  Widget _buildTax() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Tax / Percentage', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutField(label: 'Amount', controller: _amount,
              isDark: widget.isDark, hint: '1000', suffix: '₨', onChanged: _calcTax),
          const SizedBox(height: 12),
          BrutField(label: 'Tax / Percentage Rate', controller: _percent,
              isDark: widget.isDark, hint: '18', suffix: '%', onChanged: _calcTax),
          const SizedBox(height: 20),
          BrutButton(label: 'Calculate', onTap: _calcTax, isDark: widget.isDark),
          if (_taxAmount != null) ...[
            const SizedBox(height: 20),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 10),
            BrutResult(label: 'Tax Amount', value: '₨ ${_fmt(_taxAmount!)}',
                isDark: widget.isDark, highlight: true),
            const SizedBox(height: 8),
            BrutResult(label: 'Total (with Tax)', value: '₨ ${_fmt(_afterTax!)}', isDark: widget.isDark),
            const SizedBox(height: 8),
            BrutResult(label: 'Percentage of', value: '${_percent.text}% of ${_amount.text}', isDark: widget.isDark),
          ],
        ],
      );
}
