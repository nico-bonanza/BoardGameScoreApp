import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/presentation/widgets/modals/user/update_modal.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final Box<User> userBox = Hive.box<User>('users');
  late final ValueListenable<Box<User>> userListenable;

  @override
  void initState() {
    super.initState();
    userListenable = userBox.listenable(keys: [widget.user.id]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ユーザー詳細'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // constraints: BoxConstraints(maxWidth: 600), 最大幅制限：600。
          constraints: BoxConstraints(), // 最大幅制限：なし。
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder<Box<User>>(
              valueListenable: userListenable,
              builder: (context, box, _) {
                final currentUser = box.get(widget.user.id);
                if (currentUser == null) {
                  return Center(child: Text('ユーザーが見つかりません'));
                }
                return Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.person),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.user.name,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // モーダル表示
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // キーボードで自動調整
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (context) =>
                                UserUpdateModal(user: widget.user),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 1,
                  ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
