import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';

class FastOrderCommentField extends StatelessWidget {
  final TextEditingController commentController;

  const FastOrderCommentField({super.key, required this.commentController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
          ),
          child: TextField(
            controller: commentController,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: "Ej: Llevo 50 cajas de cerámica frágil, dimensiones 40x40...",
              hintStyle: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
              contentPadding: const EdgeInsets.all(15),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildWarningBox(context, "RECOMENDACIÓN: Indica si la carga es frágil o voluminosa."),
      ],
    );
  }

  Widget _buildWarningBox(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.warningYellow.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 12, color: AppColors.warningYellow),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color))),
        ],
      ),
    );
  }
}
