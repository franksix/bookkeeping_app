import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '记账本',
      theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('记账本', style: TextStyle(fontSize: 32))),
      ),
    );
  }
}
