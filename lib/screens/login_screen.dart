import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/currency_service.dart'; // Importe o seu serviço aqui
import 'landing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instanciamos o serviço aqui dentro do State
  final CurrencyService _currencyService = CurrencyService();

  @override
  Widget build(BuildContext context) {
    const Color verdeOliva = Color(0xFFABC33E);
    const Color cinzaFundoFooter = Color(0xFFF9FBF2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(Icons.link, color: Colors.black, size: 24),
        ),
        titleSpacing: 0,
        title: Text("SC CONECTA",
            style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          // --- COTAÇÃO DINÂMICA COM FUTUREBUILDER ---
          Center(
            child: FutureBuilder<double>(
              future: _currencyService.fetchDollarRate(),
              builder: (context, snapshot) {
                // Se snapshot.hasData for falso (carregando) ou erro, mostra 0,00
                double valor = (snapshot.hasData) ? snapshot.data! : 0.0;
                String valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

                return Row(
                  children: [
                    Text("USD 1 | R\$ $valorFormatado ",
                        style: const TextStyle(color: Colors.black, fontSize: 11)),
                    const Icon(Icons.info_outline, size: 14, color: verdeOliva),
                  ],
                );
              },
            ),
          ),
          // ------------------------------------------
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: VerticalDivider(indent: 20, endIndent: 20, width: 1, color: Colors.grey),
          ),
          const Icon(Icons.shopping_cart_outlined, color: verdeOliva, size: 22),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // --- CARD DE IDENTIFICAÇÃO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text("Identificação", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _buildField("E-MAIL", false),
                    const SizedBox(height: 20),
                    _buildField("SENHA", true, showEsqueceu: true),
                    const SizedBox(height: 30),
                    _buildButton("Continuar", Colors.black, Colors.white, () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const LandingPageScreen()));
                    }),
                    const SizedBox(height: 20),
                    const Text("Não tem cadastro? Cadastre-se",
                        style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 30),
                    const Text("Login com:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 150,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                            Text(" Google", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),

            // --- RODAPÉ (FOOTER) MOBILE ---
            Container(
              color: cinzaFundoFooter,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(60),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.facebook, color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Text("SC CONECTA",
                                style: GoogleFonts.montserrat(color: verdeOliva, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactItem("Comercial", "(47) 99757-2020", "comercial@scconecta.com.br"),
                            const SizedBox(height: 15),
                            _buildContactItem("Suporte", "(19) 98365-0303", "suporte@scconecta.com.br"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 10),
                  const Text("Política de Privacidade | Termos de Uso",
                      style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES (MOVIDOS PARA DENTRO DO STATE) ---

  Widget _buildField(String label, bool isPass, {bool showEsqueceu = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            if (showEsqueceu)
              GestureDetector(
                onTap: () {},
                child: const Text("Esqueceu?",
                    style: TextStyle(fontSize: 11, decoration: TextDecoration.underline, color: Colors.black54)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPass,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color bg, Color fg, VoidCallback tap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: bg, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: tap,
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildContactItem(String label, String fone, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 2),
        Text(fone, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        Text(email, style: const TextStyle(fontSize: 9, color: Colors.black54)),
      ],
    );
  }
}