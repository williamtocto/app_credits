import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_colors.dart';

/// Modos de cálculo de fecha de pago
enum PaymentDateMode {
  secondSaturday, // Segundo sábado de cada mes
  specificDay,    // Día específico del mes
}

class SettingsService {
  static final SettingsService instance = SettingsService._init();
  static const String _keyPaymentDateMode = 'payment_date_mode';
  static const String _keyThemeId = 'theme_id';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyReminderDays = 'reminder_days';

  SettingsService._init();

  /// Obtener el modo de fecha de pago configurado
  Future<PaymentDateMode> getPaymentDateMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeString = prefs.getString(_keyPaymentDateMode);
    
    if (modeString == null) {
      return PaymentDateMode.secondSaturday; // Por defecto: segundo sábado
    }
    
    return PaymentDateMode.values.firstWhere(
      (e) => e.toString() == modeString,
      orElse: () => PaymentDateMode.secondSaturday,
    );
  }

  /// Guardar el modo de fecha de pago
  Future<void> setPaymentDateMode(PaymentDateMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPaymentDateMode, mode.toString());
  }

  /// Obtener el tema configurado
  Future<AppColors> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeId = prefs.getString(_keyThemeId);
    
    if (themeId == null) {
      return AppColors.classicGreen; // Por defecto: verde clásico
    }
    
    return AppColors.getById(themeId);
  }

  /// Guardar el tema seleccionado
  Future<void> setTheme(AppColors colors) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeId, colors.id);
  }

  /// Verificar si las notificaciones están habilitadas
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true; // Por defecto: habilitadas
  }

  /// Habilitar/deshabilitar notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  /// Obtener días de anticipación para recordatorios
  Future<int> getReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyReminderDays) ?? 3; // Por defecto: 3 días
  }

  /// Establecer días de anticipación para recordatorios
  Future<void> setReminderDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderDays, days);
  }
}
