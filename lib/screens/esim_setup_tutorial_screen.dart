import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import 'diagnostic_screen.dart';

class ESimSetupTutorialScreen extends StatefulWidget {
  final String? iccid;
  final String? carrierName;

  const ESimSetupTutorialScreen({
    super.key,
    this.iccid,
    this.carrierName,
  });

  @override
  State<ESimSetupTutorialScreen> createState() => _ESimSetupTutorialScreenState();
}

class _ESimSetupTutorialScreenState extends State<ESimSetupTutorialScreen> {
  bool _step1Done = true; // eSIM já instalado
  bool _step2Done = false; // Roaming ativado
  bool _step3Done = false; // Linha pessoal desativada

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.verdeFundo,
      appBar: AppBar(
        backgroundColor: AppColors.verdePrincipal,
        title: Text(
          'Configure seu eSIM',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ícone de sucesso
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.verdePrincipal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sim_card,
                        size: 40,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '🎉 eSIM SCCONECTA Instalado!',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Siga os passos abaixo para configurar corretamente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // Checklist de configuração
              Text(
                'Checklist de Configuração',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              
              // Step 1 - eSIM Instalado
              _buildChecklistItem(
                step: 1,
                title: 'eSIM SCCONECTA Instalado',
                description: 'Seu chip internacional foi instalado com sucesso',
                isDone: _step1Done,
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              
              const SizedBox(height: 12),
              
              // Step 2 - Ativar Roaming
              _buildChecklistItem(
                step: 2,
                title: 'Ative o Roaming do eSIM',
                description: 'Vá em Configurações > Conexões > Redes móveis > SCCONECTA > Ative "Roaming de dados"',
                isDone: _step2Done,
                icon: Icons.public,
                color: Colors.orange,
                actionButton: TextButton.icon(
                  onPressed: () {
                    setState(() => _step2Done = !_step2Done);
                  },
                  icon: Icon(
                    _step2Done ? Icons.check : Icons.settings,
                    size: 18,
                  ),
                  label: Text(_step2Done ? 'Feito' : 'Marcar como feito'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.verdePrincipal,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Step 3 - Desativar linha pessoal
              _buildChecklistItem(
                step: 3,
                title: 'Desative sua Linha Pessoal',
                description: 'Vá em Configurações > Conexões > Gerenciador de SIM > Desative sua linha pessoal',
                isDone: _step3Done,
                icon: Icons.sim_card_alert,
                color: Colors.red,
                actionButton: TextButton.icon(
                  onPressed: () {
                    setState(() => _step3Done = !_step3Done);
                  },
                  icon: Icon(
                    _step3Done ? Icons.check : Icons.settings,
                    size: 18,
                  ),
                  label: Text(_step3Done ? 'Feito' : 'Marcar como feito'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.verdePrincipal,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Botão de verificação
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DiagnosticScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user, color: Colors.white),
                  label: Text(
                    'Verificar Configuração',
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
              
              const SizedBox(height: 15),
              
              // Botão secundário
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
              
              const SizedBox(height: 20),
              
              // Aviso importante
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

  Widget _buildChecklistItem({
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
                  const SizedBox(height: 8),
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
