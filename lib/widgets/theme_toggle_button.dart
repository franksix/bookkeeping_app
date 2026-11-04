import 'package:flutter/material.dart';
import '../theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? '切换到亮色' : '切换到暗色',
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: ThemeController.instance.toggle,
        );
      },
    );
  }
}