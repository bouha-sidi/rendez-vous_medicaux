import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/app_theme.dart';
import 'patient_doctor_detail_page.dart';
import 'patient_my_appointments_page.dart';
import 'login_page.dart';

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  late Future<List<dynamic>> _doctorsFuture;

  String q = "";
  int selectedService = 1;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = Api.getDoctors();
  }

  Future<void> _reload() async {
    setState(() => _doctorsFuture = Api.getDoctors());
  }

  void _openProfileMenu(BuildContext context) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text("Mon profil"),
                  subtitle: Text("Gérer compte patient"),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Modifier profil"),
                  onTap: () => Navigator.pop(context, "edit"),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Déconnexion"),
                  onTap: () => Navigator.pop(context, "logout"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (value == "logout") {
      await Api.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } else if (value == "edit") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("➡️ Page Modifier Profil (à connecter)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = const [
      (Icons.local_hospital, "Hospital"),
      (Icons.medical_services, "Doctor"),
      (Icons.medication, "Medicine"),
      (Icons.emergency, "Ambulance"),
    ];

    final w = MediaQuery.of(context).size.width;

    // ✅ Mobile-first responsive grid
    final int crossAxisCount = w < 420
        ? 2
        : w < 700
            ? 3
            : w < 1024
                ? 4
                : 5;

    // ✅ Cards ratio tuned for phone (avoid giant cards)
    final double childAspectRatio = w < 420 ? 0.78 : 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace Patient"),
        actions: [
          IconButton(
            tooltip: "Mes rendez-vous",
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientMyAppointmentsPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "Profil",
            icon: const Icon(Icons.account_circle),
            onPressed: () => _openProfileMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<dynamic>>(
            future: _doctorsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snap.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 60),
                    Center(child: Text("❌ Erreur: ${snap.error}")),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text("Réessayer"),
                    ),
                  ],
                );
              }

              final raw = (snap.data ?? []).cast<dynamic>();
              final doctors =
                  raw.map((e) => (e as Map).cast<String, dynamic>()).where((d) {
                final name = (d["fullName"] ?? "").toString().toLowerCase();
                final spec = (d["specialty"] ?? "").toString().toLowerCase();
                return q.isEmpty || name.contains(q) || spec.contains(q);
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: [
                  // ✅ Search (clean + mobile)
                  TextField(
                    onChanged: (v) =>
                        setState(() => q = v.trim().toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: "Search doctor, specialty...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ✅ Services (no overflow)
                  const Text(
                    "Services",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final s = services[i];
                        final selected = selectedService == i;

                        return InkWell(
                          onTap: () => setState(() => selectedService = i),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 92,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primary.withOpacity(.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primary.withOpacity(.35)
                                    : Colors.black12,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  s.$1,
                                  size: 22,
                                  color: selected
                                      ? AppTheme.primary
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(height: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    s.$2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: selected
                                          ? AppTheme.primary
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ Title + count
                  Row(
                    children: [
                      const Text(
                        "Near Doctor",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${doctors.length}",
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (doctors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Center(child: Text("Aucun médecin trouvé")),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctors.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, i) {
                        final d = doctors[i];
                        return PatientDoctorGridCardCompact(
                          doctor: d,
                          onOpen: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientDoctorDetailPage(doctor: d),
                              ),
                            );
                          },
                          onReserve: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientDoctorDetailPage(doctor: d),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PatientDoctorGridCardCompact extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onOpen;
  final VoidCallback onReserve;

  const PatientDoctorGridCardCompact({
    super.key,
    required this.doctor,
    required this.onOpen,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final name = (doctor["fullName"] ?? "Médecin").toString();
    final specialty = (doctor["specialty"] ?? "").toString();
    final price = (doctor["consultationPrice"] ?? "").toString();

    final urlFromApi = (doctor["doctorPhotoUrl"] ?? "").toString();
    final filename = (doctor["doctorPhoto"] ?? "").toString();
    final photoUrl =
        urlFromApi.isNotEmpty ? urlFromApi : Api.doctorPhotoUrl(filename);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Photo small but nice
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: AppTheme.primary.withOpacity(.08),
                    child: photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.person,
                                color: AppTheme.primary,
                                size: 38,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              color: AppTheme.primary,
                              size: 38,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                  const SizedBox(width: 4),
                  const Text(
                    "4.9",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    price.isEmpty ? "" : "$price MRU",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton(
                  onPressed: onReserve,
                  child: const Text(
                    "Réservez",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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
