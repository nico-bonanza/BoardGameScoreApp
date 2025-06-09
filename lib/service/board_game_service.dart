import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/board_game.dart';

// ボードゲームサービス
class BoardGameService {
  // モデル取得
  final _box = Hive.box<BoardGame>('boardGames');
  final Uuid _uuid = Uuid();

  // 登録
  Future<void> registerBoardGame(String title) async {
    final game = BoardGame(
      id: _uuid.v4(),
      title: title,
    );

    await _box.put(game.id, game);
  }

  // 全件取得
  List<BoardGame> getAllGames() {
    return _box.values.toList();
  }
}
