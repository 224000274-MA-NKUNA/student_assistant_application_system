// lib/viewmodels/admin_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:student_assistant_app/models/application_models.dart';


class AdminViewModel extends ChangeNotifier {
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'all';
  String _searchQuery = '';

  List<ApplicationModel> get allApplications => _allApplications;
  List<ApplicationModel> get filteredApplications => _filteredApplications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  int get totalApplications => _allApplications.length;
  int get pendingApplications => _allApplications.where((app) => app.status == 'pending').length;
  int get approvedApplications => _allApplications.where((app) => app.status == 'approved').length;
  int get rejectedApplications => _allApplications.where((app) => app.status == 'rejected').length;

  void applyFilters() {
    List<ApplicationModel> result = [..._allApplications];
    
    if (_currentFilter != 'all') {
      result = result.where((app) => app.status == _currentFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((app) {
        return app.studentNumber.toLowerCase().contains(query) ||
               app.fullName.toLowerCase().contains(query) ||
               app.email.toLowerCase().contains(query);
      }).toList();
    }
    
    _filteredApplications = result;
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilters();
  }

  void clearFilters() {
    _currentFilter = 'all';
    _searchQuery = '';
    applyFilters();
  }

  String? validateRejectionReason(String? reason) {
    if (reason == null || reason.trim().isEmpty) {
      return 'Rejection reason is required';
    }
    if (reason.trim().length < 10) {
      return 'Please provide at least 10 characters';
    }
    return null;
  }

  Future<List<ApplicationModel>> loadAllApplications() async {
    _isLoading = true;
    notifyListeners();

    _allApplications = [];
    _filteredApplications = [];

    _isLoading = false;
    notifyListeners();
    return _allApplications;
  }

  Future<bool> approveApplication(String applicationId, String adminNotes) async {
    _isLoading = true;
    notifyListeners();

    final index = _allApplications.indexWhere((app) => app.id == applicationId);
    if (index != -1) {
      final updatedApp = _allApplications[index].copyWith(status: 'approved', updatedAt: DateTime.now());
      _allApplications[index] = updatedApp;
      applyFilters();
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> rejectApplication(String applicationId, String rejectionReason) async {
    _isLoading = true;
    notifyListeners();

    final index = _allApplications.indexWhere((app) => app.id == applicationId);
    if (index != -1) {
      final updatedApp = _allApplications[index].copyWith(
        status: 'rejected',
        rejectionReason: rejectionReason,
        updatedAt: DateTime.now(),
      );
      _allApplications[index] = updatedApp;
      applyFilters();
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();

    _allApplications.removeWhere((app) => app.id == applicationId);
    applyFilters();

    _isLoading = false;
    notifyListeners();
    return true;
  }
}