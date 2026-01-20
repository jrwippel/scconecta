import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../main.dart'; 
import 'pagamento_screen.dart'; 
import '../widgets/custom_app_bar.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/cart_service.dart';


class SelecaoPlanoScreen extends StatefulWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const SelecaoPlanoScreen({super.key, this.dataInicio, this.dataFim});

  @override
  State<SelecaoPlanoScreen> createState() => _SelecaoPlanoScreenState();
}

class _SelecaoPlanoScreenState extends State<SelecaoPlanoScreen> {
  final cart = CartService();
  String planoAtivo = "América";
  bool mostrarVantagens = true;
  double precoBase = 29.0;
  bool suporteEsim = true; 
  bool retirarAgencia = false;
  bool aparelhoCompativelEsim = false;
  String? unidadeSelecionada;
  final TextEditingController _cepController = TextEditingController();

  final List<String> unidadesAgencia = [
    "SC Câmbio - Rua Nereu Ramos, 165 - Sala 904 - Centro - Blumenau/SC",
    "SC Câmbio - Avenida Otto Renaux, 445 - Sala 23 - São Luiz - Brusque/SC",
    "Intercultural - Rua Koesa, 298 - Sala 702 - Kobrasol - São José/SC",
    "Flytour - Rua Curt Hering, 235 - sala 02 - Centro - Blumenau/SC",
    "Bittencourt Espíndola Viagens & Turismo - Florianópolis/SC"
  ];

  @override
  void initState() {
    super.initState();
    _verificarSuporteEsim();
    cart.tempEsim = 0;
    cart.tempChip = 0;
  }

