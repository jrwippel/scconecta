import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  // Canal de comunicação com o Android (deve ser o mesmo do MainActivity.kt)
  static const platform = MethodChannel('com.scconecta.app/roaming');
  
  List<dynamic> _linhas = [];
  bool _isLoading = false;
  bool _isEsimSupported = false;
  String _eid = "";
  
  // Variáveis do Teste de Velocidade
  bool _isTestingSpeed = false;
  double _downloadRate = 0.0; 
  double _progress = 0.0;

  final Color verdeOliva = const Color(0xFFABC33E);

  @override
  void initState() {
    super.initState();
    _fetchDiagnostico();
  }

  // Busca as informações do sistema via MethodChannel
  Future<void> _fetchDiagnostico() async {
    setState(() => _isLoading = true);
    try {
      final Map<dynamic, dynamic> supportData = await platform.invokeMethod('checkEsimSupport');
      final List<dynamic> result = await platform.invokeMethod('getLinesInfo');
      setState(() {
        _isEsimSupported = supportData['isSupported'] ?? false;
        _eid = supportData['eid'] ?? "";
        _linhas = result;
      });
    } on PlatformException catch (e) {
      debugPrint("Erro na plataforma: ${e.message}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Realiza o teste de velocidade baixando um arquivo temporário
  Future<void> _runSpeedTest() async {
    setState(() {
      _isTestingSpeed = true;
      _downloadRate = 0.0;
      _progress = 0.0;
    });

    try {
      // Arquivo de 10MB para teste
      final url = Uri.parse('https://speed.cloudflare.com/__down?bytes=10485760');
      
      final stopwatch = Stopwatch()..start();
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final int bytes = response.bodyBytes.length;
        final double seconds = stopwatch.elapsedMilliseconds / 1000.0;
        
        // Conversão para Mbps: (Bytes * 8 bits) / (1024 * 1024) / segundos
        final double mbps = (bytes * 8) / (1024 * 1024) / seconds;

        setState(() {
          _downloadRate = mbps;
          _progress = 1.0;
        });
      }
    } catch (e) {
      debugPrint("Erro no teste: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Falha ao medir velocidade. Verifique seu sinal de internet.")),
        );
      }
    } finally {
      setState(() => _isTestingSpeed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Conectividade", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDiscreetHeader(), 
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

  Widget _buildDiscreetHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isEsimSupported ? Icons.check_circle_outline : Icons.info_outline,
                size: 14, color: _isEsimSupported ? verdeOliva : Colors.grey),
              const SizedBox(width: 8),
              Text(
                _isEsimSupported ? "Dispositivo compatível com eSIM" : "Dispositivo sem suporte a eSIM",
                style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold,
                  color: _isEsimSupported ? verdeOliva : Colors.grey[600]),
              ),
            ],
          ),
          if (_isEsimSupported && _eid != "N/A" && _eid.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("EID: $_eid", style: TextStyle(fontSize: 9, color: Colors.grey[400], letterSpacing: 0.5)),
            ),
        ],
      ),
    );
  }

  Widget _buildSimCard(Map<dynamic, dynamic> linha) {
    bool isRoamingOn = linha['roamingEnabled'] ?? false;
    bool isActive = linha['isLineActive'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                              _buildStatusTag(isActive),
                              const SizedBox(width: 8),
                              if (isActive) _buildNetworkBadge(linha['networkType']),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // AÇÃO PARA DESATIVAR LINHA/CHIP
                          InkWell(
                            onTap: () => platform.invokeMethod('openSimSettings'),
                            child: Row(
                              children: [
                                Text("GERENCIAR LINHA / DESATIVAR CHIP",
                                  style: TextStyle(fontSize: 9, color: Colors.blue[600], fontWeight: FontWeight.bold)),
                                const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.blue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRoamingIndicator(isRoamingOn, isActive),
                  ],
                ),
                if (isActive) ...[
                  const Divider(height: 24),
                  _buildSpeedSection(),
                ]
              ],
            ),
          ),
          // Barra inferior de atalho para Roaming caso esteja em risco
          if (!isRoamingOn && isActive) _buildAlertBar(),
        ],
      ),
    );
  }

  Widget _buildSpeedSection() {
    return Column(
      children: [
        if (_isTestingSpeed) 
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: LinearProgressIndicator(value: _progress, color: verdeOliva, backgroundColor: Colors.grey[100], minHeight: 2),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("DOWNLOAD", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("${_downloadRate.toStringAsFixed(1)} Mbps", 
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            ElevatedButton(
              onPressed: _isTestingSpeed ? null : _runSpeedTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeOliva,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(_isTestingSpeed ? "TESTANDO..." : "TESTAR VELOCIDADE", 
                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: verdeOliva, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusTag(bool active) {
    return Text(active ? "● ATIVO" : "○ DESATIVADO",
        style: TextStyle(color: active ? Colors.green[700] : Colors.grey[600], fontSize: 9, fontWeight: FontWeight.bold));
  }

  Widget _buildRoamingIndicator(bool enabled, bool active) {
    return Column(
      children: [
        const Text("ROAMING", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
        Icon(Icons.check_circle, color: (active && enabled) ? verdeOliva : Colors.grey[300], size: 26),
      ],
    );
  }

  Widget _buildAlertBar() {
    return InkWell(
      onTap: () => platform.invokeMethod('openRoamingSettings'),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
        child: Center(child: Text("ROAMING DESATIVADO. TOQUE PARA AJUSTAR.", style: TextStyle(color: Colors.red[800], fontSize: 10, fontWeight: FontWeight.bold))),
      ),
    );
  }
}