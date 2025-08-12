import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/record.dart';
import 'package:game_score_app/domain/models/record_item.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/presentation/screens/record/detail_screen.dart';
import 'package:game_score_app/presentation/screens/record/edit_screen.dart';
import 'package:game_score_app/utils/date_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecordListScreen extends StatelessWidget {
  const RecordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Record>('records');
    final recordItemBox = Hive.box<RecordItem>('recordItems');
    final userBox = Hive.box<User>('users');

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
              final records = recordBox.values.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final record = records[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // ボドゲタイトル
                  title: Text(
                    getBoardGameName(record?.boardGameId),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // プレイ日
                      Text(formattedToday(record.createdAt)),
                      const SizedBox(height: 4),
                      Text(
                        recordItemBox.values
                            .where((item) => item.recordId == record.id)
                                .map((item) => userBox.values.firstWhere((user)=> user.id == item.userId).name)
                                .toSet()
                                .join('\u0020\u0020'), // 半角スペース×2で結合
                      ),
                    ],
                  ),
                  // // UUID
                  // subtitle: Text('UUID: ${record?.id ?? '-'}'),
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
