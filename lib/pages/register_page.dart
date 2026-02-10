// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api.dart';
import '../widgets/wave_header.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_buttons.dart';

enum UserRole { patient, doctor }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserRole role = UserRole.patient;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final specialtyCtrl = TextEditingController();
  final clinicAddressCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  final passCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();

  bool hide1 = true;
  bool hide2 = true;
  bool loading = false;

  XFile? doctorPhoto;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    specialtyCtrl.dispose();
    clinicAddressCtrl.dispose();
    priceCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> pickDoctorPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img != null) {
      setState(() => doctorPhoto = img);
    }
  }

  Future<void> _submit() async {
    // ✅ validation
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        passCtrl.text.isEmpty ||
        pass2Ctrl.text.isEmpty) {
      _toast("Remplis tous les champs obligatoires.");
      return;
    }

    if (passCtrl.text != pass2Ctrl.text) {
      _toast("Les mots de passe ne correspondent pas.");
      return;
    }

    if (role == UserRole.doctor) {
      if (specialtyCtrl.text.trim().isEmpty ||
          clinicAddressCtrl.text.trim().isEmpty ||
          priceCtrl.text.trim().isEmpty) {
        _toast("Pour Médecin, spécialité/adresse/prix sont obligatoires.");
        return;
      }
      final price = int.tryParse(priceCtrl.text.trim());
      if (price == null) {
        _toast("Consultation price doit être un nombre.");
        return;
      }
      if (doctorPhoto == null) {
        _toast("Choisis une photo du médecin.");
        return;
      }

      setState(() => loading = true);
      try {
        await Api.registerDoctor(
          fullName: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          password: passCtrl.text,
          specialty: specialtyCtrl.text.trim(),
          clinicAddress: clinicAddressCtrl.text.trim(),
          consultationPrice: price,
          doctorPhoto: doctorPhoto!,
        );

        if (!mounted) return;
        _toast("Compte Médecin créé ✅");
        Navigator.pop(context);
      } catch (e) {
        _toast(e.toString().replaceAll("Exception:", "").trim());
      } finally {
        if (mounted) setState(() => loading = false);
      }
      return;
    }

    // PATIENT
    setState(() => loading = true);
    try {
      await Api.registerPatient(
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: passCtrl.text,
      );

      if (!mounted) return;
      _toast("Compte Patient créé ✅");
      Navigator.pop(context);
    } catch (e) {
      _toast(e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = role == UserRole.doctor;

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
                AppTextField(controller: nameCtrl, hint: "Full name"),
                const SizedBox(height: 12),
                AppTextField(controller: emailCtrl, hint: "Email"),
                const SizedBox(height: 12),
                AppTextField(controller: phoneCtrl, hint: "Phone"),
                const SizedBox(height: 12),

                if (isDoctor) ...[
                  AppTextField(
                    controller: specialtyCtrl,
                    hint: "Specialty (ex: Cardiologue)",
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: clinicAddressCtrl,
                    hint: "Clinic address",
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: priceCtrl,
                    hint: "Consultation price (ex: 500)",
                  ),
                  const SizedBox(height: 12),

                  // ✅ Photo picker
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: loading ? null : pickDoctorPhoto,
                      icon: const Icon(Icons.photo),
                      label: Text(
                        doctorPhoto == null
                            ? "Choisir photo médecin"
                            : "Photo: ${doctorPhoto!.name}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                AppTextField(
                  controller: passCtrl,
                  hint: "Password",
                  obscure: hide1,
                  suffix: IconButton(
                    onPressed: () => setState(() => hide1 = !hide1),
                    icon: Icon(hide1 ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                const SizedBox(height: 12),

                AppTextField(
                  controller: pass2Ctrl,
                  hint: "Confirm password",
                  obscure: hide2,
                  suffix: IconButton(
                    onPressed: () => setState(() => hide2 = !hide2),
                    icon: Icon(hide2 ? Icons.visibility_off : Icons.visibility),
                  ),
                ),

                const SizedBox(height: 18),

                GradientButton(
                  text: loading
                      ? "Création..."
                      : (isDoctor
                            ? "Create Doctor Account"
                            : "Create Patient Account"),
                  onTap: loading ? null : _submit,
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login"),
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
