// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreRecordAdapter extends TypeAdapter<ScoreRecord> {
  @override
  final int typeId = 2;

  @override
  ScoreRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreRecord(
      id: fields[0] as String,
      boardGame: fields[1] as BoardGame,
      createdAt: fields[2] as DateTime,
      scoreItems: (fields[3] as List).cast<ScoreItem>(),
      playerTotalScores: (fields[4] as List).cast<PlayerTotalScore>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScoreRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.boardGame)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.scoreItems)
      ..writeByte(4)
      ..write(obj.playerTotalScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoreItemAdapter extends TypeAdapter<ScoreItem> {
  @override
  final int typeId = 3;

  @override
  ScoreItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreItem(
      itemName: fields[0] as String,
      scores: (fields[1] as List).cast<PlayerScore>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScoreItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.itemName)
      ..writeByte(1)
      ..write(obj.scores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerScoreAdapter extends TypeAdapter<PlayerScore> {
  @override
  final int typeId = 4;

  @override
  PlayerScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerScore(
      player: fields[0] as User,
      scores: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerScore obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.player)
      ..writeByte(1)
      ..write(obj.scores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerTotalScoreAdapter extends TypeAdapter<PlayerTotalScore> {
  @override
  final int typeId = 5;

  @override
  PlayerTotalScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerTotalScore(
      player: fields[0] as User,
      total: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerTotalScore obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.player)
      ..writeByte(1)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerTotalScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
