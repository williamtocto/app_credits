import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/credit_service.dart';

class CreateCreditPage extends StatefulWidget {
  final bool simulationMode;
  
  const CreateCreditPage({super.key, this.simulationMode = false});

  @override
  State<CreateCreditPage> createState() => _CreateCreditPageState();
}

class _CreateCreditPageState extends State<CreateCreditPage> {
  final _formKey = GlobalKey<FormState>();
  final CreditService _service = CreditService();

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _termController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (widget.simulationMode) {
          // Modo simulación: solo calcular sin guardar
          final simulatedCredit = await _service.simulateCredit(
            name: _nameController.text.trim(),
            amount: double.parse(_amountController.text),
            termMonths: int.parse(_termController.text),
            monthlyInterest: double.parse(_interestController.text),
            startDate: _selectedDate,
          );

          if (mounted) {
            Navigator.pop(context, simulatedCredit);
          }
        } else {
          // Modo normal: guardar el crédito
          final createdCredit = await _service.createCredit(
            name: _nameController.text.trim(),
            amount: double.parse(_amountController.text),
            termMonths: int.parse(_termController.text),
            monthlyInterest: double.parse(_interestController.text),
            startDate: _selectedDate,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crédito creado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, createdCredit);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al ${widget.simulationMode ? "simular" : "crear"} crédito: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.simulationMode ? 'Calculadora de Crédito' : 'Nuevo Crédito'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de información del crédito
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: primaryColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Información del Crédito',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Descripción del Crédito
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Descripción del Crédito',
                            hintText: 'Ej: Crédito Personal Diciembre 2024',
                            prefixIcon: Icon(Icons.title, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa una descripción';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Monto solicitado
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Monto Solicitado',
                            hintText: '0.00',
                            prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el monto';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Ingresa un monto válido mayor a 0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Card de condiciones del crédito
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings, color: primaryColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Condiciones del Crédito',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Plazo
                        TextFormField(
                          controller: _termController,
                          decoration: InputDecoration(
                            labelText: 'Plazo (meses)',
                            hintText: 'Ej: 12',
                            prefixIcon: Icon(Icons.calendar_month, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el plazo';
                            }
                            final term = int.tryParse(value);
                            if (term == null || term <= 0) {
                              return 'Ingresa un plazo válido mayor a 0';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Interés mensual
                        TextFormField(
                          controller: _interestController,
                          decoration: InputDecoration(
                            labelText: 'Interés Mensual (%)',
                            hintText: 'Ej: 2.5',
                            prefixIcon: Icon(Icons.percent, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el interés';
                            }
                            final interest = double.tryParse(value);
                            if (interest == null || interest < 0) {
                              return 'Ingresa un interés válido';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Fecha de solicitud
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de Solicitud',
                              prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botón de crear
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.simulationMode ? Icons.calculate : Icons.save, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        widget.simulationMode ? 'Calcular y Ver Tabla' : 'Guardar y Generar Tabla',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
