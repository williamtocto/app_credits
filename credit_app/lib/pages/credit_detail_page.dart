import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../models/installment_model.dart';
import '../services/credit_service.dart';
import '../widgets/amortization_table.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.credit.name)),
      body: AmortizationTable(
        credit: widget.credit,
        onPaidToggle: (Installment installment) async {
          // Si ya está pagada, desmarcar sin confirmación
          if (installment.paid) {
            await widget.service.unmarkInstallmentPaid(installment.id!);
            setState(() {
              installment.paid = false;
            });
            return;
          }

          // Si no está pagada, validar orden secuencial
          // Verificar que todas las cuotas anteriores estén pagadas
          bool allPreviousPaid = true;
          for (var inst in widget.credit.installments) {
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
              setState(() {
                installment.paid = true;
              });
            }
          }
        },
      ),
    );
  }
}
