import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api.dart';
import '../../widgets/app_text_field.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String selectedGender = 'male';
  String? profilePhotoUrl;

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final p = await Api.getProfile();
      if (mounted) {
        String dob = p["date_of_birth"] ?? "";
        if (dob.contains("T")) {
          dob = dob.split("T")[0];
        }

        setState(() {
          nameCtrl.text = p["fullName"] ?? "";
          phoneCtrl.text = p["phone"] ?? "";
          dateCtrl.text = dob;
          addressCtrl.text = p["address"] ?? "";
          selectedGender = p["gender"] ?? "male";
          profilePhotoUrl = p["profilePhoto"];
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => uploadingPhoto = true);
    try {
      final photoPath = await Api.uploadProfilePhoto(picked);
      setState(() => profilePhotoUrl = photoPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo mise à jour"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      await Api.updateProfile(
        fullName: nameCtrl.text,
        phone: phoneCtrl.text,
        dateOfBirth: dateCtrl.text.isNotEmpty ? dateCtrl.text : null,
        address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
        gender: selectedGender,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil mis à jour"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Mon profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Photo de profil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profilePhotoUrl != null
                        ? NetworkImage("${Api.baseServerUrl}$profilePhotoUrl")
                        : null,
                    child: profilePhotoUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  if (uploadingPhoto)
                    const CircularProgressIndicator()
                  else
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6A35FF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),

              // Champs éditables
              TextFormField(
                controller: nameCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? "Le nom est requis" : null,
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? "Le téléphone est requis" : null,
                decoration: InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: dateCtrl,
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
                decoration: InputDecoration(
                  labelText: "Date de naissance",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: "Adresse",
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              // Genre
              Row(
                children: [
                  const Text("Genre : "),
                  Radio<String>(
                    value: "male",
                    groupValue: selectedGender,
                    onChanged: (v) => setState(() => selectedGender = v!),
                  ),
                  const Text("Homme"),
                  Radio<String>(
                    value: "female",
                    groupValue: selectedGender,
                    onChanged: (v) => setState(() => selectedGender = v!),
                  ),
                  const Text("Femme"),
                ],
              ),
              const SizedBox(height: 40),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A35FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Enregistrer les modifications",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
