import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pagamento_screen.dart'; // Import para reabrir o pagamento

class MeusPedidosScreen extends StatelessWidget {
  const MeusPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Meus Pedidos", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(child: Text("Faça login para ver seus pedidos."))
          : StreamBuilder<QuerySnapshot>(
              // Busca apenas os pedidos do usuário logado, ordenando pelos mais recentes
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
    
    // Formatação básica da data (se existir)
    String dataFormatada = "";
    if (data['dataPedido'] != null) {
      DateTime dt = (data['dataPedido'] as Timestamp).toDate();
      dataFormatada = "${dt.day}/${dt.month}/${dt.year}";
    }

    return Container(      
      margin: const EdgeInsets.only(bottom: 16), // Forma correta
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ExpansionTile(
        title: Text("Pedido #${doc.id.substring(0, 5)}...", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Data: $dataFormatada - USD\$ ${data['totalGeralUsd']}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPago ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            data['status'] ?? 'Pendente',
            style: TextStyle(color: isPago ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                // Lista os itens do pedido
                ...((data['itens'] as List).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item['quantidade']}x Plano ${item['plano']} (${item['tipo']})"),
                        Text("USD\$ ${item['precoUsd']}"),
                      ],
                    ),
                  );
                }).toList()),
                const Divider(),
                const SizedBox(height: 10),
                if (!isPago)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFABC33E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        // REABRE A TELA DE PAGAMENTO COM OS DADOS DO PEDIDO EXISTENTE
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PagamentoScreen(
                              valorTotal: (data['totalGeralUsd'] as num).toDouble(),
                              pedidoId: doc.id,
                            ),
                          ),
                        );
                      },
                      child: const Text("CONCLUIR PAGAMENTO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text("Pedido finalizado com sucesso.", style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}