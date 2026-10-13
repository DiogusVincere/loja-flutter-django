/// Modelo de dados do endereço (ViaCEP)
class AddressModel {
  final String cep;
  final String street;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String? number;

  AddressModel({
    required this.cep,
    required this.street,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.number,
  });

  /// Converte JSON do ViaCEP para AddressModel
  factory AddressModel.fromViaCep(Map<String, dynamic> json) {
    return AddressModel(
      cep: json['cep'] as String,
      street: json['logradouro'] as String,
      complement: json['complemento'] as String?,
      neighborhood: json['bairro'] as String,
      city: json['localidade'] as String,
      state: json['uf'] as String,
    );
  }

  /// Converte AddressModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'street': street,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'number': number,
    };
  }

  /// Retorna o endereço formatado
  String get fullAddress {
    final parts = <String>[
      street,
      if (number != null && number!.isNotEmpty) 'nº $number',
      if (complement != null && complement!.isNotEmpty) complement!,
      neighborhood,
      '$city - $state',
      'CEP: $cep',
    ];
    return parts.join(', ');
  }

  /// Cria uma cópia do endereço com campos atualizados
  AddressModel copyWith({
    String? cep,
    String? street,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? number,
  }) {
    return AddressModel(
      cep: cep ?? this.cep,
      street: street ?? this.street,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      number: number ?? this.number,
    );
  }

  @override
  String toString() {
    return 'AddressModel($fullAddress)';
  }
}