 Future<void> _finalizarPedidoNoFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator(color: verdePrincipal)),
  );

  try {
    List<Map<String, dynamic>> itensData = cart.itens.map((item) => {
      'plano': item.plano,
      'tipo': item.tipo,
      'datas': item.datas,
      'quantidade': item.quantidade,
      'precoUsd': item.precoFinalCalculado,
      'totalDias': item.totalDias,
    }).toList();

    final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    String nomeUsuario = userDoc.data()?['nome'] ?? user.displayName ?? "Usuário Desconhecido";

    // 1. Guardamos a referência do documento criado
    DocumentReference docRef = await FirebaseFirestore.instance.collection('pedidos').add({
      'userId': user.uid,
      'userEmail': user.email,
      'userName': nomeUsuario,
      'dataPedido': FieldValue.serverTimestamp(),
      'itens': itensData,
      'totalGeralUsd': cart.totalGeralUsd,
      'status': 'Pendente',
    });

    if (mounted) {
      Navigator.pop(context); 
      double valorParaPagar = cart.totalGeralUsd; 
      
      // Capturamos o ID gerado pelo Firebase
      String idDoPedidoCriado = docRef.id;

      setState(() {
        cart.itens.clear(); 
      });

      // 2. Enviamos o ID para a tela de pagamento
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (c) => PagamentoScreen(
          valorTotal: valorParaPagar, 
          pedidoId: idDoPedidoCriado, // Novo parâmetro
        ))
      );
    }
  } catch (e) {
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
  }
}

  Future<void> _verificarSuporteEsim() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    bool compativel = true;
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (int.parse(androidInfo.version.release) < 10) compativel = false;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (iosInfo.utsname.machine.contains("iPhone8") || 
            iosInfo.utsname.machine.contains("iPhone9") || 
            iosInfo.utsname.machine.contains("iPhone10")) {
          compativel = false;
        }
      }
    } catch (e) { compativel = true; }
    setState(() => suporteEsim = compativel);
  }

  String get textoPeriodo {
    if (widget.dataInicio != null && widget.dataFim != null) {
      final df = DateFormat("dd/MM/yyyy");
      return "${df.format(widget.dataInicio!)} - ${df.format(widget.dataFim!)}";
    }
    return "Datas não selecionadas";
  }

  int get totalDiasViagem {
    if (widget.dataInicio != null && widget.dataFim != null) {
      return widget.dataFim!.difference(widget.dataInicio!).inDays + 1;
    }
    return 1;
  }

  double calcularValorTotalPlano() {
    int dias = totalDiasViagem;
    double valor = (planoAtivo == "América") ? 29.0 : 35.0;
    if (dias > 5) {
      double diariaExtra = (planoAtivo == "América") ? 2.45 : 3.00;
      valor += (dias - 5) * diariaExtra;
    }
    return valor;
  }

  void _mudarPlano(String plano) {
    setState(() {
      planoAtivo = plano;
      precoBase = (plano == "América") ? 29.0 : 35.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA IGUAL À LANDING PAGE ---
    final User? user = FirebaseAuth.instance.currentUser;
    final String nomeParaExibir = user?.displayName ?? user?.email?.split('@')[0] ?? "Usuário";
  // -----------------------------------



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        userName: nomeParaExibir, 
        onLogout: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        cartCount: cart.totalItens, 
        onCartClick: () => _abrirCarrinho(), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumb(),
            const SizedBox(height: 15),
            _buildHeader(),
            const SizedBox(height: 12),
            _buildTabButtons(),
            const SizedBox(height: 15),
            if (mostrarVantagens) _buildConteudoVantagens() else _buildConteudoEspecificacoes(),
            const SizedBox(height: 20),
            _buildCardConfiguracaoCompleto(),
          ],
        ),
      ),
      bottomNavigationBar: _buildRodapeResumo(), 
    );
  }

  Widget _buildBreadcrumb() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              Icon(Icons.home_outlined, size: 18, color: verdePrincipal),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text("Escolha o seu plano", style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF2F4E8), borderRadius: BorderRadius.circular(5)),
          child: Text(textoPeriodo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: verdePrincipal)),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "eSIMs e Chips com dados e voz ilimitados", 
                style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "A partir de", 
              style: GoogleFonts.montserrat(
                fontSize: 10, 
                color: Colors.black45, 
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5
              )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  "USD\$ ", 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: verdePrincipal)
                ),
                Text(
                  precoBase.toStringAsFixed(0), 
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w800, 
                    fontSize: 26, 
                    color: Colors.black,
                    height: 1
                  )
                ),
                const Text(
                  ",00", 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        _tabButton("Vantagens", mostrarVantagens, () => setState(() => mostrarVantagens = true)),
        const SizedBox(width: 10),
        _tabButton("Especificações", !mostrarVantagens, () => setState(() => mostrarVantagens = false)),
      ],
    );
  }

  Widget _buildCardConfiguracaoCompleto() {
    double valorAtualDestaSelecao = calcularValorTotalPlano();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: verdePrincipal),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Escolha o Plano para sua viagem", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              _planSelectButton("Plano América", planoAtivo == "América"),
              const SizedBox(width: 10),
              _planSelectButton("Plano Mundo", planoAtivo == "Mundo"),
            ],
          ),
          const SizedBox(height: 15),
          // MODIFICAÇÃO: Chamada dos seletores com parâmetros ajustados
          _buildCounterRow("eSIM", Icons.qr_code_2, cart.tempEsim, (v) => setState(() => cart.tempEsim = v), hasInfo: true, bloqueado: !suporteEsim),
          const SizedBox(height: 12),
          _buildCounterRow("Chip", Icons.sim_card_outlined, cart.tempChip, (v) => setState(() => cart.tempChip = v), hasWarning: true),
          
          if (cart.tempChip > 0) ...[
            const SizedBox(height: 20),
            const Text("Prazo de entrega do Chip", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!retirarAgencia) 
              TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Informe o CEP",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: _cepController.text.length >= 8 ? const Icon(Icons.check_circle, color: verdePrincipal) : null,
                ),
                onChanged: (v) => setState(() {}),
              )
            else
              _buildDropdownUnidades(),
            Row(
              children: [
                Checkbox(value: retirarAgencia, activeColor: verdePrincipal, onChanged: (v) => setState(() {
                  retirarAgencia = v ?? false;
                  if (!retirarAgencia) unidadeSelecionada = null;
                })),
                const Text("Retirar em uma agência", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: aparelhoCompativelEsim, 
                activeColor: verdePrincipal, 
                onChanged: suporteEsim ? (v) => setState(() => aparelhoCompativelEsim = v ?? false) : null
              ),
              const Expanded(child: Text("O meu aparelho é compatível com eSIM", style: TextStyle(fontSize: 11, decoration: TextDecoration.underline))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total desta seleção", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("USD\$ ${((cart.tempEsim + cart.tempChip) * valorAtualDestaSelecao).toStringAsFixed(2)}", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 18, color: verdePrincipal)),
            ],
          ),
          const SizedBox(height: 20),
          _buildBuyButton(),
        ],
      ),
    );
  }

  // --- MÉTODO COUNTER ROW AJUSTADO PARA IGUALAR ALTURAS E EVITAR QUEBRA ---
  Widget _buildCounterRow(String label, IconData icon, int value, Function(int) onChanged, {bool hasInfo = false, bool hasWarning = false, bool bloqueado = false}) {
    return Container(
      height: 55, // Altura fixa para garantir que ambos sejam iguais
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4E8), 
        borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 13)),
              if (bloqueado) 
                const Text("Hardware não detectado", style: TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          if (hasInfo) 
            IconButton(
              icon: Icon(Icons.info_outline, size: 16, color: bloqueado ? Colors.orange : verdePrincipal), 
              onPressed: () => _mostrarAvisoEsim(context, bloqueado),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          
          // Ajuste do texto de aviso para não quebrar a linha
          if (hasWarning) 
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "⚠️ Envio correios", 
                style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.w500),
                maxLines: 1,
              ),
            ),
          
          const Spacer(),
          
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(5), 
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: Row(
              children: [
                _countBtn("-", () => value > 0 ? onChanged(value - 1) : null),
                Container(
                  width: 30, 
                  alignment: Alignment.center, 
                  child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold))
                ),
                _countBtn("+", () => onChanged(value + 1)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _countBtn(String char, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30, 
        alignment: Alignment.center, 
        child: Text(char, style: TextStyle(color: onTap == null ? Colors.grey : verdePrincipal, fontSize: 18, fontWeight: FontWeight.bold))
      ),
    );
  }

  // --- RESTO DOS MÉTODOS (IGUAIS) ---
  Widget _buildRodapeResumo() {
    if (cart.itens.isEmpty) return const SizedBox.shrink();
    double taxaCambio = 5.579056; 
    double totalUsd = cart.totalGeralUsd;
    List<int> listaDias = cart.itens.map((i) => i.totalDias).toSet().toList();
    String diasFormatados = listaDias.join(" | ");
    int totalEsim = cart.itens.where((i) => i.tipo == "eSIM").fold(0, (sum, i) => sum + i.quantidade);
    int totalChip = cart.itens.where((i) => i.tipo == "Chip").fold(0, (sum, i) => sum + i.quantidade);

    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$diasFormatados dia(s) | $totalEsim eSIM | $totalChip Chip",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                Text("R\$ ${(totalUsd * taxaCambio).toStringAsFixed(2)} BRL",
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _abrirCarrinho(),
            style: ElevatedButton.styleFrom(
              backgroundColor: verdePrincipal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            ),
            child: const Text("Finalizar compra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _abrirCarrinho() {
    if (cart.itens.isEmpty) return;
    double taxaCambio = 5.579056; 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          double totalUsd = cart.totalGeralUsd;
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Carrinho", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close, color: verdePrincipal), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.itens.length,
                    itemBuilder: (context, index) {
                      final item = cart.itens[index];
                      double precoMedioDia = item.precoFinalCalculado / item.totalDias;
                      return _buildItemCarrinho(
                        titulo: "Plano ${item.plano}",
                        tipo: item.tipo,
                        data: item.datas,
                        quantidade: item.quantidade,
                        precoDia: precoMedioDia,
                        icon: item.tipo == "eSIM" ? Icons.qr_code_2 : Icons.sim_card_outlined,
                        onDelete: () {
                          setState(() => cart.itens.removeAt(index));
                          setModalState(() {});
                          if (cart.itens.isEmpty) Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Geral", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("USD\$ ${totalUsd.toStringAsFixed(2)}", style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.flag, size: 14, color: Colors.green),
                              const SizedBox(width: 5),
                              Text("R\$ ${(totalUsd * taxaCambio).toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () {
                      Navigator.pop(context);
                      //Navigator.push(context, MaterialPageRoute(builder: (c) => PagamentoScreen(valorTotal: totalUsd)));
                      _finalizarPedidoNoFirebase();
                    },
                    child: const Text("Finalizar compra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Continuar comprando", style: TextStyle(color: Colors.black87, decoration: TextDecoration.underline, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCarrinho({required String titulo, required String data, required String tipo, required int quantidade, required double precoDia, required IconData icon, required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9FBF2), borderRadius: BorderRadius.circular(10), border: Border.all(color: verdePrincipal.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 14, color: verdePrincipal),
              const SizedBox(width: 5),
              Text(data, style: const TextStyle(fontSize: 11, color: Colors.black87)),
              const Spacer(),
              Text("USD\$ ${precoDia.toStringAsFixed(2)} por dia", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: verdePrincipal), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFF2F4E8), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Text("Qtd de $tipo", style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.black54), onPressed: onDelete),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text("x$quantidade", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    bool podeComprar = (cart.tempEsim > 0 || cart.tempChip > 0);
    double valorCalculado = calcularValorTotalPlano();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: podeComprar ? verdePrincipal : Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: podeComprar ? () {
          setState(() {
            if (cart.tempEsim > 0) {
              cart.itens.add(CartItem(plano: planoAtivo, tipo: "eSIM", datas: textoPeriodo, quantidade: cart.tempEsim, precoFinalCalculado: valorCalculado, totalDias: totalDiasViagem));
            }
            if (cart.tempChip > 0) {
              cart.itens.add(CartItem(plano: planoAtivo, tipo: "Chip", datas: textoPeriodo, quantidade: cart.tempChip, precoFinalCalculado: valorCalculado, totalDias: totalDiasViagem));
            }
            cart.tempEsim = 0; cart.tempChip = 0;
          });
          _abrirCarrinho();
        } : null,
        child: const Text("Adicionar ao Carrinho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _tabButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? verdePrincipal : const Color(0xFFF2F4E8),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: verdePrincipal, width: 0.5),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _planSelectButton(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _mudarPlano(label.replaceAll("Plano ", "")),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? verdePrincipal : const Color(0xFFF2F4E8), borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
      ),
    );
  }

  Widget _buildDropdownUnidades() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Selecione uma localidade", style: TextStyle(fontSize: 12)),
          value: unidadeSelecionada,
          items: unidadesAgencia.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 10)))).toList(),
          onChanged: (v) => setState(() => unidadeSelecionada = v),
        ),
      ),
    );
  }

  Widget _buildConteudoVantagens() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 5,
      children: [
        _iconInfo(Icons.wifi, "Internet Ilimitada"),
        _iconInfo(Icons.flight_takeoff, "Embarque já conectado"),
        _iconInfo(Icons.phone_in_talk_outlined, "Voz ilimitada*"),
        _iconInfo(Icons.chat_outlined, "Suporte WhatsApp"),
        _iconInfo(Icons.speed, "Alta velocidade"),
        _iconInfo(Icons.public, "+120 países*"),
      ],
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 16, color: verdePrincipal), const SizedBox(width: 6), Expanded(child: Text(text, style: const TextStyle(fontSize: 10)))]);
  }

  Widget _buildConteudoEspecificacoes() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Text("Serviço de voz e dados ilimitados. O roteamento não é permitido por regras das operadoras locais. Cobertura total em redes 4G/5G.",
        style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
    );
  }

  void _mostrarAvisoEsim(BuildContext context, bool possivelmenteIncompativel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sobre o eSIM", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(possivelmenteIncompativel 
          ? "Atenção: Não detectamos suporte a eSIM neste aparelho. Verifique se o seu modelo é compatível antes de prosseguir."
          : "Este aparelho parece ser compatível com eSIM. Certifique-se de que o aparelho não possui bloqueio de operadora.",
          style: const TextStyle(fontSize: 14)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: verdePrincipal)))],
      ),
    );
  }
}