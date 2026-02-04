import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'selecao_plano_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String nomeParaExibir = user?.displayName ?? user?.email?.split('@')[0] ?? "Usuário";

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
      ),      
      backgroundColor: AppColors.verdeFundo, 
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 24, 
                          fontWeight: FontWeight.w800, 
                          color: Colors.black, 
                          height: 1.2
                        ),
                        children: const [
                          TextSpan(text: "Seu chip internacional\n"),
                          TextSpan(text: "ativado no Brasil", style: TextStyle(color: AppColors.verdePrincipal)),
                          TextSpan(text: ", com "),
                          TextSpan(text: "internet e voz ilimitada", style: TextStyle(color: AppColors.verdePrincipal)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    
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
                              
                              // BLOQUEIO VISUAL: Desabilita dias que não cumprem o requisito de 4 dias
                              enabledDayPredicate: (day) {
                                if (_rangeStart != null && _rangeEnd == null) {
                                  // Se selecionou o início, bloqueia os 3 dias seguintes (pois o mínimo é o 4º dia)
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

                                  // Se o usuário selecionou o fim, fechamos o calendário
                                  // A regra do enabledDayPredicate já garante que ele só clique em datas válidas
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
                               disabledTextStyle: TextStyle(color: Colors.black26), // Troque black24 por black26o dos dias desabilitados
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
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
              Center(
                child: Image.asset(
                  'assets/images/mulher_viagem.png',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text("Nossos Planos", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 25),
                    _buildCardPlano('assets/images/plano-america.png', 'Plano América', 'USD\$ 29,00'),
                    _buildCardPlano('assets/images/plano-mundo.png', 'Plano Mundo', 'USD\$ 39,00'),
                    const SizedBox(width: 25),
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
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(imagePath, height: 110, width: 160, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          Text(nome, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14), textAlign: TextAlign.center),
          Text("A partir de", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          Text(preco, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.verdePrincipal)),
        ],
      ),
    );
  }
}