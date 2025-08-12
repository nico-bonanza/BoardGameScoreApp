import 'package:flutter/material.dart';
import 'package:game_score_app/presentation/screens/user/detail_screen.dart';
import 'package:game_score_app/presentation/widgets/modals/user/input_modal.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<User>('users');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 戻るボタンを無効化
        title: Text('ユーザー'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<User> userBox, _) {
          // データがない場合のメイン表示
          if (userBox.isEmpty) {
            return const Center(child: Text('あなたは孤高のソロボーダー'));
          }

          // メイン表示
          return ListView.builder(
            itemCount: userBox.length,
            itemBuilder: (context, index) {
              final users = userBox.values.toList()
                ..sort((a, b) => a.name.compareTo(b.name));
              final user = users[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // ユーザー名
                  title: Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // // UUID
                  // subtitle: Text('UUID: ${user?.id ?? '-'}'),
                  leading: const Icon(Icons.person),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(
                          user: user!,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // 右下プラスボタン
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
