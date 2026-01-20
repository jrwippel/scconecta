import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para o nome dinâmico
import '../services/currency_service.dart'; 

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName; // Transformado em opcional
  final VoidCallback onLogout;
  final VoidCallback? onCartClick;
  final int cartCount;
  
  final CurrencyService _currencyService = CurrencyService();

  CustomAppBar({
    super.key,
    this.userName, // Opcional agora
    required this.onLogout,
    this.onCartClick,
    this.cartCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    const Color verdeOliva = Color(0xFFABC33E);

    // Lógica para pegar o nome caso não tenha sido passado via parâmetro
    final User? user = FirebaseAuth.instance.currentUser;
    final String nomeParaExibir = userName ?? user?.displayName ?? user?.email?.split('@')[0] ?? "Viajante";

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
              const Text("Olá, ", style: TextStyle(color: Colors.black54, fontSize: 11)),
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
              String valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');
              return Row(
                children: [
                  Text("USD 1 | R\$ $valorFormatado", 
                    style: const TextStyle(color: verdeOliva, fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.info_outline, size: 12, color: verdeOliva),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        const VerticalDivider(indent: 15, endIndent: 15, width: 10, color: Colors.black12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: SizedBox(
            width: 55,
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeOliva,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: const Text("Sair", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ),
        GestureDetector(
          onTap: onCartClick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Badge(
              backgroundColor: Colors.red,
              label: Text('$cartCount', style: const TextStyle(fontSize: 9, color: Colors.white)),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined, color: verdeOliva, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}