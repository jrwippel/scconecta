import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Mudamos a forma de instanciar para evitar o erro de construtor
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> cadastrar(String email, String password, String nome) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      await userCredential.user?.updateDisplayName(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Inicia o processo de login
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. Obtém os detalhes da autenticação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Cria a credencial para o Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Retorna o UserCredential do Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Erro detalhado no Google Sign-In: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}