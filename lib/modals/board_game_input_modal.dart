import 'package:flutter/material.dart';
import 'package:game_score_app/service/board_game_service.dart';

class BoardGameInputModal extends StatefulWidget {
  const BoardGameInputModal({super.key});

  @override
  State<BoardGameInputModal> createState() => _BoardGameInputModalState();
}

class _BoardGameInputModalState extends State<BoardGameInputModal> {
  final _titleController = TextEditingController();
  final _service = BoardGameService();

  void _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    await _service.registerBoardGame(_titleController.text);

    if (!mounted) return; // 非同期実行中に画面切り替わった際に、以下の処理を行わないようにする。
    Navigator.pop(context); // モーダルを閉じる
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_titleController.text}を追加しました。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // キーボード対応
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ボドゲ棚に追加', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
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
