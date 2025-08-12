import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/board_game_service.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/utils/modal_utils.dart';
import 'package:hive/hive.dart';

class ScoringCategoryUpdateModal extends StatefulWidget {
  final ScoringCategory scoringCategory;
  final Box<ScoringCategory> scoringCategoryBox;
  const ScoringCategoryUpdateModal({super.key, required this.scoringCategory, required this.scoringCategoryBox});

  @override
  State<ScoringCategoryUpdateModal> createState() => _ScoringCategoryUpdateModalState();
}

class _ScoringCategoryUpdateModalState extends State<ScoringCategoryUpdateModal> {
  var _nameController = TextEditingController();
  final _service = BoardGameService();

  String? _errorMessage;

  void _submit() async {
    _errorMessage = null;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    // 重複チェック
    final exists = widget.scoringCategoryBox.values.any((e) =>
        e.boardGameId == widget.scoringCategory.boardGameId && // 同じボードゲーム内
        e.name == newName &&
        e.id != widget.scoringCategory.id); // 自分自身は除外
    if (exists) {
      setState(() {
        _errorMessage = '同名の項目がすでに存在します。';
      });
      return;
    }

    widget.scoringCategory.name = newName;
    await _service.updateScoringCategory(widget.scoringCategory);

    // 画面の存在確認（非同期処理の画面遷移対策）
    if (!mounted) return;
    // モーダルを閉じてスナックバー表示
    closeModalWithSnackBar(context, '更新しました。');
  }

  // 初期化
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.scoringCategory.name);
  }

  // コントローラー破棄
  @override
  void dispose() {
    _nameController.dispose();
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
            const Text('項目名変更', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '項目名',
                border: OutlineInputBorder(),
              ),
            ),
            // エラーメッセージ
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
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
