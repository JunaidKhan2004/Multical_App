import 'package:flutter/widgets.dart';
import 'academic_screen.dart';
import 'calculator_screen.dart';
import 'currency_screen.dart';
import 'date_screen.dart';
import 'discount_screen.dart';
import 'financial_screen.dart';
import 'health_screen.dart';
import 'programmer_screen.dart';
import 'statistics_screen.dart';
import 'unit_screen.dart';

/// Builds the calculator screen for a given grid index (see [HomeScreen]'s
/// card order). Shared by [HomeScreen] (tapping a card) and [SplashScreen]
/// (launching straight into the user's default calculator).
Widget buildCalcScreen(
  int index, {
  required bool isDark,
  required VoidCallback onToggleDark,
}) {
  return switch (index) {
    0 => CalculatorScreen(isDark: isDark, onToggleDark: onToggleDark),
    1 => ProgrammerScreen(isDark: isDark, onToggleDark: onToggleDark),
    2 => FinancialScreen(isDark: isDark, onToggleDark: onToggleDark),
    3 => UnitScreen(isDark: isDark, onToggleDark: onToggleDark),
    4 => StatisticsScreen(isDark: isDark, onToggleDark: onToggleDark),
    5 => DateScreen(isDark: isDark, onToggleDark: onToggleDark),
    6 => HealthScreen(isDark: isDark, onToggleDark: onToggleDark),
    7 => AcademicScreen(isDark: isDark, onToggleDark: onToggleDark),
    8 => DiscountScreen(isDark: isDark, onToggleDark: onToggleDark),
    9 => CurrencyScreen(isDark: isDark, onToggleDark: onToggleDark),
    _ => CalculatorScreen(isDark: isDark, onToggleDark: onToggleDark),
  };
}
