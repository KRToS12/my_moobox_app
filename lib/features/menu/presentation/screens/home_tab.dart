import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/saved_points_carousel.dart';
import '../widgets/home/home_action_buttons.dart';
import '../widgets/home/available_fleet_carousel.dart';
import '../widgets/home/mission_banner.dart';

class HomeTab extends StatefulWidget {
  final String rol;
  const HomeTab({super.key, required this.rol});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          // Un pequeño delay para que la UI muestre la rueda de carga agradablemente
          await Future.delayed(const Duration(milliseconds: 800));
          // Recarga todo el estado, forzando a los componentes internos a reconstruirse si es necesario
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(onPointAdded: () {
                if (mounted) setState(() {});
              }),
              SavedPointsCarousel(key: UniqueKey()), // Forzamos a remontar para leer la base de datos fresca
              const SizedBox(height: 25),
              const HomeActionButtons(),
              const SizedBox(height: 35),
              const AvailableFleetCarousel(),
              const SizedBox(height: 40),
              const MissionBanner(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}