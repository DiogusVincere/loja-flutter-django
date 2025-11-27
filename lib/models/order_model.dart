import 'cart_item_model.dart';
import 'address_model.dart';

/// Modelo de dados do pedido
class OrderModel {
  final int? id;
  final List<CartItemModel> items;
  final AddressModel address;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;
  final String status;
  final String? paymentMethod;

  OrderModel({
    this.id,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    DateTime? createdAt,
    this.status = 'pending',
    this.paymentMethod,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converte JSON para OrderModel
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      address: AddressModel.fromViaCep(json['address'] as Map<String, dynamic>),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
    );
  }

  /// Converte OrderModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'address': address.toJson(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'payment_method': paymentMethod,
    };
  }

  /// Cria uma cópia do pedido com campos atualizados
  OrderModel copyWith({
    int? id,
    List<CartItemModel>? items,
    AddressModel? address,
    double? subtotal,
    double? deliveryFee,
    double? total,
    DateTime? createdAt,
    String? status,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      address: address ?? this.address,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, total: R\$ ${total.toStringAsFixed(2)}, status: $status)';
  }
}