import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/presentation/widgets/modals/board_game/update_modal.dart';
import 'package:game_score_app/presentation/widgets/modals/scoring_category/input_model.dart';
import 'package:game_score_app/presentation/widgets/modals/scoring_category/update_modal.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BoardGameDetailScreen extends StatefulWidget {
  final BoardGame boardGame;

  const BoardGameDetailScreen({
    super.key,
    required this.boardGame,
  });

  @override
  State<BoardGameDetailScreen> createState() => _BoardGameDetailScreenState();
}

class _BoardGameDetailScreenState extends State<BoardGameDetailScreen> {
  final Box<BoardGame> boardGameBox = Hive.box<BoardGame>('boardGames');
  final scoringCategoryBox = Hive.box<ScoringCategory>('scoringCategories');

  late final ValueListenable<Box<BoardGame>> boardGameListenable;

  // 項目削除
    Future<void> _deleteCategory(ScoringCategory category) async {
    // 削除前に確認ダイアログを表示
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: const Text('本当にこの項目を削除しますか？'),
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
      // 論理削除
      category.isDelete = true;
      await category.save();
    }
  }

  @override
  void initState() {
    super.initState();
    boardGameListenable = boardGameBox.listenable(keys: [widget.boardGame.id]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ボドゲ詳細'),
      ),
      // 登録済みの得点項目をリスト表示。
      body: Column(
        children: [
          // ユーザー情報部分
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(), // 最大幅制限なし
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<Box<BoardGame>>(
                  valueListenable: boardGameListenable,
                  builder: (context, box, _) {
                    final currentBoardGame = box.get(widget.boardGame.id);
                    if (currentBoardGame == null) {
                      return const Center(child: Text('ボードゲームが見つかりません'));
                    }
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.pentagon),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      currentBoardGame.title,
                                      style: const TextStyle(fontSize: 18),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) =>
                                      BoardGameUpdateModal(boardGame: currentBoardGame),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 1,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // リスト部分（スクロール可能）
          Expanded(
            child: ValueListenableBuilder<Box<ScoringCategory>>(
              valueListenable: scoringCategoryBox.listenable(),
              builder: (context, box, _) {
                final filtered = box.values
                    .where((e) => e.boardGameId == widget.boardGame.id)
                    .where((e) => e.isDelete == false)
                    .toList();

                filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (filtered.isEmpty) {
                  return const Center(child: Text('得点項目がありません'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    return ListTile(
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            // tooltip: '詳細',
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteCategory(category);
                            },
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            // tooltip: '編集',
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                builder: (context) =>
                                    ScoringCategoryUpdateModal(
                                  scoringCategory: category,
                                  scoringCategoryBox: scoringCategoryBox,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // モーダル表示
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // キーボードで自動調整
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => ScoringCategoryInputModel(
              boardGameId: widget.boardGame.id,
              scoringCategoryBox: scoringCategoryBox,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
