// Formato de moneda: $ 2,000,000
String formatCurrency(double amount) {
  return "\$ ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}";
}
