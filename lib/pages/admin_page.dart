import 'package:flutter/material.dart';
import '../services/api.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool loading = true;
  List<dynamic> pendingDoctors = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => loading = true);
    try {
      pendingDoctors = await Api.getPendingDoctors();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _verifyDoctor(int id) async {
    try {
      await Api.verifyDoctor(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Médecin validé")),
      );
      await _loadPending();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin • Validation Médecins"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _loadPending,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: "Logout",
            onPressed: () async {
              await Api.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, "/login");
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pendingDoctors.isEmpty
              ? const Center(child: Text("Aucun médecin en attente ✅"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pendingDoctors.length,
                  itemBuilder: (_, i) {
                    final d = pendingDoctors[i] as Map<String, dynamic>;
                    final id = d["id"] as int;

                    final fullName = (d["fullName"] ?? "").toString();
                    final specialty = (d["specialty"] ?? "").toString();
                    final email = (d["email"] ?? "").toString();
                    final phone = (d["phone"] ?? "").toString();
                    final address = (d["clinicAddress"] ?? "").toString();
                    final price = (d["consultationPrice"] ?? "").toString();
                    final photo = (d["doctorPhoto"] ?? "").toString();

                    // نفس PORT في backend
                    final photoUrl = photo.isEmpty
                        ? null
                        : "http://127.0.0.1:3000/uploads/doctors/$photo";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: photoUrl == null
                                      ? null
                                      : NetworkImage(photoUrl),
                                  child: photoUrl == null
                                      ? const Icon(Icons.person, size: 26)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(specialty,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("Email: $email"),
                            Text("Phone: $phone"),
                            Text("Adresse: $address"),
                            Text("Prix: $price"),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _verifyDoctor(id),
                                    icon: const Icon(Icons.verified),
                                    label: const Text("Valider"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
