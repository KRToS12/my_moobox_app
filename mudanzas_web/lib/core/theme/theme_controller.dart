import 'package:flutter/material.dart';

/// ValueNotifier global para el modo de tema.
/// Se inicializa en light. Cualquier widget puede leerlo o cambiarlo.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

extension ThemeModeToggle on ValueNotifier<ThemeMode> {
  bool get isLight => value == ThemeMode.light;

  void toggle() {
    value = isLight ? ThemeMode.dark : ThemeMode.light;
  }
}
