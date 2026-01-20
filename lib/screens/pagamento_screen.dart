import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../main.dart'; 
import '../widgets/custom_app_bar.dart'; 
import '../services/cart_service.dart';
import '../screens/landing_screen.dart'; 

class PagamentoScreen extends StatefulWidget {
  final double valorTotal;
  final String pedidoId; 

  const PagamentoScreen({
    super.key, 
    required this.valorTotal, 
    required this.pedidoId
  });

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  final cart = CartService();
  
  // 1. CONTROLLERS PARA CAPTURA DE DADOS
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _nomeCartaoController = TextEditingController();
  final TextEditingController _numeroCartaoController = TextEditingController();

  // 2. CONFIGURAÇÃO DAS MÁSCARAS
  final maskCpf = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final maskWhatsapp = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
  final maskCartao = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
  final maskValidade = MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r'[0-9]')});
  final maskCvv = MaskTextInputFormatter(mask: '###', filter: {"#": RegExp(r'[0-9]')});

  String metodoPaga = "Cartão"; 
  bool aceitouTermos = false;
  bool cartaoTerceiro = false;
  final double taxaCambio = 5.58;

  @override
  void dispose() {
    _cpfController.dispose();
    _whatsappController.dispose();
    _nomeCartaoController.dispose();
    _numeroCartaoController.dispose();
    super.dispose();
  }

  // 3. FUNÇÃO PRINCIPAL: GRAVAR NO FIREBASE
  Future<void> _processarPagamento() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_cpfController.text.length < 14 || _whatsappController.text.length < 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha CPF e WhatsApp corretamente.")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFABC33E))),
    );

    try {
      // ATUALIZA O PEDIDO EXISTENTE
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId)
          .update({
        'status': 'Pago',
        'metodoPagamento': metodoPaga,
        'cpfCliente': _cpfController.text, 
        'whatsappCliente': _whatsappController.text, 
        'dataConfirmacaoPagamento': FieldValue.serverTimestamp(),
        'valorFinalPago': widget.valorTotal,
      });

      if (mounted) {
        Navigator.pop(context); 
        _mostrarSucesso();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String nomeParaExibir = user?.displayName ?? user?.email?.split('@')[0] ?? "Usuário";
    double valorBrl = widget.valorTotal * taxaCambio;
    const Color verdeBorda = Color(0xFFABC33E); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(      
        userName: nomeParaExibir,
        onLogout: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        cartCount: cart.totalItens, 
        onCartClick: () => _abrirCarrinhoResumo(), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumb(verdeBorda),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: verdeBorda, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAbas(),
                  const SizedBox(height: 25),
                  
                  // CAMPOS DE IDENTIFICAÇÃO (CONECTADOS)
                  Row(
                    children: [
                      Expanded(child: _field("Informe o seu CPF", "000.000.000-00", controller: _cpfController, mask: maskCpf)),
                      const SizedBox(width: 15),
                      Expanded(child: _field("WhatsApp", "(00) 00000-0000", controller: _whatsappController, mask: maskWhatsapp)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Os dados do pedido serão enviados para o e-mail associado ao seu CPF.", style: TextStyle(fontSize: 9, color: Colors.black54)),
                  const SizedBox(height: 20),

                  if (metodoPaga == "Cartão") 
                    _buildConteudoCartao(valorBrl, verdeBorda)
                  else 
                    _buildConteudoPix(valorBrl),

                  const SizedBox(height: 20),
                  _checkboxTermos(verdeBorda),
                  const SizedBox(height: 20),
                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total a pagar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("USD\$ ${widget.valorTotal.toStringAsFixed(2)}", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _botaoFinalizar(verdeBorda),
                  const SizedBox(height: 15),
                  _seloSeguranca(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET DE CAMPO REUTILIZÁVEL (IMPORTANTE: AGORA COM CONTROLLER)
  Widget _field(String l, String h, {TextEditingController? controller, MaskTextInputFormatter? mask}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      SizedBox(
        height: 45,
        child: TextField(
          controller: controller,
          inputFormatters: mask != null ? [mask] : [],
          keyboardType: mask != null ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: h,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    ],
  );

  Widget _buildConteudoCartao(double valorBrl, Color verdeBorda) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(height: 24, width: 24, child: Checkbox(value: cartaoTerceiro, activeColor: verdeBorda, onChanged: (v) => setState(() => cartaoTerceiro = v!))),
            const Text(" Pagamento com cartão de terceiro", style: TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 15),
        _field("Número do cartão", "0000 0000 0000 0000", controller: _numeroCartaoController, mask: maskCartao),
        const SizedBox(height: 12),
        _field("Nome como no cartão", "NOME IMPRESSO", controller: _nomeCartaoController),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 2, child: _field("Validade", "MM/AA", mask: maskValidade)),
            const SizedBox(width: 10),
            Expanded(flex: 1, child: _field("CVV", "000", mask: maskCvv)),
          ],
        ),
        const SizedBox(height: 15),
        _fieldCupom(),
        const SizedBox(height: 15),
        const Text("Parcelamento", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _dropdownParcelas(),
        const SizedBox(height: 15),
        _resumoSimples(valorBrl),
      ],
    );
  }

  Widget _buildConteudoPix(double valorBrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field("Nome Completo", "Digite seu nome"),
        const SizedBox(height: 15),
        _fieldCupom(),
        const SizedBox(height: 15),
        _resumoSimples(valorBrl),
      ],
    );
  }

  Widget _fieldCupom() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Cupom de desconto", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Container(
        height: 45,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFABC33E)), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const Expanded(child: TextField(decoration: InputDecoration(hintText: "CUPOM", border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 10)))),
            TextButton(onPressed: () {}, child: const Text("Aplicar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
      ),
    ],
  );

  Widget _resumoSimples(double brl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Valor convertido", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFFF9FBF2), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("USD\$ ${widget.valorTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Row(children: [const Icon(Icons.flag, size: 14, color: Colors.green), const SizedBox(width: 4), Text("R\$ ${brl.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87))])
          ],
        ),
      ),
    ],
  );

  Widget _dropdownParcelas() => Container(
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(isExpanded: true, value: "1", items: const [DropdownMenuItem(value: "1", child: Text("1x sem juros", style: TextStyle(fontSize: 13)))], onChanged: (v) {}))
  );

  Widget _buildBreadcrumb(Color verde) => Row(children: [GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.home_outlined, size: 18, color: Color(0xFFABC33E))), const Icon(Icons.chevron_right, size: 14, color: Colors.grey), Text("Pagamento", style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500))]);
  
  Widget _buildAbas() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: const Color(0xFFF2F4E8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFABC33E).withOpacity(0.5))),
    child: Row(children: [_payTab("Cartão de crédito", Icons.credit_card, metodoPaga == "Cartão"), _payTab("Pix", Icons.pix, metodoPaga == "Pix")])
  );

  Widget _payTab(String t, IconData i, bool s) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => metodoPaga = t.contains("Pix") ? "Pix" : "Cartão"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: s ? const Color(0xFFABC33E) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 16, color: s ? Colors.white : Colors.black54), const SizedBox(width: 8), Text(t, style: TextStyle(color: s ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13))])
      )
    )
  );

  Widget _checkboxTermos(Color c) => Row(children: [SizedBox(height: 24, width: 24, child: Checkbox(value: aceitouTermos, activeColor: c, onChanged: (v) => setState(() => aceitouTermos = v!))), const Expanded(child: Text(" Li e concordo com os Termos de Uso.", style: TextStyle(fontSize: 11, decoration: TextDecoration.underline)))]);
  
  Widget _botaoFinalizar(Color c) => SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: c, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0), onPressed: aceitouTermos ? _processarPagamento : null, child: Text(metodoPaga == "Pix" ? "GERAR QR CODE PIX" : "REALIZAR PAGAMENTO", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14))));
  
  Widget _seloSeguranca() => const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.security, size: 14, color: Colors.grey), SizedBox(width: 5), Text("Pagamento processado em ambiente seguro", style: TextStyle(fontSize: 10, color: Colors.grey))]);

  void _abrirCarrinhoResumo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Resumo", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
            Expanded(child: ListView.builder(itemCount: cart.itens.length, itemBuilder: (c, i) => ListTile(title: Text(cart.itens[i].plano), trailing: Text("USD\$ ${cart.itens[i].precoFinalCalculado}")))),
            const Divider(),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), onPressed: () => Navigator.pop(context), child: const Text("VOLTAR", style: TextStyle(color: Colors.white))))
          ],
        ),
      ),
    );
  }

void _mostrarSucesso() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      content: const Text("Pagamento realizado com sucesso!", textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () {
            // ESTA É A FORMA MAIS SEGURA:
            // Remove todas as telas da memória e volta para a primeira tela definida no seu main.dart
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text("VOLTAR AO INÍCIO"),
        )
      ],
    ),
  );
}
}