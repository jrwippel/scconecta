import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/esim_api_service.dart';
import '../services/native_esim_service.dart';
import 'esim_setup_wizard_screen.dart';

/// Tela de ativação de eSIM
/// Busca detalhes do eSIM e permite instalação com um clique
class ESimActivationScreen extends StatefulWidget {
  final String activationCode;

  const ESimActivationScreen({
    super.key,
    required this.activationCode,
  });

  @override
  State<ESimActivationScreen> createState() => _ESimActivationScreenState();
}

class _ESimActivationScreenState extends State<ESimActivationScreen> {
  ESimDetails? _esimDetails;
  bool _isLoading = true;
  bool _isInstalling = false;
  String? _errorMessage;
  bool _deviceSupported = true;

  @override
  void initState() {
    super.initState();
    _checkDeviceAndLoadDetails();
  }

  Future<void> _checkDeviceAndLoadDetails() async {
    try {
      // FORÇADO PARA TESTES - sempre considera suportado
      final supported = true; // await NativeESimService.isDeviceSupported();
      
      if (!supported) {
        setState(() {
          _deviceSupported = false;
          _isLoading = false;
        });
        return;
      }

      // Busca detalhes do eSIM
      await _loadESimDetails();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar dispositivo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadESimDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await ESimApiService.getESimDetails(
        widget.activationCode,
      );

      setState(() {
        _esimDetails = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao buscar eSIM: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _installESim() async {
    if (_esimDetails == null) return;

    try {
      setState(() {
        _isInstalling = true;
        _errorMessage = null;
      });

      // 1. Instala o eSIM via código nativo
      // Se for LPA de teste, será simulado automaticamente
      final result = await NativeESimService.installESim(
        _esimDetails!.lpaString,
      );

      if (!result.success) {
        throw Exception(result.errorMessage ?? 'Falha na instalação');
      }

      // 2. Confirma ativação na API
      final deviceInfo = await NativeESimService.getDeviceInfo();
      await ESimApiService.confirmActivation(
        widget.activationCode,
        deviceInfo,
      );

      // 3. Navega para wizard de configuração
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ESimSetupWizardScreen(
              activationCode: widget.activationCode,
              planName: _esimDetails!.plan.name,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro na instalação: $e';
        _isInstalling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ativar eSIM',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_deviceSupported
              ? _buildUnsupportedDevice()
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
    );
  }

  Widget _buildUnsupportedDevice() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Dispositivo não suportado',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Seu dispositivo não suporta eSIM. Você precisa de um aparelho compatível para usar este serviço.',
              style: GoogleFonts.montserrat(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Ops! Algo deu errado',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.montserrat(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loadESimDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8DBB1B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final details = _esimDetails!;

    return SingleChildScrollView(
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
                  Icons.sim_card,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Seu eSIM está pronto!',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Instale agora com um único clique',
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

          // Detalhes do Plano
          _buildInfoCard(
            title: 'Plano',
            icon: Icons.public,
            children: [
              _buildInfoRow('Nome', details.plan.name),
              _buildInfoRow('Dados', details.plan.data),
              _buildInfoRow('Voz', details.plan.voice),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details.plan.countries.map((country) {
                  return Chip(
                    label: Text(
                      country,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF8DBB1B).withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Validade
          _buildInfoCard(
            title: 'Validade',
            icon: Icons.calendar_today,
            children: [
              _buildInfoRow(
                'Início',
                _formatDate(details.validity.startDate),
              ),
              _buildInfoRow(
                'Término',
                _formatDate(details.validity.endDate),
              ),
              _buildInfoRow(
                'Dias restantes',
                '${details.validity.daysRemaining} dias',
                valueColor: const Color(0xFF8DBB1B),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informações Técnicas
          _buildInfoCard(
            title: 'Informações Técnicas',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow('Código', details.activationCode),
              _buildInfoRow('ICCID', details.iccid),
              _buildInfoRow('Status', _getStatusText(details.status)),
            ],
          ),

          const SizedBox(height: 32),

          // Botão de Instalação
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
                          'Instalar eSIM Agora',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Aviso
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
                    'Após a instalação, você será guiado passo a passo para configurar seu eSIM.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8DBB1B)),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending_activation':
        return 'Pendente';
      case 'active':
        return 'Ativo';
      case 'expired':
        return 'Expirado';
      default:
        return status;
    }
  }
}
