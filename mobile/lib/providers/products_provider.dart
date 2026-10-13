import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

/// Provider para gerenciamento de produtos
class ProductsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Todos';

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  /// Lista de categorias disponíveis
  List<String> get categories => [
        'Todos',
        AppConstants.categorySnacks,
        AppConstants.categoryPizzas,
        AppConstants.categoryDrinks,
        AppConstants.categoryDesserts,
      ];

  /// Produtos filtrados pela categoria selecionada
  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'Todos') {
      return _products;
    }
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  /// Produtos de lanches
  List<ProductModel> get snacks {
    return _products
        .where((product) => product.category == AppConstants.categorySnacks)
        .toList();
  }

  /// Produtos de pizzas
  List<ProductModel> get pizzas {
    return _products
        .where((product) => product.category == AppConstants.categoryPizzas)
        .toList();
  }

  /// Carrega todos os produtos
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar produtos';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega produtos por categoria
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.getProductsByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar produtos';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Define a categoria selecionada
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Busca um produto pelo ID
  ProductModel? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Recarrega os produtos
  Future<void> refresh() async {
    await loadProducts();
  }
}