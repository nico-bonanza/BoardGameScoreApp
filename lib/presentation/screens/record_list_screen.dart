import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/record.dart';
import 'package:game_score_app/presentation/screens/record_detail_screen.dart';
import 'package:game_score_app/presentation/screens/record_edit_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordListScreen extends StatelessWidget {
  const RecordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Record>('records');

    String getBoardGameName(String? boardGameId) {
      if (boardGameId == null) return '不明なゲーム';
      final box = Hive.box<BoardGame>('boardGames');
      final boardGame = box.values.firstWhere((bg) => bg.id == boardGameId);
      return boardGame.title;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 戻るボタンを無効化
        title: Text('プレイ記録'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Record> recordBox, _) {
          if (recordBox.isEmpty) {
            return const Center(child: Text('あなたの後ろに道はない。'));
          }

          return ListView.builder(
            itemCount: recordBox.length,
            itemBuilder: (context, index) {
              final record = recordBox.getAt(index);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    getBoardGameName(record?.boardGameId),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('UUID: ${record?.id ?? '-'}'),
                  leading: const Icon(Icons.receipt_long),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecordDetailScreen(
                          record: record!,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecordEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
