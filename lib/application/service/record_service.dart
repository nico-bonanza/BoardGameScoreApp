import 'package:game_score_app/domain/models/record.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/domain/models/record_item.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/board_game.dart';

// 記録サービス
class RecordService {
  // モデル取得
  final _recordBox = Hive.box<Record>('records');
  final _recordItemBox = Hive.box<RecordItem>('recordItems');
  final _scoringCategoryBox = Hive.box<ScoringCategory>('scoringCategories');
  final _userBox = Hive.box<User>('users');
  final _boardGameBox = Hive.box<BoardGame>('BoardGames');
  final Uuid _uuid = Uuid();

  // 登録：記録
  Future<Record> createRecordAndGet(BoardGame boardGame) async {
    final String recordId = _uuid.v4();
    final record = Record(
      id: recordId,
      boardGameId: boardGame.id,
      isSynced: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _recordBox.put(record.id, record);
    return record;
  }

  // 登録：記録-得点項目-ユーザ
  createRecordItem(Record record, ScoringCategory scoringCategory, User user) async {
    final recordItem = RecordItem(
      id: _uuid.v4(),
      recordId: record.id,
      userId: user.id,
      scoringCategoryId: scoringCategory.id,
      score: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _recordItemBox.put(recordItem.id, recordItem);
  }

  // 記録IDから、設定された得点項目を取得
  List<ScoringCategory> getScoringCategoriesByRecordId(String recordId){
      final scoringCategoryIds = _recordItemBox.values
          .where((item) => item.recordId == recordId)
          .map((item) => item.scoringCategoryId)
          .toList();

      final scoringCategories = _scoringCategoryBox.values
          .where((sc)=>scoringCategoryIds
          .contains(sc.id))
          .toList();

      return scoringCategories;
  }

  // 記録IDから、設定されたユーザーを取得
  List<User> getUsersByRecordId(String recordId) {
    final userIds = _recordItemBox.values
        .where((item) => item.recordId == recordId)
        .map((item) => item.userId)
        .toList();

    final users = _userBox.values
        .where((sc) => userIds.contains(sc.id))
        .toList();

    return users;
  }

  // 記録IDから、設定されたボドゲを取得
  BoardGame getBoardGameByRecordId(String recordId) {
    final boardGameId = _recordBox.values
        .firstWhere((item) => item.id == recordId)
        .boardGameId;

    final boardGame = _boardGameBox.values.firstWhere((bg) => bg.id == boardGameId);

    return boardGame;
  }
}
