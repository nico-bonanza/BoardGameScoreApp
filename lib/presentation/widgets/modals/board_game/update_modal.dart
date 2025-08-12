import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/board_game_service.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/utils/modal_utils.dart';

class BoardGameUpdateModal extends StatefulWidget {
  final BoardGame boardGame;
  const BoardGameUpdateModal({super.key, required this.boardGame});

  @override
  State<BoardGameUpdateModal> createState() => _BoardGameUpdateModalState();
}

class _BoardGameUpdateModalState extends State<BoardGameUpdateModal> {
  var _titleController = TextEditingController();
  final _service = BoardGameService();

  void _submit() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) return;

    widget.boardGame.title = newTitle;
    await _service.updateBoardGame(widget.boardGame);

    // 画面の存在確認（非同期処理の画面遷移対策）
    if (!mounted) return;
    // モーダルを閉じてスナックバー表示
    closeModalWithSnackBar(context, '更新しました。');
  }

  // 初期化
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.boardGame.title);
  }

  // コントローラー破棄
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
            const Text('タイトル変更', style: TextStyle(fontSize: 18)),
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
