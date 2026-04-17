import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class HomeSectionTitle extends StatelessWidget {
  final String text;
  const HomeSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), letterSpacing: 1.5),
    );
  }
}
