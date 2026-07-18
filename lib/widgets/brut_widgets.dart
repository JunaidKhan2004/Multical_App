import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/navigation.dart';
import '../theme/app_theme.dart';

// ── Home button (header back-to-grid icon) ────────────────────────────────────

/// Header icon that returns to the home grid. Pops the current route if
/// possible; if this screen has no route to pop back to (e.g. it was
/// launched directly as the user's default calculator), it navigates to
/// the home grid instead of leaving the user stuck.
class HomeButton extends StatelessWidget {
  final bool isDark;
  const HomeButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.cream : AppColors.deepest;
    return GestureDetector(
      onTap: () => goHome(context),
      child: Icon(Icons.arrow_back_ios_new, color: color, size: 18),
    );
  }
}

// ── Reusable brutalism text field ─────────────────────────────────────────────

class BrutField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isDark;
  final String? hint;
  final String? suffix;
  final VoidCallback? onChanged;

  const BrutField({
    super.key,
    required this.label,
    required this.controller,
    required this.isDark,
    this.keyboardType = TextInputType.number,
    this.hint,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor =
        (isDark ? AppColors.cream : AppColors.deepest).withAlpha(180);
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bgColor = isDark ? AppColors.darkButton : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkShadow : AppColors.lightShadow;
    final shadowColor = borderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceMono(
            color: labelColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: (_) => onChanged?.call(),
            style: GoogleFonts.spaceMono(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            cursorColor: textColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: hint,
              hintStyle: GoogleFonts.spaceMono(
                color: textColor.withAlpha(80),
                fontSize: 14,
              ),
              suffixText: suffix,
              suffixStyle: GoogleFonts.spaceMono(
                color: textColor.withAlpha(150),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable result card ──────────────────────────────────────────────────────

class BrutResult extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  const BrutResult({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight
        ? (isDark ? AppColors.cream : AppColors.deepest)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final labelColor = highlight
        ? (isDark ? AppColors.deepest : AppColors.cream).withAlpha(180)
        : (isDark ? AppColors.cream : AppColors.deepest).withAlpha(150);
    final valueColor = highlight
        ? (isDark ? AppColors.deepest : AppColors.cream)
        : (isDark ? AppColors.cream : AppColors.deepest);
    final borderColor = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceMono(
              color: labelColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.spaceMono(
                color: valueColor,
                fontSize: highlight ? 20 : 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class BrutSection extends StatelessWidget {
  final String title;
  final bool isDark;

  const BrutSection({super.key, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.cream : AppColors.deepest;
    final lineColor = isDark ? AppColors.dark : AppColors.medium;
    return Row(
      children: [
        Container(width: 6, height: 18, color: lineColor),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.spaceMono(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Action button (brutalism style, full-width) ───────────────────────────────

class BrutButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool primary;

  const BrutButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.primary = true,
  });

  @override
  State<BrutButton> createState() => _BrutButtonState();
}

class _BrutButtonState extends State<BrutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? (widget.isDark ? AppColors.cream : AppColors.deepest)
        : (widget.isDark ? AppColors.darkButton : AppColors.lightButton);
    final fg = widget.primary
        ? (widget.isDark ? AppColors.deepest : AppColors.cream)
        : AppColors.cream;
    final shadow = widget.isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(
          _pressed ? 4 : 0,
          _pressed ? 4 : 0,
          0,
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: shadow, width: 2.5),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: shadow,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.spaceMono(
              color: fg,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Segmented control ─────────────────────────────────────────────────────────

class BrutSegment extends StatelessWidget {
  final List<String> options;
  final int selected;
  final bool isDark;
  final void Function(int) onSelect;

  const BrutSegment({
    super.key,
    required this.options,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? AppColors.cream : AppColors.deepest;
    final inactiveBg =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final activeFg = isDark ? AppColors.deepest : AppColors.cream;
    final inactiveFg =
        (isDark ? AppColors.cream : AppColors.deepest).withAlpha(150);
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border, width: 2.5),
        boxShadow: [
          BoxShadow(color: border, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        children: options.asMap().entries.map((e) {
          final isActive = e.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: isActive ? activeBg : inactiveBg,
                child: Center(
                  child: Text(
                    e.value.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: isActive ? activeFg : inactiveFg,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
