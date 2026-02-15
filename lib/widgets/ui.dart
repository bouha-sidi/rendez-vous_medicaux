import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle(this.title, {super.key, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selected ? AppTheme.primary.withOpacity(.35) : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18, color: selected ? AppTheme.primary : AppTheme.muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppTheme.primary : AppTheme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (doctor["fullName"] ?? "Doctor").toString();
    final spec = (doctor["specialty"] ?? "").toString();
    final addr = (doctor["clinicAddress"] ?? "").toString();
    final price = (doctor["consultationPrice"] ?? "").toString();
    final photoUrl = (doctor["doctorPhotoUrl"] ??
            doctor["doctorPhotoUrl"] ??
            doctor["doctorPhotoUrl"])
        .toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primary.withOpacity(.15),
              backgroundImage: (doctor["doctorPhotoUrl"] != null &&
                      (doctor["doctorPhotoUrl"] as String).isNotEmpty)
                  ? NetworkImage(doctor["doctorPhotoUrl"])
                  : null,
              child: (doctor["doctorPhotoUrl"] == null ||
                      (doctor["doctorPhotoUrl"] as String).isEmpty)
                  ? const Icon(Icons.person, color: AppTheme.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(spec,
                      style: const TextStyle(
                          color: AppTheme.muted, fontWeight: FontWeight.w600)),
                  if (addr.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(addr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.muted)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                const SizedBox(height: 6),
                Text(price.isEmpty ? "" : "$price MRU",
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
