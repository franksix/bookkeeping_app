class Record {
  final int? id;
  final double amount;
  final bool isExpense;
  final String category;
  final String note;
  final DateTime date;

  Record({
    this.id,
    required this.amount,
    required this.isExpense,
    required this.category,
    this.note = '',
    required this.date,
});

  Map<String,dynamic> toMap(){
    return{
      'id':id,
      'amount':amount,
      'is_expense':isExpense?1:0,
      'category':category,
      'note':note,
      'date':formatDate(date),
    };
  }
  factory Record.fromMap(Map<String,dynamic> map){
    return Record(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      isExpense: (map['is_expense'] as int) ==1,
      category: map['category'] as String,
      note: (map['note'] as String?) ?? '',
      date: DateTime.parse(map['date'] as String),
    );
  }
}

String formatDate(DateTime d){
  final mm = d.month.toString().padLeft(2,'0');
  final dd = d.day.toString().padLeft(2,'0');
  return '${d.year}-$mm-$dd';
}

String formatAmount(double v) => v.toStringAsFixed(2);

const List<String> expenseCategories = ['餐饮','交通','购物','娱乐','居住','其他'];
const List<String> incomeCategories = ['工资','奖金','理财','其他'];
