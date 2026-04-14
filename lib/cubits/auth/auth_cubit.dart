import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';
import 'package:flutter/foundation.dart';

class AuthCubit extends Cubit<AuthState>{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(email: user.email ?? ''));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(String email, String password) async {
  emit(AuthLoading());
  try {
    debugPrint('Attempting register for: $email');

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    debugPrint('Register success: ${credential.user?.email}');
    emit(AuthAuthenticated(email: credential.user?.email ?? ''));

  } on FirebaseAuthException catch (e) {
    debugPrint('FirebaseAuthException code: ${e.code}');
    debugPrint('FirebaseAuthException message: ${e.message}');
    emit(AuthError(message: _mapFirebaseError(e.code)));

  } catch (e, stackTrace) {
    // ✅ Print the REAL error
    debugPrint('REAL ERROR: $e');
    debugPrint('STACK TRACE: $stackTrace');
    emit(AuthError(message: e.toString()));  // ← show real error in snackbar
  }
}
  
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try{
      debugPrint('Attempting login for: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      debugPrint('Login success: ${credential.user?.email}');
      emit(AuthAuthenticated(email: credential.user?.email ?? ''));

    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} — ${e.message}');
      emit(AuthError(message: _mapFirebaseError(e.code)));
    } catch (e) {
    debugPrint('Unexpected login error: $e');
    emit(AuthError(message: 'Login failed. Please try again.'));
  }
  }

  Future<void> logout() async{
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void signUp(String text, String text2) {}
}