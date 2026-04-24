import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 375;
  static const double mobileLg = 480;
  static const double tablet = 768;
  static const double desktopSm = 1024;
  static const double desktop = 1280;
  static const double desktopLg = 1440;
  static const double desktopXl = 1920;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tablet && w < desktopSm;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopSm;

  static bool isDesktopLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopLg;

  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < tablet) return 24;
    if (w < desktopSm) return 48;
    if (w < desktop) return 72;
    return 80;
  }

  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= desktopLg) return 1320;
    if (w >= desktop) return 1200;
    return w;
  }
}
