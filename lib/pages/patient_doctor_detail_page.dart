import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/app_theme.dart';

class PatientDoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const PatientDoctorDetailPage({super.key, required this.doctor});

  @override
  State<PatientDoctorDetailPage> createState() =>
      _PatientDoctorDetailPageState();
}

class _PatientDoctorDetailPageState extends State<PatientDoctorDetailPage> {
  DateTime selected = DateTime.now().add(const Duration(days: 1));
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;
    final id = int.tryParse(d["id"].toString()) ?? 0;

    final name = (d["fullName"] ?? "Doctor").toString();
    final spec = (d["specialty"] ?? "").toString();
    final addr = (d["clinicAddress"] ?? "").toString();
    final price = (d["consultationPrice"] ?? "").toString();

    final urlFromApi = (d["doctorPhotoUrl"] ?? "").toString();
    final filename = (d["doctorPhoto"] ?? "").toString();
    final photoUrl =
        urlFromApi.isNotEmpty ? urlFromApi : Api.doctorPhotoUrl(filename);

    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppTheme.primary.withOpacity(.15),
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? const Icon(Icons.person,
                          color: AppTheme.primary, size: 30)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(spec,
                          style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                          SizedBox(width: 6),
                          Text("4.9",
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          SizedBox(width: 6),
                          Text("(120 reviews)",
                              style: TextStyle(color: AppTheme.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _miniInfo(
                  Icons.location_on, addr.isEmpty ? "Clinic Address" : addr),
              const SizedBox(width: 10),
              _miniInfo(Icons.payments, price.isEmpty ? "-" : "$price MRU"),
            ],
          ),

          const SizedBox(height: 16),
          const Text("Choose date & time",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      initialDate: selected,
                    );
                    if (date == null) return;

                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selected),
                    );
                    if (time == null) return;

                    setState(() {
                      selected = DateTime(date.year, date.month, date.day,
                          time.hour, time.minute);
                    });
                  },
                  child: const Text("Change"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Text("Note (optional)",
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "Write a message..."),
          ),

          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: id == 0
                ? null
                : () async {
                    try {
                      await Api.bookAppointment(
                        doctorId: id,
                        dateTime: selected,
                        note: note.text,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("✅ Appointment request sent (pending)")),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ $e")),
                      );
                    }
                  },
            child: const Text("GET APPOINTMENT"),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
