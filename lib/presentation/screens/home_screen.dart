import 'package:flutter/material.dart';
import 'package:game_score_app/presentation/screens/board_game/list_screen.dart';
import 'package:game_score_app/presentation/screens/record/list_screen.dart';
import 'package:game_score_app/presentation/screens/user/list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ボトムナビゲータの画面配列
  final List<Widget> _screens = [
    RecordListScreen(), // プレイ記録
    BoardGameListScreen(), // ボドゲ棚
    UserListScreen(), // ユーザー
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'プレイ記録',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shelves),
              label: 'ボドゲ棚',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: 'ユーザー',
            ),
          ]),
    );
  }
}
