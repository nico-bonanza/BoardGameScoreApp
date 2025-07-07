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
  DateTime createdAt; // 作成日
  @HiveField(3)
  bool isSynced; // 同期済みフラグ

  Record({
    required this.id,
    required this.boardGameId,
    required this.createdAt,
    required this.isSynced,
  });
}
