import 'package:flutter/material.dart';

import '../models/record.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<Record> _records = [
    Record(
      amount: 20,
      isExpense: true,
      category: '餐饮',
      note: '午饭',
      date: DateTime(2026, 8, 24),
    ),
    Record(
      amount: 88,
      isExpense: true,
      category: '交通',
      date: DateTime(2026, 8, 20),
    ),
    Record(
      amount: 5000,
      isExpense: false,
      category: '工资',
      note: '8月工资',
      date: DateTime(2026, 8, 1),
    ),
  ];

  String? _selectedMonth;
  
  String _monthKey(DateTime d)=>'${d.year}-${d.month.toString().padLeft(2,'0')}';

  Widget _monthSelector(List<String> months, String selected) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: "月份",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
      ),
      items: months
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (v) => setState(() => _selectedMonth = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedMonth ?? _monthKey(DateTime.now());
    final months = _records.map((r)=>_monthKey(r.date)).toSet().toList()
    ..sort((a,b)=>b.compareTo(a));
    if (!months.contains(selected)){
      months.add(selected);
      months.sort((a,b)=>b.compareTo(a));
    }
    final monthRecords = _records.where((r)=>_monthKey(r.date)==selected).toList();
    final income = monthRecords
        .where((r) => !r.isExpense)
        .fold<double>(0, (sum, r) => sum + r.amount);
    final expense = monthRecords
        .where((r) => r.isExpense)
        .fold<double>(0, (sum, r) => sum + r.amount);
    final balance = income - expense;

    final byCategory = <String, double>{};
    for (final r in monthRecords.where((r) => r.isExpense)) {
      byCategory[r.category] = (byCategory[r.category] ?? 0) + r.amount;
    }
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _monthSelector(months, selected),
          const SizedBox(height: 16,),
          Text('本月共${monthRecords.length}笔账',style: const TextStyle(fontSize: 14,color: Colors.grey),),
          _totalCard('收入', income, Colors.green),
          const SizedBox(height: 12),
          _totalCard('支出', expense, Colors.redAccent),
          const SizedBox(height: 12),
          _totalCard('结余', balance, Colors.blue),
          const SizedBox(height: 24),
          const Text(
            '支出分类占比',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('这个月还没有支出记录',style: TextStyle(color: Colors.grey),),
            )
          else
          ...sorted.map((e) => _categoryBar(e.key, e.value, expense)),
        ],
      ),
    );
  }

  Widget _totalCard(String label, double value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              '¥${formatAmount(value)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBar(String name, double value, double total) {
    final percent = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name),
              Text(
                '¥${formatAmount(value)}  (${(percent * 100).toStringAsFixed(1)}%)',
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percent, minHeight: 8),
          ),
        ],
      ),
    );
  }
}
