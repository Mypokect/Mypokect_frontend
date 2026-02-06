class TransactionOccurrence {
  final int id;
  final String title;
  final double amount;
  final String date;
  final String type;
  final bool isPaid;
  final String? category;

  TransactionOccurrence({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.isPaid = false,
    this.category,
  });

  factory TransactionOccurrence.fromJson(Map<String, dynamic> json) {
    return TransactionOccurrence(
      id: json['id'] as int,
      title: json['title'] as String,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] as String,
      type: json['type'] as String,
      isPaid: json['is_paid'] == true || json['isPaid'] == true,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'type': type,
      'is_paid': isPaid,
      'category': category,
    };
  }
}
