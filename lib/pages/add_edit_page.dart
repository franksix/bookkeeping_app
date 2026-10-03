import 'package:flutter/material.dart';

class AddEditPage extends StatefulWidget {
  const AddEditPage({super.key});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  bool _isExpense = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _switchType(bool isExpense) {
    setState(() => _isExpense = isExpense);
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
      appBar: AppBar(title: const Text("记一笔")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _chip('支出', _isExpense, ()=>_switchType(true)),
                const SizedBox(width: 12,),
                _chip('收入', !_isExpense, ()=>_switchType(false)),
              ],
            ),
            const SizedBox(height: 16,),
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
          ],
        ),
      ),
    );
  }
}
