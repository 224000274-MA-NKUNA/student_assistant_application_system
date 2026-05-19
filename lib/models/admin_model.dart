// lib/models/admin_model.dart
// Immutable data model representing an administrator account.

class AdminModel {
  final String id; // Supabase auth user UUID(MA-NKUNA)
  final String email; //Admin's email address. (MA-NKUNA)
  final String fullName; // Display name shown in the dashboard.(MA-NKUNA)

  AdminModel({
    required this.id,
    required this.email,
    required this.fullName,
  });
/// Returns a new [AdminModel] with any supplied fields overridden.(MA-NKUNA)
  /// Unmodified fields fall back to the current instance's values.(MA-NKUNA)
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
