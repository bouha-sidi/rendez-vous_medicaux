import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/app_theme.dart';

class PatientMyAppointmentsPage extends StatefulWidget {
  const PatientMyAppointmentsPage({super.key});

  @override
  State<PatientMyAppointmentsPage> createState() =>
      _PatientMyAppointmentsPageState();
}

class _PatientMyAppointmentsPageState extends State<PatientMyAppointmentsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getMyAppointments();
  }

  Future<void> _reload() async {
    setState(() => _future = Api.getMyAppointments());
  }

  Color _statusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case "accepted":
        return "Accepté";
      case "rejected":
        return "Refusé";
      default:
        return "En attente";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes rendez-vous"),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 60),
                  Center(child: Text("❌ ${snap.error}")),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text("Réessayer"),
                  ),
                ],
              );
            }

            final list = snap.data ?? [];

            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      "Aucun rendez-vous",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final a = list[i] as Map<String, dynamic>;
                final doctorName = a["doctorName"] ?? "Doctor";
                final specialty = a["specialty"] ?? "";
                final date = a["appointmentDate"] ?? "";
                final status = (a["status"] ?? "pending").toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              size: 18, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Expanded(child: Text(date)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusText(status),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
