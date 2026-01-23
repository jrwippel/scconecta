import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  static const platform = MethodChannel('com.scconecta.app/roaming');
  bool _isLoading = false;
  List<dynamic> _linhas = [];

  @override
  void initState() {
    super.initState();
    _executarDiagnostico();
  }

  Future<void> _executarDiagnostico() async {
    setState(() => _isLoading = true);
    try {
      await [Permission.phone, Permission.location].request();

      final List<dynamic> result = await platform.invokeMethod('getLinesInfo');
      setState(() => _linhas = result);
    } on PlatformException catch (e) {
      debugPrint("Erro: ${e.message}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diagnóstico de Chips")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _linhas.length,
              itemBuilder: (context, index) {
                final linha = _linhas[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          linha['isEsim'] ? Icons.install_mobile : Icons.sim_card,
                          color: Colors.blue,
                        ),
                        title: Text(
                          "${linha['carrierName']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              linha['isEsim']
                                  ? "Tecnologia: eSIM"
                                  : "Tecnologia: Chip Físico",
                            ),
                            Text(
                              linha['isActive'] == true
                                  ? "Linha ativa"
                                  : "Linha inativa",
                              style: TextStyle(
                                color: linha['isActive'] == true
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Roaming"),
                            Icon(
                              Icons.circle,
                              color: linha['roamingEnabled'] == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              linha['roamingAllowed'] == true
                                  ? "Permitido"
                                  : "Bloqueado",
                              style: GoogleFonts.montserrat(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (linha['roamingAllowed'] == true &&
                          linha['roamingEnabled'] == false)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.info, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Roaming está permitido, mas você está em rede doméstica.",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12, color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _executarDiagnostico,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
