import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // 收藏功能
  var favorites = <WordPair>[];

  void toggleFavorite() {
    // 存在就删除否则添加
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    print(favorites);
    notifyListeners();
  }
}

// `StatefulWidget` 这是一种具有 `State` 的 widget.
// 将 `MyHomePage` 转换为有状态 widget
// 重构选择 `Convert to StatefulWidget`
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 开始的下划线将此类设置为私有类, 并由编译器强制执行
class _MyHomePageState extends State<MyHomePage> {
  // 扩展 `State` 因此可以管理其自己的值

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    // 重构选择 `Wrap with Builder`
    // 每当约束发生更改时，系统都会调用 `LayoutBuilder` 的 `builder` 回调
    // · 用户调整应用窗口的大小
    // · 用户将手机从人像模式旋转到横屏模式，或从横屏模式旋转到人像模式
    // · `MyHomePage` 旁边的一些 widget 变大，使 `MyHomePage` 的约束变小
    // ...
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Row(
        children: [
          // `SafeArea` 将确保其子项不会被硬件凹凸或状态栏遮挡
          SafeArea(
              // 以防止导航栏按钮被遮挡，例如被移动状态栏遮挡
              child: NavigationRail(
                  // 查询当前的 `constraints` 来决定是否显示标签
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                        icon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(
                        icon: Icon(Icons.favorite), label: Text("Favorites"))
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    // 更新 Widget 状态
                    setState(() {
                      selectedIndex = value;
                    });
                  })),
          // 使用 `Expanded` 占用可用的水平空间
          Expanded(
              // `Container` 指定背景颜色
              child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: page,
          ))
        ],
      ));
    });
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text("No favorites yet"),
      );
    }

    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: Text("You have"
                "${appState.favorites.length} favorites:")),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          )
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // 图标
    IconData icon = appState.favorites.contains(pair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(
            height: 10,
          ),
          Row(
            // 不要占用所有可用的水平空间
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text("Like"),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next')),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
