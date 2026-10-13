import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import '../widgets/custom_button.dart';
import '../utils/theme.dart';

/// Tela de confirmação do pedido
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _apiService = ApiService();
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'money';

  final _paymentMethods = [
    {'id': 'money', 'name': 'Dinheiro', 'icon': Icons.attach_money},
    {'id': 'credit_card', 'name': 'Cartão de Crédito', 'icon': Icons.credit_card},
    {'id': 'debit_card', 'name': 'Cartão de Débito', 'icon': Icons.payment},
    {'id': 'pix', 'name': 'PIX', 'icon': Icons.pix},
  ];

  Future<void> _handleConfirmOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (cartProvider.deliveryAddress == null) {
      _showErrorDialog('Por favor, informe o endereço de entrega');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Cria o modelo do pedido
      final order = OrderModel(
        items: cartProvider.items,
        address: cartProvider.deliveryAddress!,
        subtotal: cartProvider.subtotal,
        deliveryFee: cartProvider.deliveryFee,
        total: cartProvider.total,
        paymentMethod: _selectedPaymentMethod,
      );

      // Envia o pedido para o backend
      final createdOrder = await _apiService.createOrder(order);

      if (!mounted) return;

      if (createdOrder != null) {
        // Limpa o carrinho
        cartProvider.clear();
        
        // Mostra mensagem de sucesso
        _showSuccessDialog(createdOrder);
      } else {
        throw Exception('Erro ao criar pedido');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Erro ao processar pedido. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Pedido Confirmado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu pedido foi realizado com sucesso!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (order.id != null)
              Text(
                'Número do pedido: #${order.id}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            const SizedBox(height: 8),
            Text(
              'Total: R\$ ${order.total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Acompanhe o status do seu pedido em tempo real.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Voltar ao Início'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Informações do cliente
            _buildSection(
              title: 'Dados do Cliente',
              icon: Icons.person_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nome', authProvider.user?.name ?? '-'),
                  _buildInfoRow('Email', authProvider.user?.email ?? '-'),
                  if (authProvider.user?.phone != null)
                    _buildInfoRow('Telefone', authProvider.user!.phone!),
                ],
              ),
            ),
            
            // Endereço de entrega
            _buildSection(
              title: 'Endereço de Entrega',
              icon: Icons.location_on_outlined,
              child: Text(
                cartProvider.deliveryAddress?.fullAddress ?? 'Endereço não informado',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            
            // Itens do pedido
            _buildSection(
              title: 'Itens do Pedido',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: cartProvider.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.name}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          'R\$ ${item.subtotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Forma de pagamento
            _buildSection(
              title: 'Forma de Pagamento',
              icon: Icons.payment_outlined,
              child: Column(
                children: _paymentMethods.map((method) {
                  return RadioListTile<String>(
                    value: method['id'] as String,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                    title: Row(
                      children: [
                        Icon(
                          method['icon'] as IconData,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(method['name'] as String),
                      ],
                    ),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            
            // Resumo financeiro
            _buildSection(
              title: 'Resumo do Pedido',
              icon: Icons.receipt_outlined,
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Subtotal',
                    'R\$ ${cartProvider.subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Taxa de entrega',
                    cartProvider.deliveryFee == 0
                        ? 'GRÁTIS'
                        : 'R\$ ${cartProvider.deliveryFee.toStringAsFixed(2)}',
                    valueColor: cartProvider.deliveryFee == 0
                        ? AppTheme.successColor
                        : null,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Total',
                    'R\$ ${cartProvider.total.toStringAsFixed(2)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          child: CustomButton(
            text: 'Confirmar Pedido',
            onPressed: _isProcessing ? null : _handleConfirmOrder,
            isLoading: _isProcessing,
            icon: Icons.check,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueColor,
                    fontWeight: valueColor != null ? FontWeight.bold : null,
                  ),
        ),
      ],
    );
  }
}