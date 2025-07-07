import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/user.dart';

class PlayerSelectModal extends StatefulWidget {
  final List<User> allUsers;

  const PlayerSelectModal({super.key, required this.allUsers});

  @override
  State<PlayerSelectModal> createState() => _PlayerSelectModalState();
}

class _PlayerSelectModalState extends State<PlayerSelectModal> {
  late List<User> _filteredUsers;
  final Set<User> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.allUsers; // 呼び出し元から渡された全ユーザー
  }

// 絞り込み（ひらがな・カタカナ問わず）
  void _updateQuery(String text) {
    setState(() {
      final queryHiragana = _toHiragana(text.toLowerCase());

      _filteredUsers = widget.allUsers.where((item) {
        final titleHiragana = _toHiragana(item.name.toLowerCase());
        return titleHiragana.contains(queryHiragana);
      }).toList();
    });
  }

  // ひらがな・かたかな変換
  String _toHiragana(String input) {
    // 全角カタカナ → 全角ひらがな に変換
    return input.replaceAllMapped(RegExp(r'[\u30A1-\u30F6]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x60);
    });
  }

// ユーザー選択/選択解除
  void _toggleUser(User user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _submitSelection() {
    Navigator.pop(context, _selectedUsers.toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("プレイヤーを選ぶ"),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: "ユーザーを検索...",
                border: OutlineInputBorder(),
              ),
              onChanged: _updateQuery,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? const Text("一致するユーザーが見つかりません")
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        final isSelected = _selectedUsers.contains(user);
                        return ListTile(
                          title: Text(user.name),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onTap: () => _toggleUser(user),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedUsers.isNotEmpty ? _submitSelection : null,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
