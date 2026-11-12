import 'package:flutter/material.dart';

/// ValueNotifier = una scatola che contiene un valore e avvisa chi la ascolta.
/// È il più piccolo "state manager" possibile: perfetto per capire il concetto
/// prima di incontrare Cubit/Bloc.
final ValueNotifier<ThemeMode> modalitaTema = ValueNotifier(ThemeMode.system);

/// Cicla chiaro -> scuro -> sistema.
void cambiaTema() {
  modalitaTema.value = switch (modalitaTema.value) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  };
}

IconData iconaTema(ThemeMode modo) => switch (modo) {
  ThemeMode.light => Icons.light_mode,
  ThemeMode.dark => Icons.dark_mode,
  ThemeMode.system => Icons.brightness_auto,
};

String etichettaTema(ThemeMode modo) => switch (modo) {
  ThemeMode.light => 'Tema chiaro',
  ThemeMode.dark => 'Tema scuro',
  ThemeMode.system => 'Tema del sistema',
};
