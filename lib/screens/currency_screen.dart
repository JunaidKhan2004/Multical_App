import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';

class CurrencyScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const CurrencyScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _input = TextEditingController();
  int _fromIndex = 0;
  int _toIndex = 1;

  // Rates relative to USD (base)
  // Updated approximate rates (offline)
  static const _currencies = [
    _Currency('PKR', 'Pakistani Rupee', '₨', 278.50),
    _Currency('USD', 'US Dollar', '\$', 1.0),
    _Currency('EUR', 'Euro', '€', 0.92),
    _Currency('GBP', 'British Pound', '£', 0.79),
    _Currency('SAR', 'Saudi Riyal', '﷼', 3.75),
    _Currency('AED', 'UAE Dirham', 'د.إ', 3.67),
    _Currency('INR', 'Indian Rupee', '₹', 83.10),
    _Currency('CNY', 'Chinese Yuan', '¥', 7.24),
    _Currency('JPY', 'Japanese Yen', '¥', 149.50),
    _Currency('CAD', 'Canadian Dollar', 'C\$', 1.36),
    _Currency('AUD', 'Australian Dollar', 'A\$', 1.53),
    _Currency('CHF', 'Swiss Franc', 'Fr', 0.88),
    _Currency('TRY', 'Turkish Lira', '₺', 32.15),
    _Currency('BDT', 'Bangladeshi Taka', '৳', 110.0),
    _Currency('MYR', 'Malaysian Ringgit', 'RM', 4.72),
  ];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  double get _result {
    final val = double.tryParse(_input.text);
    if (val == null) return 0;
    final from = _currencies[_fromIndex];
    final to = _currencies[_toIndex];
    // Convert: val → USD → target
    final inUsd = val / from.rateToUsd;
    return inUsd * to.rateToUsd;
  }

  String _fmt(double v) {
    if (v >= 1000000) return v.toStringAsFixed(0);
    if (v >= 100) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }

  void _swap() {
    setState(() {
      final tmp = _fromIndex;
      _fromIndex = _toIndex;
      _toIndex = tmp;
    });
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    if (AppSettings.haptic) HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied: $value',
          style: GoogleFonts.spaceMono(fontSize: 12)),
      duration: const Duration(seconds: 1),
      backgroundColor:
          widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface =
        widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;
    final dimColor = textColor.withAlpha(130);
    final result = _result;
    final hasResult = _input.text.isNotEmpty &&
        double.tryParse(_input.text) != null;

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
                border:
                    Border(bottom: BorderSide(color: borderColor, width: 3)),
              ),
              child: Row(
                children: [
                  HomeButton(isDark: widget.isDark),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENCY',
                          style: GoogleFonts.spaceMono(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3)),
                      Text('OFFLINE RATES',
                          style: GoogleFonts.spaceMono(
                              color: dimColor,
                              fontSize: 9,
                              letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From currency
                    BrutSection(title: 'From', isDark: widget.isDark),
                    const SizedBox(height: 8),
                    _CurrencyDropdown(
                      currencies: _currencies,
                      selected: _fromIndex,
                      isDark: widget.isDark,
                      onChanged: (i) => setState(() => _fromIndex = i),
                    ),
                    const SizedBox(height: 12),
                    BrutField(
                      label: 'Amount',
                      controller: _input,
                      isDark: widget.isDark,
                      hint: '100',
                      suffix: _currencies[_fromIndex].symbol,
                      onChanged: () => setState(() {}),
                    ),

                    // Swap button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: GestureDetector(
                          onTap: _swap,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? AppColors.darkButton
                                  : AppColors.lightButton,
                              border: Border.all(
                                  color: widget.isDark
                                      ? AppColors.darkShadow
                                      : AppColors.lightShadow,
                                  width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                    color: widget.isDark
                                        ? AppColors.darkShadow
                                        : AppColors.lightShadow,
                                    offset: const Offset(3, 3),
                                    blurRadius: 0)
                              ],
                            ),
                            child: Text('⇅',
                                style: GoogleFonts.spaceMono(
                                    color: AppColors.cream, fontSize: 20)),
                          ),
                        ),
                      ),
                    ),

                    // To currency
                    BrutSection(title: 'To', isDark: widget.isDark),
                    const SizedBox(height: 8),
                    _CurrencyDropdown(
                      currencies: _currencies,
                      selected: _toIndex,
                      isDark: widget.isDark,
                      onChanged: (i) => setState(() => _toIndex = i),
                    ),

                    // Result
                    const SizedBox(height: 20),
                    GestureDetector(
                      onLongPress: hasResult
                          ? () => _copy(
                              '${_currencies[_toIndex].symbol} ${_fmt(result)}')
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppColors.cream
                              : AppColors.deepest,
                          border: Border.all(
                              color: widget.isDark
                                  ? AppColors.darkShadow
                                  : AppColors.lightShadow,
                              width: 2.5),
                          boxShadow: [
                            BoxShadow(
                                color: widget.isDark
                                    ? AppColors.darkShadow
                                    : AppColors.lightShadow,
                                offset: const Offset(5, 5),
                                blurRadius: 0)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_currencies[_fromIndex].symbol} ${_input.text.isEmpty ? "0" : _input.text}  →',
                              style: GoogleFonts.spaceMono(
                                  color: widget.isDark
                                      ? AppColors.deepest.withAlpha(150)
                                      : AppColors.cream.withAlpha(160),
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${_currencies[_toIndex].symbol} ${hasResult ? _fmt(result) : "0"}',
                                style: GoogleFonts.spaceMono(
                                    color: widget.isDark
                                        ? AppColors.deepest
                                        : AppColors.cream,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currencies[_toIndex].name,
                              style: GoogleFonts.spaceMono(
                                  color: widget.isDark
                                      ? AppColors.deepest.withAlpha(130)
                                      : AppColors.cream.withAlpha(150),
                                  fontSize: 10,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text('Long press to copy',
                                style: GoogleFonts.spaceMono(
                                    color: widget.isDark
                                        ? AppColors.deepest.withAlpha(80)
                                        : AppColors.cream.withAlpha(100),
                                    fontSize: 9)),
                          ],
                        ),
                      ),
                    ),

                    // Exchange rate info
                    const SizedBox(height: 12),
                    BrutResult(
                      label: 'Exchange Rate',
                      value:
                          '1 ${_currencies[_fromIndex].code} = ${_fmt(_currencies[_toIndex].rateToUsd / _currencies[_fromIndex].rateToUsd)} ${_currencies[_toIndex].code}',
                      isDark: widget.isDark,
                    ),

                    // All rates section
                    const SizedBox(height: 24),
                    BrutSection(
                        title: 'All Rates (vs ${_currencies[_fromIndex].code})',
                        isDark: widget.isDark),
                    const SizedBox(height: 10),
                    _RatesTable(
                      currencies: _currencies,
                      baseIndex: _fromIndex,
                      isDark: widget.isDark,
                      onSelect: (i) => setState(() => _toIndex = i),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: widget.isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      child: Text(
                        '⚠ Offline rates — for reference only.\nActual rates may vary.',
                        style: GoogleFonts.spaceMono(
                            color: textColor.withAlpha(120),
                            fontSize: 10,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Currency data model ───────────────────────────────────────────────────────
class _Currency {
  final String code;
  final String name;
  final String symbol;
  final double rateToUsd;
  const _Currency(this.code, this.name, this.symbol, this.rateToUsd);
}

// ── Currency dropdown ─────────────────────────────────────────────────────────
class _CurrencyDropdown extends StatelessWidget {
  final List<_Currency> currencies;
  final int selected;
  final bool isDark;
  final void Function(int) onChanged;

  const _CurrencyDropdown({
    required this.currencies,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2.5),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<int>(
        value: selected,
        isExpanded: true,
        dropdownColor: bg,
        underline: const SizedBox(),
        icon: Icon(Icons.expand_more, color: textColor),
        style: GoogleFonts.spaceMono(
            color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
        items: currencies
            .asMap()
            .entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    '${e.value.symbol}  ${e.value.code} — ${e.value.name}',
                    style: GoogleFonts.spaceMono(
                        color: textColor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: (i) {
          if (i != null) onChanged(i);
        },
      ),
    );
  }
}

// ── All rates table ───────────────────────────────────────────────────────────
class _RatesTable extends StatelessWidget {
  final List<_Currency> currencies;
  final int baseIndex;
  final bool isDark;
  final void Function(int) onSelect;

  const _RatesTable({
    required this.currencies,
    required this.baseIndex,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;
    final base = currencies[baseIndex];

    String fmt(double v) {
      if (v >= 1000) return v.toStringAsFixed(2);
      if (v >= 1) return v.toStringAsFixed(4);
      return v.toStringAsFixed(6);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border, width: 2.5),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
        ],
      ),
      child: Column(
        children: currencies.asMap().entries.map((e) {
          final i = e.key;
          final cur = e.value;
          if (i == baseIndex) return const SizedBox.shrink();
          final rate = cur.rateToUsd / base.rateToUsd;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              color: i.isEven ? bg : bg.withAlpha(200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    color: isDark ? AppColors.dark : AppColors.medium,
                    child: Text(cur.code,
                        style: GoogleFonts.spaceMono(
                            color: AppColors.cream,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(cur.name,
                        style: GoogleFonts.spaceMono(
                            color: textColor.withAlpha(160), fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    '${cur.symbol} ${fmt(rate)}',
                    style: GoogleFonts.spaceMono(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
