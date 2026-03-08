import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import '../services/language_service.dart';
import '../screens/meus_pedidos_screen.dart';
import '../screens/diagnostic_screen.dart'; 
import '../screens/login_screen.dart';
import '../l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final VoidCallback onLogout;
  final VoidCallback? onCartClick;
  final int cartCount;
  final List<Widget>? actions;

  final CurrencyService _currencyService = CurrencyService();

  CustomAppBar({
    super.key,
    this.userName,
    required this.onLogout,
    this.onCartClick,
    this.cartCount = 0,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  void _showLanguageDialog(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations?.translate('select_language') ?? 'Selecionar Idioma'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, languageService, 'pt', '🇧🇷 Português'),
              _buildLanguageOption(context, languageService, 'en', '🇺🇸 English'),
              _buildLanguageOption(context, languageService, 'es', '🇪🇸 Español'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, LanguageService service, String code, String label) {
    final isSelected = service.currentLocale.languageCode == code;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFABC33E)) : null,
      onTap: () {
        service.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeOliva = Color(0xFFABC33E);
    final localizations = AppLocalizations.of(context);
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final User? user = snapshot.data;
        
        final String nomeParaExibir = user != null 
            ? (userName ?? user.displayName ?? user.email?.split('@')[0] ?? localizations?.translate('user') ?? "Usuário")
            : localizations?.translate('visitor') ?? "Visitante";

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
                  Text("${localizations?.translate('hello') ?? 'Olá,'} ", style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  Expanded(
                    child: Text(
                      nomeParaExibir,
                      style: const TextStyle(
                        color: Colors.black, 
                        fontSize: 13, 
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              FutureBuilder<double>(
                future: _currencyService.fetchDollarRate(),
                builder: (context, snapshotRate) {
                  double valor = (snapshotRate.hasData) ? snapshotRate.data! : 0.0;
                  String valorFormatado = valor.toStringAsFixed(2).replaceAll('.', ',');
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
            // Actions customizadas (se fornecidas)
            if (actions != null) ...actions!,
            
            GestureDetector(
              onTap: onCartClick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: Badge(
                  backgroundColor: Colors.red,
                  label: Text('$cartCount', style: const TextStyle(fontSize: 9, color: Colors.white)),
                  isLabelVisible: cartCount > 0,
                  child: const Icon(Icons.shopping_cart_outlined, color: verdeOliva, size: 24),
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (value) {
                if (value == 'pedidos') {
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MeusPedidosScreen()),
                    );
                  }
                } else if (value == 'diagnostico') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DiagnosticScreen()),
                  );
                } else if (value == 'idioma') {
                  _showLanguageDialog(context);
                } else if (value == 'sair') {
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
                PopupMenuItem(
                  value: 'diagnostico',
                  child: Row(
                    children: [
                      Icon(Icons.sensors, color: verdeOliva, size: 20),
                      const SizedBox(width: 10),
                      const Text("Conectividade", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'idioma',
                  child: Row(
                    children: [
                      Icon(Icons.language, color: verdeOliva, size: 20),
                      const SizedBox(width: 10),
                      const Text("Idioma", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                if (user != null)
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
      },
    );
  }
}