import 'package:flutter/material.dart';
import '../models/credit_model.dart';
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
        onPaidToggle: (index) {
          setState(() {
            widget.service.markInstallmentPaid(widget.credit, index + 1);
          });
        },
      ),
    );
  }
}
