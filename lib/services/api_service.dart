import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

class ApiService {
  String? _authToken;

  /// Seta o token JWT retornado pelo Django
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Limpa token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Headers usados em todas requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // ----------------------------
  // LOGIN
  // ----------------------------

  Future<UserModel?> login(String email, String password) async {
    try {
      final url = Uri.parse(AppConstants.loginEndpoint);

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          "username": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);

        if (user.token != null) {
          setAuthToken(user.token!);
        }

        return user;
      } else {
        print("LOGIN ERROR: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro no login: $e");
      return null;
    }
  }

  // ----------------------------
  // REGISTRO
  // ----------------------------

  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(AppConstants.registerEndpoint);

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);

        if (user.token != null) {
          setAuthToken(user.token!);
        }

        return user;
      } else {
        print("REGISTER ERROR: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro no registro: $e");
      return null;
    }
  }

  // ----------------------------
  // PRODUTOS
  // ----------------------------

  Future<List<ProductModel>> getProducts() async {
    try {
      final url = Uri.parse(AppConstants.productsEndpoint);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data
            .map((p) => ProductModel.fromJson(p))
            .toList();
      } else {
        print("Erro ao obter produtos: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erro ao buscar produtos: $e");
      return [];
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final url = Uri.parse("${AppConstants.productsEndpoint}?category=$category");

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data.map((p) => ProductModel.fromJson(p)).toList();
      } else {
        print("Erro ao filtrar produtos: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erro no filtro de produtos: $e");
      return [];
    }
  }

  // ----------------------------
  // PEDIDOS
  // ----------------------------

  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final url = Uri.parse(AppConstants.ordersEndpoint);

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrderModel.fromJson(data);
      } else {
        print("Erro ao criar pedido: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erro no createOrder: $e");
      return null;
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final url = Uri.parse(AppConstants.ordersEndpoint);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data.map((o) => OrderModel.fromJson(o)).toList();
      } else {
        print("Erro ao obter pedidos: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erro no getOrders: $e");
      return [];
    }
  }
}
