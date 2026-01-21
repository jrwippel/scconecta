import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para copiar para o teclado
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pagamento_screen.dart'; 

class MeusPedidosScreen extends StatelessWidget {
  const MeusPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Meus Pedidos", 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(child: Text("Faça login para ver seus pedidos."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pedidos')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('dataPedido', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Erro ao carregar pedidos."));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFABC33E)));
                }

                final pedidos = snapshot.data!.docs;

                if (pedidos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("Você ainda não tem pedidos.", 
                          style: GoogleFonts.montserrat(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    var pedido = pedidos[index];
                    return _buildCardPedido(context, pedido);
                  },
                );
              },
            ),
    );
  }

  Widget _buildCardPedido(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isPago = data['status'] == 'Pago';
    
    // Verificação de tipos de itens no pedido
    List itens = data['itens'] ?? [];
    bool temEsim = itens.any((item) => item['tipo'] == 'eSIM');
    bool temChip = itens.any((item) => item['tipo'] == 'Chip');

    String dataFormatada = "";
    if (data['dataPedido'] != null) {
      DateTime dt = (data['dataPedido'] as Timestamp).toDate();
      dataFormatada = "${dt.day}/${dt.month}/${dt.year}";
    }

    return Container(      
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text("Pedido #${doc.id.substring(0, 5).toUpperCase()}", 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Data: $dataFormatada - USD\$ ${data['totalGeralUsd']}", 
          style: const TextStyle(fontSize: 12)),
        trailing: _statusBadge(data['status']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                ...itens.map((item) => _itemLinha(item)).toList(),
                const Divider(),
                const SizedBox(height: 10),
                
                if (!isPago)
                  _botaoPagar(context, data, doc.id)
                else ...[
                  // Ações para Pedidos Pagos
                  if (temEsim) _botaoConfigurarEsim(context, data),
                  if (temChip) _infoRastreioChip(data),
                  if (!temEsim && !temChip)
                    const Text("Processando seu pedido...", 
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _statusBadge(String? status) {
    bool isPago = status == 'Pago';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPago ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status ?? 'Pendente',
        style: TextStyle(
          color: isPago ? Colors.green : Colors.orange, 
          fontWeight: FontWeight.bold, 
          fontSize: 11
        ),
      ),
    );
  }

  Widget _itemLinha(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text("${item['quantidade']}x ${item['plano']} (${item['tipo']})", 
              style: const TextStyle(fontSize: 13)),
          ),
          Text("USD\$ ${item['precoUsd']}", 
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _botaoPagar(BuildContext context, Map<String, dynamic> data, String id) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFABC33E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => PagamentoScreen(
              valorTotal: (data['totalGeralUsd'] as num).toDouble(), 
              pedidoId: id
            )
          )
        ),
        child: const Text("CONCLUIR PAGAMENTO", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _botaoConfigurarEsim(BuildContext context, Map<String, dynamic> pedido) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner, size: 18),
          label: const Text("CONFIGURAR MEU eSIM"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, 
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _mostrarModalEsim(context, pedido),
        ),
      ),
    );
  }

  Widget _infoRastreioChip(Map<String, dynamic> pedido) {
    String rastreio = pedido['codigo_rastreio'] ?? "Aguardando postagem...";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100], 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 14, color: Colors.grey),
              SizedBox(width: 5),
              Text("RASTREIO CHIP FÍSICO", 
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 5),
          Text(rastreio, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _mostrarModalEsim(BuildContext context, Map<String, dynamic> pedido) {
    String smdp = pedido['esim_sm_dp_address'] ?? "Smdp.fornecedor.com";
    String code = pedido['esim_activation_code'] ?? "Aguardando liberação...";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            const Text("Instalação do eSIM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Copie os dados abaixo para configurar manualmente em Ajustes > Celular do seu aparelho:",
              style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 25),
            _campoCopia(context, "Endereço SM-DP+", smdp),
            const SizedBox(height: 15),
            _campoCopia(context, "Código de Ativação", code),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _campoCopia(BuildContext context, String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!)
          ),
          child: Row(
            children: [
              Expanded(child: Text(valor, style: const TextStyle(fontFamily: 'monospace', fontSize: 13))),
              IconButton(
                icon: const Icon(Icons.copy, size: 20, color: Colors.blueAccent),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: valor));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$label copiado!"), duration: const Duration(seconds: 1))
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}