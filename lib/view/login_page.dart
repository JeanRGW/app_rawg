import 'package:app_rawg/view/auth_page.dart';
import 'package:app_rawg/view/components/custom_button.dart';
import 'package:app_rawg/view/components/custom_text_field.dart';
import 'package:app_rawg/view/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signUserIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (email.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = "Preencha email e senha.";
        });
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = "Email inválido.";
            break;

          case 'user-disabled':
            _errorMessage = "Usuário desativado.";
            break;

          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
          case 'INVALID_LOGIN_CREDENTIALS':
            _errorMessage = "Email ou senha incorretos.";
            break;

          case 'too-many-requests':
            _errorMessage =
                "Muitas tentativas. Aguarde um pouco e tente novamente.";
            break;

          case 'network-request-failed':
            _errorMessage = "Sem conexão com a internet.";
            break;

          case 'user-token-expired':
            _errorMessage = "Sessão expirada. Faça login novamente.";
            break;

          case 'operation-not-allowed':
            _errorMessage = "Login por email/senha não está habilitado.";
            break;

          default:
            _errorMessage = "Erro desconhecido: ${e.message}";
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  "RAWG",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 44,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(
                  Icons.videogame_asset,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 100),

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
                  text: _isLoading ? "Entrando..." : "Entrar",
                  onTap: _isLoading ? null : signUserIn,
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => showForgotPasswordDialog(context),
                  child: const Text(
                    "Esqueceu a senha?",
                    style: TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    );
                  },
                  child: const Text(
                    "Não tem uma conta? Registrar",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    AuthPage.isGuest = true;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    );
                  },
                  child: const Text(
                    "Usar como visitante desta vez",
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

  void showForgotPasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    String? message;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> resetPassword() async {
              setState(() {
                isLoading = true;
                message = null;
              });

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: controller.text.trim(),
                );

                setState(() {
                  message = "Email de recuperação enviado!";
                });
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'invalid-email':
                    message = "Email inválido.";
                    break;

                  case 'user-not-found':
                    message = "Usuário não encontrado.";
                    break;

                  case 'network-request-failed':
                    message = "Sem conexão com a internet.";
                    break;

                  case 'too-many-requests':
                    message = "Muitas tentativas. Tente novamente mais tarde.";
                    break;

                  case 'operation-not-allowed':
                    message = "Função de recuperação de senha desabilitada.";
                    break;

                  default:
                    message = "Erro ao enviar email: ${e.message}";
                }
              } catch (_) {
                message = "Erro inesperado ao recuperar senha.";
              } finally {
                setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              backgroundColor: Colors.blueGrey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Recuperar senha",
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Digite seu email",
                      hintStyle: TextStyle(color: Colors.white60),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (message != null)
                    Text(
                      message!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : resetPassword,
                  child: Text(
                    isLoading ? "Enviando..." : "Enviar",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
