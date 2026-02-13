import 'package:flutter/material.dart';
import '../services/api.dart';

// ✅ UI kit
import '../ui/app_colors.dart';
import '../ui/app_styles.dart';
import '../ui/ui_components.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> with TickerProviderStateMixin {
  late TabController tab;

  Map<String, dynamic>? doctor;
  bool loadingProfile = true;

  List pending = [];
  List accepted = [];
  List history = [];
  bool loadingAppointments = true;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 3, vsync: this);
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([
      fetchProfile(),
      fetchAppointments(),
    ]);
  }

  // ✅ LOGOUT (clear stack)
  Future<void> _logout() async {
    await Api.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  // ✅ GET /api/doctor/profile  (supports {data:{...}})
  Future<void> fetchProfile() async {
    setState(() => loadingProfile = true);
    try {
      final res = await Api.getAuth("/doctor/profile");

      Map<String, dynamic> d = {};
      if (res is Map<String, dynamic>) {
        if (res["data"] is Map<String, dynamic>) {
          d = (res["data"] as Map<String, dynamic>);
        } else {
          d = res;
        }
      }

      setState(() {
        doctor = d;
        loadingProfile = false;
      });
    } catch (e) {
      setState(() => loadingProfile = false);
      debugPrint("fetchProfile error: $e");
    }
  }

  // ✅ GET /api/doctor/appointments
  Future<void> fetchAppointments() async {
    setState(() => loadingAppointments = true);
    try {
      final res = await Api.getAuth("/doctor/appointments");
      final list = (res is List) ? res : [];

      final p = <dynamic>[];
      final a = <dynamic>[];
      final h = <dynamic>[];

      for (final rdv in list) {
        final status = (rdv["status"] ?? "pending").toString().toLowerCase();

        if (status == "pending") {
          p.add(rdv);
        } else if (status == "accepted" ||
            status == "confirme" ||
            status == "confirmé") {
          a.add(rdv);
        } else {
          h.add(rdv);
        }
      }

      setState(() {
        pending = p;
        accepted = a;
        history = h;
        loadingAppointments = false;
      });
    } catch (e) {
      setState(() => loadingAppointments = false);
      debugPrint("fetchAppointments error: $e");
    }
  }

  // ✅ PUT /api/doctor/appointments/:id  {status}
  Future<void> updateStatus(int id, String status) async {
    await Api.putAuth("/doctor/appointments/$id", {"status": status});
    await fetchAppointments();
  }

  // ✅ Open profile card (wait for data if empty)
  Future<void> openProfile() async {
    if (loadingProfile || doctor == null || doctor!.isEmpty) {
      await fetchProfile();
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DoctorProfileCardSheet(
        doctor: doctor ?? {},
        onEdit: () {
          Navigator.pop(context);
          _openEditProfile();
        },
        onLogout: () async {
          Navigator.pop(context);
          await _logout();
        },
      ),
    );
  }

  // ✅ Open edit sheet
  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => DoctorProfileEditSheet(
        doctor: doctor ?? {},
        onSaved: () async {
          Navigator.pop(context);
          await fetchProfile();
        },
      ),
    );
  }

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (doctor?["fullName"] ?? "Doctor").toString();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Schedule",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              loadingProfile ? "Loading profile..." : "Dr. $fullName",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.90),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Profil",
            onPressed: openProfile,
            icon: const Icon(Icons.account_circle),
          ),
          IconButton(
            tooltip: "Logout",
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: TabBar(
                controller: tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.subText,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withOpacity(0.10),
                ),
                tabs: const [
                  Tab(text: "Upcoming"),
                  Tab(text: "Accepted"),
                  Tab(text: "History"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: loadingAppointments
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAll,
              child: TabBarView(
                controller: tab,
                children: [
                  AppointmentsListModern(
                    data: pending,
                    emptyText: "No upcoming appointments",
                    showActions: true,
                    onAccept: (id) => updateStatus(id, "accepted"),
                    onRefuse: (id) => updateStatus(id, "refused"),
                  ),
                  AppointmentsListModern(
                    data: accepted,
                    emptyText: "No accepted appointments",
                    showActions: false,
                  ),
                  AppointmentsListModern(
                    data: history,
                    emptyText: "History is empty",
                    showActions: false,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: loadAll,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

// =================== APPOINTMENTS LIST (MODERN) ===================

class AppointmentsListModern extends StatelessWidget {
  final List data;
  final String emptyText;
  final bool showActions;
  final void Function(int id)? onAccept;
  final void Function(int id)? onRefuse;

  const AppointmentsListModern({
    super.key,
    required this.data,
    required this.emptyText,
    required this.showActions,
    this.onAccept,
    this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              emptyText,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (_, i) {
        final rdv = data[i];

        final id = (rdv["id"] is num)
            ? (rdv["id"] as num).toInt()
            : int.tryParse("${rdv["id"]}") ?? 0;

        final patient = (rdv["patientName"] ??
                rdv["patient_fullName"] ??
                rdv["patient"] ??
                "Patient")
            .toString();

        final date = (rdv["date"] ?? rdv["appointmentDate"] ?? "").toString();
        final time = (rdv["time"] ?? rdv["appointmentTime"] ?? "").toString();
        final status = (rdv["status"] ?? "pending").toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: UiCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient, style: AppStyles.h2),
                      const SizedBox(height: 4),
                      Text("$date • $time", style: AppStyles.sub),
                      const SizedBox(height: 8),
                      StatusChip(status: status),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (showActions)
                  Column(
                    children: [
                      IconButton(
                        tooltip: "Accept",
                        onPressed: () => onAccept?.call(id),
                        icon: const Icon(Icons.check_circle,
                            color: AppColors.success),
                      ),
                      IconButton(
                        tooltip: "Refuse",
                        onPressed: () => onRefuse?.call(id),
                        icon: const Icon(Icons.cancel, color: AppColors.danger),
                      ),
                    ],
                  )
                else
                  const Icon(Icons.chevron_right, color: AppColors.subText),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =================== PROFILE CARD SHEET ===================

class DoctorProfileCardSheet extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onEdit;
  final Future<void> Function() onLogout;

  const DoctorProfileCardSheet({
    super.key,
    required this.doctor,
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = (doctor["fullName"] ?? "Doctor").toString();
    final email = (doctor["email"] ?? "-").toString();
    final phone = (doctor["phone"] ?? "-").toString();
    final specialty = (doctor["specialty"] ?? "-").toString();
    final clinic = (doctor["clinicAddress"] ?? "-").toString();
    final price = (doctor["consultationPrice"] ?? "-").toString();

    final doctorPhoto = (doctor["doctorPhoto"] ?? "").toString();
    final directUrl = (doctor["doctorPhotoUrl"] ?? "").toString();

    final photoUrl =
        directUrl.isNotEmpty ? directUrl : Api.doctorPhotoUrl(doctorPhoto);
    final hasPhoto = photoUrl.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                blurRadius: 30,
                offset: Offset(0, 14),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFFEFF6FF),
                      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                      child: !hasPhoto
                          ? const Icon(Icons.person,
                              size: 34, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dr. $fullName", style: AppStyles.h2),
                          const SizedBox(height: 4),
                          Text(specialty, style: AppStyles.sub),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _miniChip(Icons.email, email),
                              _miniChip(Icons.phone, phone),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: UiCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _infoRow(Icons.location_on, "Clinic", clinic),
                      const SizedBox(height: 10),
                      _infoRow(Icons.payments, "Price", price),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlineBtn(
                        text: "Logout",
                        onTap: () async => await onLogout(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlineBtn(
                        text: "Close",
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryBtn(
                        text: "Modifier",
                        onTap: onEdit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _miniChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.subText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// =================== PROFILE EDIT SHEET ===================

class DoctorProfileEditSheet extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onSaved;

  const DoctorProfileEditSheet({
    super.key,
    required this.doctor,
    required this.onSaved,
  });

  @override
  State<DoctorProfileEditSheet> createState() => _DoctorProfileEditSheetState();
}

class _DoctorProfileEditSheetState extends State<DoctorProfileEditSheet> {
  late final TextEditingController fullName;
  late final TextEditingController email;
  late final TextEditingController phone;
  late final TextEditingController specialty;
  late final TextEditingController clinicAddress;
  late final TextEditingController consultationPrice;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    fullName = TextEditingController(text: "${d["fullName"] ?? ""}");
    email = TextEditingController(text: "${d["email"] ?? ""}");
    phone = TextEditingController(text: "${d["phone"] ?? ""}");
    specialty = TextEditingController(text: "${d["specialty"] ?? ""}");
    clinicAddress = TextEditingController(text: "${d["clinicAddress"] ?? ""}");
    consultationPrice =
        TextEditingController(text: "${d["consultationPrice"] ?? ""}");
  }

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    phone.dispose();
    specialty.dispose();
    clinicAddress.dispose();
    consultationPrice.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      await Api.putAuth("/doctor/profile", {
        "fullName": fullName.text.trim(),
        "email": email.text.trim(),
        "phone": phone.text.trim(),
        "specialty": specialty.text.trim(),
        "clinicAddress": clinicAddress.text.trim(),
        "consultationPrice": int.tryParse(consultationPrice.text.trim()) ?? 0,
      });

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _field("Full name", fullName),
            _field("Email", email),
            _field("Phone", phone),
            _field("Specialty", specialty),
            _field("Clinic address", clinicAddress),
            _field("Consultation price", consultationPrice,
                keyboard: TextInputType.number),
            const SizedBox(height: 10),
            saving
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : PrimaryBtn(text: "Save", onTap: save),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
