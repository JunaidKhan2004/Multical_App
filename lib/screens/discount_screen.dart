import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';

class DiscountScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const DiscountScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  int _tab = 0; // 0=Discount, 1=Markup, 2=Compare

  // Discount tab
  final _price = TextEditingController();
  final _discount = TextEditingController();

  // Markup tab
  final _cost = TextEditingController();
  final _markup = TextEditingController();

  // Compare tab
  final _item1Name = TextEditingController(text: 'Item A');
  final _item1Price = TextEditingController();
  final _item1Qty = TextEditingController(text: '1');
  final _item2Name = TextEditingController(text: 'Item B');
  final _item2Price = TextEditingController();
  final _item2Qty = TextEditingController(text: '1');

  @override
  void dispose() {
    _price.dispose();
    _discount.dispose();
    _cost.dispose();
    _markup.dispose();
    _item1Name.dispose();
    _item1Price.dispose();
    _item1Qty.dispose();
    _item2Name.dispose();
    _item2Price.dispose();
    _item2Qty.dispose();
    super.dispose();
  }

  // ── Discount calculations ──────────────────────────────────────────────────
  double? get _origPrice => double.tryParse(_price.text);
  double? get _discPct => double.tryParse(_discount.text);

  double? get _discountAmount {
    final p = _origPrice; final d = _discPct;
    if (p == null || d == null) return null;
    return p * d / 100;
  }

  double? get _finalPrice {
    final da = _discountAmount;
    if (da == null) return null;
    return _origPrice! - da;
  }

  double? get _savings => _discountAmount;

  // ── Markup calculations ────────────────────────────────────────────────────
  double? get _costPrice => double.tryParse(_cost.text);
  double? get _markupPct => double.tryParse(_markup.text);

  double? get _sellingPrice {
    final c = _costPrice; final m = _markupPct;
    if (c == null || m == null) return null;
    return c * (1 + m / 100);
  }

  double? get _profit {
    final sp = _sellingPrice;
    if (sp == null) return null;
    return sp - _costPrice!;
  }

  double? get _profitMargin {
    final sp = _sellingPrice;
    if (sp == null || sp == 0) return null;
    return (_profit! / sp) * 100;
  }

  // ── Compare calculations ───────────────────────────────────────────────────
  double? get _p1 => double.tryParse(_item1Price.text);
  double? get _p2 => double.tryParse(_item2Price.text);
  double? get _q1 => double.tryParse(_item1Qty.text);
  double? get _q2 => double.tryParse(_item2Qty.text);

  double? get _perUnit1 {
    final p = _p1; final q = _q1;
    if (p == null || q == null || q == 0) return null;
    return p / q;
  }

  double? get _perUnit2 {
    final p = _p2; final q = _q2;
    if (p == null || q == null || q == 0) return null;
    return p / q;
  }

  String get _betterDeal {
    final u1 = _perUnit1; final u2 = _perUnit2;
    if (u1 == null || u2 == null) return '—';
    if (u1 < u2) return '${_item1Name.text} is cheaper!';
    if (u2 < u1) return '${_item2Name.text} is cheaper!';
    return 'Same price per unit';
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
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
                  Text('DISCOUNT',
                      style: GoogleFonts.spaceMono(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3)),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.all(12),
              child: BrutSegment(
                options: const ['DISCOUNT', 'MARKUP', 'COMPARE'],
                selected: _tab,
                isDark: widget.isDark,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _tab == 0
                    ? _buildDiscount()
                    : _tab == 1
                        ? _buildMarkup()
                        : _buildCompare(textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Discount Tab ───────────────────────────────────────────────────────────
  Widget _buildDiscount() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Discount Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutField(
              label: 'Original Price',
              controller: _price,
              isDark: widget.isDark,
              hint: '2000',
              suffix: '₨',
              onChanged: () => setState(() {})),
          const SizedBox(height: 12),
          BrutField(
              label: 'Discount',
              controller: _discount,
              isDark: widget.isDark,
              hint: '30',
              suffix: '%',
              onChanged: () => setState(() {})),

          if (_finalPrice != null) ...[
            const SizedBox(height: 24),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 12),

            // Big final price card
            GestureDetector(
              onLongPress: () => _copy('₨ ${_fmt(_finalPrice!)}'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.cream : AppColors.deepest,
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
                  children: [
                    Text('FINAL PRICE',
                        style: GoogleFonts.spaceMono(
                            color: widget.isDark
                                ? AppColors.deepest.withAlpha(160)
                                : AppColors.cream.withAlpha(180),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('₨ ${_fmt(_finalPrice!)}',
                        style: GoogleFonts.spaceMono(
                            color: widget.isDark
                                ? AppColors.deepest
                                : AppColors.cream,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1)),
                    const SizedBox(height: 2),
                    Text('Long press to copy',
                        style: GoogleFonts.spaceMono(
                            color: widget.isDark
                                ? AppColors.deepest.withAlpha(100)
                                : AppColors.cream.withAlpha(120),
                            fontSize: 9)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            BrutResult(
                label: 'You Save',
                value: '₨ ${_fmt(_savings!)}',
                isDark: widget.isDark,
                highlight: false),
            const SizedBox(height: 8),
            BrutResult(
                label: 'Original Price',
                value: '₨ ${_fmt(_origPrice!)}',
                isDark: widget.isDark),
            const SizedBox(height: 8),
            BrutResult(
                label: 'Discount Applied',
                value: '${_fmt(_discPct!)}%',
                isDark: widget.isDark),

            // Visual discount bar
            const SizedBox(height: 20),
            BrutSection(title: 'Savings Breakdown', isDark: widget.isDark),
            const SizedBox(height: 10),
            _DiscountBar(
              pct: _discPct! / 100,
              isDark: widget.isDark,
            ),
          ],
        ],
      );

  // ── Markup Tab ─────────────────────────────────────────────────────────────
  Widget _buildMarkup() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutSection(title: 'Markup / Profit Calculator', isDark: widget.isDark),
          const SizedBox(height: 14),
          BrutField(
              label: 'Cost Price',
              controller: _cost,
              isDark: widget.isDark,
              hint: '1000',
              suffix: '₨',
              onChanged: () => setState(() {})),
          const SizedBox(height: 12),
          BrutField(
              label: 'Markup',
              controller: _markup,
              isDark: widget.isDark,
              hint: '40',
              suffix: '%',
              onChanged: () => setState(() {})),

          if (_sellingPrice != null) ...[
            const SizedBox(height: 24),
            BrutSection(title: 'Result', isDark: widget.isDark),
            const SizedBox(height: 12),
            BrutResult(
                label: 'Selling Price',
                value: '₨ ${_fmt(_sellingPrice!)}',
                isDark: widget.isDark,
                highlight: true),
            const SizedBox(height: 8),
            BrutResult(
                label: 'Profit Amount',
                value: '₨ ${_fmt(_profit!)}',
                isDark: widget.isDark),
            const SizedBox(height: 8),
            BrutResult(
                label: 'Profit Margin',
                value: '${_fmt(_profitMargin!)}%',
                isDark: widget.isDark),
            const SizedBox(height: 8),
            BrutResult(
                label: 'Cost Price',
                value: '₨ ${_fmt(_costPrice!)}',
                isDark: widget.isDark),
          ],
        ],
      );

  // ── Compare Tab ────────────────────────────────────────────────────────────
  Widget _buildCompare(Color textColor) {
    final u1 = _perUnit1;
    final u2 = _perUnit2;
    final hasResult = u1 != null && u2 != null;
    final betterIndex = hasResult
        ? (u1 <= u2 ? 0 : 1)
        : -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrutSection(title: 'Price Comparison', isDark: widget.isDark),
        const SizedBox(height: 6),
        Text('Find which item gives more value for money',
            style: GoogleFonts.spaceMono(
                color: textColor.withAlpha(120), fontSize: 10)),
        const SizedBox(height: 16),

        // Item 1
        _CompareItem(
          nameCtrl: _item1Name,
          priceCtrl: _item1Price,
          qtyCtrl: _item1Qty,
          isDark: widget.isDark,
          isBetter: betterIndex == 0,
          perUnit: u1,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),

        // VS divider
        Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: widget.isDark ? AppColors.dark : AppColors.medium,
            child: Text('VS',
                style: GoogleFonts.spaceMono(
                    color: AppColors.cream,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4)),
          ),
        ),
        const SizedBox(height: 12),

        // Item 2
        _CompareItem(
          nameCtrl: _item2Name,
          priceCtrl: _item2Price,
          qtyCtrl: _item2Qty,
          isDark: widget.isDark,
          isBetter: betterIndex == 1,
          perUnit: u2,
          onChanged: () => setState(() {}),
        ),

        if (hasResult) ...[
          const SizedBox(height: 20),
          BrutSection(title: 'Winner', isDark: widget.isDark),
          const SizedBox(height: 10),
          BrutResult(
              label: 'Better Deal',
              value: _betterDeal,
              isDark: widget.isDark,
              highlight: true),
          const SizedBox(height: 8),
          if (u1 != u2)
            BrutResult(
                label: 'Difference per unit',
                value: '₨ ${_fmt((u1 - u2).abs())}',
                isDark: widget.isDark),
        ],
      ],
    );
  }
}

