import 'package:hive/hive.dart';

class CalculationHistory extends HiveObject {
  late String expression;
  late String result;
  late DateTime timestamp;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

class CalculationHistoryAdapter extends TypeAdapter<CalculationHistory> {
  @override
  final int typeId = 0;

  @override
  CalculationHistory read(BinaryReader reader) {
    return CalculationHistory(
      expression: reader.readString(),
      result: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CalculationHistory obj) {
    writer.writeString(obj.expression);
    writer.writeString(obj.result);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
