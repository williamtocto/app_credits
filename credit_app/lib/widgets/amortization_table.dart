// lib/widgets/amortization_table.dart
import 'package:flutter/material.dart';
import '../models/credit_model.dart';
import '../models/installment_model.dart';

/// Widget que muestra la tabla de amortización.
/// onPaidToggle recibe el [Installment] que se marcó/desmarcó.
/// Se acepta una función asíncrona: `Future<void> Function(Installment)`
/// Si es null, el checkbox estará deshabilitado (modo solo lectura)
class AmortizationTable extends StatelessWidget {
  final Credit credit;
  final Future<void> Function(Installment)? onPaidToggle;

  const AmortizationTable({
    super.key,
    required this.credit,
    this.onPaidToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay cuotas, mostramos un placeholder
    if (credit.installments.isEmpty) {
      return const Center(child: Text('No hay cuotas para este crédito.'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.only(bottom: 80), // Padding para evitar que se oculte detrás de la barra inferior
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 40,
            columns: const [
              DataColumn(label: Text('N°')),
              DataColumn(label: Text('Fecha de Pago')),
              DataColumn(label: Text('Saldo Capital')),
              DataColumn(label: Text('Capital')),
              DataColumn(label: Text('Interés')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Pagado')),
            ],
            rows: credit.installments.asMap().entries.map((entry) {
              final inst = entry.value;

              return DataRow(
                // Color de fondo suave para cuotas pagadas
                color: inst.paid
                    ? WidgetStateProperty.all(
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      )
                    : null,
                cells: [
                  DataCell(Text(inst.number.toString())),
                  DataCell(Text(inst.dueDateFormatted)),
                  DataCell(Text(inst.balance.toStringAsFixed(2))),
                  DataCell(Text(inst.capital.toStringAsFixed(2))),
                  DataCell(Text(inst.interest.toStringAsFixed(2))),
                  DataCell(Text(inst.total.toStringAsFixed(2))),
                  DataCell(
                    Checkbox(
                      value: inst.paid,
                      onChanged: onPaidToggle == null ? null : (bool? value) async {
                        await onPaidToggle!(inst);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
