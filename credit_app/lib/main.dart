import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const BaseApp());
}

class BaseApp extends StatelessWidget {
  const BaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Créditos',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
