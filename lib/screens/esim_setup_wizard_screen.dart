import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../services/native_esim_service.dart';

/// Wizard de configuração do eSIM
/// Guia o usuário através de 3 passos essenciais
class ESimSetupWizardScreen extends StatefulWidget {
  final String activationCode;
  final String planName;

  const ESimSetupWizardScreen({
    super.key,
    required this.activationCode,
    required this.planName,
  });

  @override
  State<ESimSetupWizardScreen> createState() => _ESimSetupWizardScreenState();
}

class _ESimSetupWizardScreenState extends State<ESimSetupWizardScreen> {
  int _currentStep = 0;
  final Map<int, bool> _completedSteps = {
    0: true, // Instalação já foi feita
    1: false, // Ativar roaming
    2: false, // Desativar linha pessoal
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    // Carrega progresso salvo (implementar SharedPreferences depois)
    // Por enquanto, apenas marca instalação como completa
    setState(() {
      _completedSteps[0] = true;
    });
  }

  Future<void> _saveProgress() async {
    // Salva progresso (implementar SharedPreferences depois)
  }

  void _markStepComplete(int step) {
    setState(() {
      _completedSteps[step] = true;
      if (step < 2) {
        _currentStep = step + 1;
      }
    });
    _saveProgress();
  }

  Future<void> _openRoamingSettings() async {
    try {
      await NativeESimService.openRoamingSettings();
      // Aguarda usuário voltar e marca como completo
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showConfirmDialog(
            'Roaming Ativado?',
            'Você ativou o roaming de dados para o eSIM SCCONECTA?',
            1,
          );
        }
      });
    } catch (e) {
      _showError('Erro ao abrir configurações: $e');
    }
  }

  Future<void> _openLineSettings() async {
    try {
      await NativeESimService.openLineSettings();
      // Aguarda usuário voltar e marca como completo
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _showConfirmDialog(
            'Linha Desativada?',
            'Você desativou sua linha pessoal?',
            2,
          );
        }
      });
    } catch (e) {
      _showError('Erro ao abrir configurações: $e');
    }
  }

  void _showConfirmDialog(String title, String message, int step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ainda não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markStepComplete(step);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DBB1B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sim, concluído'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _finishSetup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF8DBB1B), size: 32),
            const SizedBox(width: 12),
            Text(
              'Tudo Pronto!',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu eSIM está configurado e pronto para usar!',
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Lembre-se:',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildReminder(
              '✈️ Ao embarcar, mantenha apenas o eSIM SCCONECTA ativo',
            ),
            _buildReminder(
              '🌍 Ao chegar ao destino, ative os dados móveis e reinicie o aparelho',
            ),
            _buildReminder(
              '📱 Seu plano: ${widget.planName}',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Volta para tela anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DBB1B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Entendi!'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminder(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.montserrat(fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurar eSIM',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStepCard(
                    stepNumber: 1,
                    title: 'eSIM Instalado',
                    description: 'Seu eSIM foi instalado com sucesso no dispositivo.',
                    icon: Icons.check_circle,
                    isCompleted: _completedSteps[0]!,
                    isCurrent: _currentStep == 0,
                    onAction: null, // Já concluído
                  ),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    stepNumber: 2,
                    title: 'Ativar Roaming de Dados',
                    description: Platform.isIOS
                        ? 'Vá em Ajustes > Celular > Selecione o eSIM SCCONECTA > Ative "Roaming de Dados"'
                        : 'Vá em Configurações > Conexões > Redes Móveis > Ative "Roaming de Dados"',
                    icon: Icons.signal_cellular_alt,
                    isCompleted: _completedSteps[1]!,
                    isCurrent: _currentStep == 1,
                    onAction: _openRoamingSettings,
                    actionLabel: 'Abrir Configurações',
                  ),
                  const SizedBox(height: 16),
                  _buildStepCard(
                    stepNumber: 3,
                    title: 'Desativar Linha Pessoal',
                    description: Platform.isIOS
                        ? 'Ao embarcar, vá em Ajustes > Celular > Desative sua linha pessoal'
                        : 'Ao embarcar, vá em Configurações > Conexões > Gerenciador de Chips > Desative seu chip pessoal',
                    icon: Icons.sim_card_outlined,
                    isCompleted: _completedSteps[2]!,
                    isCurrent: _currentStep == 2,
                    onAction: _openLineSettings,
                    actionLabel: 'Abrir Configurações',
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          if (_completedSteps.values.every((completed) => completed))
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DBB1B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline),
                      const SizedBox(width: 12),
                      Text(
                        'Concluir Configuração',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalSteps = 3;
    final completedCount = _completedSteps.values.where((v) => v).length;
    final progress = completedCount / totalSteps;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedCount/$totalSteps passos',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8DBB1B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF8DBB1B).withOpacity(0.1)
            : isCurrent
                ? Colors.blue.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF8DBB1B)
              : isCurrent
                  ? Colors.blue.shade300
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF8DBB1B)
                      : isCurrent
                          ? Colors.blue
                          : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : Text(
                          '$stepNumber',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted)
                      Text(
                        'Concluído',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF8DBB1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 32,
                color: isCompleted
                    ? const Color(0xFF8DBB1B)
                    : isCurrent
                        ? Colors.blue
                        : Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          if (onAction != null && !isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? Colors.blue : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel ?? 'Configurar',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
