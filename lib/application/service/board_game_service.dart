import 'package:cloud_firestore/cloud_firestore.dart';
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

    // Firestoreへの書き込み
    await FirebaseFirestore.instance
        .collection('boardGames')
        .doc(game.id)
        .set(game.toFirestoreMap());
  }

  // ボドゲ更新
  Future<void> updateBoardGame(BoardGame boardGame) async {
    await _box.put(boardGame.id, boardGame);

    // Firestoreへの書き込み
    await FirebaseFirestore.instance
        .collection('boardGames')
        .doc(boardGame.id)
        .set(boardGame.toFirestoreMap(), SetOptions(merge: true));
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _boxScoringCategory.put(category.id, category);

    // Firestoreへの書き込み
    await FirebaseFirestore.instance
        .collection('scoringCategories')
        .doc(category.id)
        .set(category.toFirestoreMap());
  }

  // 得点項目:更新
  Future<void> updateScoringCategory(ScoringCategory scoringCategory) async {
    scoringCategory.updatedAt = DateTime.now();
    await _boxScoringCategory.put(scoringCategory.id, scoringCategory);

    // Firestoreへの書き込み
    await FirebaseFirestore.instance
        .collection('scoringCategories')
        .doc(scoringCategory.id)
        .set(scoringCategory.toFirestoreMap(), SetOptions(merge: true)); // 渡されたフィールドだけ更新
  }
}
