import 'product_model.dart';

/// Modelo de dados do item no carrinho
class CartItemModel {
  final ProductModel product;
  int quantity;
  final String? observations;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.observations,
  });

  /// Calcula o subtotal do item (preço x quantidade)
  double get subtotal => product.price * quantity;

  /// Incrementa a quantidade
  void incrementQuantity() {
    quantity++;
  }

  /// Decrementa a quantidade (mínimo 1)
  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  /// Converte JSON para CartItemModel
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      observations: json['observations'] as String?,
    );
  }

  /// Converte CartItemModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'observations': observations,
    };
  }

  /// Cria uma cópia do item com campos atualizados
  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? observations,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      observations: observations ?? this.observations,
    );
  }

  @override
  String toString() {
    return 'CartItemModel(product: ${product.name}, quantity: $quantity, subtotal: R\$ ${subtotal.toStringAsFixed(2)})';
  }
}