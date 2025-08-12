import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/record_service.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/presentation/widgets/modals/player_select_modal.dart';
import 'package:game_score_app/presentation/widgets/modals/scoring_category_select_modal.dart';
import 'package:game_score_app/presentation/widgets/modals/title_select_modal.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/presentation/screens/record/detail_screen.dart';
import 'package:game_score_app/utils/date_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordEditScreen extends StatefulWidget {
  final BoardGame? boardGame;
  final List<User>? players;
  final List<ScoringCategory>? scoringCategories;
  final DateTime? date;

  const RecordEditScreen({super.key, this.boardGame, this.players, this.date, this.scoringCategories});

  @override
  State<RecordEditScreen> createState() => _RecordEditScreenState();
}

class _RecordEditScreenState extends State<RecordEditScreen> {
  final _recordService = RecordService();

  static const double appSpacing = 10;
  late BoardGame? selectedBoardGame;
  late DateTime selectedDate; // 初期作成日
  late List<User> selectedPlayers;
  late List<ScoringCategory> selectedScoringCategories;

  @override
  void initState() {
    super.initState();
    selectedBoardGame = widget.boardGame;
    selectedPlayers = widget.players ?? [];
    selectedScoringCategories = widget.scoringCategories ?? [];
    selectedDate = widget.date ?? DateTime.now();
  }

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

  // プレイヤー
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

    // 得点項目
  void _tapScoringCategory() async {
    final scoringCategoryBox = Hive.box<ScoringCategory>('scoringCategories');
    final allScoringCategories = scoringCategoryBox.values
        .where((e) => e.boardGameId == selectedBoardGame?.id)
        .toList();

    final selectedItems = await showModalBottomSheet<List<ScoringCategory>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ScoringCategorySelectModal(allScoringCategories: allScoringCategories),
        );
      },
    );

    if (selectedItems != null) {
      setState(() {
        selectedScoringCategories = selectedItems;
        // 必要なら ID など他のプロパティも保持可能
      });
    }
  }

  Future<void> _onPressedSaveIcon() async {
    List<String> messages = [];

    if (selectedBoardGame == null) {
      messages.add('・タイトルを選んでください');
    }
    if (selectedPlayers.isEmpty) {
      messages.add('・プレイヤーを選択してください');
    }
    if (selectedScoringCategories.isEmpty) {
      messages.add('・得点項目を選択してください');
    }

    if (messages.isNotEmpty) {
      final errorText = messages.join('\n');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
        ),
      );
      return; // 保存処理に進まない
    }

    // 登録：記録
    final record = await _recordService.createRecordAndGet(selectedBoardGame!);

    // 登録：記録情報（ユーザー・得点項目）
    for (var player in selectedPlayers) {
      for (var sc in selectedScoringCategories) {
        await _recordService.createRecordItem(record, sc, player);
      }
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text("プレイ記録編集"),
          actions: [
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  _onPressedSaveIcon();
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
                  const SizedBox(height: appSpacing),

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

                  const SizedBox(height: appSpacing),
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

                  const SizedBox(height: appSpacing),
                  const Text(
                    'プレイヤー',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 1),
                  // プレイヤー要素：ジェスチャー検知
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
                  ),
                  const SizedBox(height: appSpacing),
                  const Text(
                    '得点項目',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 1),
                  // 得点項目要素：ジェスチャー検知
                  GestureDetector(
                    onTap: _tapScoringCategory,
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
                              '得点項目を選ぶ',
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
                    children: selectedScoringCategories
                        .map((scoringCategory) => Text(scoringCategory.name))
                        .toList(),
                  )
                ]))));
  }
}
