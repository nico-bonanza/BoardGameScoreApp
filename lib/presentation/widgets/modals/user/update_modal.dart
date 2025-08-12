import 'package:flutter/material.dart';
import 'package:game_score_app/application/service/user_service.dart';
import 'package:game_score_app/domain/models/user.dart';

class UserUpdateModal extends StatefulWidget {
  final User user;
  const UserUpdateModal({super.key, required this.user});

  @override
  State<UserUpdateModal> createState() => _UserUpdateModalState();
}

class _UserUpdateModalState extends State<UserUpdateModal> {
  var _nameController = TextEditingController();
  final _service = UserService();

  void _submit() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    widget.user.name = newName;
    await _service.updateUser(widget.user);

    if (!mounted) return; // 非同期実行中に画面切り替わった際に、以下の処理を行わないようにする。
    Navigator.pop(context); // モーダルを閉じる
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('更新しました。')),
    );
  }

  // 初期化
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
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
            const Text('ユーザー名変更', style: TextStyle(fontSize: 18)),
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
