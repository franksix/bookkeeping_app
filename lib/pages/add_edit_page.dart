import 'package:flutter/material.dart';

class AddEditPage extends StatefulWidget{
  const AddEditPage({super.key});

  @override
  State<AddEditPage> createState()=>_AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage>{
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  @override
  void dispose(){
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:const Text("记一笔"),),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller:_amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:const InputDecoration(
                labelText: '金额',
                prefixText:'¥',
                border: OutlineInputBorder(),
              )
            )
          ],
        ),
      ),
    );
  }
}