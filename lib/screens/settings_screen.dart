import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_settings.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brut_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleDark;
  const SettingsScreen(
      {super.key, required this.isDark, required this.onToggleDark});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDark = widget.isDark;
  bool _haptic = true;
  bool _liveCalc = true;
  int _historyLimit = 100;
  int _defaultCalc = 0;

  // Default Calculator feature disabled for now (see below).
  // Index 0 = show the home grid (default). Indices 1-10 map to
  // buildCalcScreen's 0-9 (subtract 1 before passing it in).
  // static const _calcNames = [
  //   'Home Grid',
  //   'Calculator', 'Programmer', 'Financial', 'Unit Converter',
  //   'Statistics', 'Date & Time', 'Health', 'Academic / GPA',
  //   'Discount', 'Currency',
  // ];

  static const _historyLimits = [25, 50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _isDark = p.getBool('isDark') ?? true;
      _haptic = p.getBool('haptic') ?? true;
      _liveCalc = p.getBool('liveCalc') ?? true;
      _historyLimit = p.getInt('historyLimit') ?? 100;
      _defaultCalc = p.getInt('defaultCalc') ?? 0;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('haptic', _haptic);
    await p.setBool('liveCalc', _liveCalc);
    await p.setInt('historyLimit', _historyLimit);
    await p.setInt('defaultCalc', _defaultCalc);
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Theme(
        data: _isDark ? ThemeData.dark() : ThemeData.light(),
        child: AlertDialog(
          backgroundColor: _isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero),
          title: Text('Clear History?',
              style: GoogleFonts.spaceMono(
                  color: _isDark ? AppColors.cream : AppColors.deepest,
                  fontWeight: FontWeight.bold)),
          content: Text('All saved calculations will be deleted.',
              style: GoogleFonts.spaceMono(
                  color: (_isDark ? AppColors.cream : AppColors.deepest)
                      .withAlpha(180),
                  fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('CANCEL',
                  style: GoogleFonts.spaceMono(
                      color: _isDark ? AppColors.cream : AppColors.deepest,
                      fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('DELETE',
                  style: GoogleFonts.spaceMono(
                      color: const Color(0xFFE57373),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      HistoryService().clearAll();
      if (mounted) {
        if (AppSettings.haptic) HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('History cleared.',
              style: GoogleFonts.spaceMono(fontSize: 13)),
          backgroundColor: _isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface =
        _isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = _isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = _isDark ? AppColors.dark : AppColors.medium;
    final dimColor = textColor.withAlpha(140);

    return Scaffold(
      backgroundColor: bg,
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: textColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('SETTINGS',
                      style: GoogleFonts.spaceMono(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Appearance ───────────────────────────────────────────
                    BrutSection(title: 'Appearance', isDark: _isDark),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      title: 'Dark Mode',
                      subtitle: _isDark ? 'Dark theme is ON' : 'Light theme is ON',
                      isDark: _isDark,
                      trailing: _BrutSwitch(
                        value: _isDark,
                        isDark: _isDark,
                        onChanged: (_) async {
                          setState(() => _isDark = !_isDark);
                          widget.onToggleDark();
                          final p = await SharedPreferences.getInstance();
                          await p.setBool('isDark', _isDark);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Behaviour ────────────────────────────────────────────
                    BrutSection(title: 'Behaviour', isDark: _isDark),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      title: 'Haptic Feedback',
                      subtitle: 'Vibrate on button press',
                      isDark: _isDark,
                      trailing: _BrutSwitch(
                        value: _haptic,
                        isDark: _isDark,
                        onChanged: (v) {
                          setState(() => _haptic = v);
                          AppSettings.setHaptic(v);
                          _save();
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      title: 'Live Calculation',
                      subtitle: 'Show result while typing',
                      isDark: _isDark,
                      trailing: _BrutSwitch(
                        value: _liveCalc,
                        isDark: _isDark,
                        onChanged: (v) {
                          setState(() => _liveCalc = v);
                          _save();
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Default Calculator ───────────────────────────────────
                    // Feature disabled for now.
                    // BrutSection(
                    //     title: 'Default Calculator', isDark: _isDark),
                    // const SizedBox(height: 4),
                    // Text('Screen shown right after launch',
                    //     style: GoogleFonts.spaceMono(
                    //         color: dimColor, fontSize: 10)),
                    // const SizedBox(height: 10),
                    // Container(
                    //   decoration: BoxDecoration(
                    //     color: _isDark
                    //         ? AppColors.darkButton
                    //         : AppColors.lightSurface,
                    //     border: Border.all(
                    //         color: _isDark
                    //             ? AppColors.darkShadow
                    //             : AppColors.lightShadow,
                    //         width: 2.5),
                    //     boxShadow: [
                    //       BoxShadow(
                    //           color: _isDark
                    //               ? AppColors.darkShadow
                    //               : AppColors.lightShadow,
                    //           offset: const Offset(4, 4),
                    //           blurRadius: 0)
                    //     ],
                    //   ),
                    //   padding: const EdgeInsets.symmetric(horizontal: 12),
                    //   child: DropdownButton<int>(
                    //     value: _defaultCalc,
                    //     isExpanded: true,
                    //     dropdownColor: _isDark
                    //         ? AppColors.darkButton
                    //         : AppColors.lightSurface,
                    //     underline: const SizedBox(),
                    //     icon: Icon(Icons.expand_more, color: textColor),
                    //     style: GoogleFonts.spaceMono(
                    //         color: textColor,
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.bold),
                    //     items: _calcNames
                    //         .asMap()
                    //         .entries
                    //         .map((e) => DropdownMenuItem(
                    //               value: e.key,
                    //               child: Text(e.value,
                    //                   style: GoogleFonts.spaceMono(
                    //                       color: textColor, fontSize: 13)),
                    //             ))
                    //         .toList(),
                    //     onChanged: (i) {
                    //       if (i != null) {
                    //         setState(() => _defaultCalc = i);
                    //         _save();
                    //       }
                    //     },
                    //   ),
                    // ),

                    // const SizedBox(height: 20),

                    // ── History ──────────────────────────────────────────────
                    BrutSection(title: 'History', isDark: _isDark),
                    const SizedBox(height: 12),
                    Text('MAX SAVED ENTRIES',
                        style: GoogleFonts.spaceMono(
                            color: dimColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: _historyLimits.map((limit) {
                        final active = limit == _historyLimit;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _historyLimit = limit);
                              _save();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: active
                                    ? (_isDark
                                        ? AppColors.cream
                                        : AppColors.deepest)
                                    : (_isDark
                                        ? AppColors.darkSurface
                                        : AppColors.lightSurface),
                                border: Border.all(
                                    color: _isDark
                                        ? AppColors.darkShadow
                                        : AppColors.lightShadow,
                                    width: 2),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                            color: _isDark
                                                ? AppColors.darkShadow
                                                : AppColors.lightShadow,
                                            offset: const Offset(3, 3),
                                            blurRadius: 0)
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  limit.toString(),
                                  style: GoogleFonts.spaceMono(
                                      color: active
                                          ? (_isDark
                                              ? AppColors.deepest
                                              : AppColors.cream)
                                          : textColor.withAlpha(150),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Clear history button
                    GestureDetector(
                      onTap: _clearHistory,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A0000),
                          border: Border.all(
                              color: const Color(0xFF3E0000), width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFF3E0000),
                                offset: Offset(4, 4),
                                blurRadius: 0)
                          ],
                        ),
                        child: Center(
                          child: Text('CLEAR ALL HISTORY',
                              style: GoogleFonts.spaceMono(
                                  color: AppColors.cream,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── About ────────────────────────────────────────────────
                    BrutSection(title: 'About', isDark: _isDark),
                    const SizedBox(height: 12),
                    _InfoTile(
                        label: 'App', value: 'Multical', isDark: _isDark),
                    const SizedBox(height: 8),
                    _InfoTile(
                        label: 'Version',
                        value: '1.0.0',
                        isDark: _isDark),
                    const SizedBox(height: 8),
                    _InfoTile(
                        label: 'Calculators',
                        value: '10 types',
                        isDark: _isDark),
                    const SizedBox(height: 8),
                    _InfoTile(
                        label: 'Database',
                        value: 'Hive (offline)',
                        isDark: _isDark),
                    const SizedBox(height: 8),
                    _InfoTile(
                        label: 'Theme',
                        value: 'Brutalism',
                        isDark: _isDark),
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

// ── Settings tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.spaceMono(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.spaceMono(
                        color: textColor.withAlpha(140), fontSize: 10)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ── Brutalism toggle switch ───────────────────────────────────────────────────
class _BrutSwitch extends StatelessWidget {
  final bool value;
  final bool isDark;
  final void Function(bool) onChanged;

  const _BrutSwitch({
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark ? AppColors.cream : AppColors.deepest;
    final inactiveBg = isDark ? AppColors.darkButton : AppColors.lightButton;
    final knobColor = value
        ? (isDark ? AppColors.deepest : AppColors.cream)
        : AppColors.cream.withAlpha(180);
    final border = isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: value ? activeBg : inactiveBg,
          border: Border.all(color: border, width: 2),
          boxShadow: [
            BoxShadow(color: border, offset: const Offset(2, 2), blurRadius: 0)
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 18,
            height: 18,
            color: knobColor,
          ),
        ),
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoTile(
      {required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.cream : AppColors.deepest;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.spaceMono(
                color: textColor.withAlpha(140),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        Text(value,
            style: GoogleFonts.spaceMono(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
