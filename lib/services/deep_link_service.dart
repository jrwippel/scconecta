import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Callback quando receber um deep link
  Function(Uri)? onLinkReceived;

  // Inicializa o serviço de deep links
  Future<void> initialize() async {
    // Verifica se o app foi aberto por um deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Erro ao obter link inicial: $e');
    }

    // Escuta novos deep links enquanto o app está aberto
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Erro no deep link: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    print('Deep link recebido: $uri');
    
    // Notifica o callback se existir
    if (onLinkReceived != null) {
      onLinkReceived!(uri);
    }
  }

  // Extrai parâmetros do deep link
  Map<String, String> extractParams(Uri uri) {
    return uri.queryParameters;
  }

  // Verifica se é um link de instalação de eSIM
  bool isESimInstallLink(Uri uri) {
    return uri.path.contains('/esim/install') || 
           uri.path.contains('/esim');
  }

  // Obtém o ICCID do link
  String? getICCIDFromLink(Uri uri) {
    return uri.queryParameters['iccid'];
  }

  // Verifica se é um link de ativação de eSIM
  bool isESimActivationLink(Uri uri) {
    return uri.path.contains('/esim/activate') || 
           uri.path.contains('/activate');
  }

  // Extrai código de ativação do link
  String? getActivationCodeFromLink(Uri uri) {
    // Tenta pegar do query parameter
    String? code = uri.queryParameters['code'];
    
    // Se não encontrou, tenta pegar do path
    if (code == null) {
      final pathSegments = uri.pathSegments;
      if (pathSegments.contains('activate') && pathSegments.length > pathSegments.indexOf('activate') + 1) {
        code = pathSegments[pathSegments.indexOf('activate') + 1];
      }
    }
    
    return code;
  }

  // Valida formato do link de ativação
  bool isValidActivationLink(Uri uri) {
    return isESimActivationLink(uri) && getActivationCodeFromLink(uri) != null;
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
