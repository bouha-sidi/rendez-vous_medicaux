import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/wave_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_buttons.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool remember = false;
  bool hide = true;
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final data = await Api.login(email: email, password: pass);

      // backend renvoie: user.role = "patient" | "doctor" | "admin"
      final roleRaw = data["user"]?["role"] ?? "";
      final role = roleRaw.toString().trim().toLowerCase();

      debugPrint("LOGIN ROLE => $role");

      if (!mounted) return;

      // ✅ IMPORTANT:
      // pushNamedAndRemoveUntil => efface l'historique de navigation
      // donc "Back" ne revient pas au login.
      if (role == "patient") {
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/patient",
          (route) => false,
        );
      } else if (role == "doctor" || role == "medecin" || role == "médecin") {
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/doctor",
          (route) => false,
        );
      } else if (role == "admin") {
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/admin",
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rôle inconnu: $role")),
        );
      }
    } catch (e) {
      final msg = e
          .toString()
          .replaceAll("Exception:", "")
          .replaceAll("Exception", "")
          .trim();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.isEmpty ? "Erreur login" : msg)),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          WaveHeader(
            height: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.local_hospital, size: 72, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "MED-RENDEZVOUS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              "Welcome back !",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                AppTextField(controller: emailCtrl, hint: "Email"),
                const SizedBox(height: 12),
                AppTextField(
                  controller: passCtrl,
                  hint: "Password",
                  obscure: hide,
                  suffix: IconButton(
                    onPressed: () => setState(() => hide = !hide),
                    icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: remember,
                      onChanged: (v) => setState(() => remember = v ?? false),
                    ),
                    const Text("Remember me"),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // plus tard: page reset password
                      },
                      child: const Text("Forget password?"),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                OutlinePurpleButton(
                  text: loading ? "Connexion..." : "Login",
                  onTap: loading ? null : handleLogin,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New user? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFF6A35FF),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
