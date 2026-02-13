import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class UiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const UiCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000)),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const PrimaryBtn({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class OutlineBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const OutlineBtn({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status; // pending / accepted / refused
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color c = AppColors.warning;
    String t = "Pending";

    if (s == "accepted" || s == "confirme" || s == "confirmé") {
      c = AppColors.success;
      t = "Accepted";
    } else if (s == "refused" ||
        s == "rejected" ||
        s == "annule" ||
        s == "annulé") {
      c = AppColors.danger;
      t = "Refused";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(t,
          style:
              TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class BlueHeader extends StatelessWidget {
  final Widget child;
  const BlueHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: child,
    );
  }
}
