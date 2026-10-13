import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/address_model.dart';
import '../utils/constants.dart';

/// Provider para gerenciamento do carrinho (BagProvider)
class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  AddressModel? _deliveryAddress;

  List<CartItemModel> get items => List.unmodifiable(_items);
  AddressModel? get deliveryAddress => _deliveryAddress;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  /// Calcula o subtotal dos itens
  double get subtotal {
    return _items.fold(0.0, (total, item) => total + item.subtotal);
  }

  /// Calcula a taxa de entrega
  double get deliveryFee {
    if (subtotal >= AppConstants.freeDeliveryMinimum) {
      return 0.0;
    }
    return AppConstants.deliveryFee;
  }

  /// Calcula o total do pedido (subtotal + taxa de entrega)
  double get total => subtotal + deliveryFee;

  /// Adiciona um produto ao carrinho
  void addProduct(ProductModel product, {String? observations}) {
    // Verifica se o produto já está no carrinho
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Se já existe, incrementa a quantidade
      _items[existingIndex].incrementQuantity();
    } else {
      // Se não existe, adiciona novo item
      _items.add(CartItemModel(
        product: product,
        quantity: 1,
        observations: observations,
      ));
    }

    notifyListeners();
  }

  /// Remove um produto do carrinho
  void removeProduct(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Incrementa a quantidade de um produto
  void incrementQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );
    item.incrementQuantity();
    notifyListeners();
  }

  /// Decrementa a quantidade de um produto
  void decrementQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );
    
    if (item.quantity > 1) {
      item.decrementQuantity();
    } else {
      // Se a quantidade for 1, remove o item
      removeProduct(productId);
    }
    
    notifyListeners();
  }

  /// Atualiza a quantidade de um produto
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );
    item.quantity = quantity;
    notifyListeners();
  }

  /// Define o endereço de entrega
  void setDeliveryAddress(AddressModel address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  /// Remove o endereço de entrega
  void clearDeliveryAddress() {
    _deliveryAddress = null;
    notifyListeners();
  }

  /// Limpa o carrinho
  void clear() {
    _items.clear();
    _deliveryAddress = null;
    notifyListeners();
  }

  /// Verifica se um produto está no carrinho
  bool hasProduct(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Retorna a quantidade de um produto no carrinho
  int getProductQuantity(int productId) {
    try {
      final item = _items.firstWhere(
        (item) => item.product.id == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  /// Retorna o número total de produtos no carrinho
  int get totalProducts {
    return _items.fold(0, (total, item) => total + item.quantity);
  }
}