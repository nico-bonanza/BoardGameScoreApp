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
  late final PageController _pageController;

  final List<Widget> _screens = [
    RecordListScreen(),
    BoardGameListScreen(),
    UserListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
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
        ],
      ),
    );
  }
}
