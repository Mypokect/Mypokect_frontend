class TransactionOccurrence {
  final int id;
  final String title;
  final double amount;
  final String type;
  final String? category;
  final String date;
  bool isPaid; // No es 'final' para permitir la actualización optimista

  TransactionOccurrence({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.category,
    required this.date,
    required this.isPaid,
  });

  factory TransactionOccurrence.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionOccurrence(
        id: json['id'] as int,
        title: json['title'] as String? ?? 'Sin Título',
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        type: json['type'] as String? ?? 'expense',
        category: json['category'] as String?,
        date: json['date'] as String,
        isPaid: json['is_paid'] == 1 || json['is_paid'] == true,
      );
    } catch (e) {
      print("❌ ERROR al parsear TransactionOccurrence.fromJson: $e");
      print("   JSON con problemas: $json");
      rethrow; // Lanza el error para que sea visible
    }
  }
}