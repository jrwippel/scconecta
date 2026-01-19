import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart'; // Importando a tela de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const SCConectaApp());
}

// Cores que todas as telas vão usar
const Color verdePrincipal = Color(0xFF8DBB1B);
const Color verdeFundo = Color(0xFFF9FBF2);
const Color cinzaBorda = Color(0xFFD1D1D1);
const Color pretoBotao = Color(0xFF1A1A1A);

class SCConectaApp extends StatelessWidget {
  const SCConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}