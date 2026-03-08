import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'pagamento_screen.dart'; 
import '../widgets/custom_app_bar.dart';
import '../l10n/app_localizations.dart'; 

const Color verdePrincipal = Color(0xFFABC33E);

// --- MODELO DO ITEM DO CARRINHO ---
class CartItem {
  final String plano;
  final String tipo; 
  final String datas;
  final int quantidade;
  final double precoFinalCalculado; 
  final int totalDias;

  CartItem({
    required this.plano,
    required this.tipo,
    required this.datas,
    required this.quantidade,
    required this.precoFinalCalculado,
    required this.totalDias,
  });
}

// --- CLASSE SERVICE (SINGLETON) ---
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> itens = [];
  int tempEsim = 0;
  int tempChip = 0;

  int get totalItens => itens.fold(0, (sum, item) => sum + item.quantidade);
  double get totalGeralUsd => itens.fold(0, (sum, item) => sum + (item.precoFinalCalculado * item.quantidade));
}

class SelecaoPlanoScreen extends StatefulWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const SelecaoPlanoScreen({super.key, this.dataInicio, this.dataFim});

  @override
  State<SelecaoPlanoScreen> createState() => _SelecaoPlanoScreenState();
}

class _SelecaoPlanoScreenState extends State<SelecaoPlanoScreen> {
  static const platform = MethodChannel('com.scconecta.app/roaming');
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

  Future<void> _verificarSuporteEsim() async {
    bool compativel = false;
    try {
      final Map<dynamic, dynamic> supportData = await platform.invokeMethod('checkEsimSupport');
      compativel = supportData['isSupported'] ?? false;
    } catch (e) {
      debugPrint("Erro ao acessar hardware: $e");
      compativel = false; 
    }

    if (mounted) {
      setState(() {
        suporteEsim = compativel;
      });
    }
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
    double valor;
    double diariaExtra;
    
    switch (planoAtivo) {
      case "América":
        valor = 29.0;
        diariaExtra = 2.45;
        break;
      case "Mundo":
        valor = 35.0;
        diariaExtra = 3.00;
        break;
      case "Brasil":
        valor = 29.0;
        diariaExtra = 2.45;
        break;
      default:
        valor = 29.0;
        diariaExtra = 2.45;
    }
    
    if (dias > 5) {
      valor += (dias - 5) * diariaExtra;
    }
    return valor;
  }

  void _mudarPlano(String plano) {
    setState(() {
      planoAtivo = plano;
      switch (plano) {
        case "América":
          precoBase = 29.0;
          break;
        case "Mundo":
          precoBase = 35.0;
          break;
        case "Brasil":
          precoBase = 29.0;
          break;
        default:
          precoBase = 29.0;
      }
    });
  }

