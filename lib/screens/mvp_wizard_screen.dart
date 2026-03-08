import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Wizard de configuração mockado (MVP)
class MVPWizardScreen extends StatefulWidget {
  final String activationCode;

  const MVPWizardScreen({
    super.key,
    required this.activationCode,
  });

  @override
  State<MVPWizardScreen> createState() => _MVPWizardScreenState();
}

class _MVPWizardScreenState extends State<MVPWizardScreen> {
  bool _step1Done = true; // eSIM instalado (auto-completo)
  bool _step2Done = false; // Roaming ativado
  bool _step3Done = false; // Linha desativada

  bool get _allStepsDone => _step1Done && _step2Done && _step3Done;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verdeFundo,
      appBar: AppBar(
        backgroundColor: AppColors.verdePrincipal,
        title: Text(
          'Configurar eSIM',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Banner de demonstração
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '🎭 Demonstração - Clique nos botões para simular',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Header
              if (!_allStepsDone) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.verdePrincipal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 40,
                    color: AppColors.verdePrincipal,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Configure seu eSIM',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Siga os passos abaixo para configurar corretamente',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '🎉 Tudo Pronto!',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Seu eSIM está configurado corretamente. Boa viagem!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 30),

              // Checklist
              _buildStep(
                step: 1,
                title: 'eSIM Instalado',
                description: 'Seu chip internacional foi instalado com sucesso',
                isDone: _step1Done,
                icon: Icons.sim_card,
                color: Colors.green,
              ),

              const SizedBox(height: 15),

              _buildStep(
                step: 2,
                title: 'Ativar Roaming',
                description: 'Ative o roaming de dados do eSIM SCCONECTA',
                isDone: _step2Done,
                icon: Icons.public,
                color: Colors.orange,
                actionButton: !_step2Done
                    ? ElevatedButton(
                        onPressed: () {
                          // Simula abertura de configurações
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎭 Simulando abertura de configurações...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Marca como feito após 2 segundos
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() => _step2Done = true);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrincipal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Configurar Agora',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 15),

              _buildStep(
                step: 3,
                title: 'Desativar Linha Pessoal',
                description: 'Desative sua linha pessoal ao embarcar no avião',
                isDone: _step3Done,
                icon: Icons.sim_card_alert,
                color: Colors.red,
                actionButton: !_step3Done
                    ? ElevatedButton(
                        onPressed: () {
                          // Simula abertura de configurações
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎭 Simulando abertura de configurações...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Marca como feito após 2 segundos
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() => _step3Done = true);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrincipal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Lembrar Depois',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : null,
              ),

              const SizedBox(height: 30),

              // Botão de verificação
              if (_allStepsDone) ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/landing',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: Text(
                      'Voltar ao Início',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrincipal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/landing',
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.verdePrincipal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Fazer Depois',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Aviso
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '⚠️ Importante: Não desative sua linha pessoal antes de chegar ao destino!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildStep({
    required int step,
    required String title,
    required String description,
    required bool isDone,
    required IconData icon,
    required Color color,
    Widget? actionButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_circle : icon,
                  color: isDone ? Colors.green : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passo $step',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: 12),
                  actionButton,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
