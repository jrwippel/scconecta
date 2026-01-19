import 'package:flutter/material.dart';
import '../services/currency_service.dart'; 

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onLogout;
  final VoidCallback? onCartClick;
  final int cartCount;
  
  // Instanciamos o serviço aqui
  final CurrencyService _currencyService = CurrencyService();

  CustomAppBar({
    super.key,
    required this.userName,
    required this.onLogout,
    this.onCartClick,
    this.cartCount = 0,
  });

  // Aumentamos um pouco a altura para acomodar as duas linhas com conforto
  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    const Color verdeOliva = Color(0xFFABC33E);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 65, // Alinhado com o preferredSize
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- LINHA 1: NOME DO USUÁRIO ---
          Row(
            children: [
              const Text("Olá, ", style: TextStyle(color: Colors.black54, fontSize: 11)),
              Expanded(
                child: Text(
                  userName, 
                  style: const TextStyle(
                    color: Colors.black, 
                    fontSize: 13, 
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Corta o nome se for muito longo
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 2),

          // --- LINHA 2: COTAÇÃO DINÂMICA (Abaixo do nome) ---
          FutureBuilder<double>(
            future: _currencyService.fetchDollarRate(),
            builder: (context, snapshot) {
              // Se snapshot.hasData for falso (carregando) ou o valor for 0.0, mostra 0,00
              double valor = (snapshot.hasData) ? snapshot.data! : 0.0;
              String valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');

              return Row(
                children: [
                  Text(
                    "USD 1 | R\$ $valorFormatado", 
                    style: const TextStyle(
                      color: verdeOliva, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.info_outline, size: 12, color: verdeOliva),
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        const VerticalDivider(
          indent: 15, 
          endIndent: 15, 
          width: 10, 
          color: Colors.black12
        ),

        // --- BOTÃO SAIR ---
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
              child: const Text(
                "Sair", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)
              ),
            ),
          ),
        ),

        // --- CARRINHO ---
        GestureDetector(
          onTap: onCartClick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Badge(
              backgroundColor: Colors.red,
              label: Text(
                '$cartCount', 
                style: const TextStyle(fontSize: 9, color: Colors.white)
              ),
              isLabelVisible: cartCount > 0,
              child: const Icon(
                Icons.shopping_cart_outlined, 
                color: verdeOliva, 
                size: 22
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}