import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      dataTableTheme: const DataTableThemeData(
        headingRowColor: MaterialStatePropertyAll(Colors.indigoAccent),
        headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}