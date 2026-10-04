import 'package:flutter/material.dart';

import '../models/record.dart';

class AddEditPage extends StatefulWidget {
  final Record? record;
  const AddEditPage({super.key,this.record});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  final _noteCtrl = TextEditingController();

  bool _isExpense = true;

  String _category = expenseCategories.first;

  List<String> get _categories =>
      _isExpense ? expenseCategories : incomeCategories;

  @override
  void initState(){
    super.initState();
    final r = widget.record;
    if (r!=null){
      _isExpense = r.isExpense;
      _category = r.category;
      _date = r.date;
      _amountCtrl.text = r.amount.toStringAsFixed(2);
      _noteCtrl.text=r.note;
    }
  }

  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _switchType(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      if (_isExpense) {
        _category = expenseCategories.first;
      } else {
        _category = incomeCategories.first;
      }
    });
  }
  
  Future<void> _pickDate() async{
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final record = Record(
      amount: double.parse(_amountCtrl.text.trim()),
      isExpense: _isExpense,
      category: _category,
      note: _noteCtrl.text.trim(),
      date: _date,
    );
    Navigator.pop(context,record);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.record == null?"记一笔":'编辑账目')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _chip('支出', _isExpense, () => _switchType(true)),
                const SizedBox(width: 12),
                _chip('收入', !_isExpense, () => _switchType(false)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '金额',
                prefixText: '¥',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入金额';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return '金额格式不对';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16,),
            InkWell(
              onTap:_pickDate,
              child: InputDecorator(decoration: const InputDecoration(
                labelText: '日期',
                border: OutlineInputBorder(),
              ),
              child: Text(formatDate(_date)),
              ),
            ),
            const SizedBox(height: 16,),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32,),
            ElevatedButton(onPressed: _save,style: ElevatedButton.styleFrom(minimumSize:const Size.fromHeight(48)), child: const Text('保存'))
          ],
        ),
      ),
    );
  }
}
