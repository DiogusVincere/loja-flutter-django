/// Constantes da aplicação Mange Eats
class AppConstants {
  // URLs da API
  static const String baseUrl = 'http://seu-servidor-django.com/api';
  static const String loginEndpoint = '$baseUrl/auth/login/';
  static const String registerEndpoint = '$baseUrl/auth/register/';
  static const String productsEndpoint = '$baseUrl/products/';
  static const String ordersEndpoint = '$baseUrl/orders/';
  
  // ViaCEP API
  static const String viaCepBaseUrl = 'https://viacep.com.br/ws';
  
  // Taxa de entrega
  static const double deliveryFee = 5.0;
  static const double freeDeliveryMinimum = 100.0;
  
  // Validações
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  
  // Mensagens
  static const String appName = 'Mange Eats';
  static const String welcomeMessage = 'Bem-vindo ao Mange Eats!';
  static const String loginError = 'Erro ao fazer login. Verifique suas credenciais.';
  static const String registerError = 'Erro ao criar conta. Tente novamente.';
  static const String networkError = 'Erro de conexão. Verifique sua internet.';
  static const String emptyCartMessage = 'Seu carrinho está vazio';
  static const String invalidCepMessage = 'CEP inválido. Digite um CEP válido.';
  
  // Categorias de produtos
  static const String categorySnacks = 'Lanches';
  static const String categoryPizzas = 'Pizzas';
  static const String categoryDrinks = 'Bebidas';
  static const String categoryDesserts = 'Sobremesas';
}