import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets/wave_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_buttons.dart';
import 'login_page.dart';

enum UserRole { patient, doctor }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserRole role = UserRole.patient;

  // Champs communs
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  // Champs médecin
  final specialtyCtrl = TextEditingController();
  final clinicAddressCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Champs patient (profil détaillé)
  final dateCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String selectedGender = 'male';

  // Password
  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  bool hide1 = true;
  bool hide2 = true;

  bool loading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    specialtyCtrl.dispose();
    clinicAddressCtrl.dispose();
    priceCtrl.dispose();
    dateCtrl.dispose();
    addressCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validation
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        passCtrl.text.isEmpty ||
        pass2Ctrl.text.isEmpty) {
      _showSnackBar("Remplis tous les champs obligatoires.");
      return;
    }

    if (passCtrl.text != pass2Ctrl.text) {
      _showSnackBar("Les mots de passe ne correspondent pas.");
      return;
    }

    if (passCtrl.text.length < 6) {
      _showSnackBar("Le mot de passe doit contenir au moins 6 caractères.");
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailCtrl.text.trim())) {
      _showSnackBar("Adresse email invalide.");
      return;
    }

    if (role == UserRole.doctor) {
      if (specialtyCtrl.text.trim().isEmpty ||
          clinicAddressCtrl.text.trim().isEmpty ||
          priceCtrl.text.trim().isEmpty) {
        _showSnackBar(
          "Pour Médecin, spécialité/adresse/prix sont obligatoires.",
        );
        return;
      }
    }

    setState(() => loading = true);

    try {
      await Api.register(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
        role: role == UserRole.patient ? 'patient' : 'doctor',
        phone: phoneCtrl.text.trim(),
        specialty: role == UserRole.doctor ? specialtyCtrl.text.trim() : null,
        clinicAddress: role == UserRole.doctor
            ? clinicAddressCtrl.text.trim()
            : null,
        consultationPrice: role == UserRole.doctor
            ? int.tryParse(priceCtrl.text.trim())
            : null,
        dateOfBirth: role == UserRole.patient ? dateCtrl.text.trim() : null,
        address: role == UserRole.patient ? addressCtrl.text.trim() : null,
        gender: role == UserRole.patient ? selectedGender : null,
      );

      if (!mounted) return;
      _showSnackBar(
        "Compte créé avec succès ! Connectez-vous.",
        isError: false,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception:", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Create account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 14),

          // Sélecteur de rôle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: _RoleSwitcher(
              role: role,
              onChanged: (r) => setState(() => role = r),
            ),
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                AppTextField(controller: nameCtrl, hint: "Nom complet"),
                const SizedBox(height: 12),
                AppTextField(
                  controller: emailCtrl,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: phoneCtrl,
                  hint: "Téléphone",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                // Champs patient
                if (role == UserRole.patient) ...[
                  AppTextField(
                    controller: dateCtrl,
                    hint: "Date de naissance",
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(
                          const Duration(days: 365 * 18),
                        ),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          dateCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    suffix: const Icon(Icons.calendar_today, size: 20),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: addressCtrl, hint: "Adresse"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Homme"),
                          value: "male",
                          groupValue: selectedGender,
                          onChanged: (v) => setState(() => selectedGender = v!),
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Femme"),
                          value: "female",
                          groupValue: selectedGender,
                          onChanged: (v) => setState(() => selectedGender = v!),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Champs médecin
                if (role == UserRole.doctor) ...[
                  AppTextField(
                    controller: specialtyCtrl,
                    hint: "Spécialité (ex: Cardiologue)",
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: clinicAddressCtrl,
                    hint: "Adresse du cabinet",
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: priceCtrl,
                    hint: "Prix consultation (ex: 500)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                ],

                AppTextField(
                  controller: passCtrl,
                  hint: "Mot de passe",
                  obscure: hide1,
                  suffix: IconButton(
                    onPressed: () => setState(() => hide1 = !hide1),
                    icon: Icon(hide1 ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: pass2Ctrl,
                  hint: "Confirmer mot de passe",
                  obscure: hide2,
                  suffix: IconButton(
                    onPressed: () => setState(() => hide2 = !hide2),
                    icon: Icon(hide2 ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                const SizedBox(height: 18),

                loading
                    ? const CircularProgressIndicator()
                    : GradientButton(
                        text: role == UserRole.patient
                            ? "Créer un compte patient"
                            : "Créer un compte médecin",
                        onTap: _submit,
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Déjà un compte ? Se connecter"),
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

class _RoleSwitcher extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onChanged;
  const _RoleSwitcher({required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleChip(
              selected: role == UserRole.patient,
              text: "Patient",
              icon: Icons.person,
              onTap: () => onChanged(UserRole.patient),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _RoleChip(
              selected: role == UserRole.doctor,
              text: "Médecin",
              icon: Icons.medical_services,
              onTap: () => onChanged(UserRole.doctor),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final bool selected;
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleChip({
    required this.selected,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF6A35FF), Color(0xFF21B6FF)],
                )
              : null,
          color: selected ? null : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF6A35FF),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF6A35FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
