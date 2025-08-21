import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/board_game_service.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/utils/modal_utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';

class ScoringCategoryInputModel extends StatefulWidget {
  final String boardGameId;
  final Box<ScoringCategory> scoringCategoryBox;

  const ScoringCategoryInputModel({super.key, required this.boardGameId, required this.scoringCategoryBox});

  @override
  State<ScoringCategoryInputModel> createState() => _ScoringCategoryInputModelState();
}

class _ScoringCategoryInputModelState extends State<ScoringCategoryInputModel> {
  final _scoringCategoryController = TextEditingController();
  final _service = BoardGameService();

  String? _errorMessage;

  void _submit() async {
    _errorMessage = null;

    final scoringCategory = _scoringCategoryController.text.trim();
    if (scoringCategory.isEmpty) return;

    // 同名項目取得
    final existItem = widget.scoringCategoryBox.values.firstWhereOrNull((e) =>
        e.boardGameId == widget.boardGameId && // 同じボードゲーム内
        e.name == scoringCategory);

    // 存在する場合
    if (existItem != null) {
      // 有効データなら、重複エラーメッセージ
      if (existItem.isDelete == false) {
        setState(() {
          _errorMessage = '同名の項目がすでに存在します。';
        });
        return;
      }
      // 無効データなら、再有効化
      else {
        existItem.isDelete = false;
        existItem.createdAt = DateTime.now();
        await existItem.save();
      }
    } else {
      // 新規保作成
      await _service.registerScoringCategory(widget.boardGameId, _scoringCategoryController.text);
    }

    // 画面の存在確認（非同期処理の画面遷移対策）
    if (!mounted) return;
    // モーダルを閉じてスナックバー表示
    closeModalWithSnackBar(context, '${_scoringCategoryController.text}を追加しました。');
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
