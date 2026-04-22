import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in anonymously for guest mode
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use authenticate() for google_sign_in 7.2.0
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Get the authentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential with idToken
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow; // Rethrow to let provider handle the error
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Re-authenticate with email and password
  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  // Re-authenticate with Google
  Future<void> reauthenticateWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // Delete the current Firebase Auth user
  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
