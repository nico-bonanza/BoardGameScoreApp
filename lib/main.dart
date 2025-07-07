import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game_score_app/domain/models/user.dart';
import 'package:game_score_app/domain/models/board_game.dart';
import 'package:game_score_app/domain/models/record.dart';
import 'package:game_score_app/domain/models/scoring_category.dart';
import 'package:game_score_app/domain/models/user_scoring_category_score.dart';
import 'package:game_score_app/presentation/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // flutter初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Hive初期化
  await Hive.initFlutter();
  // 型アダプター登録
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BoardGameAdapter());
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(ScoringCategoryAdapter());
  Hive.registerAdapter(UserScoringCategoryScoreAdapter());
  // モデルをHiveで利用可能な状態にする（インデックス情報などのメモリマッピング）
  await Hive.openBox<User>('users');
  await Hive.openBox<BoardGame>('boardGames');
  await Hive.openBox<Record>('records');
  await Hive.openBox<ScoringCategory>('scoringCategories');
  await Hive.openBox<UserScoringCategoryScore>('userScoringCategoryScores');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('ja'), // 日本語
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 252, 255, 249), // やや明るめのグレー
        textTheme: GoogleFonts.zenMaruGothicTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF2E2E2E), // やや明るめのグレー
        textTheme: GoogleFonts.zenMaruGothicTextTheme().apply(
          bodyColor: Colors.white, // 入力値やテキストの色
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Flutter Demo',
  //     theme: ThemeData(
  //       // This is the theme of your application.
  //       //
  //       // Try running your application with "flutter run". You'll see the
  //       // application has a blue toolbar. Then, without quitting the app, try
  //       // changing the primarySwatch below to Colors.green and then invoke
  //       // "hot reload" (press "r" in the console where you ran "flutter run",
  //       // or simply save your changes to "hot reload" in a Flutter IDE).
  //       // Notice that the counter didn't reset back to zero; the application
  //       // is not restarted.
  //       primarySwatch: Colors.blue,
  //     ),
  //     home: const MyHomePage(title: 'Flutter Demo Home Page'),
  //   );
  // }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
