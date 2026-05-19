// lib/views/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';
import 'login_screen.dart';
import '../student/student_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        if (authVM.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (!authVM.isLoggedIn) {
          return const LoginScreen();
        }
        
        // Load data after login - use Future.microtask to avoid build issues
        Future.microtask(() async {
          final appVM = context.read<ApplicationViewModel>();
          if (authVM.currentUserId != null) {
            debugPrint('Loading applications for user: ${authVM.currentUserId}');
            debugPrint('Is Admin: ${authVM.isAdmin}');
            if (authVM.isAdmin) {
              await appVM.fetchAllApplications();
            } else {
              await appVM.fetchMyApplications(authVM.currentUserId!);
            }
          }
        });
        
        if (authVM.isAdmin) {
          return const AdminDashboardScreen();
        }
        return const StudentHomeScreen();
      },
    );
  }
}