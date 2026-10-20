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

  // 登録：記録と記録情報（ユーザー×得点項目）をまとめて作成
  // firestoreへは1回のバッチ書き込みで保存する（1件ずつ書くと件数分の通信待ちが発生するため）
  Future<Record> createRecordWithItems(
      BoardGame boardGame, List<User> players, List<ScoringCategory> scoringCategories) async {
    final now = DateTime.now();
    final record = Record(
      id: _uuid.v4(),
      boardGameId: boardGame.id,
      isSynced: false,
      createdAt: now,
      updatedAt: now,
    );

    final recordItems = <RecordItem>[];
    for (var player in players) {
      var rowNumber = 0; // 項目の表示順
      for (var sc in scoringCategories) {
        recordItems.add(RecordItem(
          id: _uuid.v4(),
          recordId: record.id,
          userId: player.id,
          scoringCategoryId: sc.id,
          score: null,
          createdAt: now,
          updatedAt: now,
          rowNumber: rowNumber,
        ));
        rowNumber++;
      }
    }

    // 端末への保存
    await _recordBox.put(record.id, record);
    await _recordItemBox.putAll({for (var item in recordItems) item.id: item});

    // firestoreへの保存（バッチ1件あたり最大500書き込み）
    final firestore = FirebaseFirestore.instance;
    final recordRef = firestore.collection('records').doc(record.id);
    final batch = firestore.batch();
    batch.set(recordRef, record.toFirestoreMap());
    for (var item in recordItems) {
      batch.set(recordRef.collection('recordItems').doc(item.id), item.toFirestoreMap());
    }
    await batch.commit();

    return record;
  }

  // 削除：記録と記録情報をまとめて削除
  // firestoreは親ドキュメントを消してもサブコレクションが残るため、recordItemsも個別に削除する
  Future<void> deleteRecordWithItems(Record record, List<RecordItem> recordItems) async {
    // 端末から削除
    await _recordItemBox.deleteAll(recordItems.map((e) => e.key));
    await _recordBox.delete(record.id);

    // firestoreから削除（バッチ1件あたり最大500件）
    final firestore = FirebaseFirestore.instance;
    final recordRef = firestore.collection('records').doc(record.id);
    final batch = firestore.batch();
    for (var item in recordItems) {
      batch.delete(recordRef.collection('recordItems').doc(item.id));
    }
    batch.delete(recordRef);
    await batch.commit();
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
