class Installment {
  final int? id;
  final int creditId;
  final int number;
  final String monthLabel; // @deprecated - solo para compatibilidad durante migración
  final DateTime dueDate;  // Nueva fecha de vencimiento completa
  final double balance;
  final double capital;
  final double interest;
  bool paid;

  Installment({
    this.id,
    required this.creditId,
    required this.number,
    required this.monthLabel,
    required this.dueDate,
    required this.balance,
    required this.capital,
    required this.interest,
    this.paid = false,
  });

  double get total => capital + interest;
  
  /// Formato de fecha para visualización: DD/MM/YYYY
  String get dueDateFormatted {
    return "${dueDate.day.toString().padLeft(2, '0')}/"
           "${dueDate.month.toString().padLeft(2, '0')}/"
           "${dueDate.year}";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditId': creditId,
      'number': number,
      'monthLabel': monthLabel,
      'dueDate': dueDate.toIso8601String(),
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
      monthLabel: map['monthLabel'] ?? '', // Compatibilidad con datos antiguos
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate'])
          : _parseMonthLabel(map['monthLabel']), // Fallback para migración
      balance: map['balance'],
      capital: map['capital'],
      interest: map['interest'],
      paid: map['paid'] == 1,
    );
  }
  
  /// Convierte monthLabel (M/YYYY) a DateTime (primer día del mes)
  static DateTime _parseMonthLabel(String monthLabel) {
    final parts = monthLabel.split('/');
    if (parts.length == 2) {
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      return DateTime(year, month, 1);
    }
    return DateTime.now(); // Fallback si el formato es inválido
  }
}
