class Installment {
  final int? id;
  final int creditId;
  final int number;
  final String monthLabel;
  final double balance;
  final double capital;
  final double interest;
  bool paid;

  Installment({
    this.id,
    required this.creditId,
    required this.number,
    required this.monthLabel,
    required this.balance,
    required this.capital,
    required this.interest,
    this.paid = false,
  });

  double get total => capital + interest;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditId': creditId,
      'number': number,
      'monthLabel': monthLabel,
      'balance': balance,
      'capital': capital,
      'interest': interest,
      'paid': paid ? 1 : 0,
    };
  }

  factory Installment.fromMap(Map<String, dynamic> map) {
    return Installment(
      id: map['id'],
      creditId: map['creditId'],
      number: map['number'],
      monthLabel: map['monthLabel'],
      balance: map['balance'],
      capital: map['capital'],
      interest: map['interest'],
      paid: map['paid'] == 1,
    );
  }
}
