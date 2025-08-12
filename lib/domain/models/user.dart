import 'package:hive/hive.dart';
import 'hive_type_ids.dart';

part 'user.g.dart';

// ユーザー
@HiveType(typeId: HiveTypeIds.user)
class User extends HiveObject{
  @HiveField(0)
  String id; // UUID
  @HiveField(1)
  String name; // ユーザー名
  @HiveField(2)
  DateTime createdAt; // 作成日
  @HiveField(3)
  DateTime updatedAt; // 更新日

  User({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}
