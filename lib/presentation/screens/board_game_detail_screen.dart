import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/presentation/widgets/modals/scoring_category_input_model.dart';
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
  // 得点項目Hive
  final scoringCategoryBox = Hive.box<ScoringCategory>('scoringCategories');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardGame.title),
      ),
      // 登録済みの得点項目をリスト表示。
      body: ValueListenableBuilder( // データ監視&即反映
        valueListenable: scoringCategoryBox.listenable(),
        builder: (context, Box<ScoringCategory> box, _) {
          // boardGameId で絞り込み
          final filtered = box.values
              .where((e) => e.boardGameId == widget.boardGame.id)
              .toList();

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
              );
            },
          );
        },
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
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
