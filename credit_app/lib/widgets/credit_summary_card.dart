import 'package:flutter/material.dart';
import '../models/credit_model.dart';

class CreditSummaryCard extends StatefulWidget {
  final Credit credit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CreditSummaryCard({
    super.key,
    required this.credit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<CreditSummaryCard> createState() => _CreditSummaryCardState();
}

class _CreditSummaryCardState extends State<CreditSummaryCard> {
  bool _isVisible = false;

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingInstallments = widget.credit.getRemainingInstallments();
    final totalInstallments = widget.credit.termMonths;
    final remainingCapital = widget.credit.getRemainingCapital();
    final totalOwed = widget.credit.getTotalOwed();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header verde con el título y el ícono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.credit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _toggleVisibility,
                        tooltip: _isVisible ? 'Ocultar valores' : 'Mostrar valores',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: widget.onDelete,
                        tooltip: 'Eliminar crédito',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Contenido del card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Número de crédito
                  Text(
                    'N° de Crédito: ${widget.credit.id ?? 0}',
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
                  _buildDetailRow('Tasa', '${widget.credit.monthlyInterest.toStringAsFixed(2)}%'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Monto Solicitado',
                    _isVisible ? '\$${widget.credit.amount.toStringAsFixed(2)}' : '\$****',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Capital por pagar',
                    _isVisible ? '\$${remainingCapital.toStringAsFixed(2)}' : '\$****',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Total Adeudado',
                    _isVisible ? '\$${totalOwed.toStringAsFixed(2)}' : '\$****',
                  ),
                  const SizedBox(height: 16),
                  
                  // Link "Ver todos mis créditos"
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: widget.onTap,
                  //     child: const Text(
                  //       'Ver todos mis créditos',
                  //       style: TextStyle(
                  //         color: Color(0xFF4CAF50),
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
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
