import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../models/installment_model.dart';
import '../services/credit_service.dart';
import '../widgets/amortization_table.dart';
import '../widgets/credit_detail_header.dart';

class CreditDetailPage extends StatefulWidget {
  final Credit credit;
  final CreditService service;

  const CreditDetailPage({
    super.key,
    required this.credit,
    required this.service,
  });

  @override
  State<CreditDetailPage> createState() => _CreditDetailPageState();
}

class _CreditDetailPageState extends State<CreditDetailPage> {
  late Credit _currentCredit;

  @override
  void initState() {
    super.initState();
    _currentCredit = widget.credit;
  }

  /// Recargar el crédito desde la base de datos para actualizar los valores
  Future<void> _reloadCredit() async {
    final updatedCredit = await widget.service.getCreditById(_currentCredit.id!);
    if (updatedCredit != null) {
      setState(() {
        _currentCredit = updatedCredit;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentCredit.name)),
      body: Column(
        children: [
          // Encabezado con resumen del crédito en la parte superior
          CreditDetailHeader(
            credit: _currentCredit,
          ),
          
          // Tabla de amortización debajo
          Expanded(
            child: AmortizationTable(
              credit: _currentCredit,
              onPaidToggle: (Installment installment) async {
                // Si ya está pagada, desmarcar sin confirmación
                if (installment.paid) {
                  await widget.service.unmarkInstallmentPaid(installment.id!);
                  await _reloadCredit(); // Recargar para actualizar el resumen
                  return;
                }

                // Si no está pagada, validar orden secuencial
                // Verificar que todas las cuotas anteriores estén pagadas
                bool allPreviousPaid = true;
                for (var inst in _currentCredit.installments) {
                  if (inst.number < installment.number && !inst.paid) {
                    allPreviousPaid = false;
                    break;
                  }
                }

                // Si hay cuotas anteriores sin pagar, mostrar advertencia
                if (!allPreviousPaid && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Orden de pago'),
                        content: const Text(
                            'Debe pagar las cuotas anteriores antes de pagar esta cuota.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Entendido'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                // Mostrar diálogo de confirmación
                if (context.mounted) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar pago'),
                        content: Text(
                            '¿Está seguro de marcar la cuota ${installment.number} como pagada?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
                    },
                  );

                  // Si confirmó, marcar como pagada
                  if (confirm == true) {
                    await widget.service.markInstallmentPaid(installment.id!);
                    await _reloadCredit(); // Recargar para actualizar el resumen
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
