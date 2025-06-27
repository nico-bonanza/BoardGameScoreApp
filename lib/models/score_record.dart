import 'package:hive/hive.dart';
import 'user.dart';
import 'board_game.dart';
import 'hive_type_ids.dart';

part 'score_record.g.dart';

// ゲーム記録
@HiveType(typeId: HiveTypeIds.scoreRecord)
class ScoreRecord extends HiveObject {
  @HiveField(0)
  String id; // UUID

  @HiveField(1)
  BoardGame boardGame; // ボードゲーム情報

  @HiveField(2)
  DateTime createdAt; // 作成日

  @HiveField(3)
  List<ScoreItem> scoreItems; // 項目記録

  @HiveField(4)
  List<PlayerTotalScore> playerTotalScores; // プレイヤーの合計点

  ScoreRecord({
    required this.id,
    required this.boardGame,
    required this.createdAt,
    required this.scoreItems,
    required this.playerTotalScores,
  });
}

// 得点項目
@HiveType(typeId: HiveTypeIds.scoreItem)
class ScoreItem {
  @HiveField(0)
  String itemName; // 項目名

  @HiveField(1)
  List<PlayerScore> scores; // プレイヤーの項目得点

  ScoreItem({
    required this.itemName,
    required this.scores,
  });
}

// プレイヤーの項目得点
@HiveType(typeId: HiveTypeIds.playerScore)
class PlayerScore {
  @HiveField(0)
  User player; // プレイヤー

  @HiveField(1) // 項目得点
  int scores;

  PlayerScore({
    required this.player,
    required this.scores,
  });
}

// プレイヤーの合計点
@HiveType(typeId: HiveTypeIds.playerTotalScore)
class PlayerTotalScore {
  @HiveField(0)
  User player; // プレイヤー

  @HiveField(1)
  int total; // 合計点

  PlayerTotalScore({
    required this.player,
    required this.total,
  });
}
