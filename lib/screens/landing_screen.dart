import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'selecao_plano_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class LandingPageScreen extends StatefulWidget {
  const LandingPageScreen({super.key});

  @override
  State<LandingPageScreen> createState() => _LandingPageScreenState();
}

class _LandingPageScreenState extends State<LandingPageScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showCalendar = false;
  
  // Carrossel de planos
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 3; // 3 planos
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final User? user = FirebaseAuth.instance.currentUser;
    final String nomeParaExibir = user?.displayName ?? user?.email?.split('@')[0] ?? localizations?.translate('user') ?? "Usuário";

    String textoData = "Data inicial — Data final";
    if (_rangeStart != null && _rangeEnd != null) {
      final df = DateFormat("EEE, d 'de' MMM", 'pt_BR');
      textoData = "${df.format(_rangeStart!)} — ${df.format(_rangeEnd!)}";
    }

    return Scaffold(
      appBar: CustomAppBar(
        userName: nomeParaExibir,
        onLogout: () async {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        actions: [
          // Botão MVP Demo
          IconButton(
            icon: const Icon(Icons.science, color: Color(0xFFABC33E)),
            tooltip: 'MVP Demo',
            onPressed: () {
              Navigator.pushNamed(context, '/mvp-demo');
            },
          ),
        ],
      ),      
      backgroundColor: AppColors.verdeFundo, 
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título atualizado conforme imagem
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 20, 
                          fontWeight: FontWeight.w800, 
                          color: Colors.black, 
                          height: 1.3
                        ),
                        children: const [
                          TextSpan(text: "Saia do seu país com internet ativa e seu celular configurado.\n"),
                          TextSpan(
                            text: "Internet e voz ilimitada em mais de 120 países", 
                            style: TextStyle(color: AppColors.verdePrincipal)
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subtítulo
                    Text(
                      "Tenha conexão estável com 4G ou 5G desde o embarque. Ideal para turismo, intercâmbio ou viagens a trabalho, com suporte em português.",
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Campo de data
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_month, color: AppColors.verdePrincipal),
                            title: Text(textoData, style: const TextStyle(fontSize: 15)),
                            trailing: _rangeStart != null 
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => setState(() {
                                    _rangeStart = null;
                                    _rangeEnd = null;
                                  }),
                                )
                              : null,
                            onTap: () => setState(() => _showCalendar = !_showCalendar),
                          ),
                          if (_showCalendar) 
                            TableCalendar(
                              locale: 'pt_BR',
                              firstDay: DateTime.now(),
                              lastDay: DateTime.now().add(const Duration(days: 365)),
                              focusedDay: _focusedDay,
                              rangeSelectionMode: RangeSelectionMode.enforced,
                              rangeStartDay: _rangeStart,
                              rangeEndDay: _rangeEnd,
                              
                              enabledDayPredicate: (day) {
                                if (_rangeStart != null && _rangeEnd == null) {
                                  final limiteMinimo = _rangeStart!.add(const Duration(days: 3));
                                  if (day.isAfter(_rangeStart!) && day.isBefore(limiteMinimo.add(const Duration(seconds: 1)))) {
                                    return false;
                                  }
                                }
                                return true;
                              },

                              onRangeSelected: (start, end, focusedDay) {
                                setState(() {
                                  _rangeStart = start;
                                  _rangeEnd = end;
                                  _focusedDay = focusedDay;
                                  if (end != null) {
                                    _showCalendar = false;
                                  }
                                });
                              },
                              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                              calendarStyle: const CalendarStyle(
                                rangeHighlightColor: Color(0xFFF1F8E9),
                                rangeStartDecoration: BoxDecoration(color: AppColors.verdePrincipal, shape: BoxShape.circle),
                                rangeEndDecoration: BoxDecoration(color: AppColors.verdePrincipal, shape: BoxShape.circle),
                                disabledTextStyle: TextStyle(color: Colors.black26),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Botão
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdePrincipal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_rangeStart != null && _rangeEnd != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => SelecaoPlanoScreen(
                                  dataInicio: _rangeStart,
                                  dataFim: _rangeEnd,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Selecione um período de no mínimo 4 dias."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text("Ativar meu chip agora",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Imagem
              Center(
                child: Image.asset(
                  'assets/images/mulher_viagem.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 20),
              Text("Nossos Planos", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              
              // Carrossel de planos
              SizedBox(
                height: 200,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildCardPlano('assets/images/plano-brasil.png', 'Plano Brasil', 'USD\$ 29,00'),
                    _buildCardPlano('assets/images/plano-america.png', 'Plano América', 'USD\$ 29,00'),
                    _buildCardPlano('assets/images/plano-mundo.png', 'Plano Mundo', 'USD\$ 39,00'),
                  ],
                ),
              ),
              
              // Indicadores (pontinhos)
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.verdePrincipal : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),
              
              // Botão Simulação WhatsApp (NOVO - Testa fluxo completo)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.message, color: Colors.white, size: 30),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💬 Simular Link do WhatsApp',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Teste o fluxo completo: Link → Página Web → App',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Simula que o usuário clicou no link do WhatsApp
                          Navigator.pushNamed(
                            context,
                            '/web-redirect',
                            arguments: 'ABC123',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Clicar no Link',
                          style: GoogleFonts.montserrat(
                            color: Colors.green.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPlano(String imagePath, String nome, String preco) {
    return Center(
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(imagePath, height: 120, width: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Text(nome, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center),
            const Text("A partir de", style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text(preco, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.verdePrincipal)),
          ],
        ),
      ),
    );
  }
}