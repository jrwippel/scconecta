import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; // Importação do Firebase
import 'firebase_options.dart'; // Importação das opções geradas
import 'screens/login_screen.dart'; 

void main() async {
  // 1. Garante que o Flutter esteja pronto para plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase antes de qualquer outra coisa
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Inicializa a formatação de datas (necessário para o seu calendário)
  await initializeDateFormatting('pt_BR', null);

  runApp(const SCConectaApp());
}

// Cores globais do projeto
const Color verdePrincipal = Color(0xFF8DBB1B);
const Color verdeFundo = Color(0xFFF9FBF2);
const Color cinzaBorda = Color(0xFFD1D1D1);
const Color pretoBotao = Color(0xFF1A1A1A);

class SCConectaApp extends StatelessWidget {
  const SCConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SC Conecta',
      debugShowCheckedModeBanner: false,
      
      // Configuração de Idioma (Português Brasil)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      
      theme: ThemeData(
        // Aplica o Montserrat em todo o app
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        // Define a cor principal para componentes do sistema
        colorScheme: ColorScheme.fromSeed(seedColor: verdePrincipal),
        useMaterial3: true,
      ),
      
      // Define a LoginScreen como a tela inicial
      home: const LoginScreen(),
    );
  }
}