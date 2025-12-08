import 'package:flutter/material.dart';

/// Modelo que define un esquema de colores para la aplicación
class AppColors {
  final String name;
  final Color primary;
  final String id;

  const AppColors({
    required this.name,
    required this.primary,
    required this.id,
  });

  /// Esquemas de color predefinidos
  static const AppColors classicGreen = AppColors(
    name: 'Verde Clásico',
    primary: Color(0xFF4CAF50),
    id: 'classic_green',
  );

  static const AppColors oceanBlue = AppColors(
    name: 'Azul Océano',
    primary: Color(0xFF2196F3),
    id: 'ocean_blue',
  );

  static const AppColors royalPurple = AppColors(
    name: 'Púrpura Real',
    primary: Color(0xFF9C27B0),
    id: 'royal_purple',
  );

  static const AppColors sunsetOrange = AppColors(
    name: 'Naranja Atardecer',
    primary: Color(0xFFFF9800),
    id: 'sunset_orange',
  );

  /// Lista de todos los esquemas disponibles
  static const List<AppColors> allSchemes = [
    classicGreen,
    oceanBlue,
    royalPurple,
    sunsetOrange,
  ];

  /// Obtener esquema por ID
  static AppColors getById(String id) {
    return allSchemes.firstWhere(
      (scheme) => scheme.id == id,
      orElse: () => classicGreen,
    );
  }

  /// Convertir a MaterialColor para usar en ThemeData
  MaterialColor toMaterialColor() {
    return MaterialColor(
      primary.value,
      <int, Color>{
        50: primary.withValues(alpha: 0.1),
        100: primary.withValues(alpha: 0.2),
        200: primary.withValues(alpha: 0.3),
        300: primary.withValues(alpha: 0.4),
        400: primary.withValues(alpha: 0.5),
        500: primary.withValues(alpha: 0.6),
        600: primary.withValues(alpha: 0.7),
        700: primary.withValues(alpha: 0.8),
        800: primary.withValues(alpha: 0.9),
        900: primary,
      },
    );
  }
}
