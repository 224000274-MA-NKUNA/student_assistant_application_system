// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/student_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/auth/auth_wrapper.dart';
import 'config/supabase_config.dart';

/// Async entry point — must initialise Supabase before runApp.(MA NKUNA)
// Ensure Flutter engine is ready before calling platform channels.(MA-NKUNA)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  ); // Connect the Supabase client using the project URL and anon key.(MA-NKUNA)
  runApp(const MyApp());
}

/// Root widget. Sets up global Providers and the MaterialApp.(MA-NKUNA)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthViewModel is created and immediately calls init() to restore any(MA-NKUNA)
        // existing Supabase session.(MA-NKUNA)
        ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
        // ApplicationViewModel manages the list of applications for the(MA-NKUNA)
        // current user (or all applications for an admin).(MA-NKUNA)
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        // StudentViewModel mirrors student-specific state derived from AuthViewModel(MA-NKUNA)
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
      ],
      // Consumer<AuthViewModel> rebuilds whenever auth state changes so the(MA-NKUNA)
      // correct home screen is shown after login/logout.(MA-NKUNA)
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          // Connect StudentViewModel with AuthViewModel when authVM is ready

          // Wire StudentViewModel to AuthViewModel so it always reflects the(MA-NKUNA)
          // current logged-in student without an extra Supabase round-trip.(MA-NKUNA)
          final studentVM = context.read<StudentViewModel>();
          studentVM.initialize(authVM);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Student Assistant',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              useMaterial3: true,
            ),
            // AuthWrapper decides whether to show login, student home, or admin(MA-NKUNA)
            // dashboard based on the current auth state.(MA-NKUNA)
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
