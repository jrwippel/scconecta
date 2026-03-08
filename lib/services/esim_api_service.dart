import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mock_api_service.dart';

/// Serviço de API para eSIM
/// Pode usar dados mockados ou API real
class ESimApiService {
  // Configuração
  static const bool useMockData = true; // Mude para false quando tiver API real
  static const String baseUrl = 'https://api.scconecta.com/v1';
  
  // API fake no GitHub Pages para testes
  static const String githubPagesApiUrl = 'https://jrwippel.github.io/scconecta/api/esim';
  
  // Token de autenticação (será implementado depois)
  static String? _authToken;
  
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// GET /api/v1/esim/{activation_code}
  /// Busca detalhes do eSIM pelo código de ativação
  static Future<ESimDetailsResponse> getESimDetails(String activationCode) async {
    if (useMockData) {
      // Tenta buscar da API fake do GitHub Pages primeiro
      if (activationCode.startsWith('REAL-')) {
        try {
          final url = Uri.parse('$githubPagesApiUrl/$activationCode.json');
          final response = await http.get(url);
          
          if (response.statusCode == 200) {
            print('✅ Dados carregados da API fake GitHub Pages');
            return ESimDetailsResponse.fromJson(json.decode(response.body));
          }
        } catch (e) {
          print('⚠️ Erro ao buscar da API fake, usando mock local: $e');
        }
      }
      
      // Fallback para mock local
      final mockData = await MockApiService.getESimDetails(activationCode);
      return ESimDetailsResponse.fromJson(mockData);
    }

    // API Real
    final url = Uri.parse('$baseUrl/esim/$activationCode');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
    );

    if (response.statusCode == 200) {
      return ESimDetailsResponse.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        'Erro ao buscar eSIM: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// POST /api/v1/esim/{activation_code}/activate
  /// Confirma que o eSIM foi instalado com sucesso
  static Future<ActivationResponse> confirmActivation(
    String activationCode,
    DeviceInfo deviceInfo,
  ) async {
    if (useMockData) {
      // Usa dados mockados
      final mockData = await MockApiService.confirmActivation(activationCode);
      return ActivationResponse.fromJson(mockData);
    }

    // API Real
    final url = Uri.parse('$baseUrl/esim/$activationCode/activate');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: json.encode({
        'device_info': deviceInfo.toJson(),
        'activated_at': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return ActivationResponse.fromJson(json.decode(response.body));
    } else {
      throw ApiException(
        'Erro ao confirmar ativação: ${response.statusCode}',
        response.statusCode,
      );
    }
  }
}

// ============================================================================
// MODELS
// ============================================================================

/// Resposta da API de detalhes do eSIM
class ESimDetailsResponse {
  final bool success;
  final ESimDetails data;

  ESimDetailsResponse({
    required this.success,
    required this.data,
  });

  factory ESimDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ESimDetailsResponse(
      success: json['success'] ?? false,
      data: ESimDetails.fromJson(json['data']),
    );
  }
}

/// Detalhes do eSIM
class ESimDetails {
  final String activationCode;
  final String lpaString;
  final String iccid;
  final PlanDetails plan;
  final ValidityPeriod validity;
  final String status;
  final UserInfo user;

  ESimDetails({
    required this.activationCode,
    required this.lpaString,
    required this.iccid,
    required this.plan,
    required this.validity,
    required this.status,
    required this.user,
  });

  factory ESimDetails.fromJson(Map<String, dynamic> json) {
    return ESimDetails(
      activationCode: json['activation_code'],
      lpaString: json['lpa_string'],
      iccid: json['iccid'],
      plan: PlanDetails.fromJson(json['plan']),
      validity: ValidityPeriod.fromJson(json['validity']),
      status: json['status'],
      user: UserInfo.fromJson(json['user']),
    );
  }
}

/// Detalhes do plano
class PlanDetails {
  final String id;
  final String name;
  final List<String> countries;
  final String data;
  final String voice;

  PlanDetails({
    required this.id,
    required this.name,
    required this.countries,
    required this.data,
    required this.voice,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      id: json['id'],
      name: json['name'],
      countries: List<String>.from(json['countries']),
      data: json['data'],
      voice: json['voice'],
    );
  }
}

/// Período de validade
class ValidityPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;

  ValidityPeriod({
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
  });

  factory ValidityPeriod.fromJson(Map<String, dynamic> json) {
    return ValidityPeriod(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      daysRemaining: json['days_remaining'],
    );
  }
}

/// Informações do usuário
class UserInfo {
  final String email;
  final String name;

  UserInfo({
    required this.email,
    required this.name,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email'],
      name: json['name'],
    );
  }
}

/// Resposta da confirmação de ativação
class ActivationResponse {
  final bool success;
  final ActivationData data;
  final String message;

  ActivationResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ActivationResponse.fromJson(Map<String, dynamic> json) {
    return ActivationResponse(
      success: json['success'] ?? false,
      data: ActivationData.fromJson(json['data']),
      message: json['message'] ?? '',
    );
  }
}

/// Dados da ativação
class ActivationData {
  final String activationCode;
  final String status;
  final DateTime activatedAt;

  ActivationData({
    required this.activationCode,
    required this.status,
    required this.activatedAt,
  });

  factory ActivationData.fromJson(Map<String, dynamic> json) {
    return ActivationData(
      activationCode: json['activation_code'],
      status: json['status'],
      activatedAt: DateTime.parse(json['activated_at']),
    );
  }
}

/// Informações do dispositivo
class DeviceInfo {
  final String model;
  final String os;
  final String osVersion;
  final String? imei;
  final String manufacturer;

  DeviceInfo({
    required this.model,
    required this.os,
    required this.osVersion,
    this.imei,
    required this.manufacturer,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'os': os,
      'os_version': osVersion,
      if (imei != null) 'imei': imei,
      'manufacturer': manufacturer,
    };
  }
}

/// Exceção de API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
