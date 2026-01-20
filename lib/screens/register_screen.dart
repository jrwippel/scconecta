import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final nome = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (nome.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMsg("Preencha todos os campos.");
      return;
    }

    if (password != confirm) {
      _showMsg("As senhas não coincidem.");
      return;
    }

    setState(() => _isLoading = true);

    // Passando o nome para o serviço salvar no Firebase
    String? error = await _authService.cadastrar(email, password, nome);

    if (mounted) {
      setState(() => _isLoading = false);

      if (error == null) {
        _showMsg("Conta criada com sucesso!", isError: false);
        Navigator.pop(context); 
      } else {
        _showMsg(error);
      }
    }
  }

  void _showMsg(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.redAccent : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("CRIAR CONTA", 
          style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildField("NOME COMPLETO", false, _nameController),
            const SizedBox(height: 20),
            _buildField("E-MAIL", false, _emailController),
            const SizedBox(height: 20),
            _buildField("SENHA", true, _passwordController),
            const SizedBox(height: 20),
            _buildField("CONFIRMAR SENHA", true, _confirmPasswordController),
            const SizedBox(height: 40),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.black)
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _handleRegister,
                    child: const Text("Finalizar Cadastro", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, bool isPass, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPass,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }
}