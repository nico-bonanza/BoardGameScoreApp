import 'package:flutter/material.dart';
import 'package:game_score_app/modals/user_input_modal.dart';
import 'package:game_score_app/models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<User>('users');

    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<User> userBox, _) {
          if (userBox.isEmpty) {
            return const Center(child: Text('あなたは孤高のソロボーダー'));
          }

          return ListView.builder(
            itemCount: userBox.length,
            itemBuilder: (context, index) {
              final user = userBox.getAt(index);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    user?.name ?? '無名',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('UUID: ${user?.id ?? '-'}'),
                  leading: const Icon(Icons.person),
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
          // モーダル表示
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // キーボードで自動調整
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => UserInputModal(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
