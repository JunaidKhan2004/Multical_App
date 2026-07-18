import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings.dart';

enum BtnStyle { number, operator, equals, clear, sci, toggle }

class CalcButton extends StatefulWidget {
  final String label;
  final String? sublabel;
  final VoidCallback onTap;
  final BtnStyle style;
  final int flex;
  final double? fontSize;
  final bool isDark;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.sublabel,
    this.style = BtnStyle.number,
    this.flex = 1,
    this.fontSize,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _pressed = false;

  // ── Color palette ────────────────────────────────────────────────────────

  static const _cream = Color(0xFFFFF0C4);
  static const _deepest = Color(0xFF3E0703);
  static const _medium = Color(0xFF8C1007);

  // Dark-mode face colours
  static const _darkNum = Color(0xFF660B05);
  static const _darkOp = Color(0xFF8C1007);
  static const _darkEq = _cream;
  static const _darkClear = Color(0xFF3E0703);
  static const _darkSci = Color(0xFF4A0904);
  static const _darkToggle = Color(0xFF2A0502);
  static const _darkShadow = Color(0xFF100000);

  // Light-mode face colours
  static const _lightNum = Color(0xFF8C1007);
  static const _lightOp = Color(0xFF660B05);
  static const _lightEq = _deepest;
  static const _lightClear = _medium;
  static const _lightSci = Color(0xFFAA1A10);
  static const _lightToggle = Color(0xFFFFE5A0);
  static const _lightShadow = Color(0xFF3E0703);

  Color get _face {
    if (widget.isDark) {
      return switch (widget.style) {
        BtnStyle.number   => _darkNum,
        BtnStyle.operator => _darkOp,
        BtnStyle.equals   => _darkEq,
        BtnStyle.clear    => _darkClear,
        BtnStyle.sci      => _darkSci,
        BtnStyle.toggle   => _darkToggle,
      };
    } else {
      return switch (widget.style) {
        BtnStyle.number   => _lightNum,
        BtnStyle.operator => _lightOp,
        BtnStyle.equals   => _lightEq,
        BtnStyle.clear    => _lightClear,
        BtnStyle.sci      => _lightSci,
        BtnStyle.toggle   => _lightToggle,
      };
    }
  }

  Color get _textColor {
    if (widget.style == BtnStyle.equals) {
      return widget.isDark ? _deepest : _cream;
    }
    if (widget.style == BtnStyle.toggle && !widget.isDark) {
      return _deepest;
    }
    return _cream;
  }

  Color get _shadow => widget.isDark ? _darkShadow : _lightShadow;
  Color get _border => widget.isDark ? _darkShadow : _lightShadow;

  // ── Build ────────────────────────────────────────────────────────────────

  static const _offset = 4.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (AppSettings.haptic) HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(
          _pressed ? _offset : 0,
          _pressed ? _offset : 0,
          0,
        ),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _face,
          border: Border.all(color: _border, width: 2.5),
          boxShadow: _pressed
              ? const []
              : [
                  BoxShadow(
                    color: _shadow,
                    offset: const Offset(_offset, _offset),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.spaceMono(
                  color: _textColor,
                  fontSize: widget.fontSize ?? _autoSize(widget.label),
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.sublabel != null)
                Text(
                  widget.sublabel!,
                  style: GoogleFonts.spaceMono(
                    color: _textColor.withAlpha(180),
                    fontSize: 9,
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _autoSize(String label) {
    if (label.length >= 5) return 13;
    if (label.length == 4) return 15;
    if (label.length == 3) return 17;
    return 22;
  }
}
