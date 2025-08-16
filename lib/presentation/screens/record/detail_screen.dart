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

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final _recordItemBox = Hive.box<RecordItem>('recordItems');
  final _recordBox = Hive.box<Record>('records');

  final recordService = RecordService();

  late final BoardGame boardGame;
  late final List<User> players;
  late final List<ScoringCategory> scoringCategories;
  // 2次元のコントローラー：rows x cols
  late final List<List<TextEditingController>> controllers;
  // 変更があったかどうかを記録するフラグ
  bool hasChanges = false;
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

  Future<void> _saveScores() async {
    // 変更がなければ保存しない。
    if(hasChanges == false) return;

    for (int row = 0; row < scoringCategories.length; row++) {
      final scoringCategoryId = scoringCategories[row].id;

      for (int col = 0; col < players.length; col++) {
        final userId = players[col].id;
        final scoreText = controllers[row][col].text;

        // 空欄はスキップ（または null を許容するなら続行）
        if (scoreText.trim().isEmpty) continue;

        final score = int.tryParse(scoreText);
        if (score == null) continue; // 数字でない場合は無視

        // RecordItemを取得
        final recordItem = _recordItemBox.values.firstWhere(
          (item) =>
              item.recordId == widget.record.id &&
              item.userId == userId &&
              item.scoringCategoryId == scoringCategoryId
        );

        recordItem.score = score;
        recordItem.updatedAt = DateTime.now();

        // 更新保存
        await recordItem.save();
      }
    }

    // 変更有無の監視を初期化
    hasChanges = false;

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
      // 項目削除
      await _recordItemBox.deleteAll(recordItems.map((e) => e.key));
      // 記録削除
      await _recordBox.delete(widget.record.id);

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
    // 登録：記録
    final record = await recordService.createRecordAndGet(boardGame);

    // 登録：記録情報（ユーザー・得点項目）
    var rowNumber = 0; // 項目の表示順
    for (var player in players) {
      for (var sc in scoringCategories) {
        await recordService.createRecordItem(record, sc, player, rowNumber);
        rowNumber++;
      }
      rowNumber = 0;
    }

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

        // 変更監視を追加
        controller.addListener(() {
          hasChanges = true;
        });

        return controller;
      }),
    );
  }

  // 画面切り替え時のメモリリーク
  @override
  void dispose() {
    for (var row in controllers) {
      for (var ctrl in row) {
        ctrl.dispose();
      }
    }
    super.dispose();
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
                  _saveScores();
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
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (_) => setState(() {}),
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
