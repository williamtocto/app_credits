import 'package:flutter/material.dart';
import '../../models/app_colors.dart';

class AppTheme {
  /// Generar tema basado en los colores seleccionados
  static ThemeData fromColors(AppColors colors) {
    return ThemeData(
      primarySwatch: colors.toMaterialColor(),
      primaryColor: colors.primary,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          colors.primary.withValues(alpha: 0.8),
        ),
        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        primary: colors.primary,
      ),
    );
  }
}