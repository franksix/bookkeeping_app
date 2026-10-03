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
}

String formatDate(DateTime d){
  final mm = d.month.toString().padLeft(2,'0');
  final dd = d.day.toString().padLeft(2,'0');
  return '${d.year}-$mm-$dd';
}

String formatAmount(double v) => v.toStringAsFixed(2);