import 'package:flutter/material.dart';
import 'package:game_score_app/models/record.dart';
import 'package:game_score_app/screens/score_record_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScoreRecordListScreen extends StatelessWidget {
  const ScoreRecordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ScoreRecord>('scoreRecords');

    return Scaffold(
      appBar: AppBar(
        title: Text('スコア記録'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ScoreRecord> scoreRecordBox, _) {
          if (scoreRecordBox.isEmpty) {
            return const Center(child: Text('あなたの後ろに道はない。'));
          }

          return ListView.builder(
            itemCount: scoreRecordBox.length,
            itemBuilder: (context, index) {
              final scoreRecord = scoreRecordBox.getAt(index);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    scoreRecord?.boardGame.title ?? '無名',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('UUID: ${scoreRecord?.id ?? '-'}'),
                  leading: const Icon(Icons.receipt_long),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreRecordScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
