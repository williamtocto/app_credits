import 'package:flutter/material.dart';
import '../services/credit_service.dart';
import '../models/credit_model.dart';
import 'create_credit_page.dart';
import 'credit_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CreditService _service = CreditService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créditos Registrados")),
      body: _service.credits.isEmpty
          ? const Center(child: Text("No hay créditos registrados"))
          : ListView.builder(
              itemCount: _service.credits.length,
              itemBuilder: (context, index) {
                Credit credit = _service.credits[index];
                return ListTile(
                  title: Text(credit.name),
                  subtitle: Text(
                      "Monto: ${credit.amount.toStringAsFixed(2)} - Plazo: ${credit.termMonths} meses"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreditDetailPage(
                          credit: credit,
                          service: _service,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateCreditPage(service: _service),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
