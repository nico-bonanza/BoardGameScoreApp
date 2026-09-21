import 'package:cloud_firestore/cloud_firestore.dart';
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

    // firestoreへの保存
    await FirebaseFirestore.instance
        .collection('records')
        .doc(record.id)
        .set(record.toFirestoreMap());

    return record;
  }

  // 登録：記録-得点項目-ユーザ
  createRecordItem(Record record, ScoringCategory scoringCategory, User user, int rowNumber) async {
    final recordItem = RecordItem(
      id: _uuid.v4(),
      recordId: record.id,
      userId: user.id,
      scoringCategoryId: scoringCategory.id,
      score: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rowNumber: rowNumber
    );

    await _recordItemBox.put(recordItem.id, recordItem);

    // firestoreへの保存
    await FirebaseFirestore.instance
        .collection('records')
        .doc(record.id)
        .collection('recordItems')
        .doc(recordItem.id)
        .set(recordItem.toFirestoreMap());
  }

  // 記録IDから、設定された得点項目を取得
  List<ScoringCategory> getScoringCategoriesByRecordId(String recordId) {
    // recordId に紐づく RecordItem を rowNumber 昇順で取得
    final recordItems = _recordItemBox.values
        .where((item) => item.recordId == recordId)
        .toList()
        ..sort((a, b) => a.rowNumber!.compareTo(b.rowNumber!));

    // 重複を排除しつつ、RecordItem の順序を保った scoringCategoryId のリスト
    final scoringCategoryIds =
        recordItems.map((item) => item.scoringCategoryId).toSet().toList();

    // scoringCategoryIds の順序に従って ScoringCategory を取得
    final scoringCategories = scoringCategoryIds
        .map(
          (id) => _scoringCategoryBox.values.firstWhere((sc) => sc.id == id),
        )
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

  // 記録IDから、記録データを取得
  List<RecordItem> getRecordItemsByRecordId(String recordId){
    final recordItems = _recordItemBox.values
        .where((item) => item.recordId == recordId)
        .toList();

    return recordItems;
  }
}
