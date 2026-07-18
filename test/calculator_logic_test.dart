import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/logic/calculator_logic.dart';

/// Types each character of [expr] through [CalculatorLogic.input], then
/// presses '='. Mirrors how CalcButton taps drive the logic in the UI.
String _evaluate(String expr, {bool isDegree = true}) {
  final logic = CalculatorLogic()..isDegree = isDegree;
  for (final ch in expr.split('')) {
    logic.input(ch);
  }
  logic.input('=');
  return logic.displayResult;
}

void main() {
  group('basic arithmetic', () {
    test('addition', () => expect(_evaluate('2+3'), '5'));
    test('subtraction', () => expect(_evaluate('10-4'), '6'));
    test('multiplication via ×', () {
      final logic = CalculatorLogic();
      logic.input('6');
      logic.input('×');
      logic.input('7');
      logic.input('=');
      expect(logic.displayResult, '42');
    });
    test('division via ÷', () {
      final logic = CalculatorLogic();
      logic.input('9');
      logic.input('÷');
      logic.input('2');
      logic.input('=');
      expect(logic.displayResult, '4.5');
    });
    test('division by zero is an error', () {
      final logic = CalculatorLogic();
      logic.input('5');
      logic.input('÷');
      logic.input('0');
      logic.input('=');
      expect(logic.displayResult, 'Error');
    });
    test('operator precedence', () => expect(_evaluate('2+3×4'), '14'));
    test('parentheses override precedence', () {
      final logic = CalculatorLogic();
      logic.input('(');
      logic.input('2');
      logic.input('+');
      logic.input('3');
      logic.input('()'); // closes paren
      logic.input('×');
      logic.input('4');
      logic.input('=');
      expect(logic.displayResult, '20');
    });
    test('auto-closes missing parens on evaluate', () {
      final logic = CalculatorLogic();
      logic.input('(');
      logic.input('2');
      logic.input('+');
      logic.input('3');
      logic.input('=');
      expect(logic.displayResult, '5');
    });
  });

  group('power, factorial, percent', () {
    test('power operator', () => expect(_evaluate('2^10'), '1024'));
    test('factorial', () {
      final logic = CalculatorLogic();
      logic.input('5');
      logic.input('!');
      logic.input('=');
      expect(logic.displayResult, '120');
    });
    test('unary minus binds looser than factorial: -1! is -(1!)', () {
      // Matches standard math convention (factorial binds tighter than
      // unary minus), so this is -(1!) = -1, not (-1)! which is undefined.
      final logic = CalculatorLogic();
      logic.input('-');
      logic.input('1');
      logic.input('!');
      logic.input('=');
      expect(logic.displayResult, '-1');
    });
    test('factorial of a negative number literal is an error', () {
      final logic = CalculatorLogic();
      logic.input('(');
      logic.input('-');
      logic.input('1');
      logic.input('()');
      logic.input('!');
      logic.input('=');
      expect(logic.displayResult, 'Error');
    });
    test('modulo via %', () {
      final logic = CalculatorLogic();
      logic.input('7');
      logic.input('%');
      logic.input('3');
      logic.input('=');
      expect(logic.displayResult, '1');
    });
  });

  group('scientific functions', () {
    test('sin(90) in degree mode', () {
      final logic = CalculatorLogic()..isDegree = true;
      for (final ch in 'sin('.split('')) {
        logic.input(ch);
      }
      logic.input('9');
      logic.input('0');
      logic.input('()');
      logic.input('=');
      expect(double.parse(logic.displayResult), closeTo(1.0, 1e-9));
    });
    test('sqrt of negative is an error', () {
      final logic = CalculatorLogic();
      for (final ch in 'sqrt('.split('')) {
        logic.input(ch);
      }
      logic.input('-');
      logic.input('1');
      logic.input('()');
      logic.input('=');
      expect(logic.displayResult, 'Error');
    });
    test('log domain error for non-positive input', () {
      final logic = CalculatorLogic();
      for (final ch in 'log('.split('')) {
        logic.input(ch);
      }
      logic.input('0');
      logic.input('()');
      logic.input('=');
      expect(logic.displayResult, 'Error');
    });
    test('pi constant', () {
      final logic = CalculatorLogic();
      logic.input('π');
      logic.input('=');
      expect(double.parse(logic.displayResult), closeTo(3.14159265, 1e-6));
    });
  });

  group('implicit multiplication', () {
    test('number before open paren', () => expect(_evaluate('2(3+4)'), '14'));
    test('number before pi', () {
      final logic = CalculatorLogic();
      logic.input('2');
      logic.input('π');
      logic.input('=');
      expect(double.parse(logic.displayResult), closeTo(2 * 3.141592653589793, 1e-6));
    });
  });

  group('input editing', () {
    test('backspace removes last character', () {
      final logic = CalculatorLogic();
      logic.input('1');
      logic.input('2');
      logic.input('3');
      logic.input('⌫');
      expect(logic.expression, '12');
    });
    test('backspace removes whole function token', () {
      final logic = CalculatorLogic();
      for (final ch in 'sin('.split('')) {
        logic.input(ch);
      }
      logic.input('⌫');
      expect(logic.expression, '');
    });
    test('clear resets everything', () {
      final logic = CalculatorLogic();
      logic.input('1');
      logic.input('+');
      logic.input('2');
      logic.input('C');
      expect(logic.expression, '');
      expect(logic.displayResult, '0');
    });
    test('consecutive operators replace, except leading minus', () {
      final logic = CalculatorLogic();
      logic.input('5');
      logic.input('+');
      logic.input('-');
      expect(logic.expression, '5+-');
      logic.input('3');
      logic.input('=');
      expect(logic.displayResult, '2');
    });
    test('starting a new number after = replaces expression', () {
      final logic = CalculatorLogic();
      logic.input('2');
      logic.input('+');
      logic.input('2');
      logic.input('=');
      expect(logic.displayResult, '4');
      logic.input('9');
      expect(logic.expression, '9');
    });
    test('operator after = continues from last result', () {
      final logic = CalculatorLogic();
      logic.input('2');
      logic.input('+');
      logic.input('2');
      logic.input('=');
      logic.input('+');
      logic.input('1');
      logic.input('=');
      expect(logic.displayResult, '5');
    });
  });

  group('sign toggle', () {
    test('toggles sign of trailing number back and forth', () {
      final logic = CalculatorLogic();
      logic.input('5');
      logic.input('±');
      expect(logic.expression, '-5');
      logic.input('±');
      expect(logic.expression, '5');
    });
    test('toggles sign after an operator', () {
      final logic = CalculatorLogic();
      logic.input('3');
      logic.input('+');
      logic.input('5');
      logic.input('±');
      expect(logic.expression, '3+-5');
      logic.input('±');
      expect(logic.expression, '3+5');
    });
    test('toggles sign of just-evaluated result', () {
      final logic = CalculatorLogic();
      logic.input('4');
      logic.input('=');
      logic.input('±');
      expect(logic.displayResult, '-4');
    });
  });

  group('live calculation toggle', () {
    test('updates displayResult while typing when enabled', () {
      final logic = CalculatorLogic()..liveCalc = true;
      logic.input('2');
      logic.input('+');
      logic.input('2');
      expect(logic.displayResult, '4');
    });
    test('does not update displayResult while typing when disabled', () {
      final logic = CalculatorLogic()..liveCalc = false;
      logic.input('2');
      logic.input('+');
      logic.input('2');
      expect(logic.displayResult, '0');
      logic.input('=');
      expect(logic.displayResult, '4');
    });
  });

  group('history', () {
    test('sets pendingHistory only after =', () {
      final logic = CalculatorLogic();
      logic.input('2');
      logic.input('+');
      logic.input('2');
      expect(logic.pendingHistory, isNull);
      logic.input('=');
      expect(logic.pendingHistory, ('2+2', '4'));
    });
    test('does not set pendingHistory on error', () {
      final logic = CalculatorLogic();
      logic.input('5');
      logic.input('÷');
      logic.input('0');
      logic.input('=');
      expect(logic.pendingHistory, isNull);
    });
  });
}
