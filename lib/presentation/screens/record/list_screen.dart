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

    String recordSummary(Record record) {
      final recordItems =
          recordItemBox.values.where((item) => item.recordId == record.id);

      final userIds = recordItems.map((item) => item.userId).toSet();
      final users = userIds
          .map((id) => userBox.values.firstWhere((user) => user.id == id))
          .toList()
          ..sort((a, b)=> a.name.compareTo(b.name));

      final usersWithScore = users.map((user) {
        final userItems = recordItems.where((item) => item.userId == user.id);
        var totalScore = userItems.fold<int>(0, (sum, item) => sum + (item.score ?? 0));

        return '${user.name}:$totalScore';
      });

      return usersWithScore.join('\u0020\u0020');
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
                      Text(recordSummary(record)),
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
