import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'theme_controller.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ReminderService.instance.init();
  } catch (e) {
    debugPrint('ReminderService init failed: $e');
  }
  runApp(const MyApp());
}

// 后面 MyApp / MainShell 保持原样不动
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '记账本',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const MainShell(), // 这里引用了下面定义的 MainShell
        );
      },
    );
  }
}

// ================= 从这里开始是被你漏掉的代码 =================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = const [HomePage(), StatsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long), label: '账单'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: '统计'),
        ],
      ),
    );
  }
}