import 'package:flutter/material.dart';
import 'package:mofi_app/services/api.dart'; // Ensure correct import if needed for future use

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  String userName = "Patient";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Optional: Load user name from API or LocalStorage if not already available
    // For now we keep it simple or fetch profile
    try {
      final profile = await Api.getProfile();
      if (mounted) {
        setState(() {
          userName = profile["fullName"] ?? "Patient";
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          "Espace Patient",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // futur : notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Api.logout().then((_) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF6A35FF),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bonjour, $userName 👋",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Comment allez-vous aujourd'hui ?",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Que souhaitez-vous faire ?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 16),

              // ---------- QUICK ACTIONS ----------
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Plus d'espace vertical (1.1 -> 1.0)
                children: [
                  _DashboardCard(
                    icon: Icons.search_rounded,
                    title: "Chercher",
                    subtitle: "Médecins & Spécialistes",
                    color: const Color(0xFF6A35FF),
                    onTap: () {
                      Navigator.pushNamed(context, "/patient/doctors");
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.calendar_month_rounded,
                    title: "Rendez-vous",
                    subtitle: "Gérer planning",
                    color: const Color(0xFF00C853),
                    onTap: () {
                      Navigator.pushNamed(context, "/patient/my-appointments");
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.history_rounded,
                    title: "Historique",
                    subtitle: "Comptes-rendus",
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      Navigator.pushNamed(context, "/patient/history");
                    },
                  ),
                  _DashboardCard(
                    icon: Icons.person_rounded,
                    title: "Profil",
                    subtitle: "Mes infos",
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.pushNamed(context, "/patient/profile");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40), // Espace de sécurité en bas
            ],
          ),
        ),
      ),
    );
  }
}

// ================== CARD COMPONENT ==================

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
