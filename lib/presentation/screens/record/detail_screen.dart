import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/record_service.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/record.dart';
import 'package:game_score_app/domain/models/record_item.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/presentation/screens/home_screen.dart';
import 'package:game_score_app/utils/date_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordDetailScreen extends StatefulWidget {
  final Record record;

  const RecordDetailScreen(
      {super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> with WidgetsBindingObserver {
  final _recordItemBox = Hive.box<RecordItem>('recordItems');

  final recordService = RecordService();

  late final BoardGame boardGame;
  late final List<User> players;
  late final List<ScoringCategory> scoringCategories;
  // 2次元のコントローラー：rows x cols
  late final List<List<TextEditingController>> controllers;
  // 2次元のフォーカス：rows x cols（カーソルが外れたら保存）
  late final List<List<FocusNode>> focusNodes;
  // 項目データ
  late final List<RecordItem> recordItems;

// 得点合計の計算
  int _calculateColumnTotal(int col) {
    int sum = 0;
    for (var row in controllers) {
      final val = int.tryParse(row[col].text) ?? 0;
      sum += val;
    }
    return sum;
  }

  // 1マス分の得点を保存（値に変更がなければ保存しない）
  Future<void> _saveScoreAt(int row, int col) async {
    final scoreText = controllers[row][col].text.trim();

    // 空欄は未入力(null)として保存
    final int? score;
    if (scoreText.isEmpty) {
      score = null;
    } else {
      score = int.tryParse(scoreText);
      if (score == null) return; // 数字でない場合は無視
    }

    // RecordItemを取得
    final userId = players[col].id;
    final scoringCategoryId = scoringCategories[row].id;
    final recordItem = _recordItemBox.values.firstWhere(
      (item) =>
          item.recordId == widget.record.id &&
          item.userId == userId &&
          item.scoringCategoryId == scoringCategoryId
    );

    // 変更がなければ保存しない
    if (recordItem.score == score) return;

    recordItem.score = score;
    recordItem.updatedAt = DateTime.now();

    // 更新保存
    await recordItem.save();

    // firestoreへの保存（閲覧側へリアルタイム反映）
    await FirebaseFirestore.instance
        .collection('records')
        .doc(widget.record.id)
        .collection('recordItems')
        .doc(recordItem.id)
        .set(recordItem.toFirestoreMap());
  }

  // 全マスの得点を保存（画面離脱時などの保険）
  Future<void> _saveScores({bool showMessage = false}) async {
    for (int row = 0; row < scoringCategories.length; row++) {
      for (int col = 0; col < players.length; col++) {
        await _saveScoreAt(row, col);
      }
    }

    if (!showMessage) return;
    if (!mounted) return; // context を使う前に確認

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('スコアを保存しました')),
    );
  }

  Future<void> _deleteDetail() async {
    // 削除前に確認ダイアログを表示
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('本当にこの記録を削除しますか？'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () =>
                  Navigator.of(context).pop(false), // キャンセルでfalseを返す
            ),
            TextButton(
              child: const Text('削除'),
              onPressed: () => Navigator.of(context).pop(true), // 削除でtrueを返す
            ),
          ],
        );
      },
    );

    // ダイアログで「削除」が押された場合のみ、削除処理を実行
    if (shouldDelete == true) {
      // 記録・項目削除（端末とfirestore）
      await recordService.deleteRecordWithItems(widget.record, recordItems);

      // 画面の存在確認（非同期処理の画面遷移対策）
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  Future<void> _createCopyRecord() async {
    // 登録：記録・記録情報（ユーザー・得点項目）
    final record = await recordService.createRecordWithItems(
        boardGame, players, scoringCategories);

    if (!mounted) return; // context を使う前に確認

    // 得点入力画面へ遷移（保存完了後）
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordDetailScreen(
          record: record,
        ),
      ),
    );
  }

