// lib/routes/route_manager.dart

import 'package:flutter/material.dart';
import '../views/auth/login_screen.dart';
import '../views/student/student_home_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/application_detail_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/admin_application_detail_screen.dart';

class RouteManager {
  static const String login = '/';
  static const String studentHome = '/student/home';
  static const String applicationForm = '/student/application-form';
  static const String applicationDetail = '/student/application-detail';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminApplicationDetail = '/admin/application-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeScreen());
      case applicationForm:
        return MaterialPageRoute(builder: (_) =>const  ApplicationFormScreen());
      case applicationDetail:
        final applicationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(applicationId: applicationId),
        );
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminApplicationDetail:
        final applicationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AdminApplicationDetailScreen(applicationId: applicationId),
        );
      default:
        throw Exception('Route not found: ${settings.name}');
    }
  }
}