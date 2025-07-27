// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordItemAdapter extends TypeAdapter<RecordItem> {
  @override
  final int typeId = 3;

  @override
  RecordItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordItem(
      id: fields[0] as String,
      recordId: fields[1] as String,
      userId: fields[2] as String,
      scoringCategoryId: fields[3] as String,
      score: fields[4] as int?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecordItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recordId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.scoringCategoryId)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
