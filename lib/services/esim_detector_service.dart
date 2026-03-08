import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ESimDetectorService {
  static const platform = MethodChannel('com.example.scconecta_app/esim');
  
  // Prefixos de ICCID conhecidos da SCCONECTA (ajustar conforme sua operadora)
  static const List<String> scconectaICCIDPrefixes = [
    '8901', // Exemplo - ajustar com o prefixo real
    '8902', // Adicionar outros prefixos conforme necessário
  ];

  // Verifica se há um novo eSIM SCCONECTA instalado
  static Future<Map<String, dynamic>?> checkForNewESim() async {
    try {
      final result = await platform.invokeMethod('checkNewESim');
      if (result != null && result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      print('Erro ao verificar novo eSIM: $e');
    }
    return null;
  }

  // Verifica se o eSIM é da SCCONECTA baseado no ICCID
  static bool isSCConectaESim(String? iccid) {
    if (iccid == null || iccid.isEmpty) return false;
    
    // Verifica se o ICCID começa com algum dos prefixos conhecidos
    for (var prefix in scconectaICCIDPrefixes) {
      if (iccid.startsWith(prefix)) {
        return true;
      }
    }
    
    // Também pode verificar pelo nome da operadora
    return false;
  }

  // Marca que o tutorial já foi mostrado para este eSIM
  static Future<void> markTutorialShown(String iccid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tutorial_shown_$iccid', DateTime.now().toIso8601String());
  }

  // Verifica se o tutorial já foi mostrado para este eSIM
  static Future<bool> wasTutorialShown(String iccid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('tutorial_shown_$iccid');
  }

  // Monitora mudanças nas linhas telefônicas
  static Stream<Map<String, dynamic>?> monitorESimChanges() {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await checkForNewESim();
    }).asyncMap((future) => future);
  }

  // Obtém informações de todas as linhas
  static Future<List<Map<String, dynamic>>> getAllLines() async {
    try {
      final result = await platform.invokeMethod('getAllLines');
      if (result != null && result is List) {
        return result.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print('Erro ao obter linhas: $e');
    }
    return [];
  }

  // Verifica se há eSIM SCCONECTA ativo
  static Future<bool> hasSCConectaESimActive() async {
    final lines = await getAllLines();
    for (var line in lines) {
      if (line['isEsim'] == true && isSCConectaESim(line['iccid'])) {
        return true;
      }
    }
    return false;
  }
}
