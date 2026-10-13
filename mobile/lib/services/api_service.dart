import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

/// Serviço para comunicação com a API Django
class ApiService {
  String? _authToken;

  /// Define o token de autenticação
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Remove o token de autenticação
  void clearAuthToken() {
    _authToken = null;
  }

  /// Headers padrão para requisições
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  /// Realiza login do usuário
  Future<UserModel?> login(String username, String password) async {
    try {
      final url = Uri.parse(AppConstants.loginEndpoint);
      
      // 🔥 SOLUÇÃO FINAL: Apenas email + password (como Django espera agora)
      final requestBody = {
        'username': username,
        'password': password,
      };
      
      final bodyJson = jsonEncode(requestBody);
      
      print('📤 LOGIN REQUEST:');
      print('URL: $url');
      print('Body: $bodyJson');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: bodyJson,
      );

      print('📥 LOGIN RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Login bem-sucedido!');
        
        // SimpleJWT retorna: {access, refresh, id, email, name, token}
        final user = UserModel.fromJson(data);
        
        // Armazena o token
        if (user.token != null) {
          setAuthToken(user.token!);
          print('✅ Token salvo');
        }
        
        return user;
      } else {
        print('❌ LOGIN FAILED');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ ERRO: $e');
      print('Stack: $stackTrace');
      return null;
    }
  }

  /// Registra um novo usuário
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final url = Uri.parse(AppConstants.registerEndpoint);
      
      final body = {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      };
      
      print('📤 REGISTER REQUEST:');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      print('📥 REGISTER RESPONSE:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        // Armazena o token
        if (user.token != null) {
          setAuthToken(user.token!);
        }
        
        return user;
      } else {
        print('❌ REGISTER ERROR: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro no registro: $e');
      return null;
    }
  }

  /// Busca todos os produtos
  Future<List<ProductModel>> getProducts() async {
    try {
      final url = Uri.parse(AppConstants.productsEndpoint);
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Erro ao buscar produtos: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar produtos: $e');
      return [];
    }
  }

  /// Busca produtos por categoria
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final url = Uri.parse('${AppConstants.productsEndpoint}?category=$category');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Erro ao buscar produtos por categoria: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar produtos por categoria: $e');
      return [];
    }
  }

  /// Cria um novo pedido
  Future<OrderModel?> createOrder(OrderModel order) async {
    try {
      final url = Uri.parse(AppConstants.ordersEndpoint);
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return OrderModel.fromJson(data);
      } else {
        print('❌ Erro ao criar pedido: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao criar pedido: $e');
      return null;
    }
  }

  /// Busca pedidos do usuário
  Future<List<OrderModel>> getOrders() async {
    try {
      final url = Uri.parse(AppConstants.ordersEndpoint);
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Erro ao buscar pedidos: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar pedidos: $e');
      return [];
    }
  }
}