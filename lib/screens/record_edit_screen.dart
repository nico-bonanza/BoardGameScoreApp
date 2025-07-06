import 'package:flutter/material.dart';
import 'package:game_score_app/modals/player_select_modal.dart';
import 'package:game_score_app/modals/title_select_modal.dart';
import 'package:game_score_app/models/board_game.dart';
import 'package:game_score_app/models/user.dart';
import 'package:game_score_app/screens/record_screen.dart';
import 'package:game_score_app/utils/date_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordEditScreen extends StatefulWidget {
  const RecordEditScreen({super.key});

  @override
  State<RecordEditScreen> createState() => _RecordEditScreenState();
}

class _RecordEditScreenState extends State<RecordEditScreen> {
  BoardGame? selectedBoardGame;
  DateTime selectedDate = DateTime.now(); // 初期作成日
  List<User> selectedPlayers = [];

  // タイトル部分タップ
  void _tapTitle() async {
    final gamesBox = Hive.box<BoardGame>('boardGames');
    final allBoardGames = gamesBox.values.toList();

    final boardGame = await showModalBottomSheet<BoardGame>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: TitleSelectModal(allBoardGames: allBoardGames),
        );
      },
    );

    if (boardGame != null) {
      setState(() {
        selectedBoardGame = boardGame;
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

  // タイトル部分タップ
  void _tapPlayer() async {
    final usersBox = Hive.box<User>('users');
    final allUsers = usersBox.values.toList();

    final selectedUsers = await showModalBottomSheet<List<User>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: PlayerSelectModal(allUsers: allUsers),
        );
      },
    );

    if (selectedUsers != null) {
      setState(() {
        selectedPlayers = selectedUsers;
        // 必要なら ID など他のプロパティも保持可能
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("プレイ記録編集"),
          actions: [
            selectedBoardGame == null
                ? Tooltip(
                    message: 'タイトルを選んでください',
                    child: IconButton(
                      icon: const Icon(Icons.save, color: Colors.grey),
                      onPressed: null, // 無効化
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordScreen(
                            boardGame: selectedBoardGame,
                            date: selectedDate,
                            players: selectedPlayers,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
        body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
                child: Column(
                    // Column：子要素縦並び
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // 縦並び交差配置：水平中央
                    children: [
                  const SizedBox(height: 5),

                  const Text(
                    'タイトル',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 1),
                  // タイトル要素：ジェスチャー検知
                  GestureDetector(
                    onTap: _tapTitle, // タップ検知：_clickTitleを呼び出す
                    // この子へのタップを検知する。
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedBoardGame?.title ?? 'タイトルを選ぶ',
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

                  const SizedBox(height: 10),
                  const Text(
                    '日付',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 1),
                  // 日付要素：ジェスチャー検知
                  GestureDetector(
                    onTap: _tapDate,
                    child: Column(
                      // childrenは縦並びになる
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // 横幅を最小に合わせる
                      children: [
                        Row(
                          // childrenは横並びになる
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedToday(selectedDate),
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

                  const SizedBox(height: 10),
                  const Text(
                    'プレイヤー',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 1),
                  // タイトル要素：ジェスチャー検知
                  GestureDetector(
                    onTap: _tapPlayer,
                    // この子へのタップを検知する。
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'プレイヤーを選ぶ',
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: selectedPlayers
                        .map((player) => Text(player.name))
                        .toList(),
                  )
                ]))));
  }
}
