import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../services/settings_service.dart';

/// Provider para gestionar el tema de la aplicación
class ThemeProvider extends ChangeNotifier {
  AppColors _currentColors = AppColors.classicGreen;
  final SettingsService _settingsService = SettingsService.instance;
  bool _isInitialized = false;

  AppColors get currentColors => _currentColors;
  bool get isInitialized => _isInitialized;

  /// Inicializar el tema desde las preferencias guardadas
  Future<void> initialize() async {
    _currentColors = await _settingsService.getTheme();
    _isInitialized = true;
    notifyListeners();
  }

  /// Cambiar el tema y guardar la preferencia
  Future<void> setTheme(AppColors colors) async {
    _currentColors = colors;
    await _settingsService.setTheme(colors);
    notifyListeners();
  }
}
