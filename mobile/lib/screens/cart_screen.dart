import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/viacep_service.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'checkout_screen.dart';

/// Tela do carrinho de compras
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cepController = TextEditingController();
  final _numberController = TextEditingController();
  final _viaCepService = ViaCepService();
  bool _isLoadingAddress = false;
  String? _addressError;

  @override
  void dispose() {
    _cepController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    if (_cepController.text.isEmpty) {
      setState(() {
        _addressError = 'Digite um CEP';
      });
      return;
    }

    if (!_viaCepService.isValidCep(_cepController.text)) {
      setState(() {
        _addressError = AppConstants.invalidCepMessage;
      });
      return;
    }

    setState(() {
      _isLoadingAddress = true;
      _addressError = null;
    });

    final address = await _viaCepService.getAddressByCep(_cepController.text);

    if (!mounted) return;

    if (address != null) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Adiciona o número se foi informado
      final addressWithNumber = _numberController.text.isNotEmpty
          ? address.copyWith(number: _numberController.text)
          : address;
      
      cartProvider.setDeliveryAddress(addressWithNumber);
      
      setState(() {
        _isLoadingAddress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endereço encontrado!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      setState(() {
        _isLoadingAddress = false;
        _addressError = 'CEP não encontrado. Verifique e tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
      ),
      body: cartProvider.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Lista de itens
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      return CartItemWidget(item: cartProvider.items[index]);
                    },
                  ),
                ),
                
                // Seção de endereço
                _buildAddressSection(cartProvider),
                
                // Resumo do pedido
                _buildOrderSummary(cartProvider),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.emptyCartMessage,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione produtos ao carrinho',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ver Cardápio'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço de Entrega',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          
          // Campo de CEP
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'CEP',
                  hint: '00000-000',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.length == 8) {
                      _cepController.text = _viaCepService.formatCep(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: CustomButton(
                    text: 'Buscar',
                    onPressed: _searchAddress,
                    isLoading: _isLoadingAddress,
                  ),
                ),
              ),
            ],
          ),
          
          if (_addressError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _addressError!,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                ),
              ),
            ),
          
          // Campo de número
          if (cartProvider.deliveryAddress != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomTextField(
                label: 'Número',
                hint: 'Número da residência',
                controller: _numberController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isNotEmpty && cartProvider.deliveryAddress != null) {
                    cartProvider.setDeliveryAddress(
                      cartProvider.deliveryAddress!.copyWith(number: value),
                    );
                  }
                },
              ),
            ),
          
          // Endereço encontrado
          if (cartProvider.deliveryAddress != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cartProvider.deliveryAddress!.fullAddress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    final canProceed = cartProvider.deliveryAddress != null;

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'R\$ ${cartProvider.subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Taxa de entrega
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taxa de entrega',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  cartProvider.deliveryFee == 0
                      ? 'GRÁTIS'
                      : 'R\$ ${cartProvider.deliveryFee.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cartProvider.deliveryFee == 0
                            ? AppTheme.successColor
                            : AppTheme.textPrimary,
                        fontWeight: cartProvider.deliveryFee == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
              ],
            ),
            
            if (cartProvider.subtotal < AppConstants.freeDeliveryMinimum)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Frete grátis em compras acima de R\$ ${AppConstants.freeDeliveryMinimum.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            
            const Divider(height: 24),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'R\$ ${cartProvider.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botão continuar
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Continuar',
                onPressed: canProceed ? _handleContinue : null,
                icon: Icons.arrow_forward,
              ),
            ),
            
            if (!canProceed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Informe o endereço de entrega para continuar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }
}