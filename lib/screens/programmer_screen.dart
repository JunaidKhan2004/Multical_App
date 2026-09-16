import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/brut_widgets.dart';
import '../widgets/calc_button.dart';

class ProgrammerScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const ProgrammerScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<ProgrammerScreen> createState() => _ProgrammerScreenState();
}

class _ProgrammerScreenState extends State<ProgrammerScreen> {
  int _value = 0;
  int? _prev;
  String _op = '';
  String _input = '';
  String _base = 'DEC';
  bool _justCalc = false;

  static const _bases = ['HEX', 'DEC', 'OCT', 'BIN'];

  String _toBase(int v, String base) {
    switch (base) {
      case 'HEX':
        return v < 0
            ? '-${(-v).toRadixString(16).toUpperCase()}'
            : v.toRadixString(16).toUpperCase();
      case 'OCT':
        return v < 0
            ? '-${(-v).toRadixString(8)}'
            : v.toRadixString(8);
      case 'BIN':
        if (v < 0) {
          final bits = (-v).toRadixString(2);
          return '-${_spaceBin(bits)}';
        }
        return _spaceBin(v.toRadixString(2));
      default:
        return v.toString();
    }
  }

  String _spaceBin(String s) {
    final padded = s.padLeft(((s.length + 3) ~/ 4) * 4, '0');
    final chunks = <String>[];
    for (var i = 0; i < padded.length; i += 4) {
      chunks.add(padded.substring(i, i + 4));
    }
    return chunks.join(' ');
  }

  int _parseInput(String s, String base) {
    if (s.isEmpty) return 0;
    final neg = s.startsWith('-');
    final raw = neg ? s.substring(1) : s;
    final v = switch (base) {
      'HEX' => int.tryParse(raw, radix: 16) ?? 0,
      'OCT' => int.tryParse(raw, radix: 8) ?? 0,
      'BIN' => int.tryParse(raw, radix: 2) ?? 0,
      _ => int.tryParse(raw) ?? 0,
    };
    return neg ? -v : v;
  }

  bool _digitAllowed(String d) {
    switch (_base) {
      case 'BIN':
        return '01'.contains(d);
      case 'OCT':
        return '01234567'.contains(d);
      case 'DEC':
        return '0123456789'.contains(d);
      case 'HEX':
        return '0123456789ABCDEF'.contains(d.toUpperCase());
      default:
        return false;
    }
  }

  void _tap(String v) {
    setState(() {
      switch (v) {
        case 'C':
          _value = 0;
          _prev = null;
          _op = '';
          _input = '';
          _justCalc = false;
        case '⌫':
          if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
            _value = _parseInput(_input, _base);
          }
        case '=':
          if (_prev != null && _op.isNotEmpty) {
            final cur = _input.isEmpty ? _value : _parseInput(_input, _base);
            _value = _compute(_prev!, cur, _op);
            _input = '';
            _prev = null;
            _op = '';
            _justCalc = true;
          }
        case 'NOT':
          _value = ~_value;
          _input = '';
          _justCalc = true;
        case 'AND' || 'OR' || 'XOR' || '<<' || '>>':
          if (_justCalc) {
            _prev = _value;
            _op = v;
            _input = '';
            _justCalc = false;
          } else {
            if (_prev != null && _op.isNotEmpty && _input.isNotEmpty) {
              _value = _compute(_prev!, _parseInput(_input, _base), _op);
              _prev = _value;
              _op = v;
              _input = '';
            } else {
              _prev = _input.isEmpty ? _value : _parseInput(_input, _base);
              _value = _prev!;
              _op = v;
              _input = '';
            }
          }
        default:
          if (_digitAllowed(v)) {
            if (_justCalc) {
              _input = v;
              _justCalc = false;
            } else {
              _input += v;
            }
            _value = _parseInput(_input, _base);
          }
      }
    });
  }

  int _compute(int a, int b, String op) {
    return switch (op) {
      'AND' => a & b,
      'OR' => a | b,
      'XOR' => a ^ b,
      '<<' => b < 0 || b >= 63 ? 0 : a << b,
      '>>' => b < 0 || b >= 63 ? 0 : a >> b,
      _ => b,
    };
  }

  void _changeBase(String newBase) {
    setState(() {
      _base = newBase;
      _input = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final dimColor = textColor.withAlpha(130);
    final borderColor = widget.isDark ? AppColors.dark : AppColors.medium;

    final bitwiseBtns = [
      ['AND', 'OR', 'XOR', 'NOT'],
      ['<<', '>>', 'C', '⌫'],
    ];
    final hexExtra = ['A', 'B', 'C', 'D', 'E', 'F'];
    final numRows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['0', '00', '='],
    ];

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: BannerAdBar(isDark: widget.isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
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
                  Text('PROGRAMMER',
                      style: GoogleFonts.spaceMono(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3)),
                ],
              ),
            ),
            // Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: surface,
                border:
                    Border(bottom: BorderSide(color: borderColor, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final b in ['HEX', 'DEC', 'OCT', 'BIN'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(b,
                              style: GoogleFonts.spaceMono(
                                  color: b == _base ? textColor : dimColor,
                                  fontSize: 11,
                                  fontWeight: b == _base
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  letterSpacing: 2)),
                          Text(
                            _toBase(_value, b),
                            style: GoogleFonts.spaceMono(
                              color: b == _base ? textColor : dimColor,
                              fontSize: b == _base ? 22 : 14,
                              fontWeight: b == _base
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Base selector
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: _bases.map((b) {
                  final active = b == _base;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _changeBase(b),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? (widget.isDark ? AppColors.cream : AppColors.deepest)
                              : (widget.isDark ? AppColors.darkSurface : AppColors.lightSurface),
                          border: Border.all(
                              color: widget.isDark
                                  ? AppColors.darkShadow
                                  : AppColors.lightShadow,
                              width: 2.5),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                      color: widget.isDark
                                          ? AppColors.darkShadow
                                          : AppColors.lightShadow,
                                      offset: const Offset(3, 3),
                                      blurRadius: 0)
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(b,
                              style: GoogleFonts.spaceMono(
                                  color: active
                                      ? (widget.isDark ? AppColors.deepest : AppColors.cream)
                                      : textColor.withAlpha(150),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Bitwise rows
                    for (final row in bitwiseBtns)
                      Expanded(
                        child: Row(
                          children: row
                              .map((b) => Expanded(
                                    child: CalcButton(
                                      label: b,
                                      onTap: () => _tap(b),
                                      style: BtnStyle.sci,
                                      isDark: widget.isDark,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    // HEX extra row
                    if (_base == 'HEX')
                      Expanded(
                        child: Row(
                          children: hexExtra
                              .map((b) => Expanded(
                                    child: CalcButton(
                                      label: b,
                                      onTap: () => _tap(b),
                                      style: BtnStyle.operator,
                                      isDark: widget.isDark,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    // Number rows
                    for (final row in numRows)
                      Expanded(
                        child: Row(
                          children: row.map((b) {
                            final disabled = !_digitAllowed(b) && b != '=' && b != '00';
                            return Expanded(
                              child: Opacity(
                                opacity: disabled ? 0.3 : 1.0,
                                child: IgnorePointer(
                                  ignoring: disabled,
                                  child: CalcButton(
                                    label: b,
                                    onTap: () => _tap(b),
                                    style: b == '='
                                        ? BtnStyle.equals
                                        : BtnStyle.number,
                                    isDark: widget.isDark,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
