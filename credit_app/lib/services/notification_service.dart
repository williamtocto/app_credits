import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/installment_model.dart';
import '../models/credit_model.dart';

/// Servicio para gestionar notificaciones locales
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService._init();

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Guayaquil')); // Ecuador timezone

    // Configuración para Linux
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Abrir notificación',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      linux: initializationSettingsLinux,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Manejar tap en notificación
  void _onNotificationTap(NotificationResponse response) {
    // Aquí podrías navegar a la página de detalle del crédito
    // Por ahora solo registramos el evento
    print('Notification tapped: ${response.payload}');
  }

  /// Programar recordatorio para una cuota
  Future<void> scheduleInstallmentReminder(
    Installment installment,
    int reminderDays,
  ) async {
    if (!_initialized) await initialize();

    // No programar si ya está pagado
    if (installment.paid) return;

    // Calcular fecha de notificación (reminderDays días antes)
    final notificationDate = installment.dueDate.subtract(
      Duration(days: reminderDays),
    );

    // No programar si la fecha ya pasó
    if (notificationDate.isBefore(DateTime.now())) {
      return;
    }

    // Establecer hora de notificación a las 9:00 AM
    final scheduledDate = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      9, // 9 AM
      0,
    );

    const notificationDetails = const NotificationDetails(
      linux: LinuxNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      installment.id!, // ID único de la notificación
      'Recordatorio de Pago',
      'Tu cuota #${installment.number} vence en $reminderDays días (${_formatDate(installment.dueDate)}). Monto: \$${installment.total.toStringAsFixed(2)}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'installment_${installment.id}',
    );
  }

  /// Cancelar notificación de una cuota
  Future<void> cancelInstallmentNotification(int installmentId) async {
    if (!_initialized) await initialize();
    await _notifications.cancel(installmentId);
  }

  /// Cancelar todas las notificaciones de un crédito
  Future<void> cancelCreditNotifications(Credit credit) async {
    if (!_initialized) await initialize();
    
    for (final installment in credit.installments) {
      if (installment.id != null) {
        await _notifications.cancel(installment.id!);
      }
    }
  }

  /// Reprogramar todas las notificaciones
  Future<void> rescheduleAllNotifications(
    List<Credit> credits,
    int reminderDays,
  ) async {
    if (!_initialized) await initialize();

    // Cancelar todas primero
    await _notifications.cancelAll();

    // Programar solo las no pagadas
    for (final credit in credits) {
      for (final installment in credit.installments) {
        if (!installment.paid && installment.id != null) {
          await scheduleInstallmentReminder(installment, reminderDays);
        }
      }
    }
  }

  /// Formatear fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Verificar si los permisos están otorgados
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await initialize();
    
    // En Linux, las notificaciones generalmente están siempre habilitadas
    // En Android/iOS, aquí verificarías permisos
    return true;
  }

  /// Solicitar permisos (principalmente para Android/iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();
    
    // En Linux no se requiere solicitar permisos explícitamente
    return true;
  }
}
