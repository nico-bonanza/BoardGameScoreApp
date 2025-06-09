import 'package:flutter/material.dart';
import 'package:game_score_app/models/board_game.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BoardGameListScreen extends StatelessWidget {
  const BoardGameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<BoardGame>('boardGames');

    return Scaffold(
      appBar: AppBar(
        title: Text('ボドゲ棚'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<BoardGame> boardGameBox, _) {
          if (boardGameBox.isEmpty) {
            return const Center(child: Text('棚 is 空'));
          }

          return ListView.builder(
            itemCount: boardGameBox.length,
            itemBuilder: (context, index) {
              final boardGame = boardGameBox.getAt(index);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    boardGame?.title ?? '無名',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('UUID: ${boardGame?.id ?? '-'}'),
                  leading: const Icon(Icons.pentagon),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 詳細とか編集とか
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
