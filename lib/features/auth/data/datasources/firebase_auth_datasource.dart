import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google membuka pemilih akun tetapi tidak menerbitkan ID token.
///
/// Google Sign-In hanya menerbitkan ID token bila Play Services menemukan
/// OAuth client terdaftar untuk paket + SHA-1 aplikasi (resource
/// `default_web_client_id`). Tanpa token, Firebase tidak bisa memverifikasi
/// identitas, jadi permintaan tidak boleh diteruskan ke backend.
class GoogleIdTokenMissingException implements Exception {
  const GoogleIdTokenMissingException(this.email);

  final String? email;
}

/// Firebase and Google SDK boundary for authentication.
class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    firebase.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? firebase.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final firebase.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  firebase.User? get currentUser => _auth.currentUser;

  Future<firebase.UserCredential> signInWithEmail(
    String email,
    String password,
  ) => _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<firebase.UserCredential> registerWithEmail(
    String email,
    String password,
  ) => _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<firebase.UserCredential> linkAnonymousWithEmail(
    firebase.User user,
    String email,
    String password,
  ) => user.linkWithCredential(
    firebase.EmailAuthProvider.credential(email: email, password: password),
  );

  Future<firebase.User?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final tokens = await account.authentication;
    final idToken = tokens.idToken;
    if (idToken == null || idToken.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[auth] Google tidak mengirim ID token untuk ${account.email}. '
          'Periksa OAuth client Android: paket + SHA-1 harus terdaftar di '
          'Firebase Console dan google-services.json harus memuat '
          'oauth_client bertipe 3 (web client).',
        );
      }
      throw GoogleIdTokenMissingException(account.email);
    }
    final credential = firebase.GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: idToken,
    );
    final current = _auth.currentUser;
    if (current?.isAnonymous == true) {
      // Upgrade tamu tanpa mengganti UID agar data miliknya tetap terikat.
      return (await current!.linkWithCredential(credential)).user;
    }
    return (await _auth.signInWithCredential(credential)).user;
  }

  Future<firebase.UserCredential> signInAnonymously() =>
      _auth.signInAnonymously();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> updateDisplayName(firebase.User user, String name) =>
      user.updateDisplayName(name);

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    // Tanpa sesi tidak ada email untuk diverifikasi; pemanggil selalu berada
    // di layar verifikasi yang hanya bisa dibuka dengan sesi aktif.
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<firebase.User?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    return _auth.currentUser;
  }

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Firebase is the source of truth for the app session. Google cleanup is
    // best-effort and must not turn a successful Firebase logout into failure.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
