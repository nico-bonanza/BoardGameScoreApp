import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/board_game.dart';

class TitleSelectModal extends StatefulWidget {
  final List<BoardGame> allBoardGames;

  const TitleSelectModal({super.key, required this.allBoardGames});

  @override
  State<TitleSelectModal> createState() => _TitleSelectModalState();
}

class _TitleSelectModalState extends State<TitleSelectModal> {
  late List<BoardGame> _filteredBoardGames; // 絞り込みボドゲリスト

  @override
  void initState() {
    super.initState();
    _filteredBoardGames = widget.allBoardGames;
  }

  void _updateQuery(String text) {
    setState(() {
      final queryHiragana = _toHiragana(text.toLowerCase());

      _filteredBoardGames = widget.allBoardGames.where((item) {
        final titleHiragana = _toHiragana(item.title.toLowerCase());
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("タイトルを選ぶ"),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: "タイトルを検索...",
                border: OutlineInputBorder(),
              ),
              onChanged: _updateQuery,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredBoardGames.isEmpty
                  ? const Text("一致するボードゲームが見つかりません")
                  : ListView.builder(
                      itemCount: _filteredBoardGames.length,
                      itemBuilder: (context, index) {
                        _filteredBoardGames.sort((a, b)=> a.title.compareTo(b.title));
                        final game = _filteredBoardGames[index];
                        return ListTile(
                          title: Text(game.title),
                          onTap: () {
                            Navigator.pop(context, game); // BoardGame を返す
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
