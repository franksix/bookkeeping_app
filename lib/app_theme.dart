import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark ? Colors.black : Colors.white;
    final onSurface = isDark ? Colors.white : Colors.black;
    final subtle = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    final outline = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDD);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: onSurface,
      onPrimary: surface,
      secondary: onSurface,
      onSecondary: surface,
      error: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F),
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: subtle,
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: selected ? onSurface : onSurface.withOpacity(0.55),
          );
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return TextStyle(
            color: selected ? onSurface : onSurface.withOpacity(0.55),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: onSurface,
        foregroundColor: surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: onSurface,
          foregroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: onSurface, width: 2),
        ),
      ),
    );
  }
}