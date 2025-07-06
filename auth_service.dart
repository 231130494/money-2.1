// lib/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Error signIn: ${e.message}");
      rethrow; 
    } catch (e) {
      print("Error signIn: ${e.toString()}");
      throw Exception('An unknown error occurred during sign-in.');
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Error register: ${e.message}");
      rethrow;
    } catch (e) {
      print("Error register: ${e.toString()}");
      throw Exception('An unknown error occurred during registration.');
    }
  }

  Future<void> signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (e) {
      print("Error signOut: ${e.toString()}");
      throw Exception('An error occurred during sign-out.');
    }
  }
}