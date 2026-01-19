import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart';
import 'selecao_plano_screen.dart';
import '../widgets/custom_app_bar.dart';

class LandingPageScreen extends StatefulWidget {
  const LandingPageScreen({super.key});

  @override
  State<LandingPageScreen> createState() => _LandingPageScreenState();
}

class _LandingPageScreenState extends State<LandingPageScreen> {
  DateTime _focusedDay = DateTime(2026, 2, 1);
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    String textoData = "Data inicial — Data final";
    if (_rangeStart != null && _rangeEnd != null) {
      final df = DateFormat("EEE, d 'de' MMM", 'pt_BR');
      textoData = "${df.format(_rangeStart!)} — ${df.format(_rangeEnd!)}";
    }

    return Scaffold(
      appBar: CustomAppBar(
        userName: "Jackson Ricardo", 
        onLogout: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
      ),
      backgroundColor: verdeFundo,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
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
                        TextSpan(text: "ativado no Brasil", style: TextStyle(color: verdePrincipal)),
                        TextSpan(text: ", com "),
                        TextSpan(text: "internet e voz ilimitada", style: TextStyle(color: verdePrincipal)),
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
                          leading: const Icon(Icons.calendar_month, color: verdePrincipal),
                          title: Text(textoData, style: const TextStyle(fontSize: 15)),
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
                            onRangeSelected: (start, end, focusedDay) {
                              setState(() {
                                _rangeStart = start;
                                _rangeEnd = end;
                                _focusedDay = focusedDay;
                                if (end != null) _showCalendar = false;
                              });
                            },
                            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                            calendarStyle: const CalendarStyle(
                              rangeHighlightColor: Color(0xFFF1F8E9),
                              rangeStartDecoration: BoxDecoration(color: verdePrincipal, shape: BoxShape.circle),
                              rangeEndDecoration: BoxDecoration(color: verdePrincipal, shape: BoxShape.circle),
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
      backgroundColor: verdePrincipal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
    onPressed: () {
      // Verifica se as datas foram selecionadas antes de navegar
      if (_rangeStart != null && _rangeEnd != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => SelecaoPlanoScreen(
              dataInicio: _rangeStart, // Passa a data de início
              dataFim: _rangeEnd,     // Passa a data de fim
            ),
          ),
        );
      } else {
        // Opcional: Alerta caso o usuário não tenha escolhido as datas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, selecione o período da viagem no calendário.")),
        );
      }
    },
    child: const Text(
      "Ativar meu chip agora",
      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
),
                ],
              ),
            ),

            // Imagem Principal da Moça (Centralizada e escala reduzida)
            Center(
              child: Image.asset(
                'assets/images/mulher_viagem.png', //
                height: 160,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            Text("Nossos Planos", 
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),

            const SizedBox(height: 15),

            // --- CARROSSEL COM NOMES E VALORES ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 25),
                  _buildCardPlano(
                    'assets/images/plano-america.png', 
                    'Plano América', 
                    'USD\$ 29,00'
                  ),
                  _buildCardPlano(
                    'assets/images/plano-mundo.png', 
                    'Plano Mundo', 
                    'USD\$ 39,00'
                  ),
                  const SizedBox(width: 25),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Função para criar o card com imagem, nome e valor abaixo
  Widget _buildCardPlano(String imagePath, String nome, String preco) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          // Imagem do Plano
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath, //
              height: 110,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          // Nome do Plano
          Text(
            nome,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          // Valor "A partir de"
          Text(
            "A partir de",
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          Text(
            preco,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w800, 
              fontSize: 15, 
              color: verdePrincipal
            ),
          ),
        ],
      ),
    );
  }
}