import 'package:flutter/material.dart';
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
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool remember = false;
  bool hide = true;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
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
                AppTextField(controller: userCtrl, hint: "Username"),
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
                      onPressed: () {},
                      child: const Text("Forget password?"),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                OutlinePurpleButton(
                  text: "Login",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login ✅ (UI only)")),
                    );
                  },
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

                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialCircle(Icons.alternate_email),
                    SizedBox(width: 12),
                    _SocialCircle(Icons.work),
                    SizedBox(width: 12),
                    _SocialCircle(Icons.facebook),
                    SizedBox(width: 12),
                    _SocialCircle(Icons.g_mobiledata),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sign in with another account",
                  style: TextStyle(color: Colors.grey),
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

class _SocialCircle extends StatelessWidget {
  final IconData icon;
  const _SocialCircle(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF6A35FF), width: 1.2),
        color: Colors.white,
      ),
      child: Icon(icon, color: const Color(0xFF6A35FF)),
    );
  }
}
