import 'package:flutter/material.dart';
import '../service/board_game_service.dart';

class BoardGameInputScreen extends StatefulWidget {
  const BoardGameInputScreen({Key? key}) : super(key: key);

  @override
  _BoardGameInputScreenState createState() => _BoardGameInputScreenState();
}

class _BoardGameInputScreenState extends State<BoardGameInputScreen> {
  final _titleController = TextEditingController();
  final _service = BoardGameService();

  void _submit() async {
    await _service.registerBoardGame(_titleController.text);
    if (!mounted) return; // 非同期実行中に画面切り替わった際に、以下の処理を行わないようにする。
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ボードゲームを登録しました。')),
    );
    _titleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ボードゲーム登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: _submit, child: Text('登録')),
          ],
        ),
      ),
    );
  }
}
