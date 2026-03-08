import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

/// Simula a página web que o usuário vê ao clicar no link do WhatsApp
/// Esta tela representa: https://scconecta.com/activate/ABC123
class WebRedirectScreen extends StatefulWidget {
  final String activationCode;

  const WebRedirectScreen({
    super.key,
    required this.activationCode,
  });

  @override
  State<WebRedirectScreen> createState() => _WebRedirectScreenState();
}

class _WebRedirectScreenState extends State<WebRedirectScreen> {
  int _countdown = 3;
  String _status = 'Tentando abrir o app...';
  bool _showStoreButtons = false;

  @override
  void initState() {
    super.initState();
    _tryOpenApp();
  }

  Future<void> _tryOpenApp() async {
    // Simula tentativa de abrir o app via deep link
    setState(() {
      _status = 'Verificando se o app está instalado...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // Tenta abrir o app (em produção, seria: scconecta://esim/activate?code=ABC123)
    setState(() {
      _status = 'Tentando abrir o app SCCONECTA...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // Simula que o app não está instalado (ou não respondeu)
    // Em produção, isso seria detectado automaticamente
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
          _status = 'App não detectado. Redirecionando em $_countdown...';
        });
      } else {
        timer.cancel();
        setState(() {
          _status = 'App não instalado';
          _showStoreButtons = true;
        });
      }
    });
  }

  Future<void> _openPlayStore() async {
    // Em produção, seria o link real da Play Store
    const url = 'https://play.google.com/store/apps/details?id=com.example.scconecta_app';
    
    // Por enquanto, simula instalação abrindo o app direto
    _simulateAppInstalled();
  }

  Future<void> _openAppStore() async {
    // Em produção, seria o link real da App Store
    const url = 'https://apps.apple.com/app/idXXXXXXXXX';
    
    // Por enquanto, simula instalação abrindo o app direto
    _simulateAppInstalled();
  }

  void _simulateAppInstalled() {
    // Simula que o usuário instalou o app e está abrindo
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.download_done, color: Color(0xFF8DBB1B)),
            const SizedBox(width: 12),
            Text(
              'App Instalado!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'O app SCCONECTA foi instalado com sucesso!',
              style: GoogleFonts.montserrat(),
            ),
            const SizedBox(height: 16),
            Text(
              'Agora vamos abrir o app e ativar seu eSIM.',
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialog
              _openAppDirectly();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DBB1B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Abrir App'),
          ),
        ],
      ),
    );
  }

  void _openAppDirectly() {
    // Simula abertura do app e navegação para tela de ativação
    Navigator.pushReplacementNamed(
      context,
      '/esim-activation',
      arguments: widget.activationCode,
    );
  }

  void _simulateAppAlreadyInstalled() {
    // Simula que o app JÁ estava instalado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF8DBB1B)),
            const SizedBox(width: 12),
            Text(
              'App Detectado!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'O app SCCONECTA está instalado. Abrindo automaticamente...',
          style: GoogleFonts.montserrat(),
        ),
      ),
    );

    // Aguarda 2 segundos e abre o app
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Fecha dialog
      _openAppDirectly();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Ícone
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8DBB1B), Color(0xFF6A9515)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8DBB1B).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sim_card,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Título
              Text(
                'SCCONECTA',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8DBB1B),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Ativação de eSIM',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 48),

              // Status
              if (!_showStoreButtons) ...[
                const CircularProgressIndicator(
                  color: Color(0xFF8DBB1B),
                ),
                const SizedBox(height: 24),
                Text(
                  _status,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Botões da Loja
              if (_showStoreButtons) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'App não instalado',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Para ativar seu eSIM, você precisa instalar o app SCCONECTA.',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.orange.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botão Android
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _openPlayStore,
                    icon: const Icon(Icons.android, size: 28),
                    label: Text(
                      'Instalar no Android',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3DDC84),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Botão iOS
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _openAppStore,
                    icon: const Icon(Icons.apple, size: 28),
                    label: Text(
                      'Instalar no iPhone',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão de teste: simular app já instalado
                TextButton(
                  onPressed: _simulateAppAlreadyInstalled,
                  child: Text(
                    '🧪 Simular: App já instalado',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF8DBB1B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Código de ativação
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Código de Ativação',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.activationCode,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8DBB1B),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
