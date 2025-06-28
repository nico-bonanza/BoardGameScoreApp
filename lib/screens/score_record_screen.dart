import 'package:flutter/material.dart';
import 'package:game_score_app/modals/title_select_modal.dart';
import 'package:game_score_app/models/board_game.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScoreRecordScreen extends StatefulWidget {
  const ScoreRecordScreen({super.key});

  @override
  State<ScoreRecordScreen> createState() => _ScoreRecordScreenState();
}

class _ScoreRecordScreenState extends State<ScoreRecordScreen> {
  String gameTitle = 'タイトルを選ぶ'; // 初期タイトル
  DateTime selectedDate = DateTime.now(); // 初期作成日

  // 年月日に変換して返す
  String _formattedToday() {
    return '${selectedDate.year}年${selectedDate.month.toString().padLeft(2, '0')}月${selectedDate.day.toString().padLeft(2, '0')}日';
  }

  // タイトル部分タップ
  void _tapTitle() async {
    final gamesBox = Hive.box<BoardGame>('boardGames');
    final allBoardGames = gamesBox.values.toList();

    final selectedGame = await showModalBottomSheet<BoardGame>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: TitleSelectModal(allBoardGames: allBoardGames),
        );
      },
    );

    if (selectedGame != null) {
      setState(() {
        gameTitle = selectedGame.title;
        // 必要なら ID など他のプロパティも保持可能
      });
    }
  }

  // 日付をタップ
  Future<void> _tapDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // 現在の選択日
      firstDate: DateTime(2000), // 過去の範囲
      lastDate: DateTime(2100), // 未来の範囲
      locale: const Locale('ja'), // 日本語（intl必要）
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("スコア記録")),
      body: Column(
        // Column：子要素縦並び
        crossAxisAlignment: CrossAxisAlignment.center, // 縦並び交差配置：水平中央
        children: [
          // タイトル要素：ジェスチャー検知
          GestureDetector(
            onTap: _tapTitle, // タップ検知：_clickTitleを呼び出す
            // この子へのタップを検知する。
            child: Padding(
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
                        gameTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 日付要素：ジェスチャー検知
          GestureDetector(
            onTap: _tapDate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 縦並び交差配置：中央
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 横並び（Row）中央揃え
                  children: [
                    Text(
                      _formattedToday(),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                )
              ],
            ),
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
                  0: FixedColumnWidth(150), // 行名の幅
                },
                children: const [
                  // ユーザー行
                  TableRow(
                    children: [
                      SizedBox(
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('\u200B')),
                      ), // 左上空白
                      Center(child: Text('ゆうこ')),
                      Center(child: Text('ゆうこ')),
                    ],
                  ),

                  // 得点項目行
                  // 行1：農地
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('農地'),
                      ),
                      Center(child: Text('20')),
                      Center(child: Text('25')),
                    ],
                  ),
                  // 行2：道
                  // TableRow(
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.all(8.0),
                  //       child: Text('道'),
                  //     ),
                  //     Center(child: Text('30')),
                  //     Center(child: Text('28')),
                  //   ],
                  // ),
                  // // 行3：修道院
                  // TableRow(
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.all(8.0),
                  //       child: FittedBox(
                  //         fit: BoxFit.scaleDown,
                  //         child: Text('トークンのある魚✖︎1'),
                  //       ),
                  //     ),
                  //     Center(child: Text('38')),
                  //     Center(child: Text('39')),
                  //   ],
                  // ),
                ],
              )),
          // 合計テーブル
          Padding(
              padding: EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 0),
              child: Table(
                border: TableBorder.all(color: Theme.of(context).dividerColor),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(150), // 行名の幅
                },
                children: const [
                  // 合計行（ここが追加された行）
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '合計',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${20 + 30 + 38}', // ← 実際は合計ロジックで算出
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${25 + 28 + 39}', // ← 実際は合計ロジックで算出
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
