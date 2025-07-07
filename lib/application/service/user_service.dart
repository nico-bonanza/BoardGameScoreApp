import 'package:game_score_app/domain/models/user.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// ボードゲームサービス
class UserService {
  // モデル取得
  final _box = Hive.box<User>('users');
  final Uuid _uuid = Uuid();

  // 登録
  Future<void> registerUser(String name) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
    );

    await _box.put(user.id, user);
  }

  // 全件取得
  List<User> getAllUsers() {
    return _box.values.toList();
  }
}
