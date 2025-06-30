import 'package:flutter/material.dart';
import 'package:game_score_app/modals/title_select_modal.dart';
import 'package:game_score_app/models/board_game.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordEditScreen extends StatefulWidget {
  const RecordEditScreen({super.key});

  @override
  State<RecordEditScreen> createState() => _RecordEditScreenState();
}

class _RecordEditScreenState extends State<RecordEditScreen> {
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
        appBar: AppBar(
          title: const Text("プレイ記録編集"),
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
                      // ラベル
                      const Text(
                        'タイトル',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            gameTitle,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
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
                  // childrenは縦並びになる
                  crossAxisAlignment: CrossAxisAlignment.center, // 縦並び交差配置：左寄せ
                  mainAxisSize: MainAxisSize.min, // 横幅を最小に合わせる
                  children: [
                    // ラベル
                    const Text(
                      '日付',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      // childrenは横並びになる
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 横並び（Row）中央揃え
                      children: [
                        Text(
                          _formattedToday(),
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    )
                  ],
                ),
              ),
            ]));
  }
}
