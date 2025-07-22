import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/board_game_service.dart';

class ScoringCategoryInputModel extends StatefulWidget {
  final String boardGameId;
  const ScoringCategoryInputModel({super.key, required this.boardGameId});

  @override
  State<ScoringCategoryInputModel> createState() => _ScoringCategoryInputModelState();
}

class _ScoringCategoryInputModelState extends State<ScoringCategoryInputModel> {
  final _scoringCategoryController = TextEditingController();
  final _service = BoardGameService();

  void _submit() async {
    final scoringCategory = _scoringCategoryController.text.trim();
    if (scoringCategory.isEmpty) return;
    await _service.registerScoringCategory(widget.boardGameId, _scoringCategoryController.text);

    if (!mounted) return; // 非同期実行中に画面切り替わった際に、以下の処理を行わないようにする。
    Navigator.pop(context); // モーダルを閉じる
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_scoringCategoryController.text}を追加しました。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // キーボード出現時にパディングで位置調整
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('得点項目を追加', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _scoringCategoryController,
              decoration: const InputDecoration(
                labelText: '得点項目',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
