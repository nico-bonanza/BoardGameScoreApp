import 'package:hive/hive.dart';
import 'hive_type_ids.dart';

part 'record.g.dart';

// 記録
@HiveType(typeId: HiveTypeIds.record)
class Record extends HiveObject {
  @HiveField(0)
  String id; // UUID
  @HiveField(1)
  String boardGameId; // 外部キー：ボドゲID
  @HiveField(2)
  bool isSynced; // 同期済みフラグ
  @HiveField(3)
  DateTime createdAt; // 作成日
  @HiveField(4)
  DateTime updatedAt; // 更新日

  Record({
    required this.id,
    required this.boardGameId,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });
}
