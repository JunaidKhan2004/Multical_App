import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';

class HistoryService {
  static const _boxName = 'history';
  static const _defaultLimit = 100;

  Box<CalculationHistory> get _box => Hive.box<CalculationHistory>(_boxName);

  List<CalculationHistory> getAll() =>
      _box.values.toList().reversed.toList();

  Future<void> save(String expression, String result) async {
    await _box.add(CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    ));
    final p = await SharedPreferences.getInstance();
    final limit = p.getInt('historyLimit') ?? _defaultLimit;
    while (_box.length > limit) {
      await _box.deleteAt(0);
    }
  }

  Future<void> clearAll() => _box.clear();
}
