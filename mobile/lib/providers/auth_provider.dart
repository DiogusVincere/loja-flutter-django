import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';

/// Provider para gerenciamento de autenticação
class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Inicializa o provider verificando se há usuário salvo
  Future<void> init() async {
    await _loadUserFromStorage();
  }

  /// Carrega o usuário do armazenamento local
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        _user = UserModel.fromJson(userData);
        
        // Restaura o token na API
        if (_user?.token != null) {
          _apiService.setAuthToken(_user!.token!);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar usuário do storage: $e');
    }
  }

  /// Salva o usuário no armazenamento local
  Future<void> _saveUserToStorage(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(user.toJson()));
    } catch (e) {
      print('Erro ao salvar usuário no storage: $e');
    }
  }

  /// Remove o usuário do armazenamento local
  Future<void> _removeUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      print('Erro ao remover usuário do storage: $e');
    }
  }

  /// Realiza o login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.login(username, password);
      
      if (user != null) {
        _user = user;
        await _saveUserToStorage(user);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email ou senha incorretos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao fazer login. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registra um novo usuário
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );
      
      if (user != null) {
        _user = user;
        await _saveUserToStorage(user);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erro ao criar conta';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao registrar. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Realiza o logout
  Future<void> logout() async {
    _user = null;
    _apiService.clearAuthToken();
    await _removeUserFromStorage();
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}