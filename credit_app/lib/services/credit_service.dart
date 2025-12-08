import '../models/credit_model.dart';
import '../models/installment_model.dart';
import '../services/db_services.dart';
import '../services/settings_service.dart';

class CreditService {
  final DBService _db = DBService.instance;

  /// Crear un crédito con su tabla de amortización Alemana
  Future<Credit> createCredit({
    required String name,
    required double amount,
    required int termMonths,
    required double monthlyInterest,
    required DateTime startDate,
  }) async {

    // 1️⃣ Generar tabla de amortización sin creditId aún
    final installments = await _generateAmortization(
      amount: amount,
      termMonths: termMonths,
      interestRate: monthlyInterest,
      startDate: startDate,
    );


    // 2️⃣ Crear el crédito (sin id, SQLite lo autogenera)
    final credit = Credit(
      name: name,
      startDate: startDate,
      amount: amount,
      termMonths: termMonths,
      monthlyInterest: monthlyInterest,
      installments: [],
    );

    // 3️⃣ Guardar el crédito y obtener el ID generado
    int creditId = await _db.insertCredit(credit);

    // 4️⃣ Insertar las cuotas, ahora sí con el creditId
    final updatedInstallments = installments.map((i) {
      return Installment(
        creditId: creditId,
        number: i.number,
        monthLabel: i.monthLabel,
        dueDate: i.dueDate,
        balance: i.balance,
        capital: i.capital,
        interest: i.interest,
        paid: false,
      );
    }).toList();

    await _db.insertInstallments(updatedInstallments);


    // 5️⃣ Recargar el crédito desde la base de datos con todas las cuotas
    final loadedCredit = await _db.getCreditById(creditId);
    
    return loadedCredit!;
  }

  /// Obtener todos los créditos
  Future<List<Credit>> getCredits() async {
    return await _db.getAllCredits();
  }

  /// Obtener un crédito por ID
  Future<Credit?> getCreditById(int id) async {
    return await _db.getCreditById(id);
  }

  /// Marcar una cuota como pagada
  Future<void> markInstallmentPaid(int installmentId) async {
    await _db.markInstallmentPaid(installmentId);
  }

  /// Desmarcar una cuota como pagada
  Future<void> unmarkInstallmentPaid(int installmentId) async {
    await _db.unmarkInstallmentPaid(installmentId);
  }

  /// Eliminar un crédito
  Future<void> deleteCredit(int creditId) async {
    await _db.deleteCredit(creditId);
  }

  /// Genera amortización alemana (cuota fija de capital)
  Future<List<Installment>> _generateAmortization({
    required double amount,
    required int termMonths,
    required double interestRate,
    required DateTime startDate,
  }) async {
    List<Installment> installments = [];

    // Obtener modo de fecha de configuración
    final settingsService = SettingsService.instance;
    final paymentMode = await settingsService.getPaymentDateMode();

    final double capitalFixed = amount / termMonths;
    double totalCapitalAssigned = 0.0;

    for (int month = 1; month <= termMonths; month++) {
      // Calcular el saldo ANTES de pagar esta cuota
      final double balanceBeforePayment = amount - totalCapitalAssigned;
      
      final double interest = balanceBeforePayment * (interestRate / 100);
      
      // Para la última cuota, usar el monto original menos lo ya asignado
      final double capital;
      if (month == termMonths) {
        // La última cuota debe ser exactamente lo que queda para completar el monto original
        capital = amount - totalCapitalAssigned;
      } else {
        capital = double.parse(capitalFixed.toStringAsFixed(2));
      }
      
      // Actualizar el total de capital asignado
      totalCapitalAssigned += capital;

      // Calcular la fecha de vencimiento según el modo configurado
      final DateTime dueDate;
      if (paymentMode == PaymentDateMode.secondSaturday) {
        // Segundo sábado del mes (empezando desde el siguiente mes)
        dueDate = _getSecondSaturday(startDate.year, startDate.month + month);
      } else {
        // Día específico del mes (día del startDate, empezando desde el siguiente mes)
        dueDate = DateTime(
          startDate.year,
          startDate.month + month,
          startDate.day,
        );
      }

      final installment = Installment(
        id: null,
        creditId: -1,
        number: month,
        monthLabel: "${dueDate.month}/${dueDate.year}",
        dueDate: dueDate,
        balance: double.parse(balanceBeforePayment.toStringAsFixed(2)),
        capital: double.parse(capital.toStringAsFixed(2)),
        interest: double.parse(interest.toStringAsFixed(2)),
        paid: false,
      );
      
      installments.add(installment);
    }

    return installments;
  }

  /// Calcula el segundo sábado de un mes dado
  DateTime _getSecondSaturday(int year, int month) {
    // Obtener primer día del mes
    var firstDay = DateTime(year, month, 1);
    
    // Encontrar el primer sábado (weekday 6 = sábado)
    int daysUntilSaturday = (DateTime.saturday - firstDay.weekday) % 7;
    var firstSaturday = firstDay.add(Duration(days: daysUntilSaturday));
    
    // Agregar 7 días para obtener el segundo sábado
    return firstSaturday.add(const Duration(days: 7));
  }


}
