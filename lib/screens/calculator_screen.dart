import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/calculator_logic.dart';
import '../services/app_settings.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_bar.dart';
import '../widgets/calc_button.dart';
import 'history_screen.dart';
import 'navigation.dart';

class CalculatorScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;

  const CalculatorScreen({
    super.key,
    required this.isDark,
    required this.onToggleDark,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _logic = CalculatorLogic();
  final _history = HistoryService();
  final _exprScroll = ScrollController();

  bool _isSci = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _exprScroll.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _isSci = p.getBool('isSci') ?? false;
      _logic.isDegree = p.getBool('isDeg') ?? true;
      _logic.liveCalc = p.getBool('liveCalc') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('isSci', _isSci);
    await p.setBool('isDeg', _logic.isDegree);
  }

  void _handle(String v) {
    setState(() => _logic.input(v));
    final entry = _logic.pendingHistory;
    if (entry != null) {
      _history.save(entry.$1, entry.$2);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_exprScroll.hasClients) {
        _exprScroll.jumpTo(_exprScroll.position.maxScrollExtent);
      }
    });
  }

  // ── Button layout ─────────────────────────────────────────────────────────

  // Each row is a list of (label, BtnStyle, flex, sublabel?)
  static const _stdRows = [
    [
      ('C', BtnStyle.clear, 1, null),
      ('⌫', BtnStyle.clear, 1, null),
      ('()', BtnStyle.operator, 1, null),
      ('÷', BtnStyle.operator, 1, null),
    ],
    [
      ('7', BtnStyle.number, 1, null),
      ('8', BtnStyle.number, 1, null),
      ('9', BtnStyle.number, 1, null),
      ('×', BtnStyle.operator, 1, null),
    ],
    [
      ('4', BtnStyle.number, 1, null),
      ('5', BtnStyle.number, 1, null),
      ('6', BtnStyle.number, 1, null),
      ('-', BtnStyle.operator, 1, null),
    ],
    [
      ('1', BtnStyle.number, 1, null),
      ('2', BtnStyle.number, 1, null),
      ('3', BtnStyle.number, 1, null),
      ('+', BtnStyle.operator, 1, null),
    ],
    [
      ('±', BtnStyle.number, 1, null),
      ('0', BtnStyle.number, 1, null),
      ('.', BtnStyle.number, 1, null),
      ('=', BtnStyle.equals, 1, null),
    ],
  ];

  static const _sciRows = [
    [
      ('sin(', BtnStyle.sci, 1, 'sin'),
      ('cos(', BtnStyle.sci, 1, 'cos'),
      ('tan(', BtnStyle.sci, 1, 'tan'),
      ('π', BtnStyle.sci, 1, null),
    ],
    [
      ('asin(', BtnStyle.sci, 1, 'sin⁻¹'),
      ('acos(', BtnStyle.sci, 1, 'cos⁻¹'),
      ('atan(', BtnStyle.sci, 1, 'tan⁻¹'),
      ('e', BtnStyle.sci, 1, null),
    ],
    [
      ('log(', BtnStyle.sci, 1, 'log₁₀'),
      ('ln(', BtnStyle.sci, 1, 'ln'),
      ('sqrt(', BtnStyle.sci, 1, '√'),
      ('^', BtnStyle.sci, 1, 'xʸ'),
    ],
    [
      ('%', BtnStyle.sci, 1, 'mod'),
      ('!', BtnStyle.sci, 1, 'n!'),
      ('exp(', BtnStyle.sci, 1, 'eˣ'),
      ('abs(', BtnStyle.sci, 1, '|x|'),
    ],
  ];

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final dimText = textColor.withAlpha(150);

    return Theme(
      data: widget.isDark ? AppTheme.dark : AppTheme.light,
      child: Scaffold(
        backgroundColor: bg,
        bottomNavigationBar: BannerAdBar(isDark: widget.isDark),
        body: SafeArea(
          child: Column(
            children: [
              // ── Display ───────────────────────────────────────────────────
              Expanded(
                flex: _isSci ? 2 : 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border(
                      bottom: BorderSide(
                        color: widget.isDark ? AppColors.dark : AppColors.medium,
                        width: 3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isDark
                            ? AppColors.darkShadow
                            : AppColors.lightShadow,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // DEG/RAD badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isSci
                                ? (_logic.isDegree ? 'DEG' : 'RAD')
                                : '',
                            style: GoogleFonts.spaceMono(
                              color: dimText,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            _isSci ? 'SCIENTIFIC' : 'BASIC',
                            style: GoogleFonts.spaceMono(
                              color: dimText,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Expression
                      SingleChildScrollView(
                        controller: _exprScroll,
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _logic.expression.isEmpty
                              ? '0'
                              : _logic.expression,
                          style: GoogleFonts.spaceMono(
                            color: dimText,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Result (long-press to copy)
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(
                              ClipboardData(text: _logic.displayResult));
                          if (AppSettings.haptic) {
                            HapticFeedback.mediumImpact();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Copied: ${_logic.displayResult}',
                                style: GoogleFonts.spaceMono(fontSize: 13),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: widget.isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                            ),
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _logic.displayResult,
                            style: GoogleFonts.spaceMono(
                              color: textColor,
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // ── Controls row ──────────────────────────────────────────────
              _ControlsRow(
                isDark: widget.isDark,
                isSci: _isSci,
                onToggleSci: () {
                  setState(() => _isSci = !_isSci);
                  _savePrefs();
                },
                onToggleDegRad: () {
                  setState(() => _logic.isDegree = !_logic.isDegree);
                  _savePrefs();
                },
                onHistory: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(
                      isDark: widget.isDark,
                      onRecall: (expr) {
                        setState(() {
                          _logic.expression = expr;
                          _logic.displayResult = expr;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // ── Scientific rows ───────────────────────────────────────────
              if (_isSci)
                Expanded(
                  flex: 4,
                  child: _ButtonGrid(
                    rows: _sciRows,
                    isDark: widget.isDark,
                    onTap: _handle,
                  ),
                ),

              // ── Standard rows ─────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: _ButtonGrid(
                  rows: _stdRows,
                  isDark: widget.isDark,
                  onTap: _handle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Controls row widget ────────────────────────────────────────────────────────

class _ControlsRow extends StatelessWidget {
  final bool isDark;
  final bool isSci;
  final VoidCallback onToggleSci;
  final VoidCallback onToggleDegRad;
  final VoidCallback onHistory;

  const _ControlsRow({
    required this.isDark,
    required this.isSci,
    required this.onToggleSci,
    required this.onToggleDegRad,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF2A0502) : const Color(0xFFFFE5A0);
    final border = isDark ? const Color(0xFF660B05) : const Color(0xFF8C1007);
    final fg = isDark ? AppColors.cream : AppColors.deepest;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        border: Border.symmetric(
          horizontal: BorderSide(color: border, width: 2),
        ),
      ),
      child: Row(
        children: [
          _Chip(
            label: isSci ? 'BASIC' : 'SCI',
            icon: Icons.functions,
            fg: fg,
            onTap: onToggleSci,
          ),
          _Divider(color: border),
          _Chip(
            label: 'DEG/RAD',
            icon: Icons.rotate_right,
            fg: fg,
            onTap: onToggleDegRad,
          ),
          _Divider(color: border),
          _Chip(
            label: 'HIST',
            icon: Icons.history,
            fg: fg,
            onTap: onHistory,
          ),
          _Divider(color: border),
          _Chip(
            label: 'HOME',
            icon: Icons.grid_view,
            fg: fg,
            onTap: () => goHome(context),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color fg;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 14),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                color: fg,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1.5, height: double.infinity, color: color);
}

// ── Button grid widget ─────────────────────────────────────────────────────────

typedef _BtnDef
    = (String label, BtnStyle style, int flex, String? sublabel);

class _ButtonGrid extends StatelessWidget {
  final List<List<_BtnDef>> rows;
  final bool isDark;
  final void Function(String) onTap;

  const _ButtonGrid({
    required this.rows,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
      children: rows
          .map(
            (row) => Expanded(
              child: Row(
                children: row
                    .map(
                      (def) => Expanded(
                        flex: def.$3,
                        child: CalcButton(
                          label: def.$4 ?? def.$1,
                          onTap: () => onTap(def.$1),
                          style: def.$2,
                          isDark: isDark,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
      ),
    );
  }
}
