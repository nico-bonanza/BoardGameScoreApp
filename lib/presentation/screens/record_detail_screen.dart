import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/record_service.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/record.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/presentation/screens/home_screen.dart';
import 'package:game_score_app/presentation/screens/record_edit_screen.dart';
import 'package:game_score_app/utils/date_utils.dart';

class RecordDetailScreen extends StatefulWidget {
  final Record record;

  const RecordDetailScreen(
      {super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final recordService = RecordService();
  late final BoardGame boardGame;
  late final List<User> players;
  late final List<ScoringCategory> scoringCategories;
  // 2次元のコントローラー：rows x cols
  late final List<List<TextEditingController>> controllers;

// 得点合計の計算
  int _calculateColumnTotal(int col) {
    int sum = 0;
    for (var row in controllers) {
      final val = int.tryParse(row[col].text) ?? 0;
      sum += val;
    }
    return sum;
  }

// テーブル構成の初期化
  @override
  void initState() {
    super.initState();
    // 得点項目
    scoringCategories = recordService.getScoringCategoriesByRecordId(widget.record.id);
    // プレイヤー取得
    players = recordService.getUsersByRecordId(widget.record.id);
    // ボドゲ
    boardGame = recordService.getBoardGameByRecordId(widget.record.id);
    // 表データ
    controllers = List.generate(
      scoringCategories.length,
      (_) =>
          List.generate(players.length, (_) => TextEditingController()),
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
    return PopScope( // 「戻る」機能を制御
      canPop: false, // デフォルトで「戻れない」
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // システム側で戻り済なら何もしない

        // カスタム戻る処理（例：HomeScreenに戻る）
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
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
                leading: const Icon(Icons.edit_note),
                title: const Text('表の編集'),
                onTap: () {
                  // Navigator.push(
                    // context,
                    // MaterialPageRoute(
                    //   builder: (context) => RecordEditScreen(
                    //     boardGame: widget.boardGame,
                    //     date: widget.date,
                    //     players: widget.players,
                    //   ),
                    // ),
                  // );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('なにか'),
                onTap: () {
                  // ヘルプ画面
                },
              ),
            ],
          ),
        ),
        body: Column(
          // Column：子要素縦並び
          crossAxisAlignment: CrossAxisAlignment.center, // 縦並び交差配置：水平中央
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
              crossAxisAlignment: CrossAxisAlignment.center, // 縦並び交差配置：中央
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 横並び（Row）中央揃え
                  children: [
                    Text(
                      formattedToday(widget.record.createdAt),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
            // 線
            const Divider(),
            // テーブル
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0),
              child: Table(
                border: TableBorder.all(color: Theme.of(context).dividerColor),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(150),
                },
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
                  for (int row = 0;
                      row < scoringCategories.length;
                      row++)
                    // 行
                    TableRow(
                      children: [
                        // 列：得点項目列
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(scoringCategories[row].name),
                        ),
                        //列： 得点（ユーザーごと）
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
              padding: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 0),
              child: Table(
                border: TableBorder.all(color: Theme.of(context).dividerColor),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(150),
                },
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
                          padding: const EdgeInsets.fromLTRB(0, 0, 3.0, 0),
                          child: Text(
                            '${_calculateColumnTotal(col)}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
