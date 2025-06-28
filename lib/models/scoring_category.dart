import 'package:game_score_app/models/hive_type_ids.dart';
import 'package:hive/hive.dart';

part 'scoring_category.g.dart';

// 得点項目
@HiveType(typeId: HiveTypeIds.scoringCategory)
class ScoringCategory extends HiveObject {
  @HiveField(0)
  String id; // uuid
  @HiveField(1)
  String name; // ユーザーID

  ScoringCategory({
    required this.id,
    required this.name,
  });
}
