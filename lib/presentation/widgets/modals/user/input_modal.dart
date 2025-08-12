import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/user_service.dart';
import 'package:game_score_app/utils/modal_utils.dart';

class UserInputModal extends StatefulWidget {
  const UserInputModal({super.key});

  @override
  State<UserInputModal> createState() => _UserInputModalState();
}

class _UserInputModalState extends State<UserInputModal> {
  final _nameController = TextEditingController();
  final _service = UserService();

  void _submit() async {
    final title = _nameController.text.trim();
    if (title.isEmpty) return;
    await _service.registerUser(_nameController.text);

    // 画面の存在確認（非同期処理の画面遷移対策）
    if (!mounted) return;
    // モーダルを閉じてスナックバー表示
    closeModalWithSnackBar(context, '${_nameController.text}を追加しました。');
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
            const Text('ユーザーを追加', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前',
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
