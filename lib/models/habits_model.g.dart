// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitsModelAdapter extends TypeAdapter<HabitsModel> {
  @override
  final int typeId = 1;

  @override
  HabitsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitsModel()
      ..habitName = fields[0] as String
      ..habitDescription = fields[1] as String
      ..habitCompleted = fields[2] as bool
      ..streakCount = fields[3] as int
      ..lastCompletedDate = fields[4] as DateTime?
      ..alarmHour = fields[5] as int?
      ..alarmMinute = fields[6] as int?;
  }

  @override
  void write(BinaryWriter writer, HabitsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.habitName)
      ..writeByte(1)
      ..write(obj.habitDescription)
      ..writeByte(2)
      ..write(obj.habitCompleted)
      ..writeByte(3)
      ..write(obj.streakCount)
      ..writeByte(4)
      ..write(obj.lastCompletedDate)
      ..writeByte(5)
      ..write(obj.alarmHour)
      ..writeByte(6)
      ..write(obj.alarmMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
