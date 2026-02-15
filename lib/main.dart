import 'package:flutter/material.dart';
import 'package:khdmti_project/app/theme/light_theme.dart';
import 'package:khdmti_project/routing/router.dart';
import 'package:khdmti_project/utils/localShared/preference_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceManager().init();
  await Supabase.initialize(
      url: "https://fqonjdyhujfdoyzltbje.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxb25qZHlodWpmZG95emx0YmplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExNTY2NjUsImV4cCI6MjA4NjczMjY2NX0.P446LI4e_WuWlZqVqczDkKWj41bfWebkK3kSccGXvPI");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Project',
      theme: lightTheme,
    );
  }
}
