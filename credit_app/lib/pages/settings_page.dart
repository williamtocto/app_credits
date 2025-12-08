import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'theme_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService.instance;
  PaymentDateMode? _currentMode;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  int _reminderDays = 3;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await _settingsService.getPaymentDateMode();
    final notifEnabled = await _settingsService.getNotificationsEnabled();
    final days = await _settingsService.getReminderDays();
    setState(() {
      _currentMode = mode;
      _notificationsEnabled = notifEnabled;
      _reminderDays = days;
      _isLoading = false;
    });
  }

  Future<void> _saveMode(PaymentDateMode mode) async {
    await _settingsService.setPaymentDateMode(mode);
    setState(() {
      _currentMode = mode;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración guardada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Sección de Cálculo de Fecha de Pago (ahora al inicio)
                const Text(
                  'Cálculo de Fecha de Pago',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona cómo se calculan las fechas de vencimiento de las cuotas:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                
                // Opción: Día específico
                Card(
                  child: RadioListTile<PaymentDateMode>(
                    title: const Text('Día específico del mes'),
                    subtitle: const Text(
                      'Las cuotas vencen el mismo día del mes en que se registró el crédito.\n'
                      'Ejemplo: Si el crédito se registra el 12 de enero, las cuotas vencen el 12 de cada mes.',
                    ),
                    value: PaymentDateMode.specificDay,
                    groupValue: _currentMode,
                    onChanged: (value) {
                      if (value != null) _saveMode(value);
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Opción: Segundo sábado
                Card(
                  child: RadioListTile<PaymentDateMode>(
                    title: const Text('Segundo sábado del mes'),
                    subtitle: const Text(
                      'Las cuotas vencen el segundo sábado de cada mes, independientemente de la fecha de registro.',
                    ),
                    value: PaymentDateMode.secondSaturday,
                    groupValue: _currentMode,
                    onChanged: (value) {
                      if (value != null) _saveMode(value);
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                const Text(
                  'Nota:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Esta configuración solo afecta a los créditos que se creen en el futuro. '
                  'Los créditos existentes mantienen sus fechas originales.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Sección de Notificaciones
                const Text(
                  'Notificaciones de Pago',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Recibe recordatorios antes de que venzan tus cuotas.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: SwitchListTile(
                    title: const Text('Habilitar notificaciones'),
                    subtitle: const Text('Recibir recordatorios de pago'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) async {
                      await _settingsService.setNotificationsEnabled(value);
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Notificaciones habilitadas'
                                  : 'Notificaciones deshabilitadas',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Card(
                  child: ListTile(
                    title: const Text('Días de anticipación'),
                    subtitle: Text('Recordar $_reminderDays días antes del vencimiento'),
                    trailing: DropdownButton<int>(
                      value: _reminderDays,
                      items: List.generate(7, (index) => index + 1)
                          .map((days) => DropdownMenuItem(
                                value: days,
                                child: Text('$days día${days > 1 ? 's' : ''}'),
                              ))
                          .toList(),
                      onChanged: _notificationsEnabled
                          ? (int? value) async {
                              if (value != null) {
                                await _settingsService.setReminderDays(value);
                                setState(() {
                                  _reminderDays = value;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Recordatorios configurados para $value día${value > 1 ? 's' : ''} antes',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            }
                          : null, // Deshabilitar si las notificaciones están desactivadas
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // Sección de Temas (ahora al final)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Configuración de Tema'),
                    subtitle: const Text('Personaliza los colores de la aplicación'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
