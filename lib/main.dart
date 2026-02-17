import 'package:flutter/material.dart';
import 'package:khdmti_project/app/theme/light_theme.dart';
import 'package:khdmti_project/routing/router.dart';
import 'package:khdmti_project/utils/config/constants.dart';
import 'package:khdmti_project/utils/localShared/preference_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceManager().init();
  await Supabase.initialize(
      url: Constants.supabaseUrl, anonKey: Constants.supabaseAnnonKey);
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
