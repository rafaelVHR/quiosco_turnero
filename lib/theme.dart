import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tema {
  static const morado = Color(0xFF4A0B87);
  static const moradoOscuro = Color(0xFF22064F);
  static const amarillo = Color(0xFFFBEE41);
  static const fondo = Color(0xFFF1EEF8);
  static const lila = Color(0xFFEDE3F7);
  static const texto = Color(0xFF22064F);
  static const textoSuave = Color(0xFF5B4B77);

  static ThemeData get tema => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: morado,
          primary: morado,
          secondary: amarillo,
        ),
        scaffoldBackgroundColor: fondo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      );
}