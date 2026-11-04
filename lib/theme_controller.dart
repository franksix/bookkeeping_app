import 'package:flutter/material.dart';

/// 全局主题控制器（单例）
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(ThemeMode.light);

  bool get isDark => mode.value == ThemeMode.dark;

  void toggle() {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}