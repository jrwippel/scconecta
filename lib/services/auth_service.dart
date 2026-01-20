import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Função para fazer LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      // Retorna a mensagem de erro amigável do Firebase
      return e.message;
    }
  }

  // Função para Criar Conta (Cadastro)

Future<String?> cadastrar(String email, String password, String nome) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    // ESTA LINHA SALVA O NOME NO PERFIL DO USUÁRIO
    await userCredential.user?.updateDisplayName(nome);
    
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  }
}
}