// テーブル構成の初期化
  @override
  void initState() {
    super.initState();
    // ライフサイクル監視
    WidgetsBinding.instance.addObserver(this);

    // 得点項目
    scoringCategories = recordService.getScoringCategoriesByRecordId(widget.record.id);
    // プレイヤー取得(名前で昇順)
    players = recordService
      .getUsersByRecordId(widget.record.id)
      ..sort((a, b) => a.name.compareTo(b.name));
    // ボドゲ
    boardGame = recordService.getBoardGameByRecordId(widget.record.id);
    // 記録データ
    recordItems = recordService.getRecordItemsByRecordId(widget.record.id);
    // 表データ反映
    controllers = List.generate(
      scoringCategories.length,
      (row) => List.generate(players.length, (col) {
        final controller = TextEditingController();

        // 該当するRecordItemを探してscoreをセット
        final userId = players[col].id;
        final scoringCategoryId = scoringCategories[row].id;

        final item = recordItems.firstWhere(
          (ri) =>
              (ri.userId == userId) && (ri.scoringCategoryId == scoringCategoryId),
        );

        if (item.score != null) {
          controller.text = item.score.toString();
        }

        return controller;
      }),
    );
    // カーソルが外れたら(blur)そのマスを保存
    focusNodes = List.generate(
      scoringCategories.length,
      (row) => List.generate(players.length, (col) {
        final focusNode = FocusNode();
        focusNode.addListener(() {
          if (!focusNode.hasFocus) {
            _saveScoreAt(row, col);
          }
        });
        return focusNode;
      }),
    );
  }

  // 画面切り替え時のメモリリーク
  @override
  void dispose() {
    // ライフサイクル監視
    WidgetsBinding.instance.removeObserver(this);
    // 得点入力コントローラー
    for (var row in controllers) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    // 得点入力フォーカス
    for (var row in focusNodes) {
      for (var node in row) {
        node.dispose();
      }
    }
    super.dispose();
  }

  // ライフサイクルの変更を検知
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // ホームボタン押下や画面切り替えで一時停止時
      _saveScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // 物理的「戻る」機能を制御
      canPop: false, // デフォルトで「戻れない」
      onPopInvokedWithResult: (didPop, result) async {
        // 記録保存
        await _saveScores();

        if (didPop) return; // システム側で戻り済なら何もしない

        // 画面の存在確認（非同期処理の画面遷移対策）
        if (!context.mounted) return;

        // カスタム戻る処理（例：HomeScreenに戻る）
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          // 左上戻る矢印ボタン制御
          leading: BackButton(
            onPressed: () async {
              // 記録保存
              await _saveScores();

              // 画面の存在確認（非同期処理の画面遷移対策）
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
          title: const Text("プレイ記録"),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        // 右ドロワー
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                // decoration: BoxDecoration(color: Colors.blue),
                child: Text('メニュー'),
              ),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('保存'),
                onTap: () {
                  _saveScores(showMessage: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('コピー作成'),
                onTap: () {
                  _createCopyRecord();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('なにか'),
                onTap: () {
                  // ヘルプ画面
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('削除'),
                onTap: () {
                  _deleteDetail();
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // タイトル
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            boardGame!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),

                // 日付
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formattedToday(widget.record.createdAt),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),

                const Divider(),

                // テーブル
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0),
                  child: Table(
                    border:
                        TableBorder.all(color: Theme.of(context).dividerColor),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // ヘッダー行
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('\u200B'),
                          ),
                          for (final player in players)
                            Center(child: Text(player.name)),
                        ],
                      ),
                      // 各得点行
                      for (int row = 0; row < scoringCategories.length; row++)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    scoringCategories[row].name,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ),
                            for (int col = 0; col < players.length; col++)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: controllers[row][col],
                                  focusNode: focusNodes[row][col],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  // マス外タップでカーソルを外す（blur → 保存）
                                  onTapOutside: (_) =>
                                      focusNodes[row][col].unfocus(),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                // 合計行テーブル
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 10.0),
                  child: Table(
                    border:
                        TableBorder.all(color: Theme.of(context).dividerColor),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '合計',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          for (int col = 0; col < players.length; col++)
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 3.0, 0),
                                child: Text(
                                  '${_calculateColumnTotal(col)}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
