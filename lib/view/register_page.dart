import 'package:app_rawg/view/components/custom_button.dart';
import 'package:app_rawg/view/components/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _passwordConfirmController.text;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Todos os campos devem ser preenchidos.";
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "As senhas não coincidem.";
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case "email-already-in-use":
            _errorMessage = "Este email já está cadastrado.";
            break;

          case "invalid-email":
            _errorMessage = "O email informado é inválido.";
            break;

          case "operation-not-allowed":
            _errorMessage = "Cadastro desativado.";
            break;

          case "weak-password":
            _errorMessage = "Senha fraca. (Min. 6+ caracteres)";
            break;

          case "too-many-requests":
            _errorMessage =
                "Muitas tentativas feitas. Aguarde um pouco e tente novamente.";
            break;

          case "user-token-expired":
            _errorMessage =
                "Sessão expirada. Tente novamente fazer login ou registrar.";
            break;

          case "network-request-failed":
            _errorMessage =
                "Falha de conexão. Verifique sua internet e tente de novo.";
            break;

          default:
            _errorMessage = "Erro desconhecido: ${e.message}";
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Cadastro",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: "Email",
                  icon: Icons.email_outlined,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Senha",
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Confirmar senha",
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passwordConfirmController,
                ),
                const SizedBox(height: 30),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),

                CustomButton(
                  text: _isLoading ? "Registrando..." : "Registrar",
                  onTap: _isLoading ? null : registerUser,
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Já tem uma conta? Faça login",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
