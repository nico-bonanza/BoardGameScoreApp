import 'package:flutter/material.dart';
import 'package:game_score_app/presentation/screens/board_game/detail_screen.dart';
import 'package:game_score_app/presentation/widgets/modals/board_game/input_modal.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BoardGameListScreen extends StatelessWidget {
  const BoardGameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<BoardGame>('boardGames');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 戻るボタンを無効化
        title: Text('ボドゲ棚'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<BoardGame> boardGameBox, _) {
          if (boardGameBox.isEmpty) {
            return const Center(child: Text('TANA is YOU'));
          }

          return ListView.builder(
            itemCount: boardGameBox.length,
            itemBuilder: (context, index) {
              final boardGames = boardGameBox.values.toList()
                ..sort((a, b) => a.title.compareTo(b.title));
              final boardGame = boardGames[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // ボドゲタイトル
                  title: Text(
                    boardGame.title ?? '無名',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // // UUID
                  // subtitle: Text('UUID: ${boardGame?.id ?? '-'}'),
                  leading: const Icon(Icons.pentagon),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoardGameDetailScreen(
                          boardGame: boardGame!,
                        ),
                      ),
                    );
                  },
                ),
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
            builder: (context) => BoardGameInputModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
