import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/native_esim_service.dart';
import 'esim_setup_wizard_screen.dart';

/// Tela para testar LPA String real
/// Cole a LPA que o parceiro enviou e teste a instalação
class TestRealLpaScreen extends StatefulWidget {
  const TestRealLpaScreen({super.key});

  @override
  State<TestRealLpaScreen> createState() => _TestRealLpaScreenState();
}

class _TestRealLpaScreenState extends State<TestRealLpaScreen> {
  final _lpaController = TextEditingController();
  bool _isInstalling = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    // Cole sua LPA aqui como padrão para facilitar testes
    _lpaController.text = 'LPA:1\$RSP-4040.IDEMIA.IO\$QZTI5-CGVFT-E0ISM-5EOLW';
  }

  @override
  void dispose() {
    _lpaController.dispose();
    super.dispose();
  }

  Future<void> _installESim() async {
    final lpaString = _lpaController.text.trim();

    if (lpaString.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, cole a LPA String';
      });
      return;
    }

    if (!lpaString.startsWith('LPA:1\$')) {
      setState(() {
        _errorMessage = 'LPA String inválida. Deve começar com LPA:1\$';
      });
      return;
    }

    try {
      setState(() {
        _isInstalling = true;
        _errorMessage = null;
        _successMessage = null;
      });

      // Verifica compatibilidade
      final supported = await NativeESimService.isDeviceSupported();
      if (!supported) {
        throw Exception('Dispositivo não suporta eSIM');
      }

      // Instala eSIM
      final result = await NativeESimService.installESim(lpaString);

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Falha na instalação');
      }

      // Sucesso!
      setState(() {
        _successMessage = 'eSIM instalado com sucesso!\nICCID: ${result.iccid}';
        _isInstalling = false;
      });

      // Aguarda 2 segundos e navega para wizard
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ESimSetupWizardScreen(
              activationCode: 'TESTE-REAL',
              planName: 'eSIM Real',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: $e';
        _isInstalling = false;
      });
    }
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _lpaController.text = data.text!;
      });
    }
  }

  void _clearText() {
    setState(() {
      _lpaController.clear();
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Testar LPA Real',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8DBB1B), Color(0xFF6A9515)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Testar LPA String Real',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cole a LPA String que você recebeu',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Instruções
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cole a LPA String que você converteu do QR Code',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Campo de texto
            Text(
              'LPA String',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lpaController,
              maxLines: 3,
              style: GoogleFonts.robotoMono(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'LPA:1\$servidor\$codigo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Colar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearText,
                      tooltip: 'Limpar',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botão de instalação
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isInstalling ? null : _installESim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8DBB1B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isInstalling
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Instalando...',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download),
                          const SizedBox(width: 12),
                          Text(
                            'Instalar eSIM Real',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Mensagem de erro
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Mensagem de sucesso
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Informações técnicas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Informações',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Formato', 'LPA:1\$servidor\$codigo'),
                  _buildInfoRow('Exemplo', 'LPA:1\$smdp.io\$ABC-123'),
                  _buildInfoRow('Sua LPA', 'IDEMIA (operadora real)'),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ Atenção: Isso vai instalar o eSIM DE VERDADE no seu celular!',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
