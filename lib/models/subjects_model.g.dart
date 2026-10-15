// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectsModelAdapter extends TypeAdapter<SubjectsModel> {
  @override
  final int typeId = 2;

  @override
  SubjectsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectsModel()
      ..subjectName = fields[0] as String
      ..subjectDescription = fields[1] as String
      ..teacherName = fields[2] as String?
      ..id = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, SubjectsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.subjectName)
      ..writeByte(1)
      ..write(obj.subjectDescription)
      ..writeByte(2)
      ..write(obj.teacherName)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
