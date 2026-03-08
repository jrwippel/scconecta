import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; 
import 'screens/landing_screen.dart';
import 'screens/esim_setup_tutorial_screen.dart';
import 'screens/mvp_demo_purchase_screen.dart';
import 'screens/mvp_activation_screen.dart';
import 'screens/esim_activation_screen.dart';
import 'screens/esim_setup_wizard_screen.dart';
import 'screens/esim_install_screen.dart';
import 'screens/my_esims_screen.dart';
import 'screens/web_redirect_screen.dart';
import 'services/language_service.dart';
import 'services/deep_link_service.dart';
import 'services/esim_detector_service.dart';
import 'l10n/app_localizations.dart';

// --- CHAVE GLOBAL PARA NAVEGAÇÃO (ESSENCIAL) ---
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('pt_BR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('es_ES', null);

  // Inicializa o serviço de deep links
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: SCConectaApp(deepLinkService: deepLinkService),
    ),
  );
}

class SCConectaApp extends StatefulWidget {
  final DeepLinkService deepLinkService;
  
  const SCConectaApp({super.key, required this.deepLinkService});

  @override
  State<SCConectaApp> createState() => _SCConectaAppState();
}

class _SCConectaAppState extends State<SCConectaApp> {
  @override
  void initState() {
    super.initState();
    
    // Configura o callback de deep links
    widget.deepLinkService.onLinkReceived = (uri) {
      _handleDeepLink(uri);
    };
    
    // Monitora instalação de novos eSIMs
    _monitorESimInstallation();
  }

  void _handleDeepLink(Uri uri) {
    print('Processando deep link: $uri');
    
    // Link de instalação com LPA (NOVO - Fase 1)
    if (widget.deepLinkService.isLPAInstallLink(uri)) {
      final lpa = widget.deepLinkService.getLPAFromLink(uri);
      
      if (lpa != null && widget.deepLinkService.isValidLPA(lpa)) {
        print('✅ LPA válida recebida: $lpa');
        
        // Navega para a tela de instalação
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => ESimInstallScreen(lpaString: lpa),
            ),
          );
        });
        return;
      } else {
        print('❌ LPA inválida: $lpa');
      }
    }
    
    // Link de ativação de eSIM (NOVO - Fase 1)
    if (widget.deepLinkService.isESimActivationLink(uri)) {
      final code = widget.deepLinkService.getActivationCodeFromLink(uri);
      
      if (code != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => ESimActivationScreen(activationCode: code),
            ),
          );
        });
        return;
      }
    }
    
    // Link de instalação de eSIM (antigo)
    if (widget.deepLinkService.isESimInstallLink(uri)) {
      final iccid = widget.deepLinkService.getICCIDFromLink(uri);
      
      // Navega para a tela de tutorial
      Future.delayed(const Duration(milliseconds: 500), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ESimSetupTutorialScreen(iccid: iccid),
          ),
        );
      });
    }
  }

  void _monitorESimInstallation() {
    // Verifica periodicamente se há novo eSIM
    Future.delayed(const Duration(seconds: 2), () async {
      final result = await ESimDetectorService.checkForNewESim();
      
      if (result != null && result['hasNewESim'] == true) {
        final iccid = result['iccid'] as String?;
        final carrierName = result['carrierName'] as String?;
        
        // Verifica se é eSIM SCCONECTA
        if (iccid != null && ESimDetectorService.isSCConectaESim(iccid)) {
          // Verifica se já mostrou o tutorial
          final alreadyShown = await ESimDetectorService.wasTutorialShown(iccid);
          
          if (!alreadyShown) {
            // Mostra o tutorial
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => ESimSetupTutorialScreen(
                  iccid: iccid,
                  carrierName: carrierName,
                ),
              ),
            );
            
            // Marca como mostrado
            await ESimDetectorService.markTutorialShown(iccid);
          }
        }
      }
      
      // Continua monitorando
      _monitorESimInstallation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'SC Conecta',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
            Locale('es', 'ES'),
          ],
          locale: languageService.currentLocale,
          theme: ThemeData(
            textTheme: GoogleFonts.montserratTextTheme(),
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8DBB1B)),
            useMaterial3: true,
          ),
          home: const MyESimsScreen(), // MVP: Tela inicial sem login
          routes: {
            '/login': (context) => const LoginScreen(),
            '/landing': (context) => const LandingPageScreen(),
            '/mvp-demo': (context) => const MVPDemoPurchaseScreen(),
          },
          onGenerateRoute: (settings) {
            // Rota de ativação MVP (antiga)
            if (settings.name == '/activate') {
              final code = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => MVPActivationScreen(activationCode: code),
              );
            }
            
            // Rota de ativação real (NOVA - Fase 1)
            if (settings.name == '/esim-activation') {
              final code = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ESimActivationScreen(activationCode: code),
              );
            }
            
            // Rota de wizard (NOVA - Fase 1)
            if (settings.name == '/esim-wizard') {
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (context) => ESimSetupWizardScreen(
                  activationCode: args['activationCode']!,
                  planName: args['planName']!,
                ),
              );
            }
            
            // Rota de redirecionamento web (NOVA - Simula página web)
            if (settings.name == '/web-redirect') {
              final code = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => WebRedirectScreen(activationCode: code),
              );
            }
            
            return null;
          },
        );
      },
    );
  }
}