// ── Discount bar widget ───────────────────────────────────────────────────────
class _DiscountBar extends StatelessWidget {
  final double pct;
  final bool isDark;
  const _DiscountBar({required this.pct, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final saved = pct.clamp(0.0, 1.0);
    final pay = 1.0 - saved;
    return Column(
      children: [
        ClipRect(
          child: Row(
            children: [
              Expanded(
                flex: (pay * 100).round(),
                child: Container(
                  height: 28,
                  color: isDark ? AppColors.dark : AppColors.medium,
                  alignment: Alignment.center,
                  child: Text('PAY',
                      style: GoogleFonts.spaceMono(
                          color: AppColors.cream,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              if (saved > 0)
                Expanded(
                  flex: (saved * 100).round(),
                  child: Container(
                    height: 28,
                    color: const Color(0xFF81C784),
                    alignment: Alignment.center,
                    child: Text('SAVE',
                        style: GoogleFonts.spaceMono(
                            color: AppColors.deepest,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${((1 - saved) * 100).toStringAsFixed(0)}% you pay',
                style: GoogleFonts.spaceMono(
                    color: isDark ? AppColors.cream : AppColors.deepest,
                    fontSize: 10)),
            Text('${(saved * 100).toStringAsFixed(0)}% saved',
                style: GoogleFonts.spaceMono(
                    color: const Color(0xFF81C784),
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// ── Compare item widget ───────────────────────────────────────────────────────
class _CompareItem extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;
  final bool isDark;
  final bool isBetter;
  final double? perUnit;
  final VoidCallback onChanged;

  const _CompareItem({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.qtyCtrl,
    required this.isDark,
    required this.isBetter,
    required this.perUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final border = isBetter
        ? const Color(0xFF81C784)
        : (isDark ? AppColors.darkShadow : AppColors.lightShadow);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isBetter ? 3 : 2),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameCtrl,
                  onChanged: (_) => onChanged(),
                  style: GoogleFonts.spaceMono(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Item name',
                    hintStyle: GoogleFonts.spaceMono(
                        color: textColor.withAlpha(60), fontSize: 13),
                  ),
                ),
              ),
              if (isBetter)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: const Color(0xFF81C784),
                  child: Text('BEST',
                      style: GoogleFonts.spaceMono(
                          color: AppColors.deepest,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MiniField(
                    ctrl: priceCtrl,
                    hint: 'Price',
                    suffix: '₨',
                    textColor: textColor,
                    onChanged: onChanged),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniField(
                    ctrl: qtyCtrl,
                    hint: 'Qty',
                    suffix: 'units',
                    textColor: textColor,
                    onChanged: onChanged),
              ),
            ],
          ),
          if (perUnit != null) ...[
            const SizedBox(height: 6),
            Text(
              '₨ ${perUnit!.toStringAsFixed(2)} per unit',
              style: GoogleFonts.spaceMono(
                  color: isBetter
                      ? const Color(0xFF81C784)
                      : textColor.withAlpha(150),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final String suffix;
  final Color textColor;
  final VoidCallback onChanged;

  const _MiniField({
    required this.ctrl,
    required this.hint,
    required this.suffix,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => onChanged(),
      keyboardType: TextInputType.number,
      style: GoogleFonts.spaceMono(
          color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
      cursorColor: textColor,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hint,
        hintStyle:
            GoogleFonts.spaceMono(color: textColor.withAlpha(60), fontSize: 12),
        suffixText: suffix,
        suffixStyle: GoogleFonts.spaceMono(
            color: textColor.withAlpha(120), fontSize: 10),
      ),
    );
  }
}
