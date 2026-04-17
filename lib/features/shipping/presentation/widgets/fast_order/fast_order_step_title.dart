import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderStepTitle extends StatelessWidget {
  final String step;
  final String title;

  const FastOrderStepTitle({super.key, required this.step, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          child: Text(step, style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: 1.2)),
      ],
    );
  }
}
