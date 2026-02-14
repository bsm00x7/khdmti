import 'package:flutter/material.dart';
import 'package:khdmti_project/routing/router.dart';
import 'package:khdmti_project/utils/localShared/preference_manager.dart';
import 'package:khdmti_project/utils/theme/ligth_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceManager().init();
  await Supabase.initialize(
    url: 'https://elpnvbmkkoxwgmnwrjyq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVscG52Ym1ra294d2dtbndyanlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MzUyNjQsImV4cCI6MjA4NjUxMTI2NH0.XhGKtuMWqAHutHsnOuVrB-XxjGS_U0yuIAfwnO62o1I',
  );
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
      theme: ligthTheme,
    );
  }
}
