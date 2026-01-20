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
