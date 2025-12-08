import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService.instance;
  PaymentDateMode? _currentMode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await _settingsService.getPaymentDateMode();
    setState(() {
      _currentMode = mode;
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
              ],
            ),
    );
  }
}
