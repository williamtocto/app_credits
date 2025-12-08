import 'package:flutter/material.dart';
import '../models/credit_model.dart';

/// Widget de encabezado para la vista de detalle del crédito
/// Muestra el resumen del crédito sin formato de tarjeta, ocupando toda la pantalla
class CreditDetailHeader extends StatelessWidget {
  final Credit credit;

  const CreditDetailHeader({
    super.key,
    required this.credit,
  });

  @override
  Widget build(BuildContext context) {
    final remainingInstallments = credit.getRemainingInstallments();
    final totalInstallments = credit.termMonths;
    final remainingCapital = credit.getRemainingCapital();
    final totalOwed = credit.getTotalOwed();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header verde con el título
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Sin ahorro individual',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Contenido del resumen
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Número de crédito
                Text(
                  'N° de Crédito: ${credit.id ?? 0}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Cuotas pendientes
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: 'Tienes '),
                      TextSpan(
                        text: '$remainingInstallments',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const TextSpan(text: ' cuotas de '),
                      TextSpan(
                        text: '$totalInstallments',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const TextSpan(text: ' pendientes'),
                    ],
                  ),
                ),
                
                const Divider(height: 24, thickness: 1),
                
                // Detalles en formato tabla
                _buildDetailRow('Tasa', '${credit.monthlyInterest.toStringAsFixed(2)}%'),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Monto Solicitado',
                  '\$${credit.amount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Capital por pagar',
                  '\$${remainingCapital.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Total Adeudado',
                  '\$${totalOwed.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
