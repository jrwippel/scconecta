import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pagamento_screen.dart';
import '../screens/login_screen.dart';

class MeusPedidosScreen extends StatelessWidget {
  const MeusPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MONITOR DE SESSÃO: Se deslogar enquanto estiver nesta tela, ela fecha sozinha.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // Se NÃO houver usuário, redireciona IMEDIATAMENTE para o Login
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
          return const Scaffold(body: Center(child: Text("Redirecionando...")));
        }

        // Se houver usuário, renderiza a tela normal
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text("Meus Pedidos", 
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: StreamBuilder<QuerySnapshot>(
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
                      Text("Você ainda não tem pedidos.", style: GoogleFonts.montserrat(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pedidos.length,
                itemBuilder: (context, index) => _buildCardPedido(context, pedidos[index]),
              );
            },
          ),
        );
      },
    );
  }

  // --- MÉTODOS AUXILIARES (IGUAIS AOS ANTERIORES) ---

  Widget _buildCardPedido(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isPago = data['status'] == 'Pago';
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
        color: Colors.white, borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ExpansionTile(
        title: Text("Pedido #${doc.id.substring(0, 5).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Data: $dataFormatada - USD\$ ${data['totalGeralUsd']}", style: const TextStyle(fontSize: 12)),
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
                if (!isPago) _botaoPagar(context, data, doc.id)
                else ...[
                  if (temEsim) _botaoConfigurarEsim(context, data),
                  if (temChip) _infoRastreioChip(data),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String? status) {
    bool isPago = status == 'Pago';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isPago ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status ?? 'Pendente', style: TextStyle(color: isPago ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _itemLinha(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("${item['quantidade']}x ${item['plano']} (${item['tipo']})", style: const TextStyle(fontSize: 13))),
          Text("USD\$ ${item['precoUsd']}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _botaoPagar(BuildContext context, Map<String, dynamic> data, String id) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFABC33E)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PagamentoScreen(valorTotal: (data['totalGeralUsd'] as num).toDouble(), pedidoId: id))),
        child: const Text("CONCLUIR PAGAMENTO", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _botaoConfigurarEsim(BuildContext context, Map<String, dynamic> pedido) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.qr_code_scanner, size: 18),
      label: const Text("CONFIGURAR MEU eSIM"),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      onPressed: () => _mostrarModalEsim(context, pedido),
    );
  }

  Widget _infoRastreioChip(Map<String, dynamic> pedido) {
    String rastreio = pedido['codigo_rastreio'] ?? "Aguardando postagem...";
    return Text("RASTREIO: $rastreio", style: const TextStyle(fontWeight: FontWeight.bold));
  }

  void _mostrarModalEsim(BuildContext context, Map<String, dynamic> pedido) {
    // ... (mesmo código do modal de cópia anterior)
  }
}