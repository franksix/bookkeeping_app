import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/record.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Future<void> _add() async {
    final r = await Navigator.push<Record>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditPage()),
    );
    if (r != null) {
      setState(() => _records.add(r));
    }
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
        builder: (ctx)=>AlertDialog(
          title: const Text('删除这笔账？'),
          content: Text('${r.category}  ¥${formatAmount(r.amount)}'),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx,false), child: const Text('取消')),
            TextButton(onPressed: ()=>Navigator.pop(ctx,true), child: const Text('删除')),
          ],
        ),
    );
    if (ok == true){
      setState(()=> _records.remove(r));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记账本')),
      body: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) => _buildItem(_records[index]),
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
