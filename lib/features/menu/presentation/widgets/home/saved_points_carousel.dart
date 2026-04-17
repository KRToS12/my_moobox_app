import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_colors.dart';

class SavedPointsCarousel extends StatelessWidget {
  const SavedPointsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    return SizedBox(
      height: 90,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('puntos_frecuentes')
            .stream(primaryKey: ['id_punto'])
            .eq('id_usuario', userId ?? '')
            .order('created_at'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 25, top: 15),
              child: Text("No hay puntos guardados.", style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontWeight: FontWeight.w600)),
            );
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) => _buildPointChip(context, snapshot.data![i]),
          );
        },
      ),
    );
  }

  Widget _buildPointChip(BuildContext context, Map<String, dynamic> point) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              point['nombre_lugar'].toString().toUpperCase(),
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
  }
}
