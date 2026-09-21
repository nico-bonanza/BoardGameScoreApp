import 'package:hive/hive.dart';
import 'hive_type_ids.dart';

part 'board_game.g.dart';

// ボードゲーム
@HiveType(typeId: HiveTypeIds.boardGame)
class BoardGame extends HiveObject{
  @HiveField(0)
  String id; // 固定値（UUID？"carcassonne"みたいな名称？）

  @HiveField(1)
  String title; // タイトル名

  BoardGame({required this.id, required this.title});

  // firestoreへの変換map
  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
    };
  }
}
