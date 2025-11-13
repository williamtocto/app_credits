import 'installment_model.dart';

class Credit {
  final int? id;
  final String name;
  final DateTime startDate;
  final double amount;
  final int termMonths;
  final double monthlyInterest;
  List<Installment> installments;

  Credit({
    this.id,
    required this.name,
    required this.startDate,
    required this.amount,
    required this.termMonths,
    required this.monthlyInterest,
    required this.installments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'amount': amount,
      'termMonths': termMonths,
      'monthlyInterest': monthlyInterest,
    };
  }

  factory Credit.fromMap(Map<String, dynamic> map, List<Installment> installments) {
    return Credit(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      amount: map['amount'],
      termMonths: map['termMonths'],
      monthlyInterest: map['monthlyInterest'],
      installments: installments,
    );
  }
}
