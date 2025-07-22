import 'package:flutter/material.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';

class ScoringCategorySelectModal extends StatefulWidget {
  final List<ScoringCategory> allScoringCategories;

  const ScoringCategorySelectModal({super.key, required this.allScoringCategories});

  @override
  State<ScoringCategorySelectModal> createState() => _ScoringCategorySelectModalState();
}

class _ScoringCategorySelectModalState extends State<ScoringCategorySelectModal> {
  late List<ScoringCategory> _filteredScoringCategories;
  final Set<ScoringCategory> _selectedScoringCategories = {};

  @override
  void initState() {
    super.initState();
    _filteredScoringCategories = widget.allScoringCategories; // 呼び出し元から渡された得点項目
  }

// 絞り込み（ひらがな・カタカナ問わず）
  void _updateQuery(String text) {
    setState(() {
      final queryHiragana = _toHiragana(text.toLowerCase());

      _filteredScoringCategories = widget.allScoringCategories.where((item) {
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
  void _toggleScoringCategory(ScoringCategory scoringCategory) {
    setState(() {
      if (_selectedScoringCategories.contains(scoringCategory)) {
        _selectedScoringCategories.remove(scoringCategory);
      } else {
        _selectedScoringCategories.add(scoringCategory);
      }
    });
  }

  void _submitSelection() {
    Navigator.pop(context, _selectedScoringCategories.toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("得点項目を選ぶ"),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: "得点項目を検索...",
                border: OutlineInputBorder(),
              ),
              onChanged: _updateQuery,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredScoringCategories.isEmpty
                  ? const Text("一致する得点項目が見つかりません")
                  : ListView.builder(
                      itemCount: _filteredScoringCategories.length,
                      itemBuilder: (context, index) {
                        final scoringCategory = _filteredScoringCategories[index];
                        final isSelected = _selectedScoringCategories.contains(scoringCategory);
                        return ListTile(
                          title: Text(scoringCategory.name),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onTap: () => _toggleScoringCategory(scoringCategory),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedScoringCategories.isNotEmpty ? _submitSelection : null,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
