// lib/viewmodels/student_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:student_assistant_app/models/student_model.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';

class StudentViewModel extends ChangeNotifier {
  StudentModel? _currentStudent;
  List<ApplicationModel> _myApplications = [];
  bool _isLoading = false;
  String? _errorMessage;
  AuthViewModel? _authVM;

  StudentModel? get currentStudent => _currentStudent;
  List<ApplicationModel> get myApplications => _myApplications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String get currentStudentId => _currentStudent?.id ?? '';
  String get currentStudentNumber => _currentStudent?.studentNumber ?? '';
  String get currentStudentName => _currentStudent?.fullName ?? '';
  String get currentStudentEmail => _currentStudent?.email ?? '';
  int get currentYearOfStudy => _currentStudent?.yearOfStudy ?? 1;
  bool get isStudentLoggedIn => _currentStudent != null;
  
  ApplicationModel? get pendingApplication {
    try {
      return _myApplications.firstWhere((app) => app.status == 'pending');
    } catch (e) {
      return null;
    }
  }
  
  ApplicationModel? get approvedApplication {
    try {
      return _myApplications.firstWhere((app) => app.status == 'approved');
    } catch (e) {
      return null;
    }
  }
  
  bool get hasActiveApplication => pendingApplication != null;
  bool get canSubmitApplication => !hasActiveApplication && approvedApplication == null;

  // Initialize with AuthViewModel
  void initialize(AuthViewModel authVM) {
    _authVM = authVM;
    _currentStudent = authVM.currentStudent;
    notifyListeners();
  }

  String? getApplicationSubmissionError() {
    if (hasActiveApplication) {
      return 'You already have a pending application';
    }
    if (approvedApplication != null) {
      return 'You have already been approved';
    }
    return null;
  }

  bool canEditApplication(ApplicationModel application) {
    return application.status == 'pending' && application.userId == _currentStudent?.id;
  }

  bool canDeleteApplication(ApplicationModel application) {
    return application.status == 'pending' && application.userId == _currentStudent?.id;
  }

  void setStudent(StudentModel? student) {
    _currentStudent = student;
    notifyListeners();
  }

  Future<void> loadStudentProfile(String studentId) async {
    _isLoading = true;
    notifyListeners();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyApplications() async {
    _isLoading = true;
    notifyListeners();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitApplication(ApplicationModel application) async {
    if (_isLoading) return false;
    _isLoading = true;
    notifyListeners();

    final submissionError = getApplicationSubmissionError();
    if (submissionError != null) {
      _errorMessage = submissionError;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _myApplications.insert(0, application);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updateApplication(ApplicationModel application) async {
    _isLoading = true;
    notifyListeners();

    final index = _myApplications.indexWhere((app) => app.id == application.id);
    if (index != -1) {
      _myApplications[index] = application;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    _myApplications.removeWhere((app) => app.id == applicationId);

    _isLoading = false;
    notifyListeners();
    return true;
  }
  
  void reset() {
    _currentStudent = null;
    _myApplications = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}