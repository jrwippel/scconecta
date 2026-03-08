// ============================================================================
// EXEMPLO: Como usar LPA String real extraída do QR Code
// ============================================================================

// PASSO 1: Extrair LPA do QR Code
// Use: https://webqr.com/ ou Google Lens
// Você vai obter algo como:
// LPA:1$smdp.operadora.com$ABC123XYZ456-FULL-ACTIVATION-CODE

// PASSO 2: Copiar a LPA String completa
const LPA_REAL_DO_QRCODE = 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE';

// ============================================================================
// OPÇÃO A: Substituir diretamente no mock (Mais simples)
// ============================================================================

// Arquivo: lib/services/mock_api_service.dart
// Linha: ~40

static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
  await Future.delayed(_networkDelay);

  return {
    'success': true,
    'data': {
      'activation_code': activationCode,
      
      // ANTES (simulação):
      // 'lpa_string': 'LPA:1\$test.scconecta.com\$TEST-$activationCode',
      
      // DEPOIS (LPA real do QR Code):
      'lpa_string': 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE',
      
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

// ============================================================================
// OPÇÃO B: Usar código específico (Mais flexível)
// ============================================================================

// Arquivo: lib/services/mock_api_service.dart

static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
  await Future.delayed(_networkDelay);

  // Detecta se é código para LPA real
  String lpaString;
  
  if (activationCode == 'REAL123' || activationCode.startsWith('REAL-')) {
    // LPA REAL do QR Code
    lpaString = 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE';
    print('🔴 USANDO LPA REAL - Vai instalar de verdade!');
  } else {
    // LPA de teste (simulação)
    lpaString = 'LPA:1\$test.scconecta.com\$TEST-$activationCode';
    print('🟢 USANDO LPA TESTE - Apenas simulação');
  }

  return {
    'success': true,
    'data': {
      'activation_code': activationCode,
      'lpa_string': lpaString,
      // ... resto igual
    }
  };
}

// ============================================================================
// OPÇÃO C: Criar constante global (Mais organizado)
// ============================================================================

// Arquivo: lib/config/esim_config.dart (criar novo arquivo)

class ESimConfig {
  // LPA Strings disponíveis
  static const LPA_TESTE = 'LPA:1\$test.scconecta.com\$TEST-DEMO';
  static const LPA_REAL = 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE';
  
  // Modo de operação
  static const bool USE_REAL_LPA = false; // Mude para true quando quiser testar de verdade
  
  // Retorna LPA apropriada
  static String getLpaString(String activationCode) {
    if (USE_REAL_LPA) {
      return LPA_REAL;
    } else {
      return 'LPA:1\$test.scconecta.com\$TEST-$activationCode';
    }
  }
}

// Usar no mock_api_service.dart:
import '../config/esim_config.dart';

static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
  await Future.delayed(_networkDelay);

  return {
    'success': true,
    'data': {
      'activation_code': activationCode,
      'lpa_string': ESimConfig.getLpaString(activationCode), // ← Usa config
      // ... resto igual
    }
  };
}

// ============================================================================
// COMO TESTAR
// ============================================================================

// 1. Extrair LPA do QR Code (use https://webqr.com/)
// 2. Copiar a string completa
// 3. Colar em uma das opções acima
// 4. Conectar dispositivo com eSIM
// 5. Executar: flutter run --release
// 6. Clicar em "Simular Link do WhatsApp"
// 7. Clicar em "Instalar eSIM Agora"
// 8. Dialog nativo do sistema vai aparecer
// 9. Confirmar instalação
// 10. Aguardar 30-60 segundos
// 11. eSIM instalado! ✅

// ============================================================================
// IMPORTANTE: Detecção Automática
// ============================================================================

// O sistema detecta automaticamente se é LPA real ou teste:

// LPA de TESTE (simulação):
// - Contém: test.scconecta.com
// - Contém: TEST, DEMO, FAKE
// Resultado: Simulação de 3 segundos, não instala de verdade

// LPA REAL (instalação):
// - Qualquer outra LPA válida
// Resultado: Chama código nativo, instala de verdade

// Exemplos:
// 'LPA:1$test.scconecta.com$TEST-ABC'     → SIMULAÇÃO ✅
// 'LPA:1$smdp.operadora.com$ABC123'       → REAL ⚠️
// 'LPA:1$prod.esim.com$XYZ456'            → REAL ⚠️
// 'LPA:1$qualquer.com$TEST-123'           → SIMULAÇÃO ✅
// 'LPA:1$qualquer.com$DEMO-456'           → SIMULAÇÃO ✅

// ============================================================================
// LOGS ESPERADOS
// ============================================================================

// Se for LPA de teste:
// 🧪 MODO TESTE: Simulando instalação de eSIM
// 📱 LPA String: LPA:1$test.scconecta.com$TEST-ABC123
// ✅ Instalação simulada com sucesso!
// 📋 ICCID: 8955141234567890

// Se for LPA real:
// (Não aparece log de simulação)
// (Sistema operacional abre dialog nativo)
// (Instalação real acontece)

// ============================================================================
// TROUBLESHOOTING
// ============================================================================

// Problema: Dialog nativo não aparece
// Solução: Verificar se LPA não contém palavras de teste

// Problema: "LPA String inválida"
// Solução: Verificar formato LPA:1$servidor$codigo

// Problema: "Erro ao baixar perfil"
// Solução: Verificar internet, LPA pode estar expirada

// Problema: "Dispositivo não suporta eSIM"
// Solução: Testar em dispositivo com eSIM (Android 9+ ou iOS 12+)

// ============================================================================
// EXEMPLO COMPLETO PRONTO PARA COPIAR
// ============================================================================

/*
// Cole isso em lib/services/mock_api_service.dart (linha ~30)

static Future<Map<String, dynamic>> getESimDetails(String activationCode) async {
  await Future.delayed(_networkDelay);

  // ========================================
  // COLE SUA LPA STRING REAL AQUI ↓
  // ========================================
  const LPA_REAL = 'LPA:1\$smdp.operadora.com\$ABC123XYZ456-FULL-CODE';
  
  // Para testar com LPA real, mude para true:
  const USE_REAL_LPA = false; // ← Mude para true quando quiser testar de verdade
  
  final lpaString = USE_REAL_LPA 
    ? LPA_REAL 
    : 'LPA:1\$test.scconecta.com\$TEST-$activationCode';
  
  if (USE_REAL_LPA) {
    print('🔴 ATENÇÃO: Usando LPA REAL - Vai instalar eSIM de verdade!');
  } else {
    print('🟢 Usando LPA de teste - Apenas simulação');
  }

  return {
    'success': true,
    'data': {
      'activation_code': activationCode,
      'lpa_string': lpaString,
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
*/

// ============================================================================
// FIM DO EXEMPLO
// ============================================================================
