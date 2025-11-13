import 'package:flutter/material.dart';
import '../models/credit_model.dart';

class AmortizationTable extends StatelessWidget {
  final Credit credit;
  final Function(int) onPaidToggle;

  const AmortizationTable({
    super.key,
    required this.credit,
    required this.onPaidToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('N°')),
          DataColumn(label: Text('Mes de Pago')),
          DataColumn(label: Text('Saldo Capital')),
          DataColumn(label: Text('Cuota Fija')),
          DataColumn(label: Text('Interés')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Pagado')),
        ],
        rows: credit.installments
            .asMap()
            .entries
            .map(
              (entry) => DataRow(
                cells: [
                  DataCell(Text("${entry.value.number}")),
                  DataCell(Text(entry.value.monthLabel)),
                  DataCell(Text(entry.value.balance.toStringAsFixed(2))),
                  DataCell(Text(entry.value.capital.toStringAsFixed(2))),
                  DataCell(Text(entry.value.interest.toStringAsFixed(2))),
                  DataCell(Text(entry.value.total.toStringAsFixed(2))),
                  DataCell(Checkbox(
                    value: entry.value.paid,
                    onChanged: (_) => onPaidToggle(entry.key),
                  )),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
