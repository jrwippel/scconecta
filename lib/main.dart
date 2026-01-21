import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ADICIONADO para controlar as cores do sistema
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Configura o enquadramento das barras do sistema (Status Bar e Navigation Bar)
  // Isso ajuda muito no S21 para o conteúdo não "vazar" para baixo das barras.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Deixa a barra de cima transparente
    statusBarIconBrightness: Brightness.dark, // Ícones pretos (já que o fundo é claro)
    systemNavigationBarColor: Colors.white, // Cor da barra de baixo (onde ficam os botões/gestos)
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // 3. Força o app a ficar apenas em pé (opcional, evita quebras de layout ao girar)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initializeDateFormatting('pt_BR', null);

  runApp(const SCConectaApp());
}

const Color verdePrincipal = Color(0xFF8DBB1B);

class SCConectaApp extends StatelessWidget {
  const SCConectaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SC Conecta',
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
        colorScheme: ColorScheme.fromSeed(seedColor: verdePrincipal),
        useMaterial3: true,
      ),
      
      // DICA: Se a LoginScreen ainda estiver estranha, abra o arquivo login_screen.dart
      // e envolva o conteúdo do Scaffold com um widget SafeArea.
      home: const LoginScreen(),
    );
  }
}