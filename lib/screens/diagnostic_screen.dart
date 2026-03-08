import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../l10n/app_localizations.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  static const platform = MethodChannel('com.scconecta.app/roaming');
  
  List<dynamic> _linhas = [];
  bool _isLoading = false;
  bool _isEsimSupported = false;
  String _eid = "";
  
  // Teste de Velocidade
  bool _isTestingSpeed = false;
  double _downloadRate = 0.0; 
  double _progress = 0.0;

  // Status de Viagem
  bool _riscoCobranca = false;
  bool _configuracaoOk = false;
  bool _modoInformativo = false; // Novo: para cenário 4 (informativo neutro)
  String _mensagemHeader = "Analisando sua conexão...";
  
  // MODO SIMULAÇÃO PARA TESTES
  bool _modoSimulacao = true; // Ativado para testes
  int _cenarioAtual = 1; // 1, 2, 3, 4, 5 ou 6

  // Cores Profissionais
  final Color verdeOliva = const Color(0xFFABC33E);
  final Color azulInfo = const Color(0xFF2196F3);
  final Color verdeSucesso = const Color(0xFF4CAF50);
  final Color laranjaAviso = const Color(0xFFFFA000);
  final Color vermelhoCritico = const Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _fetchDiagnostico();
  }

  Future<void> _fetchDiagnostico() async {
    setState(() => _isLoading = true);
    
    if (_modoSimulacao) {
      // DADOS SIMULADOS PARA TESTE NO EMULADOR
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isEsimSupported = true;
        _eid = "89000000000000000000000000000000";
        _linhas = _getDadosSimulados(_cenarioAtual);
        _processarStatusViagem();
        _isLoading = false;
      });
      return;
    }
    
    try {
      final Map<dynamic, dynamic> supportData = await platform.invokeMethod('checkEsimSupport');
      final List<dynamic> result = await platform.invokeMethod('getLinesInfo');
      
      setState(() {
        _isEsimSupported = supportData['isSupported'] ?? false;
        _eid = supportData['eid'] ?? "";
        _linhas = result;
        _processarStatusViagem();
      });
    } on PlatformException catch (e) {
      debugPrint("Erro na plataforma: ${e.message}");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  List<dynamic> _getDadosSimulados(int cenario) {
    switch (cenario) {
      case 1: // 🔴 CENÁRIO CRÍTICO: eSIM internacional + linha nacional ativa + FORA DO BRASIL
        return [
          {
            'carrierName': 'Vivo BR',
            'mcc': '234', // Conectado em rede do Reino Unido (em roaming)
            'isLineActive': true, // ATIVA - RISCO!
            'isEsim': false,
            'roamingEnabled': true,
            'isNetworkRoaming': true, // FORA DO BRASIL
            'networkType': '4G',
          },
          {
            'carrierName': 'SCCONECTA',
            'mcc': '234', // Reino Unido (Inglaterra)
            'isLineActive': true,
            'isEsim': true, // eSIM INTERNACIONAL
            'roamingEnabled': false,
            'isNetworkRoaming': true, // FORA DO BRASIL
            'networkType': '5G',
          },
        ];
      
      case 2: // 🟢 CENÁRIO IDEAL: eSIM internacional + linha nacional desativada + FORA DO BRASIL
        return [
          {
            'carrierName': 'Tim Brasil',
            'mcc': '724',
            'isLineActive': false, // DESATIVADA - IDEAL!
            'isEsim': false,
            'roamingEnabled': false,
            'isNetworkRoaming': false,
            'networkType': '-',
          },
          {
            'carrierName': 'SCCONECTA',
            'mcc': '208',
            'isLineActive': true,
            'isEsim': true, // eSIM INTERNACIONAL
            'roamingEnabled': false,
            'isNetworkRoaming': true, // FORA DO BRASIL
            'networkType': '5G',
          },
        ];
      
      case 3: // 🟡 CENÁRIO AVISO: eSIM internacional + linha nacional ativa + AINDA NO BRASIL
        return [
          {
            'carrierName': 'Claro BR',
            'mcc': '724', // BRASIL
            'isLineActive': true, // ATIVA
            'isEsim': false,
            'roamingEnabled': false,
            'isNetworkRoaming': false, // AINDA NO BRASIL
            'networkType': '4G',
          },
          {
            'carrierName': 'SCCONECTA',
            'mcc': '724', // AINDA NO BRASIL - não conectado em rede estrangeira
            'isLineActive': true,
            'isEsim': true, // eSIM INTERNACIONAL instalado mas não em uso
            'roamingEnabled': false,
            'isNetworkRoaming': false, // AINDA NO BRASIL
            'networkType': '-',
          },
        ];
      
      case 4: // ⚪ CENÁRIO PADRÃO: Apenas linha nacional NO BRASIL
        return [
          {
            'carrierName': 'Oi Brasil',
            'mcc': '724',
            'isLineActive': true,
            'isEsim': false,
            'roamingEnabled': false,
            'isNetworkRoaming': false, // NO BRASIL
            'networkType': '4G',
          },
        ];
      
      case 5: // 🔴 CENÁRIO CRÍTICO SEM eSIM: Linha nacional FORA DO BRASIL sem chip internacional
        return [
          {
            'carrierName': 'Vivo BR',
            'mcc': '310', // Conectado em rede dos EUA!
            'isLineActive': true,
            'isEsim': false,
            'roamingEnabled': true,
            'isNetworkRoaming': true, // FORA DO BRASIL - ROAMING CARO!
            'networkType': '4G',
          },
        ];
      
      case 6: // ⚫ CENÁRIO SEM CONEXÃO: No exterior mas sem roaming habilitado (sem sinal)
        return [
          {
            'carrierName': 'Vivo BR',
            'mcc': '724', // Mantém MCC do Brasil (não conectou em rede estrangeira)
            'isLineActive': true,
            'isEsim': false,
            'roamingEnabled': false, // ROAMING DESABILITADO
            'isNetworkRoaming': false, // Não está conectado
            'networkType': '-', // Sem sinal
          },
        ];
      
      default:
        return [];
    }
  }

  void _processarStatusViagem() {
    final localizations = AppLocalizations.of(context);
    bool temEsimInternacional = false;
    bool temLinhaNacionalAtiva = false;
    bool estaForaDoBrasil = false;
    bool temConexaoCelular = false;

    for (var linha in _linhas) {
      // Identifica se é operadora brasileira
      bool isBrasil = (linha['mcc'] == "724") || 
                      ["vivo", "tim", "claro", "oi"].any((op) => 
                        linha['carrierName'].toString().toLowerCase().contains(op));
      
      bool isActive = linha['isLineActive'] ?? false;
      bool isEsim = linha['isEsim'] ?? false;
      String mcc = linha['mcc'] ?? "";
      bool isNetworkRoaming = linha['isNetworkRoaming'] ?? false;
      String networkType = linha['networkType'] ?? "-";

      // Detecta eSIM internacional ativo
      if (!isBrasil && isEsim && isActive) {
        temEsimInternacional = true;
      }

      // Detecta linha nacional ativa
      if (isBrasil && isActive) {
        temLinhaNacionalAtiva = true;
      }

      // Verifica se tem conexão celular ativa
      if (isActive && networkType != "-" && networkType.isNotEmpty) {
        temConexaoCelular = true;
      }

      // VERIFICAÇÃO PRECISA: Está fora do Brasil se:
      // 1. MCC diferente de 724 (conectado em rede estrangeira) OU
      // 2. isNetworkRoaming = true (confirmação de roaming de rede)
      if ((mcc.isNotEmpty && mcc != "724") || isNetworkRoaming) {
        estaForaDoBrasil = true;
      }
    }

    setState(() {
      // CENÁRIO 1 - CRÍTICO: eSIM internacional + linha nacional ativa + fora do Brasil
      if (temEsimInternacional && temLinhaNacionalAtiva && estaForaDoBrasil) {
        _riscoCobranca = true;
        _configuracaoOk = false;
        _modoInformativo = false;
        _mensagemHeader = localizations?.translate('diagnostic_msg_critical') ?? "Atenção! Desative sua linha pessoal para evitar cobranças de roaming.";
      } 
      // CENÁRIO 2 - IDEAL: eSIM internacional + linha nacional desativada + fora do Brasil
      else if (temEsimInternacional && !temLinhaNacionalAtiva && estaForaDoBrasil) {
        _riscoCobranca = false;
        _configuracaoOk = true;
        _modoInformativo = false;
        _mensagemHeader = localizations?.translate('diagnostic_msg_ideal') ?? "Configuração ideal! Sua linha pessoal está desativada. Boa viagem!";
      } 
      // CENÁRIO 3 - AVISO: eSIM internacional + linha nacional ativa + ainda no Brasil
      else if (temEsimInternacional && temLinhaNacionalAtiva && !estaForaDoBrasil) {
        _riscoCobranca = false;
        _configuracaoOk = false;
        _modoInformativo = false;
        _mensagemHeader = localizations?.translate('diagnostic_msg_warning') ?? "Lembre-se de desativar sua linha pessoal ao chegar no destino.";
      }
      // CENÁRIO 5 - CRÍTICO SEM eSIM: Sem eSIM internacional + fora do Brasil (roaming caro!)
      else if (!temEsimInternacional && estaForaDoBrasil) {
        _riscoCobranca = true;
        _configuracaoOk = false;
        _modoInformativo = false;
        _mensagemHeader = localizations?.translate('diagnostic_msg_roaming') ?? "Você está em roaming internacional! Adquira um chip SCCONECTA para evitar cobranças altas.";
      }
      // CENÁRIO 6 - SEM CONEXÃO: Linha ativa mas sem sinal de rede
      else if (!temConexaoCelular && temLinhaNacionalAtiva) {
        _riscoCobranca = false;
        _configuracaoOk = false;
        _modoInformativo = false;
        _mensagemHeader = localizations?.translate('diagnostic_msg_no_connection') ?? "Sem conexão de rede celular. Conecte-se ao WiFi para configurar seu chip internacional.";
      }
      // CENÁRIO 4 - PADRÃO: Sem eSIM internacional + no Brasil
      else {
        _riscoCobranca = false;
        _configuracaoOk = false;
        _modoInformativo = true; // Modo informativo
        _mensagemHeader = localizations?.translate('diagnostic_msg_default') ?? "Viaje tranquilo! Adquira seu chip SCCONECTA antes de embarcar.";
      }
    });
  }

  // --- WIDGETS DE UI ---

  Widget _buildLocalizacaoIndicador() {
    final localizations = AppLocalizations.of(context);
    bool estaForaDoBrasil = false;
    String localizacao = localizations?.translate('country_brazil') ?? "Brasil";
    String mccDetectado = "";

    // Detecta localização baseado nas linhas
    for (var linha in _linhas) {
      String mcc = linha['mcc'] ?? "";
      bool isNetworkRoaming = linha['isNetworkRoaming'] ?? false;
      
      if ((mcc.isNotEmpty && mcc != "724") || isNetworkRoaming) {
        estaForaDoBrasil = true;
        mccDetectado = mcc;
        
        // Mapeia alguns MCCs conhecidos
        switch (mcc) {
          case "310":
          case "311":
          case "312":
            localizacao = localizations?.translate('country_usa') ?? "Estados Unidos";
            break;
          case "208":
            localizacao = localizations?.translate('country_france') ?? "França";
            break;
          case "234":
            localizacao = localizations?.translate('country_uk') ?? "Reino Unido";
            break;
          case "214":
            localizacao = localizations?.translate('country_spain') ?? "Espanha";
            break;
          case "222":
            localizacao = localizations?.translate('country_italy') ?? "Itália";
            break;
          case "262":
            localizacao = localizations?.translate('country_germany') ?? "Alemanha";
            break;
          case "505":
            localizacao = localizations?.translate('country_australia') ?? "Austrália";
            break;
          default:
            localizacao = localizations?.translate('country_abroad') ?? "Exterior";
        }
        break;
      }
    }

    String textoLocalizacao = estaForaDoBrasil 
        ? "${localizations?.translate('diagnostic_location_in') ?? 'Você está em:'} $localizacao"
        : localizations?.translate('diagnostic_location_brazil') ?? "Você está no Brasil";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: estaForaDoBrasil ? Colors.blue.shade50 : Colors.green.shade50,
        border: Border(
          bottom: BorderSide(
            color: estaForaDoBrasil ? Colors.blue.shade100 : Colors.green.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            estaForaDoBrasil ? Icons.flight_takeoff : Icons.location_on,
            size: 16,
            color: estaForaDoBrasil ? Colors.blue.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            textoLocalizacao,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: estaForaDoBrasil ? Colors.blue.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHeader() {
    final localizations = AppLocalizations.of(context);
    IconData iconData = Icons.sensors_outlined;
    Color baseColor = azulInfo;
    String titulo = "DIAGNÓSTICO";
    bool mostrarBotaoWifi = false;

    if (_riscoCobranca) {
      iconData = Icons.warning_amber_rounded;
      baseColor = vermelhoCritico;
      titulo = localizations?.translate('diagnostic_action_required') ?? "AÇÃO RECOMENDADA";
    } else if (_configuracaoOk) {
      iconData = Icons.verified_user_outlined;
      baseColor = verdeSucesso;
      titulo = localizations?.translate('diagnostic_all_set') ?? "TUDO PRONTO";
    } else if (_modoInformativo) {
      iconData = Icons.flight_takeoff;
      baseColor = azulInfo;
      titulo = localizations?.translate('diagnostic_plan_trip') ?? "PLANEJE SUA VIAGEM";
    } else if (_mensagemHeader.contains("Sem conexão de rede celular") || _mensagemHeader.contains("No cellular network")) {
      iconData = Icons.wifi_off;
      baseColor = laranjaAviso;
      titulo = localizations?.translate('diagnostic_no_connection') ?? "SEM CONEXÃO";
      mostrarBotaoWifi = true;
    } else {
      iconData = Icons.info_outline;
      baseColor = laranjaAviso;
      titulo = localizations?.translate('diagnostic_configuration') ?? "CONFIGURAÇÃO";
    }

    return GestureDetector(
      onTap: mostrarBotaoWifi ? null : () => platform.invokeMethod('openRoamingSettings'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: baseColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: baseColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: baseColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(iconData, color: baseColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: 1.1)),
                      const SizedBox(height: 2),
                      Text(_mensagemHeader, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.3)),
                    ],
                  ),
                ),
                if (!mostrarBotaoWifi) Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
              ],
            ),
            if (mostrarBotaoWifi) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => platform.invokeMethod('openWifiSettings'),
                  icon: const Icon(Icons.wifi, size: 18),
                  label: Text(localizations?.translate('diagnostic_connect_wifi') ?? "CONECTAR AO WIFI", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeOliva,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimCard(Map<dynamic, dynamic> linha) {
    final localizations = AppLocalizations.of(context);
    bool isRoamingOn = linha['roamingEnabled'] ?? false;
    bool isActive = linha['isLineActive'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(linha['isEsim'] ? Icons.install_mobile : Icons.sim_card, 
                      color: isActive ? verdeOliva : Colors.grey, size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${linha['carrierName']}".toUpperCase(), 
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                isActive 
                                  ? "● ${localizations?.translate('diagnostic_active') ?? 'ATIVO'}" 
                                  : "○ ${localizations?.translate('diagnostic_inactive') ?? 'DESATIVADO'}",
                                style: TextStyle(color: isActive ? Colors.green[700] : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              if (isActive) _buildNetworkBadge(linha['networkType']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => platform.invokeMethod('openSimSettings'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(localizations?.translate('diagnostic_manage_line') ?? "GERENCIAR ESTA LINHA", style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                ),
                if (isActive) ...[
                  const Divider(height: 24),
                  _buildSpeedSection(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSection() {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      children: [
        if (_isTestingSpeed) 
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(value: _progress, color: verdeOliva, backgroundColor: Colors.grey[100], minHeight: 3),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations?.translate('diagnostic_download_speed') ?? "VELOCIDADE DE DOWNLOAD", style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("${_downloadRate.toStringAsFixed(1)} Mbps", 
                  style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            ElevatedButton(
              onPressed: _isTestingSpeed ? null : _runSpeedTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeOliva,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _isTestingSpeed 
                  ? (localizations?.translate('diagnostic_testing') ?? "TESTANDO...") 
                  : (localizations?.translate('diagnostic_test_signal') ?? "TESTAR SINAL"), 
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: verdeOliva.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: verdeOliva, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRoamingIndicator(bool enabled, bool active) {
    return Column(
      children: [
        const Text("ROAMING", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Icon(enabled ? Icons.language : Icons.language_outlined, 
          color: (active && enabled) ? verdeOliva : Colors.grey[300], size: 26),
      ],
    );
  }

  // --- LÓGICA DE NEGÓCIO ---

  Future<void> _runSpeedTest() async {
    setState(() { _isTestingSpeed = true; _downloadRate = 0.0; _progress = 0.0; });
    try {
      final url = Uri.parse('https://speed.cloudflare.com/__down?bytes=5242880');
      final stopwatch = Stopwatch()..start();
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final double mbps = (response.bodyBytes.length * 8) / (1024 * 1024) / (stopwatch.elapsedMilliseconds / 1000.0);
        setState(() { _downloadRate = mbps; _progress = 1.0; });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Falha ao testar velocidade.")));
    } finally {
      setState(() => _isTestingSpeed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(localizations?.translate('diagnostic_title') ?? "CONECTIVIDADE", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          if (_modoSimulacao)
            PopupMenuButton<int>(
              icon: const Icon(Icons.science, color: Colors.orange),
              tooltip: "Modo Simulação",
              onSelected: (cenario) {
                setState(() {
                  _cenarioAtual = cenario;
                  _fetchDiagnostico();
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 1, child: Text("🔴 Cenário 1: Crítico c/ eSIM")),
                const PopupMenuItem(value: 2, child: Text("🟢 Cenário 2: Ideal")),
                const PopupMenuItem(value: 3, child: Text("🟡 Cenário 3: Aviso")),
                const PopupMenuItem(value: 4, child: Text("⚪ Cenário 4: Padrão")),
                const PopupMenuItem(value: 5, child: Text("🔴 Cenário 5: Crítico s/ eSIM")),
                const PopupMenuItem(value: 6, child: Text("⚫ Cenário 6: Sem conexão")),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (_modoSimulacao)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade100,
              child: Text(
                "MODO SIMULAÇÃO - Cenário $_cenarioAtual",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
          _buildLocalizacaoIndicador(),
          _buildAlertHeader(),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: verdeOliva))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _linhas.length,
                  itemBuilder: (context, index) => _buildSimCard(_linhas[index]),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchDiagnostico,
        backgroundColor: verdeOliva,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}