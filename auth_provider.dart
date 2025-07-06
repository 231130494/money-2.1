// lib/auth/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money/auth/auth_service.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Stream<User?> get authStateChanges => _authService.user; // Getter untuk Stream auth state changes

  AppAuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    String? errorMessage;
    try {
      User? signedInUser = await _authService.signInWithEmailAndPassword(email, password);
      if (signedInUser == null) {
        errorMessage = 'Login gagal. Silakan coba lagi.';
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan tidak dikenal: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
    return errorMessage;
  }

  Future<String?> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    String? errorMessage;
    try {
      User? registeredUser = await _authService.registerWithEmailAndPassword(email, password);
      if (registeredUser == null) {
        errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Terjadi kesalahan tidak dikenal: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
    return errorMessage;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}