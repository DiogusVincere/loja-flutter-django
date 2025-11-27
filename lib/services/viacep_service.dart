import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../utils/constants.dart';

/// Serviço para consulta de CEP via API ViaCEP
class ViaCepService {
  /// Busca o endereço pelo CEP
  Future<AddressModel?> getAddressByCep(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      // Valida o formato do CEP
      if (cleanCep.length != 8) {
        throw Exception('CEP deve conter 8 dígitos');
      }

      // Faz a requisição para a API ViaCEP
      final url = Uri.parse('${AppConstants.viaCepBaseUrl}/$cleanCep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Verifica se o CEP foi encontrado
        if (data.containsKey('erro')) {
          throw Exception('CEP não encontrado');
        }

        return AddressModel.fromViaCep(data);
      } else {
        throw Exception('Erro ao buscar CEP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no ViaCepService: $e');
      return null;
    }
  }

  /// Valida o formato do CEP
  bool isValidCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCep.length == 8;
  }

  /// Formata o CEP para o padrão XXXXX-XXX
  String formatCep(String cep) {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanCep.length != 8) {
      return cep;
    }

    return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
  }
}