// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoring_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoringCategoryAdapter extends TypeAdapter<ScoringCategory> {
  @override
  final int typeId = 4;

  @override
  ScoringCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoringCategory(
      id: fields[0] as String,
      boardGameId: fields[1] as String,
      name: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      isDelete: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ScoringCategory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.boardGameId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isDelete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoringCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
