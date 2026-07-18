import 'dart:math' as math;

class CalculatorLogic {
  String expression = '';
  String displayResult = '0';
  bool isDegree = true;
  bool liveCalc = true;
  bool _justEvaluated = false;
  String _lastResult = '';

  // Pending history entry to be saved by the screen
  (String expr, String result)? pendingHistory;

  static const _funcTokens = [
    'asin(', 'acos(', 'atan(',
    'sin(', 'cos(', 'tan(',
    'sqrt(', 'log(', 'ln(', 'exp(',
  ];

  void input(String value) {
    pendingHistory = null;

    switch (value) {
      case 'C':
        expression = '';
        displayResult = '0';
        _justEvaluated = false;
        _lastResult = '';

      case '⌫':
        if (_justEvaluated) {
          expression = '';
          displayResult = '0';
          _justEvaluated = false;
          _lastResult = '';
          break;
        }
        if (expression.isEmpty) break;
        bool removed = false;
        for (final token in _funcTokens) {
          if (expression.endsWith(token)) {
            expression = expression.substring(0, expression.length - token.length);
            removed = true;
            break;
          }
        }
        if (!removed) {
          expression = expression.substring(0, expression.length - 1);
        }
        if (expression.isEmpty) {
          displayResult = '0';
        } else {
          _tryLive();
        }

      case '=':
        if (expression.isEmpty) break;
        _evaluate(saveHistory: true);

      case 'DEG/RAD':
        isDegree = !isDegree;

      case '±':
        _toggleSign();

      case '()':
        _insertParen();

      default:
        _append(value);
    }
  }

  void _append(String value) {
    final isOp = '+-×÷^%'.contains(value) && value.length == 1;

    if (_justEvaluated) {
      if (isOp) {
        expression = _lastResult + value;
      } else {
        expression = value;
      }
      _justEvaluated = false;
    } else {
      // Replace consecutive operator (except allowing '-' for negation)
      if (isOp && expression.isNotEmpty) {
        final last = expression[expression.length - 1];
        if ('+-×÷^%'.contains(last) && value != '-') {
          expression = expression.substring(0, expression.length - 1) + value;
          _tryLive();
          return;
        }
      }
      // Implicit × before '(' or functions or constants if last char is digit/)/constant
      if (expression.isNotEmpty) {
        final last = expression[expression.length - 1];
        final lastIsValue = RegExp(r'[\d)π]').hasMatch(last);
        final valueOpensGroup =
            value == '(' || value.endsWith('(') || value == 'π' || value == 'e';
        if (lastIsValue && valueOpensGroup) {
          expression += '×';
        }
      }
      expression += value;
    }
    _tryLive();
  }

  void _tryLive() {
    if (!liveCalc) return;
    try {
      final val = _Evaluator(expression, isDegree).eval();
      if (!val.isNaN && !val.isInfinite) {
        displayResult = _fmt(val);
      }
    } catch (_) {}
  }

  void _evaluate({bool saveHistory = false}) {
    // Auto-close missing parens
    final open = '('.allMatches(expression).length;
    final close = ')'.allMatches(expression).length;
    final full = expression + ')' * (open - close).clamp(0, 20);

    try {
      final val = _Evaluator(full, isDegree).eval();
      final formatted = _fmt(val);
      displayResult = formatted;
      _lastResult = formatted;
      if (saveHistory && !val.isNaN && !val.isInfinite) {
        pendingHistory = (expression, formatted);
      }
      _justEvaluated = true;
    } catch (_) {
      displayResult = 'Error';
    }
  }

  void _toggleSign() {
    if (expression.isEmpty) {
      expression = '-';
      _tryLive();
      return;
    }
    if (_justEvaluated) {
      final n = double.tryParse(_lastResult);
      if (n != null) {
        final toggled = _fmt(-n);
        expression = toggled;
        displayResult = toggled;
        _lastResult = toggled;
      }
      return;
    }
    // Toggle sign of the trailing number token. Found by matching just the
    // digits/constant at the end, then looking at what (if anything)
    // precedes it to decide whether a '-' right before it is a binary
    // operator or the number's own sign — a single combined regex can't
    // tell those apart because '-' plays both roles.
    final numMatch = RegExp(r'(\d+\.?\d*|π|e)$').firstMatch(expression);
    if (numMatch != null) {
      final num = numMatch.group(1)!;
      var pre = expression.substring(0, numMatch.start);
      final hasSign = pre.endsWith('-') &&
          (pre.length == 1 || '+-×÷^%('.contains(pre[pre.length - 2]));
      if (hasSign) {
        pre = pre.substring(0, pre.length - 1);
        expression = '$pre$num';
      } else {
        expression = '$pre-$num';
      }
      _tryLive();
    }
  }

  void _insertParen() {
    final open = '('.allMatches(expression).length;
    final close = ')'.allMatches(expression).length;
    final last = expression.isEmpty ? '' : expression[expression.length - 1];
    final needsOpen = expression.isEmpty ||
        '(+-×÷^%'.contains(last) ||
        open == close;
    expression += needsOpen ? '(' : ')';
    _tryLive();
  }

