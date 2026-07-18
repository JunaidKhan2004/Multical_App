import 'package:flutter/material.dart';
import 'home_screen.dart';

/// Returns to the home grid. Pops if this screen was pushed on top of
/// something (the normal case, tapping a card from [HomeScreen]); otherwise
/// this screen is the only route (launched directly as the user's default
/// calculator from splash) so it replaces itself with [HomeScreen] instead.
void goHome(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
