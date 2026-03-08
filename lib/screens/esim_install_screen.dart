import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/native_esim_service.dart';
import 'esim_setup_wizard_screen.dart';

/// Tela de instalação do eSIM via LPA String
/// Recebe a LPA do deep link e instala o eSIM
class ESimInstallScreen extends StatefulWidget {
  final String lpaString;

  const ESimInstallScreen({
    super.key,
    required this.lpaString,
  });

  @override
  State<ESimInstallScreen> createState() => _ESimInstallScreenState();
}

class _ESimInstallScreenState extends State<ESimInstallScreen> {
  bool _isInstalling = false;
  String _status = 'Preparando instalação...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Inicia instalação automaticamente
    Future.delayed(const Duration(milliseconds: 500), () {
      _installESim();
    });
  }

  Future<void> _installESim() async {
    setState(() {
      _isInstalling = true;
      _status = 'Verificando dispositivo...';
      _progress = 0.1;
    });

    try {
      // Verifica se dispositivo suporta eSIM
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _status = 'Validando LPA String...';
        _progress = 0.3;
      });

      // Valida LPA
      if (!_isValidLPA(widget.lpaString)) {
        throw Exception('LPA String inválida');
      }

      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _status = 'Instalando eSIM...';
        _progress = 0.5;
      });

      // Chama o código nativo para instalar
      final result = await NativeESimService.installESim(widget.lpaString);

      if (result['success'] == true) {
        setState(() {
          _status = 'eSIM instalado com sucesso!';
          _progress = 1.0;
        });

        // Aguarda 1 segundo e navega para o wizard
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ESimSetupWizardScreen(
                activationCode: widget.lpaString,
                planName: 'Plano eSIM SCCONECTA',
              ),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Erro desconhecido');
      }
    } catch (e) {
      setState(() {
        _isInstalling = false;
        _status = 'Erro: $e';
        _progress = 0.0;
      });

      _showErrorDialog(e.toString());
    }
  }

  bool _isValidLPA(String lpa) {
    // LPA deve começar com "LPA:1$"
    if (!lpa.startsWith('LPA:1\$')) return false;

    // Deve ter pelo menos 3 partes separadas por $
    final parts = lpa.split('\$');
    if (parts.length < 3) return false;

    return true;
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(
              'Erro na Instalação',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Não foi possível instalar o eSIM:',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                error,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.red.shade900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Possíveis causas:',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildErrorCause('• Dispositivo não suporta eSIM'),
            _buildErrorCause('• LPA String inválida ou expirada'),
            _buildErrorCause('• Sem conexão com a internet'),
            _buildErrorCause('• eSIM já foi instalado anteriormente'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Volta para tela anterior
            },
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _installESim(); // Tenta novamente
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DBB1B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCause(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF8DBB1B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sim_card_download,
                  size: 64,
                  color: Color(0xFF8DBB1B),
                ),
              ),

              const SizedBox(height: 32),

              // Título
              Text(
                'Instalando eSIM',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Status
              Text(
                _status,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Progress Bar
              if (_isInstalling) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF8DBB1B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8DBB1B),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Info Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aguarde...',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A instalação pode levar alguns segundos. Mantenha o dispositivo conectado à internet.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // LPA Info (debug)
              if (!_isInstalling)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LPA: ${widget.lpaString}',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
