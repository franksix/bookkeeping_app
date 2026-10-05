import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../db/database_helper.dart';
import '../models/record.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Record> _records = [];
  bool _loading = true;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await DatabaseHelper.instance.getRecords();
    if (!mounted) return;
    setState(() {
      _records = records;
      _selectedMonth ??= _monthKey(DateTime.now());
      _loading = false;
    });
  }

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditPage()),
    );
    if (saved == true) _load();
  }

  Map<String, List<Record>> _groupByDate(List<Record> records) {
    final grouped = <String, List<Record>>{};
    for (final r in records) {
      grouped.putIfAbsent(formatDate(r.date), () => <Record>[]).add(r);
    }
    return grouped;
  }

  Widget _buildList(List<Record> records) {
    final grouped = _groupByDate(records);
    final children = <Widget>[];
    grouped.forEach((date, rs) {
      children.add(_buildDateHeader(date, rs));
      children.addAll(rs.map(_buildItem));
    });
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: children,
    );
  }

  Widget _buildDateHeader(String date, List<Record> records) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '共${records.length}笔',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  Widget _monthSelector(List<String> months, String selected) {
    return DropdownButtonFormField<String>(
      value: selected,
      decoration: const InputDecoration(
        labelText: '月份',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
      ),
      items: months
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (v) => setState(() => _selectedMonth = v),
    );
  }

  Future<void> _edit(Record r) async {
    final updated = await Navigator.push<Record>(
      context,
      MaterialPageRoute(builder: (_) => AddEditPage(record: r)),
    );
    if (updated != null) {
      setState(() {
        final i = _records.indexOf(r);
        if (i >= 0) _records[i] = updated;
      });
    }
  }

  Future<void> _delete(Record r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这笔账？'),
        content: Text('${r.category}  ¥${formatAmount(r.amount)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _records.remove(r));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedMonth ?? _monthKey(DateTime.now());
    final months = _records.map((r) => _monthKey(r.date)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (!months.contains(selected)) {
      months.add(selected);
      months.sort((a, b) => b.compareTo(a));
    }
    final monthRecords = _records
        .where((r) => _monthKey(r.date) == selected)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('记账本')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _monthSelector(months, selected),
                ),
                Expanded(
                  child: monthRecords.isEmpty
                      ? _EmptyTip(
                          message: _records.isEmpty
                              ? '还没有账目，点右下角 + 记一笔'
                              : '这个月还没有账目，换个月份看看',
                        )
                      : _buildList(monthRecords),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(Record r) {
    final sign = r.isExpense ? '-' : '+';
    final color = r.isExpense ? Colors.redAccent : Colors.green;
    return Slidable(
      key: ValueKey(r),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _delete(r),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: '删除',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text(r.category.substring(0, 1))),
          title: Text(r.category),
          subtitle: Text(
            '${formatDate(r.date)}${r.note.isEmpty ? '' : '·${r.note}'}',
          ),
          trailing: Text(
            '$sign¥${formatAmount(r.amount)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => _edit(r),
        ),
      ),
    );
  }
}

class _EmptyTip extends StatelessWidget {
  final String message;

  const _EmptyTip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
