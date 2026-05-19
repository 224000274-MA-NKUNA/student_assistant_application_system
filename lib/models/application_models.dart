// lib/models/application_model.dart

class ApplicationModel {
  final String id;
  final String userId;
  final String studentNumber;
  final String fullName;
  final String email;
  final int yearOfStudy;
  
  // New fields for year level and semester
  final String? yearLevel;
  final String? semester;
  
  // Module fields
  final String firstModuleLevel;
  final String firstModuleName;
  final String firstModuleReason;
  final bool hasSecondModule;
  final String? secondModuleLevel;
  final String? secondModuleName;
  final String? secondModuleReason;
  
  // Document URLs
  final String? cvUrl;
  final String? academicRecordUrl;
  final String? matricCertificateUrl;
  final String? idDocumentUrl;
  
  // Status fields
  final bool eligibilityConfirmed;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.studentNumber,
    required this.fullName,
    required this.email,
    required this.yearOfStudy,
    this.yearLevel,
    this.semester,
    required this.firstModuleLevel,
    required this.firstModuleName,
    required this.firstModuleReason,
    required this.hasSecondModule,
    this.secondModuleLevel,
    this.secondModuleName,
    this.secondModuleReason,
    this.cvUrl,
    this.academicRecordUrl,
    this.matricCertificateUrl,
    this.idDocumentUrl,
    required this.eligibilityConfirmed,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      studentNumber: json['student_number'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      yearOfStudy: json['year_of_study'] ?? 1,
      yearLevel: json['year_level'],
      semester: json['semester'],
      firstModuleLevel: json['first_module_level'] ?? '',
      firstModuleName: json['first_module_name'] ?? '',
      firstModuleReason: json['first_module_reason'] ?? '',
      hasSecondModule: json['has_second_module'] ?? false,
      secondModuleLevel: json['second_module_level'],
      secondModuleName: json['second_module_name'],
      secondModuleReason: json['second_module_reason'],
      cvUrl: json['cv_url'],
      academicRecordUrl: json['academic_record_url'],
      matricCertificateUrl: json['matric_certificate_url'],
      idDocumentUrl: json['id_document_url'],
      eligibilityConfirmed: json['eligibility_confirmed'] ?? false,
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'student_number': studentNumber,
      'full_name': fullName,
      'email': email,
      'year_of_study': yearOfStudy,
      'year_level': yearLevel,
      'semester': semester,
      'first_module_level': firstModuleLevel,
      'first_module_name': firstModuleName,
      'first_module_reason': firstModuleReason,
      'has_second_module': hasSecondModule,
      if (secondModuleLevel != null) 'second_module_level': secondModuleLevel,
      if (secondModuleName != null) 'second_module_name': secondModuleName,
      if (secondModuleReason != null) 'second_module_reason': secondModuleReason,
      if (cvUrl != null) 'cv_url': cvUrl,
      if (academicRecordUrl != null) 'academic_record_url': academicRecordUrl,
      if (matricCertificateUrl != null) 'matric_certificate_url': matricCertificateUrl,
      if (idDocumentUrl != null) 'id_document_url': idDocumentUrl,
      'eligibility_confirmed': eligibilityConfirmed,
      'status': status,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? userId,
    String? studentNumber,
    String? fullName,
    String? email,
    int? yearOfStudy,
    String? yearLevel,
    String? semester,
    String? firstModuleLevel,
    String? firstModuleName,
    String? firstModuleReason,
    bool? hasSecondModule,
    String? secondModuleLevel,
    String? secondModuleName,
    String? secondModuleReason,
    String? cvUrl,
    String? academicRecordUrl,
    String? matricCertificateUrl,
    String? idDocumentUrl,
    bool? eligibilityConfirmed,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentNumber: studentNumber ?? this.studentNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      yearLevel: yearLevel ?? this.yearLevel,
      semester: semester ?? this.semester,
      firstModuleLevel: firstModuleLevel ?? this.firstModuleLevel,
      firstModuleName: firstModuleName ?? this.firstModuleName,
      firstModuleReason: firstModuleReason ?? this.firstModuleReason,
      hasSecondModule: hasSecondModule ?? this.hasSecondModule,
      secondModuleLevel: secondModuleLevel ?? this.secondModuleLevel,
      secondModuleName: secondModuleName ?? this.secondModuleName,
      secondModuleReason: secondModuleReason ?? this.secondModuleReason,
      cvUrl: cvUrl ?? this.cvUrl,
      academicRecordUrl: academicRecordUrl ?? this.academicRecordUrl,
      matricCertificateUrl: matricCertificateUrl ?? this.matricCertificateUrl,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      eligibilityConfirmed: eligibilityConfirmed ?? this.eligibilityConfirmed,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}