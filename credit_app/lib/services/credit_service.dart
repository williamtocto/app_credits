import 'package:intl/intl.dart';
import '../models/credit_model.dart';
import '../models/installment_model.dart';

class CreditService {
  final List<Credit> _credits = [];

  List<Credit> get credits => _credits;

  Credit createCredit({
    required String name,
    required double amount,
    required int termMonths,
    required double monthlyInterest,
    required DateTime startDate,
  }) {
    final installments = _generateAmortization(
      amount: amount,
      termMonths: termMonths,
      interestRate: monthlyInterest,
      startDate: startDate,
    );

    final credit = Credit(
      name: name,
      startDate: startDate,
      amount: amount,
      termMonths: termMonths,
      monthlyInterest: monthlyInterest,
      installments: installments,
    );

    _credits.add(credit);
    return credit;
  }

  List<Installment> _generateAmortization({
    required double amount,
    required int termMonths,
    required double interestRate,
    required DateTime startDate,
    int creditId = 0,
  }) {
    List<Installment> list = [];
    double remaining = amount;
    double fixedCapital = amount / termMonths;
    final formatter = DateFormat('MMM-yy');

    for (int i = 0; i < termMonths; i++) {
      double interest = remaining * (interestRate / 100);
      String monthLabel = formatter.format(
        DateTime(startDate.year, startDate.month + i + 1),
      );

      list.add(
        Installment(
          creditId: creditId,
          number: i + 1,
          monthLabel: monthLabel,
          balance: remaining,
          capital: fixedCapital,
          interest: double.parse(interest.toStringAsFixed(2)),
        ),
      );
      remaining -= fixedCapital;
    }
    return list;
  }

  void markInstallmentPaid(Credit credit, int number) {
    credit.installments[number - 1].paid = true;
  }
}
