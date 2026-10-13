/// Modelo de dados do usuário
class UserModel {
  final int? id;
  final String email;
  final String name;
  final String? phone;
  final String? token;

  UserModel({
    this.id,
    required this.email,
    required this.name,
    this.phone,
    this.token,
  });

  /// Converte JSON para UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      token: json['token'] as String?,
    );
  }

  /// Converte UserModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'token': token,
    };
  }

  /// Cria uma cópia do usuário com campos atualizados
  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name)';
  }
}