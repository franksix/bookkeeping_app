import 'package:flutter/material.dart';

import '../models/record.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<Record> _records = [
    Record(amount: 20,
        isExpense: true,
        category: '餐饮',
        note: '午饭',
        date: DateTime(2026, 8, 24)),
    Record(amount: 88,
        isExpense: true,
        category: '交通',
        date: DateTime(2026, 8, 20)),
    Record(amount: 5000,
        isExpense: false,
        category: '工资',
        note: '8月工资',
        date: DateTime(2026, 8, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    final income = _records.where((r) => !r.isExpense).fold<double>(
        0, (sum, r) => sum + r.amount);
    final expense = _records.where((r) => r.isExpense).fold<double>(
        0, (sum, r) => sum + r.amount);
    final balance = income - expense;

    return Scaffold(
      appBar: AppBar(title: const Text('统计'),),
      body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          _totalCard('收入', income, Colors.green),
      const SizedBox(height: 12),
      _totalCard('支出', expense, Colors.redAccent),
      const SizedBox(height: 22),
        _totalCard('结余', balance, Colors.blue),
        ],
      ),
    );
  }

  Widget _totalCard(String label, double value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,style: const TextStyle(fontSize: 16),),
            Text(
              '¥${formatAmount(value)}',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color:color),
            ),
          ],
        ),
      ),
    );
  }
}
