import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveHeader extends StatelessWidget {
  final double height;
  final Widget child;

  /// Décalage en plus sous la status bar
  final double contentTop;

  /// Hauteur de la partie blanche (vague)
  final double waveFactor;

  const WaveHeader({
    super.key,
    required this.height,
    required this.child,
    this.contentTop = 24, // ✅ mieux pour mobile
    this.waveFactor = 0.40, // ✅ moins de blanc = moins de coupure
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: BoxDecoration(gradient: AppTheme.headerGradient()),
          ),

          // Vague blanche en bas
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                height: height * waveFactor,
                color: Colors.white,
              ),
            ),
          ),

          // ✅ Contenu positionné EN HAUT (sans SafeArea)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: topInset + contentTop),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, 40);
    p.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.50, 28);
    p.quadraticBezierTo(size.width * 0.75, 58, size.width, 18);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
