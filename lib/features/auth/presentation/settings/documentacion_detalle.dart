import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class DocumentacionLegalScreen extends StatelessWidget {
  const DocumentacionLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildLegalTile(
              context,
              title: "TÉRMINOS Y CONDICIONES",
              icon: Icons.gavel_rounded,
              content: "Al utilizar Moobox, aceptas que las tarifas de transporte se calculan "
                  "basándose en un precio de Diesel de 9.8 BOB/L en Bolivia. "
                  "Cualquier variación en el precio oficial del combustible podría afectar "
                  "la cotización final del servicio.",
            ),
            _buildLegalTile(
              context,
              title: "POLÍTICA DE ESTIBADORES",
              icon: Icons.groups_rounded,
              content: "El servicio de carga y descarga (estibadores) es opcional y tiene "
                  "un costo fijo basado en el peso: \n"
                  "• Cargas < 3TN: 50 BOB\n"
                  "• Cargas 3TN - 10TN: 85 BOB\n"
                  "• Cargas > 10TN: 125 BOB\n"
                  "Se aplica un recargo de 35 BOB por cada piso/nivel adicional.",
            ),
            _buildLegalTile(
              context,
              title: "POLÍTICA DE PRIVACIDAD",
              icon: Icons.privacy_tip_rounded,
              content: "En Moobox protegemos tus datos personales, incluyendo tu nombre, "
                  "correo electrónico y número de teléfono almacenados en nuestra base "
                  "de datos de Supabase. No compartimos esta información "
                  "con terceros sin tu consentimiento explícito.",
            ),
            _buildLegalTile(
              context,
              title: "SEGURO Y RESPONSABILIDAD",
              icon: Icons.shield_outlined,
              content: "Moobox actúa como plataforma de enlace logístico. La responsabilidad "
                  "sobre la integridad de la carga recae en el transportista asignado, "
                  "quien debe contar con los seguros vigentes según la normativa boliviana.",
            ),
            const SizedBox(height: 40),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES VISUALES ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CENTRO LEGAL",
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "REGLAS Y PRIVACIDAD",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 10),
        Container(width: 40, height: 4, color: AppColors.primaryBlue),
      ],
    );
  }

  Widget _buildLegalTile(BuildContext context, {required String title, required IconData icon, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.5)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textBlack,
          ),
        ),
        iconColor: AppColors.primaryBlue,
        collapsedIconColor: AppColors.textSecondary,
        childrenPadding: const EdgeInsets.all(20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textBlack.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            "Moobox Logistics v1.0.0",
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 5),
          Text(
            "Última actualización: Marzo 2026",
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }
}