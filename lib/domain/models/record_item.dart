import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_score_app/domain/models/hive_type_ids.dart';
import 'package:hive/hive.dart';

part 'record_item.g.dart';

// 記録ID-ユーザID-得点項目ID-得点
@HiveType(typeId: HiveTypeIds.recordItem)
class RecordItem extends HiveObject {
  @HiveField(0)
  String id; // uuid
  @HiveField(1)
  String recordId; // 外部キー：記録ID
  @HiveField(2)
  String userId; // 外部キー：ユーザーID
  @HiveField(3)
  String scoringCategoryId; // 外部キー：得点項目ID
  @HiveField(4)
  int? score; // 得点
  @HiveField(5)
  DateTime createdAt; // 作成日
  @HiveField(6)
  DateTime updatedAt; // 更新日
  @HiveField(7)
  int? rowNumber; // 項目順

  RecordItem({
    required this.id,
    required this.recordId,
    required this.userId,
    required this.scoringCategoryId,
    this.score,
    required this.createdAt,
    required this.updatedAt,
    this.rowNumber,
  });

  // firestoreへの変換map
  Map<String, dynamic> toFirestoreMap() {
    return {
      'userId': userId,
      'scoringCategoryId': scoringCategoryId,
      'score': score,
      'rowNumber': rowNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
