import 'package:flutter/material.dart';
import 'package:game_score_app/modals/title_select_modal.dart';
import 'package:game_score_app/models/board_game.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
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

  // 得点項目（行）
  final List<String> scoringCategories = ['農地', '道', '修道院だけど長いとどう'];

  // ユーザー（列）
  final List<String> users = ['ゆうこ', 'たかし'];

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
    controllers = List.generate(
      scoringCategories.length,
      (_) => List.generate(users.length, (_) => TextEditingController()),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("プレイ記録"),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // 親scaffold内のendDrawerウィジェットを開く
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
                // 設定モーダルや画面遷移
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
                    for (final user in users) Center(child: Text(user)),
                  ],
                ),
                // 各得点行
                for (int row = 0; row < scoringCategories.length; row++)
                  // 行
                  TableRow(
                    children: [
                      // 列：得点項目列
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(scoringCategories[row]),
                      ),
                      //列： 得点（ユーザーごと）
                      for (int col = 0; col < users.length; col++)
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
                    for (int col = 0; col < users.length; col++)
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
    );
  }
}
