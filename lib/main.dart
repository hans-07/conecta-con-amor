import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ConectaConAmorApp());
}

class ConectaConAmorApp extends StatelessWidget {
  const ConectaConAmorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Conecta con Amor',
        theme: ThemeData(
          // Tema optimizado para adultos mayores
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            // Texto más grande para mejor legibilidad
            bodyLarge: TextStyle(fontSize: 20),
            bodyMedium: TextStyle(fontSize: 18),
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              // Botones más grandes y con mejor contraste
              minimumSize: const Size(120, 80),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