  Future<void> _finalizarEPagar() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Acesse sua conta para finalizar a compra.")),
        );
        Navigator.pushNamed(context, '/'); 
      }
      return;
    }

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

      DocumentReference docRef = await FirebaseFirestore.instance.collection('pedidos').add({
        'userId': user.uid,
        'userEmail': user.email,
        'dataPedido': FieldValue.serverTimestamp(),
        'itens': itensData,
        'totalGeralUsd': cart.totalGeralUsd,
        'status': 'Pendente',
      });

      if (mounted) {
        Navigator.pop(context); 
        double valorTotal = cart.totalGeralUsd;
        String idPedido = docRef.id;
        setState(() => cart.itens.clear());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => PagamentoScreen(valorTotal: valorTotal, pedidoId: idPedido),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao gerar pedido: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        userName: "Usuário", 
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

  // --- MÉTODOS DE INTERFACE ---

  Widget _buildBreadcrumb() {
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const Icon(Icons.home_outlined, size: 18, color: verdePrincipal),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(localizations?.translate('plan_breadcrumb') ?? "Escolha o seu plano", style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            localizations?.translate('plan_title') ?? "eSIMs e Chips com dados e voz ilimitados", 
            style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(localizations?.translate('landing_from') ?? "A partir de", style: GoogleFonts.montserrat(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w600)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text("USD\$ ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: verdePrincipal)),
                Text(precoBase.toStringAsFixed(0), style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 26, color: Colors.black, height: 1)),
                const Text(",00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButtons() {
    final localizations = AppLocalizations.of(context);
    return Row(
      children: [
        _tabButton(localizations?.translate('plan_advantages') ?? "Vantagens", mostrarVantagens, () => setState(() => mostrarVantagens = true)),
        const SizedBox(width: 10),
        _tabButton(localizations?.translate('plan_specifications') ?? "Especificações", !mostrarVantagens, () => setState(() => mostrarVantagens = false)),
      ],
    );
  }

  Widget _buildCardConfiguracaoCompleto() {
    final localizations = AppLocalizations.of(context);
    double valorAtualDestaSelecao = calcularValorTotalPlano();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: verdePrincipal), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations?.translate('plan_choose') ?? "Escolha o Plano para sua viagem", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _planSelectButton(localizations?.translate('plan_brazil') ?? "Plano Brasil", planoAtivo == "Brasil")),
              const SizedBox(width: 10),
              Expanded(child: _planSelectButton(localizations?.translate('plan_america') ?? "Plano América", planoAtivo == "América")),
              const SizedBox(width: 10),
              Expanded(child: _planSelectButton(localizations?.translate('plan_world') ?? "Plano Mundo", planoAtivo == "Mundo")),
            ],
          ),
          const SizedBox(height: 15),
          _buildCounterRow(
            localizations?.translate('plan_esim') ?? "eSIM", 
            Icons.qr_code_2, 
            cart.tempEsim, 
            (v) => setState(() => cart.tempEsim = v), 
            hasInfo: true, 
            bloqueado: !suporteEsim,
          ),
          const SizedBox(height: 12),
          _buildCounterRow(
            localizations?.translate('plan_chip') ?? "Chip", 
            Icons.sim_card_outlined, 
            cart.tempChip, 
            (v) => setState(() => cart.tempChip = v), 
            hasWarning: true
          ),
          
          if (cart.tempChip > 0) ...[
            const SizedBox(height: 20),
            Text(localizations?.translate('plan_delivery_time') ?? "Prazo de entrega do Chip", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (!retirarAgencia) 
              TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: localizations?.translate('plan_enter_cep') ?? "Informe o CEP",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (v) => setState(() {}),
              )
            else
              _buildDropdownUnidades(),
            Row(
              children: [
                Checkbox(value: retirarAgencia, activeColor: verdePrincipal, onChanged: (v) => setState(() => retirarAgencia = v ?? false)),
                Text(localizations?.translate('plan_pickup_agency') ?? "Retirar em uma agência", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: aparelhoCompativelEsim, 
                activeColor: verdePrincipal, 
                onChanged: (v) {
                  setState(() => aparelhoCompativelEsim = v ?? false);
                  if (v == true && !suporteEsim) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations?.translate('plan_esim_not_detected') ?? "Atenção: Garanta que o aparelho de quem for usar seja compatível."))
                    );
                  }
                }
              ),
              Expanded(
                child: Text(
                  localizations?.translate('plan_device_compatible') ?? "Confirmo que o aparelho de destino é compatível com eSIM", 
                  style: const TextStyle(fontSize: 11, decoration: TextDecoration.underline)
                )
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizations?.translate('plan_total_selection') ?? "Total desta seleção", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("USD\$ ${((cart.tempEsim + cart.tempChip) * valorAtualDestaSelecao).toStringAsFixed(2)}", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 18, color: verdePrincipal)),
            ],
          ),
          const SizedBox(height: 20),
          _buildBuyButton(),
        ],
      ),
    );
  }

  Widget _buildCounterRow(String label, IconData icon, int value, Function(int) onChanged, {bool hasInfo = false, bool hasWarning = false, bool bloqueado = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9FBF2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (hasInfo)
                      GestureDetector(
                        onTap: () => _mostrarAvisoEsim(context, bloqueado),
                        child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.info_outline, size: 16, color: verdePrincipal)),
                      ),
                  ],
                ),
                if (bloqueado && label == "eSIM")
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 10, color: Colors.orange),
                        SizedBox(width: 4),
                        Text("Celular não possui eSim", style: TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                if (hasWarning && label == "Chip")
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 10, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text("Envio via correios", style: TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
            child: Row(
              children: [
                _countBtn("-", () => value > 0 ? onChanged(value - 1) : null),
                Container(width: 30, alignment: Alignment.center, child: Text("$value", style: const TextStyle(fontWeight: FontWeight.bold))),
                _countBtn("+", () => onChanged(value + 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countBtn(String char, VoidCallback? onTap) {
    return InkWell(onTap: onTap, child: SizedBox(width: 30, child: Center(child: Text(char, style: TextStyle(color: onTap == null ? Colors.grey : verdePrincipal, fontSize: 18, fontWeight: FontWeight.bold)))));
  }

  Widget _buildRodapeResumo() {
    final localizations = AppLocalizations.of(context);
    if (cart.itens.isEmpty) return const SizedBox.shrink();
    double taxaCambio = 5.579056; 
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(localizations?.translate('plan_order_summary') ?? "Resumo do pedido", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text("R\$ ${(cart.totalGeralUsd * taxaCambio).toStringAsFixed(2)} BRL", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _abrirCarrinho(),
            style: ElevatedButton.styleFrom(backgroundColor: verdePrincipal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: Text(localizations?.translate('plan_finish_purchase') ?? "Finalizar compra", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirCarrinho() async {
    if (cart.itens.isEmpty) return;
    
    bool? prosseguir = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context, false)),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.itens.length,
                    itemBuilder: (context, index) {
                      final item = cart.itens[index];
                      return _buildItemCarrinho(
                        titulo: "Plano ${item.plano}",
                        tipo: item.tipo,
                        data: item.datas,
                        quantidade: item.quantidade,
                        onDelete: () {
                          setState(() => cart.itens.removeAt(index));
                          setModalState(() {});
                          if (cart.itens.isEmpty) Navigator.pop(context, false);
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () => Navigator.pop(context, true), 
                    child: const Text("Finalizar compra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );

    if (prosseguir == true) {
      _finalizarEPagar();
    }
  }

  Widget _buildItemCarrinho({required String titulo, required String data, required String tipo, required int quantidade, required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9FBF2), borderRadius: BorderRadius.circular(10), border: Border.all(color: verdePrincipal.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: onDelete),
            ],
          ),
          Text("$tipo | $data", style: const TextStyle(fontSize: 11)),
          Text("x$quantidade itens", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    final localizations = AppLocalizations.of(context);
    bool podeComprar = (cart.tempEsim > 0 || cart.tempChip > 0);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: podeComprar ? verdePrincipal : Colors.grey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
        onPressed: podeComprar ? () {
          setState(() {
            if (cart.tempEsim > 0) {
              cart.itens.add(CartItem(plano: planoAtivo, tipo: "eSIM", datas: textoPeriodo, quantidade: cart.tempEsim, precoFinalCalculado: calcularValorTotalPlano(), totalDias: totalDiasViagem));
            }
            if (cart.tempChip > 0) {
              cart.itens.add(CartItem(plano: planoAtivo, tipo: "Chip", datas: textoPeriodo, quantidade: cart.tempChip, precoFinalCalculado: calcularValorTotalPlano(), totalDias: totalDiasViagem));
            }
            cart.tempEsim = 0; cart.tempChip = 0;
          });
          _abrirCarrinho();
        } : null,
        child: Text(localizations?.translate('plan_add_cart') ?? "Adicionar ao Carrinho", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _tabButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? verdePrincipal : const Color(0xFFF2F4E8), borderRadius: BorderRadius.circular(5), border: Border.all(color: verdePrincipal)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _planSelectButton(String label, bool isSelected, {bool fullWidth = false}) {
    Widget button = GestureDetector(
      onTap: () => _mudarPlano(label.replaceAll("Plano ", "")),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? verdePrincipal : const Color(0xFFF2F4E8), borderRadius: BorderRadius.circular(6)),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
    
    return fullWidth ? button : Expanded(child: button);
  }

  Widget _buildDropdownUnidades() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: unidadeSelecionada,
          items: unidadesAgencia.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 10)))).toList(),
          onChanged: (v) => setState(() => unidadeSelecionada = v),
        ),
      ),
    );
  }

  Widget _buildConteudoVantagens() {
    final localizations = AppLocalizations.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 5,
      children: [
        _iconInfo(Icons.wifi, localizations?.translate('advantage_unlimited_internet') ?? "Internet Ilimitada"),
        _iconInfo(Icons.flight_takeoff, localizations?.translate('advantage_board_connected') ?? "Embarque já conectado"),
        _iconInfo(Icons.phone_in_talk_outlined, localizations?.translate('advantage_unlimited_voice') ?? "Voz ilimitada*"),
        _iconInfo(Icons.chat_outlined, localizations?.translate('advantage_whatsapp_support') ?? "Suporte WhatsApp"),
        _iconInfo(Icons.speed, localizations?.translate('advantage_high_speed') ?? "Alta velocidade"),
        _iconInfo(Icons.public, localizations?.translate('advantage_countries') ?? "+120 países*"),
      ],
    );
  }

  Widget _iconInfo(IconData icon, String text) => Row(children: [Icon(icon, size: 16, color: verdePrincipal), const SizedBox(width: 6), Text(text, style: const TextStyle(fontSize: 10))]);

  Widget _buildConteudoEspecificacoes() {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(10), 
      child: Text(
        localizations?.translate('spec_description') ?? "Voz e dados ilimitados. Cobertura 4G/5G.", 
        style: const TextStyle(fontSize: 13)
      )
    );
  }

  void _mostrarAvisoEsim(BuildContext context, bool bloqueado) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.translate('plan_esim_tech') ?? "Tecnologia eSIM"),
        content: Text(bloqueado 
          ? (localizations?.translate('plan_esim_not_detected') ?? "O sistema não detectou suporte a eSIM neste aparelho. Se estiver comprando para outra pessoa, verifique se o aparelho dela é compatível.")
          : (localizations?.translate('plan_esim_compatible') ?? "Este aparelho é compatível com eSIM.")),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(localizations?.translate('ok') ?? "OK"))],
      ),
    );
  }
}