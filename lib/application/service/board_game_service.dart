import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/board_game.dart';

// ボードゲームサービス
class BoardGameService {
  // モデル取得
  final _box = Hive.box<BoardGame>('boardGames');
  final _boxScoringCategory = Hive.box<ScoringCategory>('scoringCategories');
  final Uuid _uuid = Uuid();

  // ボドゲ登録
  Future<void> registerBoardGame(String title) async {
    final game = BoardGame(
      id: _uuid.v4(),
      title: title,
    );

    await _box.put(game.id, game);
  }

  // ボドゲ全件取得
  List<BoardGame> getAllGames() {
    return _box.values.toList();
  }

  // 得点項目登録
  Future<void> registerScoringCategory(String boardGameId, String name) async {
    final category = ScoringCategory(
      id: _uuid.v4(),
      boardGameId: boardGameId,
      name: name,
    );

    await _boxScoringCategory.put(category.id, category);
  }
}
