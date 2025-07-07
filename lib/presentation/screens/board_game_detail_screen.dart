import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:hive_flutter/hive_flutter.dart';

class _BoardGameDetailScreen extends StatefulWidget {
  final BoardGame boardGame;

  const _BoardGameDetailScreen({
    super.key,
    required this.boardGame,
  });

  @override
  State<_BoardGameDetailScreen> createState() => _BoardGameDetailScreenState();
}

class _BoardGameDetailScreenState extends State<_BoardGameDetailScreen> {
  final scoringCategoryBox = Hive.box<ScoringCategory>('scoringCategories');
  List<ScoringCategory>? scoringCategories;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    scoringCategories = scoringCategoryBox.values
        .where((item) => item.boardGameId == widget.boardGame.id)
        .toList();
  }

  void _addScoringCategory() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        scoringCategories.add(text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
