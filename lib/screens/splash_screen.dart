import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import 'calc_screens.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _init();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    _isDark = p.getBool('isDark') ?? true;
    // Default Calculator picker is disabled (see settings_screen.dart) —
    // always land on the home grid, even if an older build already saved
    // a non-zero value for this device.
    const defaultCalc = 0;
    await AppSettings.load();

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CalculationHistoryAdapter());
    }
    if (!Hive.isBoxOpen('history')) {
      await Hive.openBox<CalculationHistory>('history');
    }

    _ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    // Index 0 = home grid; 1-10 map to buildCalcScreen's 0-9.
    final destination = defaultCalc == 0
        ? const HomeScreen()
        : buildCalcScreen(
            defaultCalc - 1,
            isDark: _isDark,
            onToggleDark: _toggleDark,
          );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _toggleDark() async {
    _isDark = !_isDark;
    final p = await SharedPreferences.getInstance();
    await p.setBool('isDark', _isDark);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = _isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = _isDark ? AppColors.cream : AppColors.deepest;
    final borderColor = _isDark ? AppColors.dark : AppColors.medium;
    final shadow = _isDark ? AppColors.darkShadow : AppColors.lightShadow;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo box
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: borderColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: shadow,
                        offset: const Offset(7, 7),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '∑',
                      style: GoogleFonts.spaceMono(
                        color: textColor,
                        fontSize: 62,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // App name
                Text(
                  'MULTICAL',
                  style: GoogleFonts.spaceMono(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  color: borderColor,
                  child: Text(
                    'ALL-IN-ONE CALCULATOR',
                    style: GoogleFonts.spaceMono(
                      color: AppColors.cream,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Loading dots
                _LoadingDots(isDark: _isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  final bool isDark;
  const _LoadingDots({required this.isDark});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? AppColors.cream : AppColors.deepest;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final active = (t * 3).floor() == i;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              color: color.withAlpha(active ? 255 : 80),
            );
          }),
        );
      },
    );
  }
}
