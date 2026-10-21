class FinanceTransaction {
  final String id;
  final String title;
  final double amount;
  final bool isExpense;
  final String category; // 'Makan & Kopi', 'Transport', 'Belanja', 'Tagihan', 'Lainnya'
  final DateTime date;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    this.isExpense = true,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isExpense': isExpense,
        'category': category,
        'date': date.toIso8601String(),
      };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) => FinanceTransaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        isExpense: json['isExpense'] as bool? ?? true,
        category: json['category'] as String? ?? 'Makan & Kopi',
        date: DateTime.parse(json['date'] as String),
      );
}

class WishlistItem {
  final String id;
  final String name;
  final double targetPrice;
  final double savedAmount;
  final String iconCode;

  WishlistItem({
    required this.id,
    required this.name,
    required this.targetPrice,
    this.savedAmount = 0.0,
    this.iconCode = 'gift',
  });

  double get progress => (savedAmount / targetPrice).clamp(0.0, 1.0);
  bool get isAchieved => savedAmount >= targetPrice;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetPrice': targetPrice,
        'savedAmount': savedAmount,
        'iconCode': iconCode,
      };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as String,
        name: json['name'] as String,
        targetPrice: (json['targetPrice'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
        iconCode: json['iconCode'] as String? ?? 'gift',
      );
}
