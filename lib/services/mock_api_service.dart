import 'dart:async';

/// Serviço de API mockado para demonstração
/// Simula as respostas da API real sem precisar de backend
class MockApiService {
  // Simula delay de rede
  static const _networkDelay = Duration(seconds: 1);

  /// Simula compra de eSIM
  static Future<Map<String, dynamic>> purchaseESim({
    required String planId,
    required String userEmail,
  }) async {
    await Future.delayed(_networkDelay);

    // Gera código fake baseado no timestamp
    final code = 'DEMO${DateTime.now().millisecondsSinceEpoch % 10000}';

    return {
      'success': true,
      'data': {
        'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'activation_code': code,
        'activation_link': 'https://scconecta.com/activate/$code',
        'status': 'pending_activation',
      },
      'message': 'eSIM será enviado por WhatsApp em até 5 minutos'
    };
  }

  /// Simula busca de detalhes do eSIM
  static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
    await Future.delayed(_networkDelay);

    // Dados mockados
    return {
      'success': true,
      'data': {
        'activation_code': activationCode,
        'lpa_string': 'LPA:1\$test.scconecta.com\$TEST-$activationCode',
        'iccid': '8901234567890123456',
        'plan': {
          'id': 'america',
          'name': 'Plano América',
          'countries': ['USA', 'Canada', 'Mexico', 'Brasil'],
          'data': 'Ilimitado',
          'voice': 'Ilimitado',
        },
        'validity': {
          'start_date': DateTime.now().toIso8601String(),
          'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'days_remaining': 30,
        },
        'status': 'pending_activation',
        'user': {
          'email': 'demo@scconecta.com',
          'name': 'Usuário Demo',
        },
      }
    };
  }

  /// Simula confirmação de ativação
  static Future<Map<String, dynamic>> confirmActivation(String activationCode) async {
    await Future.delayed(_networkDelay);

    return {
      'success': true,
      'data': {
        'activation_code': activationCode,
        'status': 'active',
        'activated_at': DateTime.now().toIso8601String(),
      },
      'message': 'eSIM ativado com sucesso!'
    };
  }

  /// Simula instalação de eSIM (apenas delay)
  static Future<bool> simulateESimInstallation() async {
    // Simula processo de instalação (3 segundos)
    await Future.delayed(const Duration(seconds: 3));
    return true; // Sempre sucesso no mock
  }
}