  String _fmt(double n) {
    if (n.isInfinite) return n > 0 ? '∞' : '-∞';
    if (n.isNaN) return 'Error';
    if (n == n.truncateToDouble() && n.abs() < 1e15) {
      return n.toInt().toString();
    }
    String s = n.toStringAsPrecision(10);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
}

// ──────────────────────────────────────────────
// Recursive-descent expression evaluator
// ──────────────────────────────────────────────
class _Evaluator {
  final bool isDeg;
  late final String src;
  int p = 0;

  _Evaluator(String raw, this.isDeg) {
    src = raw.replaceAll('×', '*').replaceAll('÷', '/').trim();
  }

  double eval() {
    if (src.isEmpty) return 0;
    final v = _expr();
    _ws();
    if (p < src.length) throw Exception('Unexpected: ${src[p]}');
    return v;
  }

  String get c => p < src.length ? src[p] : '';
  void _ws() {
    while (p < src.length && src[p] == ' ') {
      p++;
    }
  }

  double _expr() {
    double v = _term();
    _ws();
    while (c == '+' || c == '-') {
      final op = c; p++;
      v = op == '+' ? v + _term() : v - _term();
      _ws();
    }
    return v;
  }

  double _term() {
    double v = _power();
    _ws();
    while (true) {
      if (c == '*') {
        p++;
        v *= _power();
      } else if (c == '/') {
        p++;
        final d = _power();
        if (d == 0) throw Exception('Division by zero');
        v /= d;
      } else if (c == '%') {
        p++;
        v %= _power();
      } else if (src.length - p >= 3 && src.substring(p, p + 3) == 'mod') {
        p += 3;
        v %= _power();
      } else {
        break;
      }
      _ws();
    }
    return v;
  }

  double _power() {
    double v = _unary();
    _ws();
    if (c == '^') {
      p++;
      v = math.pow(v, _unary()).toDouble();
    }
    return v;
  }

  double _unary() {
    _ws();
    if (c == '-') { p++; return -_fact(); }
    if (c == '+') { p++; }
    return _fact();
  }

  double _fact() {
    double v = _primary();
    _ws();
    if (c == '!') {
      p++;
      if (v < 0 || v > 20 || v != v.truncateToDouble()) {
        throw Exception('Bad factorial');
      }
      v = _factorial(v.toInt()).toDouble();
    }
    return v;
  }

  double _primary() {
    _ws();
    if (p >= src.length) throw Exception('Unexpected end');

    if (c == 'π') { p++; return math.pi; }

    if (c == '(') {
      p++;
      final v = _expr();
      _ws();
      if (c == ')') p++;
      return v;
    }

    if (c == '-') { p++; return -_primary(); }

    if (_dig(c) || c == '.') return _num();

    if (_alpha(c)) {
      final name = _ident();
      if (name == 'e') return math.e;
      if (name == 'pi') return math.pi;
      return _fn(name);
    }

    throw Exception('Unexpected: $c');
  }

  double _fn(String name) {
    _ws();
    if (c != '(') throw Exception('Expected ( after $name');
    p++;
    final arg = _expr();
    _ws();
    if (c == ')') p++;
    return switch (name) {
      'sin'  => math.sin(_r(arg)),
      'cos'  => math.cos(_r(arg)),
      'tan'  => math.tan(_r(arg)),
      'asin' => _d(math.asin(arg)),
      'acos' => _d(math.acos(arg)),
      'atan' => _d(math.atan(arg)),
      'sqrt' => arg < 0 ? throw Exception('sqrt of negative') : math.sqrt(arg),
      'log'  => arg <= 0 ? throw Exception('log domain error') : math.log(arg) / math.ln10,
      'ln'   => arg <= 0 ? throw Exception('ln domain error') : math.log(arg),
      'exp'  => math.exp(arg),
      'abs'  => arg.abs(),
      _      => throw Exception('Unknown: $name'),
    };
  }

  double _r(double v) => isDeg ? v * math.pi / 180 : v;
  double _d(double v) => isDeg ? v * 180 / math.pi : v;

  double _num() {
    final start = p;
    while (p < src.length && (_dig(c) || c == '.')) {
      p++;
    }
    // Handle scientific notation (e.g. 1.5e10)
    if (p < src.length && (c == 'e' || c == 'E')) {
      final nx = p + 1 < src.length ? src[p + 1] : '';
      if (_dig(nx) || nx == '+' || nx == '-') {
        p++;
        if (c == '+' || c == '-') {
          p++;
        }
        while (p < src.length && _dig(c)) {
          p++;
        }
      }
    }
    return double.parse(src.substring(start, p));
  }

  String _ident() {
    final start = p;
    while (p < src.length && _alpha(c)) {
      p++;
    }
    return src.substring(start, p);
  }

  bool _dig(String ch) =>
      ch.isNotEmpty && ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

  bool _alpha(String ch) =>
      ch.isNotEmpty &&
      ((ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90) ||
       (ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122));

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }
}
