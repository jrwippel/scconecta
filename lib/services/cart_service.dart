// Modelo do Item do Carrinho
class CartItem {
  final String plano;
  final String tipo; // eSIM ou Chip
  final String datas;
  final int quantidade;
  final double precoUnitario;

  CartItem({
    required this.plano,
    required this.tipo,
    required this.datas,
    required this.quantidade,
    required this.precoUnitario,
  });
}

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Agora o carrinho é uma LISTA de itens
  List<CartItem> itens = [];

  // Variáveis temporárias da tela de seleção (resetam ao entrar na tela)
  int tempEsim = 0;
  int tempChip = 0;

  int get totalItens {
    return itens.fold(0, (sum, item) => sum + item.quantidade);
  }
}
