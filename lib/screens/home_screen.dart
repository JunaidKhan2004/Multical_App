import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'calc_screens.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDark = true;
  static const _cards = [
    _CalcCard(
      icon: Icons.calculate_outlined,
      title: 'Calculator',
      subtitle: 'Basic & Scientific',
      tag: 'CALC',
    ),
    _CalcCard(
      icon: Icons.memory_outlined,
      title: 'Programmer',
      subtitle: 'HEX · DEC · OCT · BIN',
      tag: 'PROG',
    ),
    _CalcCard(
      icon: Icons.account_balance_outlined,
      title: 'Financial',
      subtitle: 'EMI · Interest · Tax',
      tag: 'FIN',
    ),
    _CalcCard(
      icon: Icons.swap_horiz,
      title: 'Unit Converter',
      subtitle: 'Length · Weight · Temp…',
      tag: 'UNIT',
    ),
    _CalcCard(
      icon: Icons.bar_chart,
      title: 'Statistics',
      subtitle: 'Mean · SD · Variance…',
      tag: 'STAT',
    ),
    _CalcCard(
      icon: Icons.calendar_today_outlined,
      title: 'Date & Time',
      subtitle: 'Age · Diff · Add/Sub',
      tag: 'DATE',
    ),
    _CalcCard(
      icon: Icons.favorite_outline,
      title: 'Health',
      subtitle: 'BMI · BMR · Calories',
      tag: 'HLTH',
    ),
    _CalcCard(
      icon: Icons.school_outlined,
      title: 'Academic',
      subtitle: 'GPA · CGPA · Target',
      tag: 'GPA',
    ),
    _CalcCard(
      icon: Icons.local_offer_outlined,
      title: 'Discount',
      subtitle: 'Sale · Markup · Compare',
      tag: 'DISC',
    ),
    _CalcCard(
      icon: Icons.currency_exchange,
      title: 'Currency',
      subtitle: 'PKR · USD · EUR · GBP…',
      tag: 'CURR',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _isDark = p.getBool('isDark') ?? true);
  }

  Future<void> _toggleDark() async {
    setState(() => _isDark = !_isDark);
    final p = await SharedPreferences.getInstance();
    await p.setBool('isDark', _isDark);
  }

  void _open(int index) {
    final screen = buildCalcScreen(
      index,
      isDark: _isDark,
      onToggleDark: _toggleDark,
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    ).then((_) => _loadPrefs()); // refresh dark mode if toggled inside
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = _isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = _isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = _isDark ? AppColors.dark : AppColors.medium;
    final shadow = _isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Theme(
      data: _isDark ? AppTheme.dark : AppTheme.light,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                decoration: BoxDecoration(
                  color: surface,
                  border:
                      Border(bottom: BorderSide(color: borderColor, width: 3)),
                  boxShadow: [
                    BoxShadow(
                        color: shadow,
                        offset: const Offset(0, 4),
                        blurRadius: 0),
                  ],
                ),
                child: Row(
                  children: [
                    // App name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MULTICAL',
                          style: GoogleFonts.spaceMono(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          'ALL-IN-ONE CALCULATOR',
                          style: GoogleFonts.spaceMono(
                            color: textColor.withAlpha(130),
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // History button
                    _IconBtn(
                      icon: Icons.history,
                      isDark: _isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryScreen(
                            isDark: _isDark,
                            onRecall: (_) {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Settings button
                    _IconBtn(
                      icon: Icons.settings_outlined,
                      isDark: _isDark,
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => SettingsScreen(
                            isDark: _isDark,
                            onToggleDark: _toggleDark,
                          ),
                          transitionsBuilder: (_, anim, __, child) =>
                              SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                                parent: anim, curve: Curves.easeOut)),
                            child: child,
                          ),
                          transitionDuration:
                              const Duration(milliseconds: 250),
                        ),
                      ).then((_) => _loadPrefs()),
                    ),
                  ],
                ),
              ),

              // ── Greeting ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'SELECT CALCULATOR',
                  style: GoogleFonts.spaceMono(
                    color: textColor.withAlpha(120),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),

              // ── Grid ───────────────────────────────────────────────────────
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (_, i) => _GridCard(
                    card: _cards[i],
                    isDark: _isDark,
                    onTap: () => _open(i),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _CalcCard {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  const _CalcCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
  });
}

// ── Grid card widget ──────────────────────────────────────────────────────────

class _GridCard extends StatefulWidget {
  final _CalcCard card;
  final bool isDark;
  final VoidCallback onTap;
  const _GridCard(
      {required this.card, required this.isDark, required this.onTap});
  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard> {
  bool _pressed = false;

  static const _offset = 5.0;

  @override
  Widget build(BuildContext context) {
    final face =
        widget.isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = widget.isDark ? AppColors.dark : AppColors.medium;
    final shadow = widget.isDark ? AppColors.darkShadow : AppColors.lightShadow;
    final textColor = widget.isDark ? AppColors.cream : AppColors.deepest;
    final tagBg = widget.isDark ? AppColors.dark : AppColors.medium;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(
          _pressed ? _offset : 0,
          _pressed ? _offset : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: face,
          border: Border.all(color: border, width: 2.5),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: shadow,
                    offset: const Offset(_offset, _offset),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              color: tagBg,
              child: Text(
                widget.card.tag,
                style: GoogleFonts.spaceMono(
                  color: AppColors.cream,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const Spacer(),
            // Icon
            Icon(widget.card.icon,
                color: textColor, size: 32),
            const SizedBox(height: 8),
            // Title
            Text(
              widget.card.title,
              style: GoogleFonts.spaceMono(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            // Subtitle
            Text(
              widget.card.subtitle,
              style: GoogleFonts.spaceMono(
                color: textColor.withAlpha(140),
                fontSize: 9,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small icon button ─────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkButton : AppColors.lightButton;
    final shadow = isDark ? AppColors.darkShadow : AppColors.lightShadow;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: shadow, width: 2),
          boxShadow: [
            BoxShadow(
                color: shadow, offset: const Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Icon(icon, color: AppColors.cream, size: 20),
      ),
    );
  }
}
