import 'package:shared_preferences/shared_preferences.dart';

/// Modos de cálculo de fecha de pago
enum PaymentDateMode {
  secondSaturday, // Segundo sábado de cada mes
  specificDay,    // Día específico del mes
}

class SettingsService {
  static final SettingsService instance = SettingsService._init();
  static const String _keyPaymentDateMode = 'payment_date_mode';

  SettingsService._init();

  /// Obtener el modo de fecha de pago configurado
  Future<PaymentDateMode> getPaymentDateMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeString = prefs.getString(_keyPaymentDateMode);
    
    if (modeString == null) {
      return PaymentDateMode.specificDay; // Por defecto: día específico
    }
    
    return PaymentDateMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => PaymentDateMode.specificDay,
    );
  }

  /// Guardar el modo de fecha de pago
  Future<void> setPaymentDateMode(PaymentDateMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPaymentDateMode, mode.toString());
  }
}
