import 'package:flutter/material.dart';
import 'package:khdmti_project/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth extends ChangeNotifier {
  static final _supabase = Supabase.instance.client;

  static Future<AuthResponse> createNewUser({required UserModel user}) async {
    return _supabase.auth.signUp(
      email: user.email,
      password: user.password,
      data: {'name': user.fullname},
    );
  }

  static Future<AuthResponse> loginUser({required UserModel user}) async {
    return _supabase.auth.signInWithPassword(
      password: user.password,
      email: user.email,
    );
  }

  final authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;

    final Session? session = data.session;
    switch (event) {
      case AuthChangeEvent.initialSession:
      // handle initial session
      case AuthChangeEvent.signedIn:
      // handle signed in

      case AuthChangeEvent.signedOut:
      case AuthChangeEvent.passwordRecovery:
      // handle password recovery
      case AuthChangeEvent.tokenRefreshed:
      // handle token refreshed
      case AuthChangeEvent.userUpdated:
      // handle user updated

      case AuthChangeEvent.mfaChallengeVerified:
      // handle mfa challenge verified
      case AuthChangeEvent.userDeleted:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  });
}
