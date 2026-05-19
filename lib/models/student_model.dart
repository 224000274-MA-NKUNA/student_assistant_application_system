// lib/models/student_model.dart

class StudentModel {
  final String id;
  final String studentNumber;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final int yearOfStudy;
  final String department;
  final String? profilePictureUrl;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentModel({
    required this.id,
    required this.studentNumber,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.yearOfStudy,
    required this.department,
    this.profilePictureUrl,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'].toString(),
      studentNumber: json['student_number'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      yearOfStudy: json['year_of_study'] ?? 1,
      department: json['department'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      role: json['role'] ?? 'student',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_number': studentNumber,
      'full_name': fullName,
      'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'year_of_study': yearOfStudy,
      'department': department,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      'role': role,
    };
  }

  StudentModel copyWith({
    String? id,
    String? studentNumber,
    String? fullName,
    String? email,
    String? phoneNumber,
    int? yearOfStudy,
    String? department,
    String? profilePictureUrl,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      studentNumber: studentNumber ?? this.studentNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      department: department ?? this.department,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}