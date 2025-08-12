import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/board_game_service.dart';
import 'package:game_score_app/utils/modal_utils.dart';

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

    // 画面の存在確認（非同期処理の画面遷移対策）
    if (!mounted) return;
    // モーダルを閉じてスナックバー表示
    closeModalWithSnackBar(context, '${_titleController.text}を追加しました。');
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
