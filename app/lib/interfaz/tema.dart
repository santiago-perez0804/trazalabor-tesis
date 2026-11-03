import 'package:flutter/material.dart';

/// Paleta tomada de los bocetos de la Figura 5 de la tesis.
///
/// Criterios para el uso a campo (tesis, "Prototipos de interfaces"):
/// - áreas táctiles de al menos 48 × 48 dp;
/// - contraste de texto de al menos 4,5:1 para el uso a pleno sol.
/// Todos los pares texto/fondo de esta paleta superan 4,5:1.
abstract final class ColoresTrazaLabor {
  static const verdeCampo = Color(0xFF2D5F4F); // encabezados y acción principal
  static const verdeOscuro = Color(0xFF1F4437);
  static const fondo = Color(0xFFF4F5F2);
  static const superficie = Colors.white;
  static const texto = Color(0xFF1B1F1D);
  static const textoSecundario = Color(0xFF4A524E);
  static const sinConexion = Color(0xFFB3261E);
  static const enLinea = Color(0xFF256B3E);
  static const pendiente = Color(0xFF8A5A00);
}

ThemeData construirTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: ColoresTrazaLabor.verdeCampo,
    primary: ColoresTrazaLabor.verdeCampo,
    surface: ColoresTrazaLabor.superficie,
    error: ColoresTrazaLabor.sinConexion,
  );

  const alturaMinima = Size(48, 56);

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: ColoresTrazaLabor.fondo,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresTrazaLabor.verdeCampo,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 17, color: ColoresTrazaLabor.texto),
      bodyMedium: TextStyle(fontSize: 15, color: ColoresTrazaLabor.texto),
      labelLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: alturaMinima,
        backgroundColor: ColoresTrazaLabor.verdeCampo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: alturaMinima,
        foregroundColor: ColoresTrazaLabor.verdeCampo,
        side: const BorderSide(color: ColoresTrazaLabor.verdeCampo, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: ColoresTrazaLabor.superficie,
    ),
    cardTheme: const CardThemeData(
      color: ColoresTrazaLabor.superficie,
      margin: EdgeInsets.symmetric(vertical: 6),
    ),
  );
}
