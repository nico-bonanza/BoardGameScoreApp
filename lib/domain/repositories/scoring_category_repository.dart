import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class ScoringCategoryRepository {
  final Box<ScoringCategory> _box;
  final Uuid _uuid = Uuid();

  ScoringCategoryRepository(this._box);

  // 登録
  Future<void> (String name) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
    );

    await _box.put(user.id, user);
  }
}
