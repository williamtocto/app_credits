import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/credit_service.dart';

class CreateCreditPage extends StatefulWidget {
  final CreditService service;
  const CreateCreditPage({super.key, required this.service});

  @override
  State<CreateCreditPage> createState() => _CreateCreditPageState();
}

class _CreateCreditPageState extends State<CreateCreditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _termCtrl = TextEditingController();
  final TextEditingController _interestCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(_startDate);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(_startDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Crédito")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Nombre del Socio"),
                validator: (v) => v!.isEmpty ? "Ingrese un nombre" : null,
              ),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Monto solicitado"),
                validator: (v) => v!.isEmpty ? "Ingrese un monto" : null,
              ),
              TextFormField(
                controller: _termCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Plazo (meses)"),
                validator: (v) => v!.isEmpty ? "Ingrese el plazo" : null,
              ),
              TextFormField(
                controller: _interestCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Interés mensual (%)"),
                validator: (v) => v!.isEmpty ? "Ingrese el interés" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Fecha de solicitud",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectDate,
                validator: (v) => v!.isEmpty ? "Seleccione una fecha" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newCredit = await widget.service.createCredit(
                      name: _nameCtrl.text,
                      amount: double.parse(_amountCtrl.text),
                      termMonths: int.parse(_termCtrl.text),
                      monthlyInterest: double.parse(_interestCtrl.text),
                      startDate: _startDate,
                    );
                    
                    // Navigate back and then to detail page
                    if (context.mounted) {
                      Navigator.pop(context, newCredit);
                    }
                  }
                },
                child: const Text("Guardar y Generar Tabla"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
