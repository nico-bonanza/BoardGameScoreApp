import 'package:game_score_app/domain/models/hive_type_ids.dart';
import 'package:hive/hive.dart';

part 'user_scoring_category_score.g.dart';

// 記録ID-ユーザID-得点項目ID-得点
@HiveType(typeId: HiveTypeIds.userScoringCategoryScore)
class UserScoringCategoryScore extends HiveObject {
  @HiveField(0)
  String scoreRecordId; // 外部キー：記録ID
  @HiveField(1)
  String userId; // 外部キー：ユーザーID
  @HiveField(2)
  String scoringCategoryId; // 外部キー：得点項目ID
  @HiveField(3)
  int score; // 得点

  UserScoringCategoryScore({
    required this.scoreRecordId,
    required this.userId,
    required this.scoringCategoryId,
    required this.score,
  });
}
