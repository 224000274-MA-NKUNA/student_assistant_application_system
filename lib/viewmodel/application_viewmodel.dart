// lib/viewmodels/application_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get pendingCount => _applications.where((a) => a.status == 'pending').length;
  int get approvedCount => _applications.where((a) => a.status == 'approved').length;
  int get rejectedCount => _applications.where((a) => a.status == 'rejected').length;
  
  ApplicationModel? get pendingApplication {
    try {
      return _applications.firstWhere((a) => a.status == 'pending');
    } catch (e) {
      return null;
    }
  }
  
  bool get hasPendingApplication => pendingApplication != null;
  bool get canSubmitApplication => !hasPendingApplication && approvedCount == 0;

  void reset() {
    _applications = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchMyApplications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('========== FETCHING MY APPLICATIONS ==========');
      debugPrint('User ID: $userId');
      
      final response = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('Raw response: $response');
      debugPrint('Found ${response.length} applications');
      
      _applications = response.map((json) => ApplicationModel.fromJson(json)).toList();
      _errorMessage = null;
      
      for (var app in _applications) {
        debugPrint('Application: ${app.id} - ${app.fullName} - ${app.status}');
      }
      
      debugPrint('Applications loaded: ${_applications.length}');
    } catch (e) {
      debugPrint('Error fetching applications: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllApplications() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('========== FETCHING ALL APPLICATIONS ==========');
      
      final response = await _supabase
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      debugPrint('Raw response: $response');
      debugPrint('Found ${response.length} total applications');
      
      _applications = response.map((json) => ApplicationModel.fromJson(json)).toList();
      _errorMessage = null;
      
      for (var app in _applications) {
        debugPrint('Application: ${app.id} - ${app.fullName} - ${app.status}');
      }
    } catch (e) {
      debugPrint('Error fetching all applications: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<bool> submitApplication(ApplicationModel application) async {
  if (_isLoading) return false;
  
  _isLoading = true;
  notifyListeners();

  try {

    
    final jsonData = application.toJson();
  
    
    // First, check if profile exists
    final profileCheck = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', application.userId)
        .maybeSingle();
    
    if (profileCheck == null) {
    
      // Create profile if it doesn't exist
      await _supabase.from('profiles').insert({
        'id': application.userId,
        'email': application.email,
        'full_name': application.fullName,
        'student_number': application.studentNumber,
        'year_of_study': application.yearOfStudy,
        'role': 'student',
      });
   
    }
    
    // Insert the application
    final response = await _supabase
        .from('applications')
        .insert(jsonData)
        .select();

  
    
    if (response.isNotEmpty) {
      final newApplication = ApplicationModel.fromJson(response.first);
      _applications.insert(0, newApplication);
      _isLoading = false;
      notifyListeners();
    
      return true;
    }
 
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

  Future<bool> updateApplication(ApplicationModel application) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Updating application: ${application.id}');
      
      await _supabase
          .from('applications')
          .update(application.toJson())
          .eq('id', application.id);

      final index = _applications.indexWhere((a) => a.id == application.id);
      if (index != -1) {
        _applications[index] = application;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Approving application: $applicationId');
      
      await _supabase
          .from('applications')
          .update({
            'status': 'approved', 
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', applicationId);

      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(status: 'approved');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Approve error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectApplication(String applicationId, String rejectionReason) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Rejecting application: $applicationId');
      debugPrint('Reason: $rejectionReason');
      
      await _supabase
          .from('applications')
          .update({
            'status': 'rejected',
            'rejection_reason': rejectionReason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);

      final index = _applications.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        _applications[index] = _applications[index].copyWith(
          status: 'rejected',
          rejectionReason: rejectionReason,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Reject error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Deleting application: $applicationId');
      
      await _supabase.from('applications').delete().eq('id', applicationId);
      _applications.removeWhere((a) => a.id == applicationId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}