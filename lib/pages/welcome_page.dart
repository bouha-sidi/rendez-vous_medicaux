import 'package:flutter/material.dart';
import '../widgets/wave_header.dart';
import '../widgets/app_buttons.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          WaveHeader(
            height: 320,
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

          const SizedBox(height: 22),
          const Center(
            child: Text(
              "Welcome !",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                GradientButton(
                  text: "Create Account",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinePurpleButton(
                  text: "Login",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          const Center(
            child: Column(
              children: [
                Row(
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
                SizedBox(height: 10),
                Text(
                  "Sign in with another account",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
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
