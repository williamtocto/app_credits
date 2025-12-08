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

  /// Obtiene el número de cuotas pagadas
  int getPaidInstallments() {
    return installments.where((inst) => inst.paid).length;
  }

  /// Obtiene el número de cuotas pendientes
  int getRemainingInstallments() {
    return installments.where((inst) => !inst.paid).length;
  }

  /// Obtiene la primera cuota no pagada
  Installment? getNextUnpaidInstallment() {
    try {
      return installments.firstWhere((inst) => !inst.paid);
    } catch (e) {
      return null; // No hay cuotas pendientes
    }
  }

  /// Calcula el capital por pagar (suma de capital de cuotas no pagadas)
  double getRemainingCapital() {
    return installments
        .where((inst) => !inst.paid)
        .fold(0.0, (sum, inst) => sum + inst.capital);
  }

  /// Calcula el total adeudado con lógica dinámica:
  /// - Si estamos en el mes de la siguiente cuota, suma la cuota completa (capital + interés)
  /// - Si no, solo retorna el capital pendiente
  double getTotalOwed() {
    final remainingCapital = getRemainingCapital();
    final nextInstallment = getNextUnpaidInstallment();
    
    if (nextInstallment == null) {
      return 0.0; // No hay cuotas pendientes
    }

    // Parsear el monthLabel (formato: "M/YYYY")
    final parts = nextInstallment.monthLabel.split('/');
    if (parts.length != 2) {
      return remainingCapital; // Formato inválido, solo retornar capital
    }

    try {
      final int paymentMonth = int.parse(parts[0]);
      final int paymentYear = int.parse(parts[1]);
      
      final now = DateTime.now();
      
      // Si estamos en el mes y año de la siguiente cuota, sumar la cuota completa
      if (now.year == paymentYear && now.month == paymentMonth) {
        return remainingCapital + nextInstallment.interest;
      }
      
      // Si no, solo retornar el capital pendiente
      return remainingCapital;
    } catch (e) {
      return remainingCapital; // Error al parsear, retornar solo capital
    }
  }
}
