import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/currency_service.dart';
import '../screens/meus_pedidos_screen.dart';
import '../screens/diagnostic_screen.dart'; // IMPORTANTE: Importar a nova tela

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final VoidCallback onLogout;
  final VoidCallback? onCartClick;
  final int cartCount;

  final CurrencyService _currencyService = CurrencyService();

  CustomAppBar({
    super.key,
    this.userName,
    required this.onLogout,
    this.onCartClick,
    this.cartCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    const Color verdeOliva = Color(0xFFABC33E);

    final User? user = FirebaseAuth.instance.currentUser;
    final String nomeParaExibir =
        userName ?? user?.displayName ?? user?.email?.split('@')[0] ?? "Viajante";

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 65,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Text("Olá, ",
                  style: TextStyle(color: Colors.black54, fontSize: 11)),
              Expanded(
                child: Text(
                  nomeParaExibir,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FutureBuilder<double>(
            future: _currencyService.fetchDollarRate(),
            builder: (context, snapshot) {
              double valor = (snapshot.hasData) ? snapshot.data! : 0.0;
              String valorFormatado =
                  valor.toStringAsFixed(2).replaceAll('.', ',');
              return Row(
                children: [
                  Text("USD 1 | R\$ $valorFormatado",
                      style: const TextStyle(
                          color: verdeOliva,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.info_outline, size: 12, color: verdeOliva),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onCartClick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: Badge(
              backgroundColor: Colors.red,
              label: Text('$cartCount',
                  style: const TextStyle(fontSize: 9, color: Colors.white)),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined,
                  color: verdeOliva, size: 24),
            ),
          ),
        ),

        // MENU DE 3 PONTINHOS ATUALIZADO
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          padding: EdgeInsets.zero,
          onSelected: (value) {
            if (value == 'pedidos') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeusPedidosScreen()),
              );
            } 
            // NOVA OPÇÃO: DIAGNÓSTICO
            else if (value == 'diagnostico') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DiagnosticScreen()),
              );
            } 
            else if (value == 'sair') {
              onLogout();
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'pedidos',
              child: Row(
                children: [
                  Icon(Icons.assignment_outlined, color: verdeOliva, size: 20),
                  const SizedBox(width: 10),
                  const Text("Meus Pedidos", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            // ITEM DO MENU: DIAGNÓSTICO
            PopupMenuItem(
              value: 'diagnostico',
              child: Row(
                children: [
                  Icon(Icons.checklist_rtl_rounded, color: verdeOliva, size: 20),
                  const SizedBox(width: 10),
                  const Text("Diagnóstico eSIM", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sair',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 10),
                  Text("Sair", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}