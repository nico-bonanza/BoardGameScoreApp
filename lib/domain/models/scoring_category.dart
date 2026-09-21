import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_score_app/domain/models/hive_type_ids.dart';
import 'package:hive/hive.dart';

part 'scoring_category.g.dart';

// 得点項目
@HiveType(typeId: HiveTypeIds.scoringCategory)
class ScoringCategory extends HiveObject {
  @HiveField(0)
  String id; // uuid
  @HiveField(1)
  String boardGameId; // 外部キー：ボドゲID
  @HiveField(2)
  String name; // 項目名
  @HiveField(3)
  DateTime createdAt; // 作成日
  @HiveField(4)
  DateTime updatedAt; // 更新日
  @HiveField(5)
  bool isDelete; // 削除フラグ

  ScoringCategory({
    required this.id,
    required this.boardGameId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    bool? isDelete = false, // 初期値はfalse
  }) : isDelete = isDelete ?? false;

  // firestoreへの変換map
  Map<String, dynamic> toFirestoreMap() {
    return {
      'boardGameId': boardGameId,
      'name': name,
      'isDelete': isDelete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
