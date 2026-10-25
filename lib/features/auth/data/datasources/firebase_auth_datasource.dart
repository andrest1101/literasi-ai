import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase and Google SDK boundary for authentication.
class FirebaseAuthDatasource {
  FirebaseAuthDatasource({
    firebase.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? firebase.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final firebase.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  static firebase.FirebaseAuth get firebaseAuth =>
      firebase.FirebaseAuth.instance;

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
    final credential = firebase.GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
    );
    final current = _auth.currentUser;
    if (current?.isAnonymous == true) {
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

  Future<void> signOut() async {
    await _auth.signOut();
    // Firebase is the source of truth for the app session. Google cleanup is
    // best-effort and must not turn a successful Firebase logout into failure.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
