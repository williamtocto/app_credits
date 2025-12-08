import 'package:flutter/material.dart';
import '../services/credit_service.dart';
import '../models/credit_model.dart';
import '../widgets/credit_summary_card.dart';
import 'create_credit_page.dart';
import 'credit_detail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CreditService _service = CreditService();

  late Future<List<Credit>> _creditsFuture;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  void _loadCredits() {
    _creditsFuture = _service.getCredits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créditos Registrados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Credit>>(
        future: _creditsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay créditos registrados"));
          }

          final credits = snapshot.data!;

          return ListView.builder(
            itemCount: credits.length,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemBuilder: (context, index) {
              final credit = credits[index];
              return CreditSummaryCard(
                credit: credit,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreditDetailPage(credit: credit, service: _service),
                    ),
                  );

                  setState(() {
                    _loadCredits();
                  });
                },
                onDelete: () async {
                  // Mostrar diálogo de confirmación
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text(
                            '¿Está seguro de eliminar el crédito "${credit.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );

                  // Si el usuario confirmó, eliminar el crédito
                  if (confirm == true && context.mounted) {
                    await _service.deleteCredit(credit.id!);
                    setState(() {
                      _loadCredits();
                    });
                  }
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCredit = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateCreditPage(service: _service),
            ),
          );
          
          // If a credit was created, navigate to its detail page
          if (newCredit != null && context.mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreditDetailPage(credit: newCredit, service: _service),
              ),
            );
          }
          
          setState(() {
            _loadCredits();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
