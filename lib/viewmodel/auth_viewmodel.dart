// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cross_file/cross_file.dart';
import '../models/student_model.dart';
import '../services/storage_service.dart';
import '../config/supabase_config.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  StudentModel? _currentStudent;
  String? _userRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  StudentModel? get currentStudent => _currentStudent;
  String? get userRole => _userRole;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _userRole == 'admin';
  bool get isStudent => _userRole == 'student';
  String? get currentUserId => _currentUser?.id;
  String? get currentUserEmail => _currentUser?.email;
  String get currentStudentName => _currentStudent?.fullName ?? 'Student';
  String get currentStudentNumber => _currentStudent?.studentNumber ?? '';
  int get currentYearOfStudy => _currentStudent?.yearOfStudy ?? 1;
  String get currentDepartment => _currentStudent?.department ?? '';

  // Generate student number: YYYYMM + SEQUENCE
  Future<String> _generateStudentNumber() async {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    
    try {
      final response = await _supabase
          .from('profiles')
          .select('student_number')
          .like('student_number', '$yearMonth%')
          .order('student_number', ascending: false)
          .limit(1);
      
      int nextSequence = 1;
      
      if (response.isNotEmpty && response.first['student_number'] != null) {
        final lastNumber = response.first['student_number'] as String;
        if (lastNumber.length >= 9) {
          final lastSequence = int.tryParse(lastNumber.substring(6)) ?? 0;
          nextSequence = lastSequence + 1;
        }
      }
      
      final sequenceStr = nextSequence.toString().padLeft(3, '0');
      return '$yearMonth$sequenceStr';
      
    } catch (e) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$yearMonth${(timestamp % 1000).toString().padLeft(3, '0')}';
    }
  }

  Future<void> init() async {
    final session = _supabase.auth.currentSession;
    
    if (session != null) {
      _currentUser = session.user;
      await _loadStudentProfile();
      await _loadUserRole();
    }
    notifyListeners();
  }

  Future<void> _loadStudentProfile() async {
    if (_currentUser == null) return;
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', _currentUser!.id)
          .maybeSingle();
      
      if (response != null) {
        _currentStudent = StudentModel.fromJson(response);
      } else {
        await _createProfile();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _createProfile() async {
    if (_currentUser == null) return;
    try {
      final studentNumber = await _generateStudentNumber();
      
      final newProfile = {
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'full_name': _currentUser!.email?.split('@').first ?? 'Student',
        'student_number': studentNumber,
        'year_of_study': 1,
        'department': 'Not Specified',
        'role': 'student',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await _supabase.from('profiles').insert(newProfile);
      await _loadStudentProfile();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadUserRole() async {
    if (_currentUser == null) return;
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', _currentUser!.id)
          .maybeSingle();
      _userRole = response?['role'] as String? ?? 'student';
    } catch (e) {
      _userRole = 'student';
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        _currentUser = response.user;
        await Future.delayed(const Duration(seconds: 1));
        await _loadStudentProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password, {String? adminSecretCode}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = response.user;
      
      if (adminSecretCode != null && adminSecretCode == SupabaseConfig.adminSecretCode) {
        _userRole = 'admin';
        
        final existingProfile = await _supabase
            .from('profiles')
            .select()
            .eq('id', _currentUser!.id)
            .maybeSingle();
        
        if (existingProfile == null) {
          final adminNumber = 'ADMIN${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}';
          await _supabase.from('profiles').insert({
            'id': _currentUser!.id,
            'email': email.trim(),
            'full_name': email.trim().split('@').first,
            'student_number': adminNumber,
            'role': 'admin',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        await _loadStudentProfile();
      } else {
        await _loadStudentProfile();
        await _loadUserRole();
        
        if (_currentStudent != null && 
            (_currentStudent!.studentNumber.isEmpty || 
             _currentStudent!.studentNumber == 'null' ||
             _currentStudent!.studentNumber.startsWith('STU'))) {
          final newStudentNumber = await _generateStudentNumber();
          await _supabase
              .from('profiles')
              .update({'student_number': newStudentNumber})
              .eq('id', _currentUser!.id);
          await _loadStudentProfile();
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phoneNumber,
    int? yearOfStudy,
    String? department,
    XFile? profileImage,
  }) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? profilePictureUrl = _currentStudent?.profilePictureUrl;
      
      if (profileImage != null) {
        profilePictureUrl = await _storageService.uploadProfilePicture(
          _currentUser!.id, 
          profileImage,
        );
      }
      
      final Map<String, dynamic> updates = {
        'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) updates['phone_number'] = phoneNumber;
      if (yearOfStudy != null) updates['year_of_study'] = yearOfStudy;
      if (department != null && department.isNotEmpty) updates['department'] = department;
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
        updates['profile_picture_url'] = profilePictureUrl;
      }
      
      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', _currentUser!.id);
      
      await _loadStudentProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _supabase.auth.signOut();
    _currentUser = null;
    _currentStudent = null;
    _userRole = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}