/* 
Student Numbers: 223046876, 223000460, 223050336, 223040081, 224000274, 224027806
Student Names: Lehlogonolo Moshoeu, Asanda Sithole, Sandile Pheko, Mvelo Masinga, Mponisi Nkuna, Cedric Motone
Questions: Main entry point of the application. Initializes Supabase, sets up MultiProvider with all ViewModels, and configures the MaterialApp with routing.
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/student_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/auth/auth_wrapper.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          final studentVM = context.read<StudentViewModel>();
          studentVM.initialize(authVM);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Student Assistant',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              useMaterial3: true,
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
