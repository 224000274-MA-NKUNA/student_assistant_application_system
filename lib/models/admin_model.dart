// lib/models/admin_model.dart

class AdminModel {
  final String id;
  final String email;
  final String fullName;

  AdminModel({
    required this.id,
    required this.email,
    required this.fullName,
  });

  AdminModel copyWith({
    String? id,
    String? email,
    String? fullName,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
    );
  }
}