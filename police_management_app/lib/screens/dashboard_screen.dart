// lib/screens/dashboard_screen.dart
// Issues 5,6,7,8,9,11: Responsive layout, Drawer with 16 classifications,
// Profile icon dropdown, News carousel, functional search, "Case Types" rename.

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:printing/printing.dart';
import '../l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/news_provider.dart';
import '../services/firestore_service.dart';
import 'package:khakhi_diary/providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

// Navigation targets for Hamburger Menu
import 'profile_screen.dart';
import 'login_security_screen.dart';
import 'app_settings_screen.dart';
import 'feedback_form_screen.dart';
import 'help_support_screen.dart';
import 'about_app_screen.dart';
import 'add_members_screen.dart';
import 'pending_transfers_screen.dart';
import 'station_access_grants_screen.dart';
import '../utils/case_visibility_ui.dart';
import 'case_form_screen.dart';
import 'form_i_v_selection_screen.dart';
import '../utils/pdf_helper.dart';
import 'case_detail_screen.dart';
import 'ad_record_detail_screen.dart';
import 'module_record_detail_screen.dart';
import 'module_hub_screen.dart';
import '../modules/core/models/base_record.dart';
import '../utils/module_pdf_helper.dart';
import '../utils/pdf_auth_gate.dart';
import 'report_case_list_screen.dart';
import 'my_cases_screen.dart';
import '../utils/police_rbac_helper.dart';
import '../widgets/send_reminder_dialog.dart';
import 'analytics_performance_screen.dart';
import 'module_form_screen.dart';
import 'common_form_screen.dart';
import '../utils/common_form_module.dart';
import '../utils/universal_search.dart';
import '../widgets/voice_search_dialog.dart';
import '../widgets/app_logo.dart';
import '../widgets/bell_icon_widget.dart';
import '../widgets/dashboard_stats_widget.dart';
import '../widgets/form_iv_category_button.dart';
import '../modules/form_iv/providers/form_iv_provider.dart';
import '../modules/form_vi/providers/form_vi_provider.dart';
import '../modules/nc/providers/nc_provider.dart';
import '../modules/missing/screens/missing_form_screen.dart';
import '../modules/nc/screens/nc_form_screen.dart';
import '../modules/preventive/providers/preventive_provider.dart';
import '../modules/ad/providers/ad_provider.dart';
import '../modules/missing/providers/missing_provider.dart';
import '../modules/kidnapping/providers/kidnapping_provider.dart';
import '../modules/theft/providers/theft_provider.dart';
import '../modules/sand_theft/providers/sand_theft_provider.dart';
import '../modules/hurt/providers/hurt_provider.dart';
import '../modules/pocso/providers/pocso_provider.dart';
import '../modules/passport/providers/passport_provider.dart';
import '../modules/monthly/providers/monthly_provider.dart';
import '../modules/pending/providers/pending_provider.dart';
import '../modules/detected/providers/detected_provider.dart';
import '../modules/undetected/providers/undetected_provider.dart';
import '../modules/disposal/providers/disposal_provider.dart';
import '../modules/two_four_wheeler/providers/two_four_wheeler_provider.dart';
import '../modules/arrested/providers/arrested_provider.dart';
import '../modules/absconded/providers/absconded_provider.dart';
import '../modules/crime_women/providers/crime_women_provider.dart';
import '../modules/juvenile/providers/juvenile_provider.dart';
import '../modules/victim/providers/victim_provider.dart';
import '../modules/accident/providers/accident_provider.dart';
import '../modules/traffic/providers/traffic_provider.dart';
import '../modules/application/providers/application_provider.dart';
import '../modules/sam_warrant/providers/sam_warrant_provider.dart';
import '../modules/muddemal/providers/muddemal_provider.dart';
import '../modules/bnss/providers/bnss_provider.dart';
import '../modules/ndps/providers/ndps_provider.dart';
import '../modules/gowans/providers/gowans_provider.dart';
import '../modules/it_act/providers/it_act_provider.dart';
import '../modules/mcoca/providers/mcoca_provider.dart';
import '../modules/uapa/providers/uapa_provider.dart';
import '../modules/mpda/providers/mpda_provider.dart';
import '../modules/coin/providers/coin_provider.dart';
import '../data/india_districts_repository.dart';
import '../data/india_states.dart';
import '../data/maharashtra_police_stations_repository.dart';
import '../widgets/searchable_picker_field.dart';

dynamic _dashboardTileIcon(String label, dynamic fallback) {
  final k = label.replaceAll('\n', ' ').trim();
  switch (k) {
    case 'Monthly':
      return FontAwesomeIcons.calendarDay;
    case 'Pending':
      return FontAwesomeIcons.solidClock;
    case 'Detected':
      return FontAwesomeIcons.certificate;
    case 'Undetected':
      return FontAwesomeIcons.magnifyingGlassMinus;
    case 'Disposal':
      return FontAwesomeIcons.clipboardCheck;
    case 'I to V':
      return FontAwesomeIcons.fileLines;
    case 'VI':
      return FontAwesomeIcons.fileLines;
    case 'Prohibition':
      return FontAwesomeIcons.bottleDroplet;
    case 'Gambling':
      return FontAwesomeIcons.dice;
    case 'A.D':
      return FontAwesomeIcons.triangleExclamation;
    case 'Hurt':
      return FontAwesomeIcons.userInjured;
    case 'Theft':
      return FontAwesomeIcons.userSecret;
    case 'Sand Theft':
      return FontAwesomeIcons.truck;
    case 'Two/Four Wheeler':
      return FontAwesomeIcons.motorcycle;
    case 'Kidnapping':
      return FontAwesomeIcons.userMinus;
    case 'Missing':
      return FontAwesomeIcons.magnifyingGlass;
    case 'N.C':
      return FontAwesomeIcons.penToSquare;
    case 'Preventive':
      return FontAwesomeIcons.ban;
    case 'Arrested':
      return FontAwesomeIcons.handcuffs;
    case 'Absconded':
      return FontAwesomeIcons.personRunning;
    case 'POCSO':
      return FontAwesomeIcons.child;
    case 'Crime against Women':
      return FontAwesomeIcons.personDress;
    case 'Juvenile':
      return FontAwesomeIcons.child;
    case 'Victim':
      return FontAwesomeIcons.bandage;
    case 'Accident':
      return FontAwesomeIcons.carBurst;
    case 'Traffic':
      return FontAwesomeIcons.trafficLight;
    case 'Application':
      return FontAwesomeIcons.fileInvoice;
    case 'Sam/Warrant':
      return FontAwesomeIcons.clipboardList;
    case 'Muddemal':
      return FontAwesomeIcons.folderOpen;
    case 'Sec 186/175 (BNSS)':
      return FontAwesomeIcons.scaleBalanced;
    case 'Passport/PVR/Lic':
    case 'Passport/ PVR/Lic':
      return FontAwesomeIcons.idCard;
    case 'NDPS':
      return FontAwesomeIcons.pills;
    case 'Gowans':
      return FontAwesomeIcons.cow;
    case 'IT Act':
      return FontAwesomeIcons.laptop;
    case 'MCOCA':
      return FontAwesomeIcons.userShield;
    case 'UAPA':
      return FontAwesomeIcons.buildingColumns;
    case 'MPDA':
      return FontAwesomeIcons.shieldHalved;
    case 'COIN':
      return FontAwesomeIcons.coins;
    case 'Licence':
      return Icons.assignment_ind_rounded;
    case 'CCTNS':
      return Icons.security_rounded;
    case 'Dial 112':
      return Icons.call_rounded;
    case 'Tadipar':
      return Icons.gavel_rounded;
    case 'History Sheet':
      return Icons.assignment_rounded;
    case 'Repeat Offender':
      return Icons.warning_rounded;
    case 'ITSSO':
      return Icons.description_rounded;
    case 'NAFIS':
      return Icons.fingerprint_rounded;
    case 'DAR':
      return Icons.folder_rounded;
    case 'IRDA':
      return Icons.analytics_rounded;
    case 'E-Learning':
      return Icons.school_rounded;
    default:
      return fallback;
  }
}

Widget _buildGridIcon(
    String label, dynamic fallback, Color color, double size) {
  final labelTrim = label.replaceAll('\n', ' ').trim();

  if (labelTrim == 'I to V') {
    return SvgPicture.asset(
      'assets/icons/1to5.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'VI') {
    return SvgPicture.asset(
      'assets/icons/6.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Pending') {
    return SvgPicture.asset(
      'assets/icons/pending.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Gambling') {
    return SvgPicture.asset(
      'assets/icons/gambling.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Juvenile') {
    return SvgPicture.asset(
      'assets/icons/juvenile.svg',
      width: size * 2.2,
      height: size * 2.2,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim.toLowerCase().replaceAll(' ', '') == 'sandtheft') {
    return SvgPicture.asset(
      'assets/icons/sandtheft.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Undetected') {
    return SvgPicture.asset(
      'assets/icons/undetected.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Hurt') {
    return SvgPicture.asset(
      'assets/icons/hurt.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Kidnapping') {
    return SvgPicture.asset(
      'assets/icons/kidnapping.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Missing') {
    return SvgPicture.asset(
      'assets/icons/missing.svg',
      width: size * 2.1,
      height: size * 2.1,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'N.C') {
    return SvgPicture.asset(
      'assets/icons/nc.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Arrested') {
    return SvgPicture.asset(
      'assets/icons/arrested.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'POCSO') {
    return SvgPicture.asset(
      'assets/icons/pocso.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Crime against Women') {
    return SvgPicture.asset(
      'assets/icons/crimewomen.svg',
      width: size * 2.2,
      height: size * 2.2,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Victim') {
    return SvgPicture.asset(
      'assets/icons/victim.svg',
      width: size * 2.2,
      height: size * 2.2,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'A.D') {
    return SvgPicture.asset(
      'assets/icons/ad.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Prohibition') {
    return SvgPicture.asset(
      'assets/icons/prohibiton.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Theft') {
    return SvgPicture.asset(
      'assets/icons/theft.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Two/Four Wheeler') {
    return SvgPicture.asset(
      'assets/icons/2-4wheeler.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Sam/Warrant') {
    return SvgPicture.asset(
      'assets/icons/sam-warrants.svg',
      width: size * 2.2,
      height: size * 2.2,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Muddemal') {
    return SvgPicture.asset(
      'assets/icons/muddemal.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'RTI') {
    return SvgPicture.asset(
      'assets/icons/rti.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Passport/PVR' ||
      labelTrim == 'Passport/PVR/Lic' ||
      labelTrim.contains('Passport')) {
    return SvgPicture.asset(
      'assets/icons/passport.svg',
      width: size * 2.2,
      height: size * 2.2,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'NDPS') {
    return SvgPicture.asset(
      'assets/icons/ndps.svg',
      width: size * 2.5,
      height: size * 2.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Gowans') {
    return SvgPicture.asset(
      'assets/icons/gowans.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'IT Act' || labelTrim == 'ITact') {
    return SvgPicture.asset(
      'assets/icons/itact.svg',
      width: size * 2.1,
      height: size * 2.1,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'MCOCA' || labelTrim == 'MACOCA') {
    return SvgPicture.asset(
      'assets/icons/macoca.svg',
      width: size * 2.1,
      height: size * 2.1,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'UAPA') {
    return SvgPicture.asset(
      'assets/icons/uapa.svg',
      width: size * 2.1,
      height: size * 2.1,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'MPDA') {
    return SvgPicture.asset(
      'assets/icons/mpda.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'COIN') {
    return SvgPicture.asset(
      'assets/icons/coin.svg',
      width: size * 2.1,
      height: size * 2.1,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'MV Act' ||
      labelTrim == 'M V Act' ||
      labelTrim == 'MVact' ||
      labelTrim == 'M.V Act') {
    return SvgPicture.asset(
      'assets/icons/mvact.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Accident') {
    return SvgPicture.asset(
      'assets/icons/accident.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Detected') {
    return SvgPicture.asset(
      'assets/icons/detected.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Disposal') {
    return SvgPicture.asset(
      'assets/icons/disposal.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Monthly') {
    return SvgPicture.asset(
      'assets/icons/monthly.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Absconded') {
    return SvgPicture.asset(
      'assets/icons/absconded.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'CCTNS') {
    return SvgPicture.asset(
      'assets/icons/cctns.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Licence') {
    return SvgPicture.asset(
      'assets/icons/licence.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Tadipar') {
    return SvgPicture.asset(
      'assets/icons/tadipar.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Repeat Offender') {
    return SvgPicture.asset(
      'assets/icons/repeatoffender.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'DAR') {
    return SvgPicture.asset(
      'assets/icons/dar.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'IRDA') {
    return SvgPicture.asset(
      'assets/icons/IRDA.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'ITSSO') {
    return SvgPicture.asset(
      'assets/icons/itsso.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
  for (final tool in ServiceData.dashboardTools) {
    if (labelTrim == tool.label) {
      return _buildServiceIcon(labelTrim, tool.icon, color, size);
    }
  }
  final dynamic icon = _dashboardTileIcon(label, fallback);
  if (icon is IconData) return Icon(icon, color: color, size: size);
  return FaIcon(icon, color: color, size: size);
}

Widget _buildServiceIcon(
    String label, dynamic fallback, Color color, double size) {
  final labelTrim = label.replaceAll('\n', ' ').trim();
  if (labelTrim == 'Tadipar') {
    return SvgPicture.asset(
      'assets/icons/tadipar.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Licence') {
    return SvgPicture.asset(
      'assets/icons/licence.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'MPDA') {
    return SvgPicture.asset(
      'assets/icons/mpda.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Repeat Offender') {
    return SvgPicture.asset(
      'assets/icons/repeatoffender.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Property Recovery') {
    return SvgPicture.asset(
      'assets/icons/muddemal.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'Passport/PVR') {
    return SvgPicture.asset(
      'assets/icons/passport.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'DAR') {
    return SvgPicture.asset(
      'assets/icons/dar.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'IRDA') {
    return SvgPicture.asset(
      'assets/icons/IRDA.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'ITSSO') {
    return SvgPicture.asset(
      'assets/icons/itsso.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  } else if (labelTrim == 'CCTNS') {
    return SvgPicture.asset(
      'assets/icons/cctns.svg',
      width: size * 1.5,
      height: size * 1.5,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
  if (fallback is IconData) return Icon(fallback, color: color, size: size);
  return FaIcon(fallback, color: color, size: size);
}

class CardsIconPainter extends CustomPainter {
  final Color color;
  CardsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background card
    canvas.save();
    canvas.translate(w * 0.65, h * 0.45);
    canvas.rotate(0.3);
    final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.55, height: h * 0.75),
        const Radius.circular(3));
    canvas.drawRRect(bgRect, Paint()..color = color);
    canvas.restore();

    // Foreground card
    canvas.save();
    canvas.translate(w * 0.35, h * 0.55);
    canvas.rotate(-0.15);
    final fgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.6, height: h * 0.8),
        const Radius.circular(3));

    canvas.drawRRect(fgRect, Paint()..color = Colors.white);
    canvas.drawRRect(fgRect, Paint()..color = color);

    final spadePaint = Paint()..color = Colors.white;
    final path = Path();
    final sh = h * 0.3;
    final sw = w * 0.25;

    path.moveTo(0, -sh * 0.5);
    path.cubicTo(sw * 0.8, -sh * 0.1, sw * 0.8, sh * 0.3, sw * 0.4, sh * 0.3);
    path.cubicTo(sw * 0.2, sh * 0.3, 0, sh * 0.1, 0, sh * 0.1);
    path.cubicTo(0, sh * 0.1, -sw * 0.2, sh * 0.3, -sw * 0.4, sh * 0.3);
    path.cubicTo(-sw * 0.8, sh * 0.3, -sw * 0.8, -sh * 0.1, 0, -sh * 0.5);

    path.moveTo(0, sh * 0.1);
    path.lineTo(sw * 0.2, sh * 0.6);
    path.lineTo(-sw * 0.2, sh * 0.6);
    path.close();

    canvas.drawPath(path, spadePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JuvenileIconPainter extends CustomPainter {
  final Color color;
  JuvenileIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headCenterY = h * 0.25;
    final headRadius = w * 0.2;

    // main head
    canvas.drawCircle(Offset(w * 0.5, headCenterY), headRadius, paint);

    // Ears
    canvas.drawCircle(Offset(w * 0.28, headCenterY), headRadius * 0.35, paint);
    canvas.drawCircle(Offset(w * 0.72, headCenterY), headRadius * 0.35, paint);

    // Hair swirl
    final hairPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    final hairPath = Path();
    hairPath.moveTo(w * 0.5, headCenterY - headRadius);
    hairPath.cubicTo(
        w * 0.55,
        headCenterY - headRadius - h * 0.1,
        w * 0.4,
        headCenterY - headRadius - h * 0.1,
        w * 0.48,
        headCenterY - headRadius - h * 0.03);
    canvas.drawPath(hairPath, hairPaint);

    // White strokes for face features
    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    // Left eye (U curve)
    final leftEyePath = Path();
    leftEyePath.moveTo(w * 0.37, headCenterY - h * 0.02);
    leftEyePath.quadraticBezierTo(
        w * 0.42, headCenterY + h * 0.04, w * 0.47, headCenterY - h * 0.02);
    canvas.drawPath(leftEyePath, whiteStroke);

    // Right eye
    final rightEyePath = Path();
    rightEyePath.moveTo(w * 0.53, headCenterY - h * 0.02);
    rightEyePath.quadraticBezierTo(
        w * 0.58, headCenterY + h * 0.04, w * 0.63, headCenterY - h * 0.02);
    canvas.drawPath(rightEyePath, whiteStroke);

    // Smile
    final smilePath = Path();
    smilePath.moveTo(w * 0.42, headCenterY + h * 0.07);
    smilePath.quadraticBezierTo(
        w * 0.5, headCenterY + h * 0.12, w * 0.58, headCenterY + h * 0.07);
    canvas.drawPath(smilePath, whiteStroke);

    // Bottom part: Scale of Justice
    final barY = headCenterY + headRadius + h * 0.02; // Top bar y position
    final scaleBottom = h * 0.95;

    // Top bar
    canvas.drawLine(
        Offset(w * 0.25, barY), Offset(w * 0.75, barY), strokePaint);

    // Central stand (down from bar)
    canvas.drawLine(Offset(w * 0.5, barY),
        Offset(w * 0.5, scaleBottom - h * 0.08), strokePaint);

    // Base (Trapezoid)
    final basePath = Path();
    basePath.moveTo(w * 0.38, scaleBottom - h * 0.08);
    basePath.lineTo(w * 0.62, scaleBottom - h * 0.08);
    basePath.lineTo(w * 0.7, scaleBottom);
    basePath.lineTo(w * 0.3, scaleBottom);
    basePath.close();
    canvas.drawPath(basePath, paint);

    // Strings
    final stringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final panY = h * 0.78; // Y where strings meet the pan

    // Left strings
    canvas.drawLine(
        Offset(w * 0.25, barY), Offset(w * 0.15, panY), stringPaint);
    canvas.drawLine(
        Offset(w * 0.25, barY), Offset(w * 0.35, panY), stringPaint);

    // Left pan (semi circle)
    final leftPanPath = Path();
    leftPanPath.arcTo(
      Rect.fromLTRB(w * 0.15, panY - (w * 0.1), w * 0.35, panY + (w * 0.1)),
      0,
      3.14159265359,
      false,
    );
    leftPanPath.close();
    canvas.drawPath(leftPanPath, paint);

    // Right strings
    canvas.drawLine(
        Offset(w * 0.75, barY), Offset(w * 0.65, panY), stringPaint);
    canvas.drawLine(
        Offset(w * 0.75, barY), Offset(w * 0.85, panY), stringPaint);

    // Right pan
    final rightPanPath = Path();
    rightPanPath.arcTo(
      Rect.fromLTRB(w * 0.65, panY - (w * 0.1), w * 0.85, panY + (w * 0.1)),
      0,
      3.14159265359,
      false,
    );
    rightPanPath.close();
    canvas.drawPath(rightPanPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SandTheftIconPainter extends CustomPainter {
  final Color color;
  SandTheftIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final chassisYTop = h * 0.75;
    final chassisYBot = h * 0.85;

    // 1. Wheels
    final r = w * 0.12;
    canvas.drawCircle(Offset(w * 0.25, h * 0.8), r, strokePaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.8), r, strokePaint);

    // 2. Chassis
    // Left segment
    canvas.drawLine(Offset(w * 0.05, chassisYTop),
        Offset(w * 0.13, chassisYTop), strokePaint);
    canvas.drawLine(Offset(w * 0.05, chassisYBot),
        Offset(w * 0.13, chassisYBot), strokePaint);
    canvas.drawLine(Offset(w * 0.05, chassisYTop),
        Offset(w * 0.05, chassisYBot), strokePaint);

    // Middle segment
    canvas.drawLine(Offset(w * 0.37, chassisYTop),
        Offset(w * 0.63, chassisYTop), strokePaint);
    canvas.drawLine(Offset(w * 0.37, chassisYBot),
        Offset(w * 0.63, chassisYBot), strokePaint);

    // Right segment
    canvas.drawLine(Offset(w * 0.87, chassisYTop),
        Offset(w * 0.95, chassisYTop), strokePaint);
    canvas.drawLine(Offset(w * 0.87, chassisYBot),
        Offset(w * 0.95, chassisYBot), strokePaint);
    canvas.drawLine(Offset(w * 0.95, chassisYTop),
        Offset(w * 0.95, chassisYBot), strokePaint);

    // 3. Cab
    final cabPath = Path();
    cabPath.moveTo(w * 0.6, chassisYTop);
    cabPath.lineTo(w * 0.6, h * 0.3);
    cabPath.lineTo(w * 0.8, h * 0.3);
    cabPath.lineTo(w * 0.95, h * 0.55);
    cabPath.lineTo(w * 0.95, chassisYTop);
    canvas.drawPath(cabPath, strokePaint);

    // Cab window
    final winPath = Path();
    winPath.moveTo(w * 0.68, h * 0.38);
    winPath.lineTo(w * 0.78, h * 0.38);
    winPath.lineTo(w * 0.86, h * 0.52);
    winPath.lineTo(w * 0.68, h * 0.52);
    winPath.close();
    canvas.drawPath(winPath, strokePaint);

    // 4. Dump Bed
    final bedPath = Path();
    bedPath.moveTo(w * 0.15, chassisYTop);
    bedPath.lineTo(w * 0.05, h * 0.4);
    bedPath.lineTo(w * 0.45, h * 0.2);
    bedPath.lineTo(w * 0.55, h * 0.15);
    bedPath.lineTo(w * 0.55, h * 0.5);
    bedPath.close();
    canvas.drawPath(bedPath, strokePaint);

    // 5. Hydraulic Arm
    canvas.drawLine(
        Offset(w * 0.4, chassisYTop), Offset(w * 0.35, h * 0.6), strokePaint);

    // 6. Sand load (wavy line)
    final sandPath = Path();
    sandPath.moveTo(w * 0.1, h * 0.45);
    sandPath.quadraticBezierTo(w * 0.2, h * 0.35, w * 0.3, h * 0.45);
    sandPath.quadraticBezierTo(w * 0.4, h * 0.55, w * 0.5, h * 0.45);
    canvas.drawPath(sandPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class UndetectedIconPainter extends CustomPainter {
  final Color color;
  UndetectedIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.round;

    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = w * 0.6;
    final cy = h * 0.4;
    final r = w * 0.35;

    // Handle
    final handleStartX = cx - r * 0.707;
    final handleStartY = cy + r * 0.707;
    final handleEndX = w * 0.15;
    final handleEndY = h * 0.85;

    // Draw handle
    canvas.drawLine(Offset(handleStartX, handleStartY),
        Offset(handleEndX, handleEndY), handlePaint);

    // Gap
    final gapWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(Offset(handleStartX - w * 0.15, handleStartY - h * 0.15),
        Offset(handleStartX + w * 0.15, handleStartY + h * 0.15), gapWhite);

    // Draw outer circle
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Inner white ring
    canvas.drawCircle(
        Offset(cx, cy),
        r * 0.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.07);

    // X mark
    final xSize = r * 0.3;
    canvas.drawLine(Offset(cx - xSize, cy - xSize),
        Offset(cx + xSize, cy + xSize), whiteStroke);
    canvas.drawLine(Offset(cx + xSize, cy - xSize),
        Offset(cx - xSize, cy + xSize), whiteStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HurtIconPainter extends CustomPainter {
  final Color color;
  HurtIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Knife Handle
    canvas.drawLine(
        Offset(w * 0.82, h * 0.15),
        Offset(w * 0.55, h * 0.42),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.12
          ..strokeCap = StrokeCap.round);

    // 2. Knife Blade
    final blade = Path();
    blade.moveTo(w * 0.62, h * 0.3); // Top-right
    blade.lineTo(w * 0.15, h * 0.77); // Tip
    blade.quadraticBezierTo(
        w * 0.3, h * 0.85, w * 0.52, h * 0.5); // Bottom curve
    blade.close();
    canvas.drawPath(blade, paint);

    // 3. Knife Guards (White Cuts)
    final cutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(
        Offset(w * 0.58, h * 0.28), Offset(w * 0.72, h * 0.42), cutPaint);
    canvas.drawLine(
        Offset(w * 0.54, h * 0.32), Offset(w * 0.68, h * 0.46), cutPaint);

    // 4. Blood Splat
    final splat = Path();
    splat.moveTo(w * 0.35, h * 0.5);
    splat.cubicTo(
        w * 0.35, h * 0.4, w * 0.55, h * 0.4, w * 0.55, h * 0.5); // Top bulge
    splat.cubicTo(
        w * 0.65, h * 0.5, w * 0.65, h * 0.65, w * 0.6, h * 0.65); // Right drip
    splat.cubicTo(w * 0.55, h * 0.65, w * 0.5, h * 0.55, w * 0.45,
        h * 0.6); // Inner curve
    splat.cubicTo(
        w * 0.4, h * 0.75, w * 0.3, h * 0.75, w * 0.3, h * 0.7); // Left drip
    splat.cubicTo(
        w * 0.3, h * 0.6, w * 0.25, h * 0.6, w * 0.35, h * 0.5); // Close

    canvas.drawPath(
        splat,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(splat, paint);

    // 5. Blood Drops
    void drawDrop(double cx, double cy, double s) {
      final drop = Path();
      drop.moveTo(cx, cy - s);
      drop.quadraticBezierTo(cx + s, cy, cx + s, cy + s * 0.5);
      drop.arcToPoint(Offset(cx - s, cy + s * 0.5),
          radius: Radius.circular(s), clockwise: true);
      drop.quadraticBezierTo(cx - s, cy, cx, cy - s);
      canvas.drawPath(drop, paint);

      final inner = Path();
      final innerS = s * 0.4;
      final innerCy = cy + s * 0.35;
      inner.moveTo(cx, innerCy - innerS);
      inner.quadraticBezierTo(
          cx + innerS, innerCy, cx + innerS, innerCy + innerS * 0.5);
      inner.arcToPoint(Offset(cx - innerS, innerCy + innerS * 0.5),
          radius: Radius.circular(innerS), clockwise: true);
      inner.quadraticBezierTo(cx - innerS, innerCy, cx, innerCy - innerS);
      canvas.drawPath(
          inner,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.015);
    }

    drawDrop(w * 0.5, h * 0.78, w * 0.06);
    drawDrop(w * 0.62, h * 0.88, w * 0.045);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KidnappingIconPainter extends CustomPainter {
  final Color color;
  KidnappingIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // --- PERSON ---
    final pStrokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Head
    canvas.drawCircle(Offset(w * 0.75, h * 0.18), w * 0.12, fillPaint);

    // Torso
    canvas.drawLine(
        Offset(w * 0.75, h * 0.32),
        Offset(w * 0.75, h * 0.62),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.2
          ..strokeCap = StrokeCap.round);

    // Legs
    canvas.drawLine(
        Offset(w * 0.67, h * 0.6), Offset(w * 0.67, h * 0.95), pStrokePaint);
    canvas.drawLine(
        Offset(w * 0.83, h * 0.6), Offset(w * 0.83, h * 0.95), pStrokePaint);

    // Arms
    final arms = Path();
    arms.moveTo(w * 0.52, h * 0.15); // left hand
    arms.lineTo(w * 0.52, h * 0.35); // left elbow
    arms.lineTo(w * 0.75, h * 0.38); // shoulders
    arms.lineTo(w * 0.98, h * 0.35); // right elbow
    arms.lineTo(w * 0.98, h * 0.15); // right hand
    canvas.drawPath(arms, pStrokePaint);

    // --- GUN ---
    // Barrel
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(w * 0.08, h * 0.45, w * 0.48, h * 0.57),
            Radius.circular(w * 0.02)),
        fillPaint);

    // Sight bump
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(w * 0.1, h * 0.41, w * 0.15, h * 0.45),
            Radius.circular(w * 0.01)),
        fillPaint);

    // Grip
    final grip = Path();
    grip.moveTo(w * 0.18, h * 0.57); // top right
    grip.lineTo(w * 0.1, h * 0.88); // bottom right
    grip.lineTo(w * 0.0, h * 0.88); // bottom left
    grip.lineTo(w * 0.08, h * 0.57); // top left
    grip.close();
    canvas.drawPath(grip, fillPaint);
    canvas.drawPath(grip, strokePaint..strokeWidth = w * 0.02);

    // Trigger guard
    final guard = Path();
    guard.moveTo(w * 0.18, h * 0.57);
    guard.lineTo(w * 0.18, h * 0.65);
    guard.lineTo(w * 0.35, h * 0.65);
    guard.lineTo(w * 0.35, h * 0.57);
    canvas.drawPath(guard, strokePaint..strokeWidth = w * 0.035);

    // Trigger
    canvas.drawLine(Offset(w * 0.25, h * 0.57), Offset(w * 0.23, h * 0.61),
        strokePaint..strokeWidth = w * 0.02);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ADIconPainter extends CustomPainter {
  final Color color;
  ADIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Puddle
    final puddle = Path();
    puddle.moveTo(w * 0.32, h * 0.63);
    puddle.cubicTo(w * 0.32, h * 0.85, w * 0.55, h * 1.0, w * 0.55, h * 0.75);
    puddle.cubicTo(w * 0.75, h * 0.75, w * 0.8, h * 0.5, w * 0.58, h * 0.37);
    puddle.close();
    canvas.drawPath(puddle, fillPaint);

    // 2. Small drop
    canvas.drawCircle(Offset(w * 0.7, h * 0.82), w * 0.05, fillPaint);

    // 3. Diagonal Line
    canvas.drawLine(
        Offset(w * 0.1, h * 0.85),
        Offset(w * 0.7, h * 0.25),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.05
          ..strokeCap = StrokeCap.round);

    // 4. Person Head
    canvas.drawCircle(Offset(w * 0.7, h * 0.18), w * 0.08, fillPaint);

    // 5. Torso
    canvas.drawLine(
        Offset(w * 0.62, h * 0.28),
        Offset(w * 0.42, h * 0.48),
        Paint()
          ..color = color
          ..strokeWidth = w * 0.13
          ..strokeCap = StrokeCap.round);

    // 6. Arms
    // Left arm (front)
    final lArm = Path();
    lArm.moveTo(w * 0.58, h * 0.32); // Start lower on torso
    lArm.lineTo(w * 0.35, h * 0.32); // Left
    lArm.lineTo(w * 0.35, h * 0.46); // Down
    canvas.drawPath(lArm, strokePaint);

    // Right arm (back)
    final rArm = Path();
    rArm.moveTo(w * 0.62, h * 0.28); // Start at shoulder
    rArm.lineTo(w * 0.72, h * 0.45); // Down-right
    rArm.lineTo(w * 0.88, h * 0.28); // Up-right
    canvas.drawPath(rArm, strokePaint);

    // 7. Legs
    // Left leg (in air)
    final lLeg = Path();
    lLeg.moveTo(w * 0.42, h * 0.48); // Start at pelvis
    lLeg.lineTo(w * 0.18, h * 0.48); // Left
    lLeg.lineTo(w * 0.15, h * 0.65); // Down
    canvas.drawPath(lLeg, strokePaint);

    // Right leg (slipping)
    final rLeg = Path();
    rLeg.moveTo(w * 0.42, h * 0.48);
    rLeg.lineTo(w * 0.32, h * 0.62); // Down-left to the line
    canvas.drawPath(rLeg, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshProfileFromFirestore();
    });
  }

  void _onNavTap(int index) {
    if (index == 2) {
      _showAddBottomSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showAddBottomSheet() {
    final isDark = context.read<ThemeProvider>().isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCaseBottomSheet(isDark: isDark),
    );
  }

  // ✅ _updateModuleProviders REMOVED — handled globally by main.dart
  // _syncStationToAllProviders in main.dart injects stationId + createdBy
  // into all providers automatically on login/PIN verify/registration.

  @override
  Widget build(BuildContext context) {
    const bool isDark = false;
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    // ✅ Station injection removed from here — handled in main.dart globally

    final size = MediaQuery.of(context).size;
    final isWide = size.width >= Breakpoints.tablet;

    final pages = [
      _HomeTab(isDark: isDark, auth: auth, onViewAll: () => _onNavTap(3)),
      _WantedTab(isDark: isDark),
      _ViewTab(isDark: isDark),
      _CalendarTab(isDark: isDark),
    ];

    final int pageIndex;
    if (_currentIndex < 2) {
      pageIndex = _currentIndex;
    } else if (_currentIndex == 3) {
      pageIndex = 2;
    } else {
      pageIndex = 3;
    }

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      resizeToAvoidBottomInset: false,
      drawer: !isWide
          ? _buildClassificationDrawer(isWide)
          : null, // Wide screens have persistent profile sidebar, no drawer needed
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: isWide
              ? _buildWideLayout(auth, l10n, pages, pageIndex)
              : _buildNarrowLayout(auth, l10n, pages, pageIndex),
        ),
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNavBar(auth, l10n),
    );
  }

  Widget _buildWideLayout(
      AuthProvider auth, AppLocalizations l10n, List<Widget> pages, int pageIndex) {
    return Row(
      children: [
        _buildWebProfileSidebar(auth,
            l10n), // Persistent profile menu on wide screens (tablet + web)
        Expanded(
          child: Column(
            children: [
              _buildAppBar(auth, showHamburger: false),
              Expanded(
                child: IndexedStack(
                  index: pageIndex,
                  children: pages,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
      AuthProvider auth, AppLocalizations l10n, List<Widget> pages, int pageIndex) {
    return Column(
      children: [
        _buildAppBar(auth, showHamburger: true),
        Expanded(
          child: IndexedStack(
            index: pageIndex,
            children: pages,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(AuthProvider auth, {required bool showHamburger}) {
    final l10n = AppLocalizations.of(
        context)!; // WEB FIX: reuse localized labels for top nav on web
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 420;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 8 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showHamburger)
            Builder(
              builder: (ctx) => IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: Icon(Icons.menu_rounded, color: AppColors.navyDark),
              ),
            ),
          AppLogo(size: isSmallPhone ? 32 : 38),
          SizedBox(width: isSmallPhone ? 4 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('KHAKHI DIARY',
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                          fontSize: isSmallPhone ? 13 : 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: AppColors.navyDark)),
                ),
                Text('Safe • Swift • Secure',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: isSmallPhone ? 8.5 : 9.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.navyMid)),
              ],
            ),
          ),
          SizedBox(width: isSmallPhone ? 4 : 6),
          if (MediaQuery.of(context).size.width >= Breakpoints.tablet) ...[
            // Show top nav items on wide screens (tablet + web)
            const SizedBox(width: 14),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _topNavItem(Icons.home_rounded, l10n.home, 0),
                    const SizedBox(width: 8),
                    _topNavItem(Icons.gps_fixed_rounded, l10n.wanted, 1),
                    const SizedBox(width: 8),
                    _topNavItem(Icons.folder_rounded, l10n.view, 3),
                    const SizedBox(width: 8),
                    _topNavItem(Icons.calendar_month_rounded, l10n.calendar, 4),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          const BellIconWidget(),
          SizedBox(width: isSmallPhone ? 2 : 4),
          _appBarBtn(
            icon: Icons.language_rounded,
            iconColor: AppColors.infoBlue,
            onTap: () => _showLanguageSheet(),
          ),
        ],
      ),
    );
  }

  Widget _topNavItem(IconData icon, String label, int index) {
    // WEB FIX: top navigation items beside title for web parity
    final isActive = _currentIndex == index; // WEB FIX: highlight current tab
    return InkWell(
      // WEB FIX: mouse + touch support on web
      onTap: () => _onNavTap(index), // WEB FIX: reuse existing navigation logic
      borderRadius:
          BorderRadius.circular(AppRadius.lg), // WEB FIX: match pill style
      child: Container(
        // WEB FIX
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // WEB FIX
        decoration: BoxDecoration(
          // WEB FIX
          color: isActive
              ? AppColors.navyMid.withValues(alpha: 0.08)
              : const Color(0xFFF4F6FB), // WEB FIX: subtle active state
          borderRadius: BorderRadius.circular(AppRadius.lg), // WEB FIX
          border: Border.all(
            // WEB FIX
            color: isActive
                ? AppColors.navyMid.withValues(alpha: 0.25)
                : AppColors.lightBorder, // WEB FIX
          ), // WEB FIX
        ), // WEB FIX
        child: Row(
          // WEB FIX
          mainAxisSize: MainAxisSize.min, // WEB FIX
          children: [
            // WEB FIX
            Icon(icon, size: 18, color: AppColors.navyDark), // WEB FIX
            const SizedBox(width: 8), // WEB FIX
            Text(
              // WEB FIX
              label, // WEB FIX
              style: GoogleFonts.poppins(
                // WEB FIX
                fontSize: 13, // WEB FIX
                fontWeight: FontWeight.w600, // WEB FIX
                color: AppColors.navyDark, // WEB FIX
              ), // WEB FIX
            ), // WEB FIX
          ], // WEB FIX
        ), // WEB FIX
      ), // WEB FIX
    ); // WEB FIX
  }

  Widget _buildDrawerHeader(AuthProvider auth, AppLocalizations l10n,
      {double headerHeight = 180}) {
    // RESPONSIVE FIX: get top padding for status bar / notch
    final topPadding = MediaQuery.of(context).padding.top;
    // Scale avatar and font sizes based on header height
    final isCompact = headerHeight < 160;
    final avatarRadius = isCompact ? 22.0 : 26.0;
    final avatarIconSize = isCompact ? 26.0 : 30.0;
    final nameFontSize = isCompact ? 15.0 : 17.0;
    final topInset = isCompact ? (topPadding + 10) : (topPadding + 14);

    final initial =
        auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'O';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        AppTheme.fadeSlideRoute(page: const ProfileScreen()),
      ),
      child: Container(
        width: double.infinity,
        height: headerHeight + topPadding,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E21), AppColors.navyMid],
          ),
        ),
        child: Stack(
          children: [
            // Background Decorative Element
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                topInset,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Stylized Avatar with Gold Glow and Shield Badge Overlay
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary
                                      .withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: AppColors.goldPrimary,
                              child: auth.profilePhoto.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        auth.profilePhoto,
                                        fit: BoxFit.cover,
                                        width: avatarRadius * 2,
                                        height: avatarRadius * 2,
                                        errorBuilder: (ctx, err, stack) => Text(
                                          initial,
                                          style: GoogleFonts.poppins(
                                            fontSize: avatarIconSize * 0.65,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.navyDark,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      initial,
                                      style: GoogleFonts.poppins(
                                        fontSize: avatarIconSize * 0.65,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.navyDark,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.navyDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.goldPrimary,
                                size: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Name & Station / Designation Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              auth.displayName.isNotEmpty
                                  ? auth.displayName
                                  : 'Officer',
                              style: GoogleFonts.poppins(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (auth.stationName.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.15)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 10,
                                          color: AppColors.goldLight,
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            auth.stationName.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.4,
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (auth.designation.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.goldPrimary
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.goldPrimary
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      auth.designation.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.goldLight,
                                        letterSpacing: 0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'View Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.goldPrimary,
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    const langs = [
      ('🇬🇧 English', 'en'),
      ('🇮🇳 हिंदी', 'hi'),
      ('🇮🇳 मराठी', 'mr'),
      ('🇮🇳 ਪੰਜਾਬੀ', 'pa'),
      ('🇮🇳 தமிழ்', 'ta'),
      ('🇮🇳 తెలుగు', 'te'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.infoBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.language_rounded,
                      color: AppColors.infoBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Select Language',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark)),
              ]),
            ),
            const Divider(height: 1),
            ...langs.map((l) => ListTile(
                  leading: Text(l.$1.split(' ').first,
                      style: const TextStyle(fontSize: 20)),
                  title: Text(l.$1.substring(l.$1.indexOf(' ') + 1),
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightText)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.goldPrimary),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Language set to ${l.$1.substring(l.$1.indexOf(' ') + 1)}',
                          style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: AppColors.infoBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ));
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _appBarBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool badge = false,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.navyDark, size: 20),
          ),
          if (badge)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.dangerRed, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  void _showStationSwitcher(BuildContext context, AuthProvider auth) {
    final firestore = FirestoreService();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _StationSwitcherSheet(
        firestore: firestore,
        auth: auth,
      ),
    );
  }

  Widget _buildClassificationDrawer(bool isWide) {
    final auth = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive drawer width: 85% of screen or 280, whichever is smaller
    final drawerWidth = screenWidth < 330 ? screenWidth * 0.85 : 280.0;
    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false, // header handles its own top padding
        child: _buildProfileMenuContent(
            auth, l10n), // WEB FIX: reuse same menu for drawer + web sidebar
      ),
    );
  }

  Widget _buildWebProfileSidebar(AuthProvider auth, AppLocalizations l10n) {
    // WEB FIX: persistent profile menu sidebar on wide web
    return SizedBox(
      // WEB FIX: fixed sidebar width to match Drawer width
      width: 280, // WEB FIX: match drawer width
      child: Material(
        // WEB FIX: ensure proper ink + theme on web
        color: Colors.white, // WEB FIX: keep same drawer background
        child: _buildProfileMenuContent(
            auth, l10n), // WEB FIX: exact same menu as Android drawer
      ),
    );
  }

  Widget _buildProfileMenuContent(AuthProvider auth, AppLocalizations l10n) {
    // WEB FIX: shared drawer/sidebar content for parity
    // RESPONSIVE FIX: use LayoutBuilder to adapt to available space
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        // Scale header: use ~28% of space but clamp between 130-180
        final headerHeight = (availableHeight * 0.28).clamp(130.0, 180.0);
        return Column(
          children: [
            _buildDrawerHeader(auth, l10n, headerHeight: headerHeight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ── Switch Policestation (senior officers only) ──
                  if (SeniorOfficerRoles.canSwitchLocation(
                      auth.designation)) ...[
                    ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -1),
                      leading: Icon(
                        Icons.swap_horiz_rounded,
                        size: 20,
                        color: auth.isViewingOtherStation
                            ? AppColors.goldPrimary
                            : AppColors.lightText,
                      ),
                      title: Text(
                        'Switch Policestation',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: auth.isViewingOtherStation
                              ? AppColors.goldPrimary
                              : AppColors.lightText,
                        ),
                      ),
                      subtitle: Text(
                        auth.isViewingOtherStation
                            ? 'Viewing: ${auth.stationName}'
                            : auth.stationName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: auth.isViewingOtherStation
                              ? AppColors.goldPrimary.withValues(alpha: 0.8)
                              : AppColors.lightSubText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: auth.isViewingOtherStation
                          ? GestureDetector(
                              onTap: () {
                                auth.resetToHomeStation();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerRed
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  'Reset',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dangerRed,
                                  ),
                                ),
                              ),
                            )
                          : null,
                      onTap: () => _showStationSwitcher(context, auth),
                    ),
                    const Divider(height: 1),
                  ],
                  if (SeniorOfficerRoles.canSwitchLocation(auth.designation) ||
                      auth.isSupervisor ||
                      auth.isAdmin) ...[
                    _drawerItem(
                      Icons.analytics_rounded,
                      'Crime Analytics & Performance',
                      () => Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                          page: const AnalyticsPerformanceScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  if (TransferRequestRoles.canApproveTransfers(auth.designation)) ...[
                    _drawerItem(
                      Icons.pending_actions_rounded,
                      TransferRequestRoles.isPiOrApi(auth.designation)
                          ? 'Pending Transfers'
                          : 'Pending PI Transfers',
                      () => Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                          page: const PendingTransfersScreen(),
                        ),
                      ),
                    ),
                  ],
                  if (TransferRequestRoles.isPiOrApi(auth.designation)) ...[
                    _drawerItem(
                      Icons.dashboard_customize_rounded,
                      'Dashboard access grants',
                      () => Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                          page: const StationAccessGrantsScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  if (TransferRequestRoles.canAssignOfficers(auth.designation))
                    _drawerItem(
                      Icons.person_add_rounded,
                      'Assign Officer',
                      () => Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                            page: const AssignOfficerScreen()),
                      ),
                    ),
                  if (TransferRequestRoles.canAssignOfficers(auth.designation))
                    const Divider(height: 1),
                  _drawerItem(
                    Icons.folder_shared_outlined,
                    'My Cases',
                    () => Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(page: const MyCasesScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    Icons.lock_person_rounded,
                    l10n.loginSecurity,
                    () => Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(
                          page: const LoginSecurityScreen()),
                    ),
                  ),
                  _drawerItem(
                    Icons.settings_rounded,
                    l10n.appSettings,
                    () => Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(page: const AppSettingsScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    Icons.feedback_rounded,
                    l10n.feedback,
                    () => Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(page: const FeedbackFormScreen()),
                    ),
                  ),
                  _drawerItem(
                    Icons.help_rounded,
                    l10n.helpSupport,
                    () => Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(page: const HelpSupportScreen()),
                    ),
                  ),
                  _drawerItem(
                    Icons.info_rounded,
                    l10n.aboutApp,
                    () => Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(page: const AboutAppScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  _drawerItem(
                    Icons.logout_rounded,
                    l10n.logout,
                    () {
                      context
                          .read<SettingsProvider>()
                          .setSkipBiometricAutoTrigger(
                              true); // keep same logout flow
                      auth.logout(); // keep same logout logic
                    },
                    color: AppColors.dangerRed,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    final c = color ?? AppColors.lightText;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(
          vertical: -1), // RESPONSIVE FIX: tighter spacing for small screens
      leading: Icon(icon, size: 20, color: c),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w500, color: c)),
      onTap: onTap, // Removed Navigator.pop to keep drawer open (Persistence)
    );
  }

  Widget _buildBottomNavBar(AuthProvider auth, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, l10n.home, 0),
              _navItem(Icons.gps_fixed_rounded, l10n.wanted, 1),
              GestureDetector(
                onTap: () => _onNavTap(2),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.navyMid.withValues(alpha: 0.5),
                          blurRadius: 14,
                          spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
              _navItem(Icons.folder_rounded, l10n.view, 3),
              _navItem(Icons.calendar_month_rounded, l10n.calendar, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final activeColor = AppColors.navyMid;
    final inactiveColor = AppColors.lightSubText;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? activeColor : inactiveColor)),
          ],
        ),
      ),
    );
  }
}

// ── HOME TAB ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final bool isDark;
  final AuthProvider auth;
  final VoidCallback? onViewAll;
  const _HomeTab({required this.isDark, required this.auth, this.onViewAll});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final FirestoreService _firestore = FirestoreService();
  List<ModuleRecord> _recentRecords = [];
  StreamSubscription? _recentSub;

  Map<String, dynamic> _mapRecordToCaseMap(ModuleRecord r) {
    Color iconColor;
    IconData icon;

    switch (r.moduleKey) {
      case 'form_1_5':
        iconColor = const Color(0xFFE91E63);
        icon = Icons.description_rounded;
        break;
      case 'form_6':
        iconColor = const Color(0xFF9C27B0);
        icon = Icons.assignment_rounded;
        break;
      case 'nc':
        iconColor = const Color(0xFF673AB7);
        icon = Icons.security_rounded;
        break;
      case 'preventive':
        iconColor = const Color(0xFF3F51B5);
        icon = Icons.shield_rounded;
        break;
      case 'ad':
        iconColor = const Color(0xFF2196F3);
        icon = Icons.account_balance_rounded;
        break;
      case 'missing':
        iconColor = const Color(0xFF03A9F4);
        icon = Icons.person_search_rounded;
        break;
      case 'kidnapping':
        iconColor = const Color(0xFF00BCD4);
        icon = Icons.warning_rounded;
        break;
      case 'theft':
        iconColor = const Color(0xFF009688);
        icon = Icons.no_encryption_rounded;
        break;
      case 'sand_theft':
        iconColor = const Color(0xFF4CAF50);
        icon = Icons.terrain_rounded;
        break;
      case 'hurt':
        iconColor = const Color(0xFF8BC34A);
        icon = Icons.local_hospital_rounded;
        break;
      case 'pocso':
        iconColor = const Color(0xFFCDDC39);
        icon = Icons.child_care_rounded;
        break;
      case 'passport':
        iconColor = const Color(0xFFFFEB3B);
        icon = Icons.badge_rounded;
        break;
      default:
        iconColor = AppColors.goldPrimary;
        icon = Icons.folder_rounded;
    }

    Color statusColor;
    switch (r.status.toLowerCase()) {
      case 'open':
        statusColor = AppColors.warningOrange;
        break;
      case 'active':
        statusColor = AppColors.infoBlue;
        break;
      case 'resolved':
        statusColor = AppColors.successGreen;
        break;
      default:
        statusColor = AppColors.infoBlue;
    }

    return {
      'title': r.title,
      'id': r.caseNumber,
      'type': r.moduleKey,
      'date': DateFormat('dd MMM yyyy').format(r.incidentDate),
      'status': r.status,
      'statusColor': statusColor,
      'iconColor': iconColor.toARGB32(),
      'icon': icon,
      'record': r,
    };
  }

  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  SearchFilters _searchFilters = SearchFilters();
  DateTime? _explicitSearchDate;

  /// Memoizes live search across rebuilds triggered by unrelated widgets (e.g. news).
  int? _searchRecordsFingerprint;
  List<SearchResult>? _cachedLiveSearchResults;

  int _carouselPage = 0;
  final CarouselSliderController _carouselCtrl = CarouselSliderController();

  // Tracks the station the recent-cases stream is currently scoped to.
  // The parent passes the SAME AuthProvider instance on every rebuild, so
  // comparing oldWidget.auth.stationName to widget.auth.stationName is
  // always equal. We instead compare against this snapshot to detect a
  // real station switch and re-subscribe so dashboard data is strictly
  // for the currently selected station only.
  String? _subscribedStationName;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureRecentStreamForCurrentStation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureRecentStreamForCurrentStation();
  }

  void _ensureRecentStreamForCurrentStation() {
    final activeStation = widget.auth.stationName;
    if (_subscribedStationName == activeStation) return;
    _clearSearchStateOnStationSwitch();
    _subscribedStationName = activeStation;
    _initRecentStream();
  }

  /// Resets dashboard search UI when the active station changes.
  void _clearSearchStateOnStationSwitch() {
    _debounce?.cancel();
    final hadSearchState = _searchQuery.isNotEmpty ||
        _explicitSearchDate != null ||
        _searchCtrl.text.isNotEmpty;
    if (!hadSearchState) return;

    _searchCtrl.clear();
    _invalidateSearchCache();
    if (mounted) {
      setState(() {
        _searchQuery = '';
        _explicitSearchDate = null;
      });
    }
  }

  void _invalidateSearchCache() {
    _searchRecordsFingerprint = null;
    _cachedLiveSearchResults = null;
  }

  bool get _hasActiveSearch =>
      _searchQuery.isNotEmpty || _explicitSearchDate != null;

  /// Banner showing resolved case visibility mode for the signed-in officer.
  Widget _buildCaseVisibilityBanner() {
    final mode = CaseVisibility.resolveFor(widget.auth);
    final label = CaseVisibility.chipPrefix(mode);
    final showAskPi = CaseVisibility.showAskPiHint(mode);

    return Material(
      elevation: 1,
      shadowColor: AppColors.navyMid.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      color: Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.22)),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.infoBlue.withValues(alpha: 0.07),
              AppColors.navyMid.withValues(alpha: 0.04),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.infoBlue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Case visibility',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSubText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.visibility_rounded,
                    size: 20, color: AppColors.navyMid.withValues(alpha: 0.7)),
              ],
            ),
            if (showAskPi) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ask your PI or API for station-wide dashboard access.',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.infoBlue,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: Text(
                  'Need full station view? Ask your PI for access.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.infoBlue,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.infoBlue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }



  String _moduleDisplayLabel(ModuleRecord record) {
    final name = record.firestoreCategoryDisplayName.trim();
    if (name.isNotEmpty) return name;
    return record.moduleKey.replaceAll('_', ' ');
  }

  String _statusBadgeLabel(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'closed' || s == 'resolved') return 'Disposed';
    if (s == 'open' || s == 'active' || s == 'pending') return 'Pending';
    return status.isEmpty ? 'Active' : status;
  }

  Color _statusBadgeColor(String badgeLabel) {
    switch (badgeLabel.toLowerCase()) {
      case 'disposed':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.warningOrange;
      default:
        return AppColors.infoBlue;
    }
  }

  List<ModuleRecord> _providerRecords<T>(
    BuildContext context, {
    required List<ModuleRecord> Function(T provider) select,
    required bool listen,
  }) {
    if (listen) {
      return select(context.watch<T>());
    }
    return select(context.read<T>());
  }

  List<(String, String, List<ModuleRecord>)> _moduleSourcesFrom(
    BuildContext context, {
    required bool listen,
  }) {
    List<ModuleRecord> rec<T>(
      List<ModuleRecord> Function(T provider) select,
    ) =>
        _providerRecords(context, select: select, listen: listen);

    return [
      ('Form I-V', 'form_1_5', rec<FormIVProvider>((p) => p.records)),
      ('Form VI', 'form_6', rec<FormVIProvider>((p) => p.records)),
      ('NC', 'nc', rec<NcProvider>((p) => p.records)),
      ('Preventive', 'preventive', rec<PreventiveProvider>((p) => p.records)),
      ('AD', 'ad', rec<AdProvider>((p) => p.records)),
      ('Missing', 'missing', rec<MissingProvider>((p) => p.records)),
      ('Kidnapping', 'kidnapping', rec<KidnappingProvider>((p) => p.records)),
      ('Theft', 'theft', rec<TheftProvider>((p) => p.records)),
      ('Sand Theft', 'sand_theft', rec<SandTheftProvider>((p) => p.records)),
      ('Hurt', 'hurt', rec<HurtProvider>((p) => p.records)),
      ('POCSO', 'pocso', rec<PocsoProvider>((p) => p.records)),
      ('Passport/PVR', 'passport', rec<PassportProvider>((p) => p.records)),
      ('Monthly', 'monthly', rec<MonthlyProvider>((p) => p.records)),
      ('Pending', 'pending', rec<PendingProvider>((p) => p.records)),
      ('Detected', 'detected', rec<DetectedProvider>((p) => p.records)),
      ('Undetected', 'undetected', rec<UndetectedProvider>((p) => p.records)),
      ('Disposal', 'disposal', rec<DisposalProvider>((p) => p.records)),
      (
        'Two/Four Wheeler',
        'two_four_wheeler',
        rec<TwoFourWheelerProvider>((p) => p.records),
      ),
      ('Arrested', 'arrested', rec<ArrestedProvider>((p) => p.records)),
      ('Absconded', 'absconded', rec<AbscondedProvider>((p) => p.records)),
      (
        'Crime against Women',
        'crime_women',
        rec<CrimeWomenProvider>((p) => p.records),
      ),
      ('Juvenile', 'juvenile', rec<JuvenileProvider>((p) => p.records)),
      ('Victim', 'victim', rec<VictimProvider>((p) => p.records)),
      ('Accident', 'accident', rec<AccidentProvider>((p) => p.records)),
      ('Traffic', 'traffic', rec<TrafficProvider>((p) => p.records)),
      ('Application', 'application', rec<ApplicationProvider>((p) => p.records)),
      ('Sam Warrant', 'sam_warrant', rec<SamWarrantProvider>((p) => p.records)),
      ('Muddemal', 'muddemal', rec<MuddemalProvider>((p) => p.records)),
      ('BNSS', 'bnss', rec<BnssProvider>((p) => p.records)),
      ('NDPS', 'ndps', rec<NdpsProvider>((p) => p.records)),
      ('Gowans', 'gowans', rec<GowansProvider>((p) => p.records)),
      ('IT Act', 'it_act', rec<ItActProvider>((p) => p.records)),
      ('MCOCA', 'mcoca', rec<McocaProvider>((p) => p.records)),
      ('UAPA', 'uapa', rec<UapaProvider>((p) => p.records)),
      ('MPDA', 'mpda', rec<MpdaProvider>((p) => p.records)),
      ('Coin', 'coin', rec<CoinProvider>((p) => p.records)),
    ];
  }

  int _moduleSourcesFingerprint(
    List<(String, String, List<ModuleRecord>)> sources,
  ) {
    return Object.hashAll(sources.map((source) {
      final records = source.$3;
      if (records.isEmpty) return Object.hash(source.$2, 0);
      var bucket = records.length;
      for (final record in records) {
        bucket = Object.hash(
          bucket,
          record.id,
          record.status,
          record.title,
          record.caseNumber,
          record.complainant,
          record.accused,
        );
      }
      return Object.hash(source.$2, bucket);
    }));
  }

  List<SearchResult> _resolveLiveSearchResults(BuildContext context) {
    final moduleSources = _moduleSourcesFrom(context, listen: true);
    final recordsFingerprint = _moduleSourcesFingerprint(moduleSources);
    final memoKey = Object.hash(
      _searchQuery,
      _explicitSearchDate?.millisecondsSinceEpoch,
      _searchFilters.activeCount,
      recordsFingerprint,
    );
    if (memoKey == _searchRecordsFingerprint &&
        _cachedLiveSearchResults != null) {
      return _cachedLiveSearchResults!;
    }

    final results = UniversalSearch.search(
      query: _searchQuery,
      moduleSources: moduleSources,
      filters: _searchFilters,
      exactDate: _explicitSearchDate,
    );
    _searchRecordsFingerprint = memoKey;
    _cachedLiveSearchResults = results;
    return results;
  }

  void _initRecentStream() {
    _recentSub?.cancel();
    _recentSub = null;
    final activeStation = widget.auth.stationName;
    if (activeStation.isEmpty) {
      if (mounted && _recentRecords.isNotEmpty) {
        setState(() => _recentRecords = []);
      }
      return;
    }
    if (mounted) setState(() => _recentRecords = []);

    _recentSub =
        _firestore.getRecentCasesStream(100, activeStation).listen((data) {
      if (!mounted) return;
      final mode = CaseVisibility.resolveFor(widget.auth);
      final filtered = CaseVisibility.filterRecords(
        data,
        uid: widget.auth.uid,
        mode: mode,
      );
      setState(() => _recentRecords = filtered.take(10).toList());
    });
  }

  @override
  void dispose() {
    _recentSub?.cancel();
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _carouselCtrl.stopAutoPlay();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppTimeouts.searchDebounce, () {
      if (!mounted) return;
      final q = value.trim();
      if (q.isEmpty && _explicitSearchDate == null) {
        setState(() {
          _searchQuery = '';
          _explicitSearchDate = null;
          _invalidateSearchCache();
        });
        return;
      }

      final parsedDate = UniversalSearch.tryParseNaturalDate(q);
      if (parsedDate != null && _explicitSearchDate == null) {
        setState(() {
          _explicitSearchDate = parsedDate;
          _searchQuery = q;
          _invalidateSearchCache();
        });
        return;
      }

      setState(() {
        _searchQuery = q;
        _invalidateSearchCache();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= Breakpoints.tablet;

    final recentCases = _recentRecords
        .where((r) => r.moduleKey != 'form_1_5')
        .map(_mapRecordToCaseMap)
        .toList();
    final top3Cases = recentCases.take(3).toList();
    final width = MediaQuery.of(context).size.width;
    final caseGridCols = width > 1200 ? 3 : (width > 800 ? 2 : 1);
    final searchResults = _hasActiveSearch
        ? _resolveLiveSearchResults(context)
        : const <SearchResult>[];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? AppSpacing.xl : AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildNewsCarousel(newsProvider, isWide),
              const SizedBox(height: AppSpacing.md),
              _buildCaseVisibilityBanner(),
              const SizedBox(height: AppSpacing.md),
              DashboardStatsWidget(auth: widget.auth),
              const SizedBox(height: AppSpacing.lg),
              _buildSearchBar(),
              if (_hasActiveSearch) ...[
                const SizedBox(height: AppSpacing.md),
                _buildMatchingModuleTabs(_searchQuery),
                if (searchResults.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildSearchResults(searchResults),
                ] else if (_matchingModulesCount(_searchQuery) == 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildNoResults(),
                ],
              ],
            ]),
          ),
        ),
        if (!_hasActiveSearch) ...[
          SliverPadding(
            padding: EdgeInsets.symmetric(
                horizontal: isWide ? AppSpacing.xl : AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: _buildThreePartClassification(isWide),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? AppSpacing.xl : AppSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _sectionHeader('Recent Cases', 'Latest record'),
                  const SizedBox(height: AppSpacing.md),
                  if (top3Cases.isEmpty) _buildNoRecentCases(),
                ],
              ),
            ),
          ),
          if (top3Cases.isNotEmpty) ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? AppSpacing.xl : AppSpacing.lg,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: caseGridCols,
                  mainAxisExtent: 128,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _caseCard(top3Cases[i]),
                  childCount: top3Cases.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _showTop10CasesModal(
                      context,
                      recentCases.take(10).toList(),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.navyDark,
                    ),
                    label: Text(
                      'See More',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyDark,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      side: const BorderSide(
                          color: AppColors.navyDark, width: 1.5),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.white,
                      elevation: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildNewsCarousel(NewsProvider news, bool isWide) {
    return Column(
      children: [
        RepaintBoundary(
          child: CarouselSlider.builder(
            carouselController: _carouselCtrl,
            itemCount: news.items.length,
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: AppTimeouts.carouselInterval,
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              autoPlayCurve: Curves.easeInOut,
              onPageChanged: (index, reason) =>
                  setState(() => _carouselPage = index),
            ),
            itemBuilder: (context, i, _) {
              final item = news.items[i];
              final color = Color(item.iconColorHex);
              return _newsCard(item, color);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSmoothIndicator(
          activeIndex: _carouselPage,
          count: news.items.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.navyMid,
            dotColor: AppColors.navyMid.withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }

  Widget _newsCard(NewsItem item, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(item.tag,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
                const SizedBox(height: 6),
                Text(item.title,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.description,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final FocusNode _searchFocusNode = FocusNode();

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocusNode,
        autofocus: false,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        enableSuggestions: true,
        autocorrect: true,
        onChanged: _onSearchChanged,
        style: GoogleFonts.poppins(color: AppColors.lightText, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search cases or type module (e.g. Murder, Theft, Missing)...',
          hintStyle:
              GoogleFonts.poppins(color: AppColors.lightSubText, fontSize: 13),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.navyMid, size: 22),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  color: AppColors.lightSubText,
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _explicitSearchDate = null);
                    _onSearchChanged('');
                  },
                ),
              IconButton(
                icon: const Icon(Icons.mic_rounded, color: AppColors.navyMid),
                tooltip: 'Speak / Voice Search',
                onPressed: () async {
                  final spoken = await VoiceSearchDialog.show(context);
                  if (spoken != null && spoken.trim().isNotEmpty) {
                    final cleanSpoken = spoken.trim();
                    final parsedDate = UniversalSearch.tryParseNaturalDate(cleanSpoken);
                    if (parsedDate != null) {
                      final formatted = DateFormat('dd MMM yyyy').format(parsedDate);
                      setState(() {
                        _explicitSearchDate = parsedDate;
                        _searchQuery = formatted;
                        _searchCtrl.text = formatted;
                        _invalidateSearchCache();
                      });
                    } else {
                      _searchCtrl.text = cleanSpoken;
                      _onSearchChanged(cleanSpoken);
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.calendar_month_rounded,
                    color: _explicitSearchDate != null
                        ? AppColors.goldPrimary
                        : AppColors.navyMid),
                onPressed: () => _showSearchDatePicker(context),
                tooltip: 'Select Custom Date',
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 16),
        ),
      ),
    );
  }

  static const List<Classification> _extraSearchClassifications = [
    Classification('Prohibition', 'admin_panel', 'mpda'),
    Classification('Gambling', 'monetization_on', 'coin'),
    Classification('RTI', 'description', 'application'),
    Classification('M.V Act', 'traffic', 'traffic'),
  ];

  List<({String title, String subtext, IconData icon, VoidCallback onTap})> _matchingMenuShortcuts(String q) {
    final cleanQ = q.toLowerCase().trim();
    if (cleanQ.isEmpty) return [];

    final shortcuts = <({String title, String subtext, List<String> keywords, IconData icon, VoidCallback onTap})>[
      (
        title: 'Total Cases',
        subtext: 'Station Cases (All)',
        keywords: ['total cases', 'total case', 'all cases', 'all case', 'total', 'station cases'],
        icon: Icons.folder_open_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const MyCasesScreen(initialTab: MyCasesTab.total))),
      ),
      (
        title: 'Pending Cases',
        subtext: 'Pending Investigation',
        keywords: ['pending cases', 'pending case', 'pending investigation'],
        icon: Icons.hourglass_top_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const MyCasesScreen(initialTab: MyCasesTab.pending))),
      ),
      (
        title: 'Disposal Cases',
        subtext: 'Resolved / Disposed',
        keywords: ['disposal cases', 'disposal case', 'disposed cases', 'disposal', 'disposed', 'closed cases'],
        icon: Icons.task_alt_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const MyCasesScreen(initialTab: MyCasesTab.disposal))),
      ),
      (
        title: 'Pending PI Transfers',
        subtext: 'Transfers',
        keywords: ['pending pi transfers', 'pending transfers', 'transfer', 'transfers', 'pi transfer'],
        icon: Icons.pending_actions_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const PendingTransfersScreen())),
      ),
      (
        title: 'Assign Officer',
        subtext: 'Team & IO',
        keywords: ['assign officer', 'assign', 'officer assignment', 'add members'],
        icon: Icons.person_add_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const AssignOfficerScreen())),
      ),
      (
        title: 'My Cases',
        subtext: 'Station Cases',
        keywords: ['my cases', 'assigned cases', 'station cases', 'cases tab'],
        icon: Icons.folder_shared_outlined,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const MyCasesScreen())),
      ),
      (
        title: 'Login & Security',
        subtext: 'Security & PIN',
        keywords: ['login & security', 'login and security', 'security', 'password', 'change password', 'pin', 'login'],
        icon: Icons.lock_person_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const LoginSecurityScreen())),
      ),
      (
        title: 'App Settings',
        subtext: 'Settings & Theme',
        keywords: ['app settings', 'settings', 'dark mode', 'theme', 'language'],
        icon: Icons.settings_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const AppSettingsScreen())),
      ),
      (
        title: 'Feedback',
        subtext: 'Feedback Form',
        keywords: ['feedback', 'feedback form', 'suggest', 'report issue'],
        icon: Icons.feedback_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const FeedbackFormScreen())),
      ),
      (
        title: 'Help & Support',
        subtext: 'Support & Helpline',
        keywords: ['help & support', 'help and support', 'support', 'help', 'helpline', 'contact'],
        icon: Icons.help_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const HelpSupportScreen())),
      ),
      (
        title: 'About App',
        subtext: 'App Info',
        keywords: ['about app', 'about', 'about khakhi diary', 'tensei tech'],
        icon: Icons.info_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const AboutAppScreen())),
      ),
      (
        title: 'Dashboard access grants',
        subtext: 'Grants',
        keywords: ['dashboard access grants', 'access grants', 'station grants', 'grants'],
        icon: Icons.dashboard_customize_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const StationAccessGrantsScreen())),
      ),
      (
        title: 'Profile',
        subtext: 'Officer Profile',
        keywords: ['profile', 'my profile', 'user profile', 'officer profile'],
        icon: Icons.account_circle_rounded,
        onTap: () => Navigator.push(context, AppTheme.fadeSlideRoute(page: const ProfileScreen())),
      ),
    ];

    return shortcuts.where((s) {
      final t = s.title.toLowerCase();
      final sub = s.subtext.toLowerCase();
      final hasKeyword = s.keywords.any((k) => k.contains(cleanQ) || cleanQ.contains(k));
      return t.contains(cleanQ) || sub.contains(cleanQ) || cleanQ.contains(t) || cleanQ.contains(sub) || hasKeyword;
    }).map((s) => (title: s.title, subtext: s.subtext, icon: s.icon, onTap: s.onTap)).toList();
  }

  int _matchingModulesCount(String query) {
    if (query.trim().isEmpty) return 0;
    final q = query.trim().toLowerCase();
    final matchingFormIV = kFormIVCaseCategories.where((cat) => cat.toLowerCase().contains(q)).length;
    final allClasses = [...Classification.all, ..._extraSearchClassifications];
    final matchingClass = allClasses.where((c) => c.name.replaceAll('\n', ' ').toLowerCase().contains(q)).length;
    final matchingMenu = _matchingMenuShortcuts(q).length;
    return matchingFormIV + matchingClass + matchingMenu;
  }

  Widget _buildMatchingModuleTabs(String query) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final q = query.trim().toLowerCase();

    final matchingFormIV = kFormIVCaseCategories.where((cat) {
      return cat.toLowerCase().contains(q);
    }).toList();

    final allClasses = [...Classification.all, ..._extraSearchClassifications];
    final matchingClassifications = allClasses.where((c) {
      final name = c.name.replaceAll('\n', ' ').toLowerCase();
      return name.contains(q);
    }).toList();

    final matchingMenus = _matchingMenuShortcuts(q);

    if (matchingFormIV.isEmpty && matchingClassifications.isEmpty && matchingMenus.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.goldDark),
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Navigation & Modules',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navyDark,
                ),
              ),
              const Spacer(),
              Text(
                'Tap to open directly',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightSubText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final menu in matchingMenus)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: menu.onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3C72).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(menu.icon, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            menu.title,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              menu.subtext,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              for (final cat in matchingFormIV)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () {
                      Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                          page: const FormIVSelectionScreen(
                            mode: FormIVSelectionMode.browse,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2193B0).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.article_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Form I-V',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              for (final item in matchingClassifications)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    onTap: () => _openClassificationItem(context, item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.navyDark,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navyDark.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _classIcon(item.iconName) is IconData
                                ? _classIcon(item.iconName) as IconData
                                : Icons.folder_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.name.replaceAll('\n', ' '),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSearchDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navyMid,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('dd MMM yyyy').format(picked);
      setState(() {
        _explicitSearchDate = picked;
        _searchCtrl.text = formatted;
      });
      _onSearchChanged(formatted);
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        isDark: widget.isDark,
        filters: _searchFilters,
        onApply: (f) {
          setState(() {
            _searchFilters = f;
            _invalidateSearchCache();
          });
          if (_searchQuery.isNotEmpty) _onSearchChanged(_searchCtrl.text);
        },
      ),
    );
  }

  Widget _buildSearchResults(List<SearchResult> searchResults) {
    final grouped = UniversalSearch.groupByModule(searchResults);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                  '${searchResults.length} result${searchResults.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark)),
              const SizedBox(width: 6),
              Text('for "$_searchQuery"',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.lightSubText)),
            ],
          ),
        ),
        ...grouped.entries.map((entry) {
          final moduleKey = entry.key;
          final items = entry.value;
          return _SearchModuleGroup(
            isDark: widget.isDark,
            moduleLabel: items.first.record.firestoreCategoryDisplayName,
            moduleKey: moduleKey,
            results: items,
          );
        }),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.lightSubText),
          const SizedBox(height: 8),
          Text('No results found for "$_searchQuery"',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.lightSubText)),
        ],
      ),
    );
  }

  dynamic _classIcon(String name) {
    switch (name) {
      case 'calendar_month':
        return Icons.calendar_month_rounded;
      case 'pending_actions':
        return FontAwesomeIcons.solidClock;
      case 'search':
        return Icons.search_rounded;
      case 'visibility_off':
        return Icons.visibility_off_rounded;
      case 'delete_forever':
        return Icons.delete_forever_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'handcuffs':
        return Icons.link_rounded;
      case 'directions_run':
        return Icons.directions_run_rounded;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'healing':
        return Icons.healing_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'woman':
        return Icons.woman_rounded;
      case 'description':
        return Icons.description_rounded;
      case 'badge':
        return Icons.badge_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'traffic':
        return Icons.traffic_rounded;
      case 'inventory':
        return Icons.inventory_2_rounded;
      case 'two_wheeler':
        return Icons.two_wheeler_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  Widget _buildThreePartClassification(bool isWide) {
    final width = MediaQuery.of(context).size.width;

    int cols = 4;
    if (width > 1200) {
      cols = 10;
    } else if (width > 900) {
      cols = 8;
    } else if (width > 600) {
      cols = 6;
    }

    final itemsPerGroup = cols * 3;
    // Dashboard-only ordering/labels tweaks (do not modify global constants):
    // - Insert Prohibition + Gambling after A.D
    // - Display "Traffic" as "M.V Act" (dashboard only)
    // - Show RTI next to Sam/Warrant (dashboard only)
    final List<Classification> cases = [
      for (final c in Classification.casesGroup) ...[
        c,
        if (c.name == 'A.D') ...[
          const Classification('Prohibition', 'admin_panel', 'mpda'),
          const Classification('Gambling', 'monetization_on', 'coin'),
        ],
      ],
    ];

    final List<Classification> services = [
      for (final c in Classification.servicesGroup)
        if (c.name == 'Traffic')
          const Classification('M.V Act', 'traffic', 'traffic')
        else if (c.name == 'Application')
          const Classification('RTI', 'description', 'application')
        else
          c,
    ];

    // Move RTI so it sits next to Sam/Warrant (keep all other ordering intact).
    final rtiIndex = services.indexWhere((c) => c.name == 'RTI');
    final samIndex = services.indexWhere((c) => c.name == 'Sam/Warrant');
    if (rtiIndex != -1 && samIndex != -1 && rtiIndex != samIndex + 1) {
      final rti = services.removeAt(rtiIndex);
      final insertAt = samIndex + 1;
      services.insert(insertAt, rti);
    }

    final List<Classification> displayItems = [
      ...Classification.statsGroup,
      ...cases,
      ...services,
      for (final tool in ServiceData.dashboardTools)
        Classification(tool.label, 'service_tool', 'service_tool'),
    ];
    final List<List<Classification>> groups = [];
    for (int i = 0; i < displayItems.length; i += itemsPerGroup) {
      groups.add(displayItems.sublist(
          i, (i + itemsPerGroup).clamp(0, displayItems.length)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.lightBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(groups.length, (gi) {
                final group = groups[gi];
                final isLast = gi == groups.length - 1;
                return Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        childAspectRatio: 0.82,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: group.length,
                      itemBuilder: (context, i) {
                        return _buildClassificationGridItem(context, group[i]);
                      },
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 10),
                      Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.lightBorder),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _openClassificationItem(BuildContext context, Classification item) {
    final label = item.name.replaceAll('\n', ' ');
    if (item.name == 'I to V') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: const FormIVSelectionScreen(
            mode: FormIVSelectionMode.browse,
          ),
        ),
      );
    } else if (item.name == 'Forms') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: const ModuleHubScreen(
            moduleLabel: 'Forms',
            moduleKey: 'form_1_5',
            readOnly: true,
          ),
        ),
      );
    } else if (item.name == 'Pending') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: const ModuleHubScreen(
            moduleLabel: 'Pending',
            moduleKey: 'pending',
            readOnly: true,
          ),
        ),
      );
    } else if (item.moduleKey == 'service_tool') {
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: CaseFormScreen(categoryName: label),
        ),
      );
    } else {
      final isStatsItem = [
        'Monthly',
        'Pending',
        'Disposal'
      ].contains(item.name);
      Navigator.push(
        context,
        AppTheme.fadeSlideRoute(
          page: ModuleHubScreen(
            moduleLabel: item.name.replaceAll('\n', ' '),
            moduleKey: item.moduleKey,
            readOnly: isStatsItem,
          ),
        ),
      );
    }
  }

  Widget _buildClassificationGridItem(
      BuildContext context, Classification item) {
    final label = item.name.replaceAll('\n', ' ');
    ServiceData? matchedTool;
    for (final t in ServiceData.dashboardTools) {
      if (t.label == label) {
        matchedTool = t;
        break;
      }
    }

    return GestureDetector(
      onTap: () => _openClassificationItem(context, item),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navyDark.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Center(
                child: _buildGridIcon(
                    item.name,
                    matchedTool?.icon ?? _classIcon(item.iconName),
                    AppColors.navyMid,
                    24),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: AppColors.lightText),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle,
      {VoidCallback? onViewAll}) {
    return GestureDetector(
      onTap: onViewAll,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyDark)),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.lightSubText)),
            ],
          ),
          const Spacer(),
          if (onViewAll != null)
            Icon(Icons.arrow_forward_ios_rounded,
                size: 18, color: AppColors.navyMid),
        ],
      ),
    );
  }

  Widget _caseCard(Map<String, dynamic> c) {
    final iconColor = Color(c['iconColor'] as int);
    final record = c['record'] as ModuleRecord?;
    final rawStatus = c['status'] as String? ?? '';
    final badgeLabel = _statusBadgeLabel(rawStatus);
    final badgeColor = _statusBadgeColor(badgeLabel);
    final moduleLabel =
        record != null ? _moduleDisplayLabel(record) : (c['type'] as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border(
            left: BorderSide(color: badgeColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (record != null) {
                      Navigator.push(
                        context,
                        AppTheme.fadeSlideRoute(
                            page: CaseDetailScreen(
                                caseData: record, showFloatingActions: false)),
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: iconColor.withValues(alpha: 0.2)),
                        ),
                        child: Icon(c['icon'] as IconData,
                            color: iconColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (moduleLabel.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.navyMid
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  moduleLabel.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: AppColors.navyMid,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Text(c['title'] as String,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text('${c['id']} • ${c['date']}',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.lightSubText)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                              color: badgeColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          badgeLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (record != null)
                IconButton(
                  tooltip: 'Download PDF',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: Icon(Icons.picture_as_pdf_outlined,
                      color: AppColors.dangerRed, size: 22),
                  onPressed: () => runWithPdfAuthGate(
                    context,
                    () => PdfHelper.generateCasePdf(record),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoRecentCases() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.history_rounded,
              size: 48,
              color: widget.isDark
                  ? AppColors.darkSubText.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No cases registered yet',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.lightSubText)),
        ],
      ),
    );
  }

  void _showTop10CasesModal(
      BuildContext context, List<Map<String, dynamic>> top10) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded,
                      color: AppColors.goldPrimary),
                  const SizedBox(width: 12),
                  Text('Top 10 Recent Cases',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: top10.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _caseCard(top10[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DEAD CODE — home grid now navigates to FormIVSelectionScreen. Pending
  // user confirmation before removal.
  // ignore: unused_element
  void _showFormIVBottomSheet(BuildContext context, {bool isAdding = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded,
                      color: AppColors.goldPrimary),
                  const SizedBox(width: 12),
                  Text('Form I-V Cases',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FormIVCategoryButtonGrid(
                labels: kFormIVCaseCategories,
                scrollable: true,
                padding: const EdgeInsets.all(24),
                onLabelTap: (label) {
                  Navigator.pop(context);
                  if (isAdding) {
                    Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(
                        page: CommonFormScreen(
                          moduleLabel: label,
                          moduleKey: 'form_1_5',
                          subCategory: label,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      AppTheme.fadeSlideRoute(
                        page: ModuleHubScreen(
                          moduleLabel: label,
                          moduleKey: 'form_1_5',
                          subCategory: label,
                          readOnly: false,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WANTED TAB ───────────────────────────────────────────────────────────────
class _WantedTab extends StatelessWidget {
  final bool isDark;
  const _WantedTab({required this.isDark});

  static const _wantedPersons = [
    {
      'name': 'Rajesh Kumar',
      'id': 'WNT/2024/001',
      'crime': 'Robbery & Assault',
      'reward': '₹50,000',
      'dangerous': true
    },
    {
      'name': 'Mohan Singh',
      'id': 'WNT/2024/002',
      'crime': 'Sand Theft',
      'reward': '₹25,000',
      'dangerous': false
    },
    {
      'name': 'Priya Das',
      'id': 'WNT/2024/003',
      'crime': 'Fraud & Cheating',
      'reward': '₹30,000',
      'dangerous': false
    },
    {
      'name': 'Abdul Hamid',
      'id': 'WNT/2024/004',
      'crime': 'Kidnapping',
      'reward': '₹1,00,000',
      'dangerous': true
    },
    {
      'name': 'Sunita Devi',
      'id': 'WNT/2024/005',
      'crime': 'Missing Case Suspect',
      'reward': '₹15,000',
      'dangerous': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border:
                  Border.all(color: AppColors.dangerRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, color: AppColors.dangerRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Wanted List — Active warrants issued',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dangerRed)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.dangerRed,
                      borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Text('${_wantedPersons.length}',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final p = _wantedPersons[i];
                final dangerous = p['dangerous'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: dangerous
                          ? AppColors.dangerRed.withValues(alpha: 0.4)
                          : AppColors.lightBorder,
                      width: dangerous ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.dangerRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.dangerRed, size: 26),
                          ),
                          if (dangerous)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                    color: AppColors.dangerRed,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.warning_rounded,
                                    color: Colors.white, size: 10),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] as String,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navyDark)),
                            Text(p['crime'] as String,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.lightSubText)),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.tag,
                                  size: 12, color: AppColors.infoBlue),
                              Text(p['id'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 11, color: AppColors.infoBlue)),
                            ]),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(p['reward'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.successGreen)),
                          Text('Reward',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: AppColors.lightSubText)),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: _wantedPersons.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── VIEW TAB ─────────────────────────────────────────────────────────────────
class _ViewTab extends StatefulWidget {
  final bool isDark;
  const _ViewTab({required this.isDark});

  @override
  State<_ViewTab> createState() => _ViewTabState();
}

class _ViewTabState extends State<_ViewTab> {
  final FirestoreService _firestore = FirestoreService();
  int _selectedTabIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  static const List<(int, IconData, String)> _tabs = [
    (0, Icons.folder_open_rounded, 'All'),
    (1, Icons.pending_actions_outlined, 'Pending'),
    (2, Icons.check_circle_outline_rounded, 'Disposed'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Stream<List<ModuleRecord>> _getStream(
      AuthProvider auth, CaseVisibilityMode mode) {
    if (_selectedTabIndex == 1) {
      return _firestore.getPendingCasesStream(auth.activeStation).map(
            (records) => CaseVisibility.filterRecords(
              records,
              uid: auth.uid,
              officerName: auth.displayName,
              mode: mode,
            ),
          );
    } else if (_selectedTabIndex == 2) {
      return _firestore.getDisposalCasesStream(auth.activeStation).map(
            (records) => CaseVisibility.filterRecords(
              records,
              uid: auth.uid,
              officerName: auth.displayName,
              mode: mode,
            ),
          );
    }
    return _firestore.getStationCasesStream(auth.activeStation).map(
          (records) => CaseVisibility.filterRecords(
            records,
            uid: auth.uid,
            officerName: auth.displayName,
            mode: mode,
          ),
        );
  }

  List<ModuleRecord> _filterRecords(List<ModuleRecord> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.caseNumber.toLowerCase().contains(q) ||
          r.complainant.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.assignedOfficer.toLowerCase().contains(q) ||
          r.firestoreCategoryDisplayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mode = CaseVisibility.resolveFor(auth);

    return StreamBuilder<List<ModuleRecord>>(
      stream: _getStream(auth, mode),
      builder: (context, snapshot) {
        final allRecords = snapshot.data ?? [];
        final filtered = _filterRecords(allRecords);
        final isLoading =
            snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Segmented Tab Selector (All, Pending, Disposed) ──────────────────
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: AppSpacing.md),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightBg,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        children: _tabs.map((t) {
                          final isSelected = _selectedTabIndex == t.$1;
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                if (_selectedTabIndex != t.$1) {
                                  setState(() => _selectedTabIndex = t.$1);
                                }
                              },
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.navyDark
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.navyDark
                                                .withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      t.$2,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.navyDark
                                              .withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      t.$3,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.navyDark
                                                .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Search Field & Count ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                          style: GoogleFonts.poppins(
                              fontSize: 13.5, color: AppColors.navyDark),
                          decoration: InputDecoration(
                            hintText:
                                'Search by FIR, title, location, category…',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: AppColors.lightSubText,
                            ),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.navyMid, size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close_rounded,
                                        color: AppColors.lightSubText,
                                        size: 18),
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(
                                  color: AppColors.lightBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(
                                  color: AppColors.lightBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(
                                  color: AppColors.navyMid, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _query.isNotEmpty
                              ? 'Found ${filtered.length} of ${allRecords.length} records'
                              : 'Total: ${filtered.length} records',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightSubText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Loading / Empty State or Records List ────────────────────────────
            if (isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.navyMid,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _query.isNotEmpty
                                ? Icons.search_off_rounded
                                : Icons.folder_open_rounded,
                            size: 48,
                            color: AppColors.navyMid.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _query.isNotEmpty
                                ? 'No matching cases'
                                : 'No records found in database',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _query.isNotEmpty
                                ? 'Try searching with a different keyword.'
                                : 'Cases created for this station will appear here from the database.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.lightSubText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          final isDisposed = c.status.toLowerCase() == 'closed' ||
                              c.status.toLowerCase() == 'disposal' ||
                              c.status.toLowerCase() == 'resolved' ||
                              c.status.toLowerCase() == 'disposed';
                          final displayStatus =
                              isDisposed ? 'Disposal' : 'Pending';
                          final accentColor = _selectedTabIndex == 2 || isDisposed
                              ? AppColors.successGreen
                              : _selectedTabIndex == 1
                                  ? AppColors.warningOrange
                                  : AppColors.infoBlue;
                          final statusColor = isDisposed
                              ? AppColors.successGreen
                              : AppColors.warningOrange;

                          final displayTitle = c.title.trim().isNotEmpty
                              ? c.title.trim()
                              : 'Untitled Case';
                          final firLabel = c.caseNumber.trim().isNotEmpty
                              ? c.caseNumber.trim()
                              : 'No FIR / case number';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.lightBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    AppTheme.fadeSlideRoute(
                                      page: c.moduleKey == 'ad'
                                          ? AdRecordDetailScreen(record: c)
                                          : ModuleRecordDetailScreen(record: c),
                                    ),
                                  );
                                },
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        width: 4,
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                            left: Radius.circular(AppRadius.md),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Top Row: FIR and Status Badge
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.navyMid
                                                          .withValues(
                                                              alpha: 0.08),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.sm),
                                                    ),
                                                    child: Text(
                                                      firLabel,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .navyDark,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: statusColor
                                                          .withValues(
                                                              alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.full),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 6,
                                                          height: 6,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: statusColor,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          displayStatus,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 10.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: statusColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),

                                              // Case Title
                                              Text(
                                                displayTitle,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.navyDark,
                                                ),
                                              ),
                                              const SizedBox(height: 3),

                                              // Category Pill
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.goldPrimary
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  c.firestoreCategoryDisplayName,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.goldDark,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              // Metadata row
                                              Wrap(
                                                spacing: 12,
                                                runSpacing: 4,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .calendar_today_rounded,
                                                        size: 12,
                                                        color: AppColors
                                                            .lightSubText,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        DateFormat('dd MMM yyyy')
                                                            .format(
                                                                c.incidentDate),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .lightSubText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (c.location.isNotEmpty)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 12,
                                                          color: AppColors
                                                              .lightSubText,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          c.location,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .lightSubText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (c.assignedOfficer
                                                      .isNotEmpty)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.person_rounded,
                                                          size: 12,
                                                          color: AppColors
                                                              .lightSubText,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          c.assignedOfficer,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .lightSubText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                              const Divider(height: 20),

                                              // Actions Row: Edit (Guarded), Reminder (Senior Only), PDF, View
                                              Builder(builder: (ctx) {
                                                final canEdit =
                                                    PoliceRbacHelper
                                                        .canEditRecord(c, auth);
                                                final canSendReminder =
                                                    PoliceRbacHelper
                                                        .canSendReminder(auth);

                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    if (canEdit)
                                                      _buildCardAction(
                                                        icon: Icons
                                                            .edit_note_rounded,
                                                        label: 'Edit',
                                                        color:
                                                            AppColors.infoBlue,
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            AppTheme
                                                                .fadeSlideRoute(
                                                              page:
                                                                  CommonFormScreen(
                                                                moduleKey:
                                                                    c.moduleKey,
                                                                moduleLabel: c
                                                                    .firestoreCategoryDisplayName,
                                                                existingRecord:
                                                                    c,
                                                             ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    if (canSendReminder)
                                                      _buildCardAction(
                                                        icon: Icons
                                                            .notifications_active_outlined,
                                                        label: 'Reminder',
                                                        color: AppColors
                                                            .warningOrange,
                                                        onTap: () {
                                                          SendReminderDialog
                                                              .show(context, c);
                                                        },
                                                      ),
                                                    _buildCardAction(
                                                      icon: Icons
                                                          .picture_as_pdf_rounded,
                                                      label: 'PDF',
                                                      color:
                                                          AppColors.dangerRed,
                                                      onTap: () {
                                                        runWithPdfAuthGate(
                                                          context,
                                                          () => ModulePdfHelper
                                                              .generatePdf(c),
                                                        );
                                                      },
                                                    ),
                                                    _buildCardAction(
                                                      icon: Icons
                                                          .visibility_rounded,
                                                      label: 'View',
                                                      color:
                                                          AppColors.goldPrimary,
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          AppTheme
                                                            .fadeSlideRoute(
                                                            page: c.moduleKey ==
                                                                    'ad'
                                                                ? AdRecordDetailScreen(
                                                                    record: c)
                                                                : ModuleRecordDetailScreen(
                                                                    record: c),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CALENDAR TAB ─────────────────────────────────────────────────────────────
class _CalCategoryMeta {
  final String label;
  final String moduleKey;
  final String? subCategory;
  int count;

  _CalCategoryMeta({
    required this.label,
    required this.moduleKey,
    this.subCategory,
    required this.count,
  });
}

class _CalendarTab extends StatefulWidget {
  final bool isDark;
  const _CalendarTab({required this.isDark});

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

enum _CalendarTabArea { weekly, monthly, yearly, custom }

class _CalendarTabState extends State<_CalendarTab> {
  _CalendarTabArea _activeArea = _CalendarTabArea.weekly;
  DateTimeRange? _customRange;
  late int _selectedMonth;
  late int _selectedYear;
  bool _showMonthlySummaryTable = false;
  bool _showMonthlyClassVTable = false;
  bool _showMonthlyClassVITable = false;
  bool _showMonthlyPreventiveTable = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  static const _heads = [
    'Murder',
    'Att to Murder',
    'Dacoity',
    'Pro Of Dacoity',
    'Total Robery',
    'Chain Robery',
    'Other Robery',
    'Total H B Ts',
    'H B Ts (Day)',
    'H B Ts (Night)',
    'Total Theft',
    'Total M VThefts',
    'SAND THEFT',
    'Chain Snaching',
    'Mobile Thefts',
    'Cattel Theft',
    'Other Thefts',
    'Extcrtion',
    'Cheating',
    'Cr Br of Trust',
    'Mischief',
    'Rioting',
    'Unlawful Assembly',
    'Attempt to suicide',
    'Hurt',
    'Kidnapping',
    'Rape',
    'Assault on Govt-',
    'Molestation (354)',
    '304 (A) I P C',
    '498 (A) I P C',
    '509 I P C',
    'Othar I P C',
    'Miscellaneous',
  ];

  static String _getHead(ModuleRecord r) {
    final sub = (r.subCategory ?? '').toLowerCase();
    final key = r.moduleKey.toLowerCase();

    if (key.contains('murder') || sub.contains('murder')) {
      return sub.contains('attempt') || sub.contains('att')
          ? 'Att to Murder'
          : 'Murder';
    }
    if (key.contains('dacoity') || sub.contains('dacoity')) {
      return sub.contains('preparation') || sub.contains('pro')
          ? 'Pro Of Dacoity'
          : 'Dacoity';
    }
    if (key.contains('robbery') || sub.contains('robery')) {
      if (sub.contains('chain')) return 'Chain Robery';
      return 'Total Robery'; // Logic can be expanded to return 'Other Robery' if needed
    }
    if (key.contains('house') || sub.contains('h b t') || sub.contains('hbt')) {
      if (sub.contains('day')) return 'H B Ts (Day)';
      if (sub.contains('night')) return 'H B Ts (Night)';
      return 'Total H B Ts';
    }
    if (key.contains('theft') || sub.contains('theft')) {
      if (key.contains('sand') || sub.contains('sand')) return 'SAND THEFT';
      if (key.contains('two_four') ||
          sub.contains('wheeler') ||
          sub.contains('vehicle')) {
        return 'Total M VThefts';
      }
      if (sub.contains('chain')) return 'Chain Snaching';
      if (sub.contains('mobile')) return 'Mobile Thefts';
      if (sub.contains('cattle') || sub.contains('cattel')) {
        return 'Cattel Theft';
      }
      if (sub.contains('other')) return 'Other Thefts';
      return 'Total Theft';
    }
    if (key.contains('extortion') || sub.contains('extcrtion')) {
      return 'Extcrtion';
    }
    if (key.contains('cheating') || sub.contains('cheating')) return 'Cheating';
    if (sub.contains('trust') || sub.contains('br of trust')) {
      return 'Cr Br of Trust';
    }
    if (key.contains('mischief') || sub.contains('mischief')) return 'Mischief';
    if (key.contains('rioting') || sub.contains('rioting')) return 'Rioting';
    if (sub.contains('unlawful') || sub.contains('assembly')) {
      return 'Unlawful Assembly';
    }
    if (sub.contains('suicide')) return 'Attempt to suicide';
    if (key.contains('hurt') || sub.contains('hurt')) return 'Hurt';
    if (key.contains('kidnapping') || sub.contains('kidnap')) {
      return 'Kidnapping';
    }
    if (key.contains('rape') || sub.contains('rape')) return 'Rape';
    if (sub.contains('assault') && sub.contains('govt')) {
      return 'Assault on Govt-';
    }
    if (sub.contains('molestation') || sub.contains('354')) {
      return 'Molestation (354)';
    }
    if (sub.contains('304')) return '304 (A) I P C';
    if (sub.contains('498')) return '498 (A) I P C';
    if (sub.contains('509')) return '509 I P C';
    if (sub.contains('other ipc') || sub.contains('othar')) {
      return 'Othar I P C';
    }

    return 'Miscellaneous';
  }

  List<ModuleRecord> _getConsolidatedRecords(BuildContext context) {
    final records = <ModuleRecord>[];
    records.addAll(context.watch<FormIVProvider>().records);
    records.addAll(context.watch<FormVIProvider>().records);
    records.addAll(context.watch<NcProvider>().records);
    records.addAll(context.watch<PreventiveProvider>().records);
    records.addAll(context.watch<AdProvider>().records);
    records.addAll(context.watch<MissingProvider>().records);
    records.addAll(context.watch<KidnappingProvider>().records);
    records.addAll(context.watch<TheftProvider>().records);
    records.addAll(context.watch<SandTheftProvider>().records);
    records.addAll(context.watch<HurtProvider>().records);
    records.addAll(context.watch<PocsoProvider>().records);
    records.addAll(context.watch<PassportProvider>().records);
    records.addAll(context.watch<TwoFourWheelerProvider>().records);
    records.addAll(context.watch<ArrestedProvider>().records);
    records.addAll(context.watch<AbscondedProvider>().records);
    records.addAll(context.watch<CrimeWomenProvider>().records);
    records.addAll(context.watch<JuvenileProvider>().records);
    records.addAll(context.watch<VictimProvider>().records);
    records.addAll(context.watch<AccidentProvider>().records);
    records.addAll(context.watch<TrafficProvider>().records);
    records.addAll(context.watch<ApplicationProvider>().records);
    records.addAll(context.watch<SamWarrantProvider>().records);
    records.addAll(context.watch<MuddemalProvider>().records);
    records.addAll(context.watch<BnssProvider>().records);
    records.addAll(context.watch<NdpsProvider>().records);
    records.addAll(context.watch<GowansProvider>().records);
    records.addAll(context.watch<ItActProvider>().records);
    records.addAll(context.watch<McocaProvider>().records);
    records.addAll(context.watch<UapaProvider>().records);
    records.addAll(context.watch<MpdaProvider>().records);
    records.addAll(context.watch<CoinProvider>().records);
    return records;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildReportTabs()),
        _buildRegistrationSummary(context, _activeArea),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildReportTabs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                _tabBtn('Weekly', _CalendarTabArea.weekly),
                _tabBtn('Monthly', _CalendarTabArea.monthly),
                _tabBtn('Yearly', _CalendarTabArea.yearly),
                _tabBtn('Custom', _CalendarTabArea.custom),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.navyMid),
                  items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(months[i],
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                          )),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMonth = val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.navyMid),
                items: List.generate(
                    5,
                    (i) => DropdownMenuItem(
                          value: DateTime.now().year - i,
                          child: Text('${DateTime.now().year - i}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        )),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedYear = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _customRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navyMid,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) setState(() => _customRange = range);
  }

  Widget _tabBtn(String label, _CalendarTabArea area) {
    final isActive = _activeArea == area;
    final color = AppColors.navyMid;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeArea = area),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.lightSubText)),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationSummary(
      BuildContext context, _CalendarTabArea area) {
    final allRecords = _getConsolidatedRecords(context);
    final now = DateTime.now();

    List<ModuleRecord> filtered;
    String rangeLabel;
    String reportTitle;

    if (area == _CalendarTabArea.weekly) {
      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart
          .add(const Duration(days: 7))
          .subtract(const Duration(seconds: 1));
      filtered = allRecords
          .where((r) =>
              (r.incidentDate.isAfter(weekStart) ||
                  r.incidentDate.isAtSameMomentAs(weekStart)) &&
              (r.incidentDate.isBefore(weekEnd) ||
                  r.incidentDate.isAtSameMomentAs(weekEnd)))
          .toList();
      rangeLabel =
          '${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}';
      reportTitle = 'WEEKLY REGISTRATION REPORT';
    } else if (area == _CalendarTabArea.monthly) {
      filtered = allRecords
          .where((r) =>
              r.incidentDate.month == _selectedMonth &&
              r.incidentDate.year == _selectedYear)
          .toList();
      rangeLabel = '${[
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ][_selectedMonth - 1]} $_selectedYear';
      reportTitle = 'MONTHLY REPORT';
    } else if (area == _CalendarTabArea.yearly) {
      filtered =
          allRecords.where((r) => r.incidentDate.year == now.year).toList();
      rangeLabel = '${now.year}';
      reportTitle = 'YEARLY REGISTRATION REPORT';
    } else {
      if (_customRange == null) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 40, horizontal: AppSpacing.lg),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.date_range_rounded,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Custom Report not generated yet',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightSubText)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _selectCustomRange(context),
                    icon: const Icon(Icons.date_range_rounded,
                        size: 18, color: Colors.white),
                    label: Text('Select Date Range',
                        style: GoogleFonts.poppins(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyMid,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      filtered = allRecords
          .where((r) =>
              r.incidentDate.isAfter(
                  _customRange!.start.subtract(const Duration(seconds: 1))) &&
              r.incidentDate
                  .isBefore(_customRange!.end.add(const Duration(days: 1))))
          .toList();
      rangeLabel =
          '${DateFormat('dd MMM yyyy').format(_customRange!.start)} - ${DateFormat('dd MMM yyyy').format(_customRange!.end)}';
      reportTitle = 'CUSTOM DATE REGISTRATION REPORT';
    }

    final Map<String, _CalCategoryMeta> catMeta = {};
    for (var r in filtered) {
      final label = r.firestoreCategoryDisplayName;
      String? sub = r.subCategory;
      final key = '${r.moduleKey}_${sub ?? ""}';
      if (!catMeta.containsKey(key)) {
        catMeta[key] = _CalCategoryMeta(
            label: label, moduleKey: r.moduleKey, subCategory: sub, count: 0);
      }
      catMeta[key]!.count++;
    }

    final sortedItems = catMeta.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    final countsForPdf = {for (var it in sortedItems) it.label: it.count};

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyDark, AppColors.navyMid]),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reportTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rangeLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (area == _CalendarTabArea.custom)
                        GestureDetector(
                          onTap: () => _selectCustomRange(context),
                          child: Row(children: [
                            const Icon(Icons.edit_calendar_rounded,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text('Change Range',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.white70)),
                          ]),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (area == _CalendarTabArea.monthly) ...[
              // Month/Year selector moved below the Monthly navbar (tabs).
              _buildMonthSelector(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statistics Summary',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDark)),
                      Text('${filtered.length} cases registered in total',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.lightSubText)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMonthlySummaryTable = !_showMonthlySummaryTable;
                        if (_showMonthlySummaryTable) {
                          _showMonthlyClassVTable = false;
                          _showMonthlyClassVITable = false;
                          _showMonthlyPreventiveTable = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.download_rounded,
                        size: 16, color: Colors.white),
                    label: Text('Summary',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyMid,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statistics Summary',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyDark)),
                      Text('${filtered.length} cases registered in total',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.lightSubText)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => runWithPdfAuthGate(
                      context,
                      () => ModulePdfHelper.generateSummaryReportPdf(
                          countsForPdf, reportTitle, rangeLabel),
                    ),
                    icon: const Icon(Icons.download_rounded,
                        size: 16, color: Colors.white),
                    label: Text('Summary',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyMid,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (area == _CalendarTabArea.monthly) ...[
              // Keep the Class V / VI / Preventives buttons always visible.
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _monthlyReportButtons(filtered, reportTitle, rangeLabel),
                    const SizedBox(height: 14),
                    if (sortedItems.isEmpty)
                      _buildEmptyReport()
                    else if (_showMonthlySummaryTable)
                      _buildMonthlySummaryPhotoTable(
                        context,
                        allRecords,
                        _selectedMonth,
                        _selectedYear,
                      )
                    else if (_showMonthlyClassVTable)
                      _buildMonthlyReportTableInternal(
                        context,
                        allRecords,
                        _selectedMonth,
                        _selectedYear,
                      ),
                    if (sortedItems.isNotEmpty && _showMonthlyClassVITable)
                      _buildMonthlyReportTableInternalVI(
                        context,
                        allRecords,
                        _selectedMonth,
                        _selectedYear,
                      ),
                    if (sortedItems.isNotEmpty && _showMonthlyPreventiveTable)
                      _buildMonthlyReportTableInternalPreventive(
                        context,
                        allRecords,
                        _selectedMonth,
                        _selectedYear,
                      ),
                  ],
                ),
              ),
            ] else ...[
              if (sortedItems.isEmpty)
                _buildEmptyReport()
              else
                ...sortedItems.map((meta) => _buildReportTile(meta)),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildMonthlyReportTableInternal(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    final List<Map<String, dynamic>> tableRows = [];

    List<ModuleRecord> filter(int m, int y,
        {bool isYearCurrent = false, bool isYearPrevious = false}) {
      return allRecords.where((r) {
        if (isYearCurrent) {
          return r.incidentDate.year == y && r.incidentDate.month <= m;
        }
        if (isYearPrevious) {
          return r.incidentDate.year == y && r.incidentDate.month <= m;
        }
        return r.incidentDate.month == m && r.incidentDate.year == y;
      }).toList();
    }

    final currentMonthRecords = filter(selectedMonth, selectedYear);
    final previousMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final previousMonthYear =
        selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final previousMonthRecords = filter(previousMonth, previousMonthYear);
    final sameMonthLastYearRecords = filter(selectedMonth, selectedYear - 1);
    final yearCurrentRecords =
        filter(selectedMonth, selectedYear, isYearCurrent: true);
    final yearPreviousRecords =
        filter(selectedMonth, selectedYear - 1, isYearPrevious: true);

    int totalcmR = 0, totalcmD = 0;
    int totalpmR = 0, totalpmD = 0;
    int totalsmlyR = 0, totalsmlyD = 0;
    int totalycR = 0, totalycD = 0;
    int totalypR = 0, totalypD = 0;

    for (int i = 0; i < _heads.length; i++) {
      final head = _heads[i];
      List<ModuleRecord> getByHead(List<ModuleRecord> recs) =>
          recs.where((r) => _getHead(r) == head).toList();

      final cm = getByHead(currentMonthRecords);
      final pm = getByHead(previousMonthRecords);
      final smly = getByHead(sameMonthLastYearRecords);
      final yc = getByHead(yearCurrentRecords);
      final yp = getByHead(yearPreviousRecords);

      int detected(List<ModuleRecord> recs) =>
          recs.where((r) => r.status.toLowerCase() != 'open').length;

      final cmR = cm.length;
      final cmD = detected(cm);
      final pmR = pm.length;
      final pmD = detected(pm);
      final smlyR = smly.length;
      final smlyD = detected(smly);
      final ycR = yc.length;
      final ycD = detected(yc);
      final ypR = yp.length;
      final ypD = detected(yp);

      final variation = ycR - ypR;

      tableRows.add({
        'N': i + 1,
        'Heads': head,
        'cm_R': cmR,
        'cm_D': cmD,
        'pm_R': pmR,
        'pm_D': pmD,
        'smly_R': smlyR,
        'smly_D': smlyD,
        'yc_R': ycR,
        'yc_D': ycD,
        'yp_R': ypR,
        'yp_D': ypD,
        'variation': variation,
        'cmRecords': cm,
        'pmRecords': pm,
        'smlyRecords': smly,
        'ycRecords': yc,
        'ypRecords': yp,
      });

      totalcmR += cmR;
      totalcmD += cmD;
      totalpmR += pmR;
      totalpmD += pmD;
      totalsmlyR += smlyR;
      totalsmlyD += smlyD;
      totalycR += ycR;
      totalycD += ycD;
      totalypR += ypR;
      totalypD += ypD;
    }

    tableRows.add({
      'N': '',
      'Heads': 'TOTAL',
      'cm_R': totalcmR,
      'cm_D': totalcmD,
      'pm_R': totalpmR,
      'pm_D': totalpmD,
      'smly_R': totalsmlyR,
      'smly_D': totalsmlyD,
      'yc_R': totalycR,
      'yc_D': totalycD,
      'yp_R': totalypR,
      'yp_D': totalypD,
      'variation': totalycR - totalypR,
      'cmRecords': const <ModuleRecord>[],
      'pmRecords': const <ModuleRecord>[],
      'smlyRecords': const <ModuleRecord>[],
      'ycRecords': const <ModuleRecord>[],
      'ypRecords': const <ModuleRecord>[],
    });

    final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevMonthYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final cmDateLabel =
        DateFormat('MMMM,yyyy').format(DateTime(selectedYear, selectedMonth));
    final pmDateLabel =
        DateFormat('MMMM,yyyy').format(DateTime(prevMonthYear, prevMonth));
    final smlyDateLabel = DateFormat('MMMM,yyyy')
        .format(DateTime(selectedYear - 1, selectedMonth));
    final ycDateLabel = 'Year,$selectedYear';
    final ypDateLabel = 'Year,${selectedYear - 1}';

    final classVRowDefs = <Map<String, dynamic>>[
      {'sr': '1', 'label': 'Murder', 'head': 'Murder'},
      {'sr': '2', 'label': 'Attempt to murder', 'head': 'Att to Murder'},
      {'sr': '3', 'label': 'Dacoity', 'head': 'Dacoity'},
      {'sr': '4', 'label': 'Pro of Decoity', 'head': 'Pro Of Dacoity'},
      {
        'sr': '5',
        'label': 'Total Robery',
        'head': 'Total Robery',
        'bold': true
      },
      {'sr': 'a', 'label': 'Chain Robery', 'head': 'Chain Robery', 'indent': 1},
      {'sr': 'b', 'label': 'Other Robery', 'head': 'Other Robery', 'indent': 1},
      {
        'sr': '6',
        'label': 'Total H.B.Ts',
        'head': 'Total H B Ts',
        'bold': true
      },
      {'sr': 'a', 'label': 'H.B.Ts (Day)', 'head': 'H B Ts (Day)', 'indent': 1},
      {
        'sr': 'b',
        'label': 'H.B.Ts (Night)',
        'head': 'H B Ts (Night)',
        'indent': 1,
      },
      {'sr': '7', 'label': 'Total thefts', 'head': 'Total Theft', 'bold': true},
      {
        'sr': 'a',
        'label': 'Total MV Thefts',
        'head': 'Total M VThefts',
        'indent': 1,
      },
      {'sr': 'b', 'label': 'Sand Theft', 'head': 'SAND THEFT', 'indent': 1},
      {
        'sr': 'c',
        'label': 'Chain Snaching',
        'head': 'Chain Snaching',
        'indent': 1,
      },
      {
        'sr': 'd',
        'label': 'Mobile Thefts',
        'head': 'Mobile Thefts',
        'indent': 1
      },
      {
        'sr': 'e',
        'label': 'Cattle Thefts',
        'head': 'Cattel Theft',
        'indent': 1
      },
      {'sr': 'f', 'label': 'Other Thefts', 'head': 'Other Thefts', 'indent': 1},
      {'sr': '8', 'label': 'Extortion', 'head': 'Extcrtion'},
      {'sr': '9', 'label': 'Cheating', 'head': 'Cheating', 'bold': true},
      {'sr': '10', 'label': 'Cr Br of Trust', 'head': 'Cr Br of Trust'},
      {'sr': '11', 'label': 'Mischief', 'head': 'Mischief'},
      {'sr': '12', 'label': 'Rioting', 'head': 'Rioting'},
      {'sr': '13', 'label': 'Unlawful assembly', 'head': 'Unlawful Assembly'},
      {'sr': '14', 'label': 'Attempt to Suicide', 'head': 'Attempt to suicide'},
      {'sr': '15', 'label': 'Hurt', 'head': 'Hurt', 'bold': true},
      {'sr': '16', 'label': 'Kidnapping', 'head': 'Kidnapping', 'bold': true},
      {'sr': '17', 'label': 'Rape', 'head': 'Rape', 'bold': true},
      {
        'sr': '18',
        'label': 'Assault on Govt.',
        'head': 'Assault on Govt-',
        'bold': true,
      },
      {'sr': '19', 'label': 'Molestation (354)', 'head': 'Molestation (354)'},
      {'sr': '20', 'label': '304 (A) IPC', 'head': '304 (A) I P C'},
      {'sr': '21', 'label': '498 (A) IPC', 'head': '498 (A) I P C'},
      {'sr': '22', 'label': '509 IPC', 'head': '509 I P C'},
      {'sr': '23', 'label': 'Other IPC', 'head': 'Othar I P C'},
      {'sr': '', 'label': 'Total', 'head': 'TOTAL', 'bold': true},
    ];

    // Class V screen: slightly larger type; Murder–Other IPC share vertical padding
    // so adjacent rows do not stack default top+bottom cell padding (extra gap).
    const classVBodyFontSize = 11.0;
    const classVTitleFontSize = 12.0;
    const classVTightRowHeads = <String>{
      'Murder',
      'Att to Murder',
      'Dacoity',
      'Pro Of Dacoity',
      'Total Robery',
      'Chain Robery',
      'Other Robery',
      'Total H B Ts',
      'H B Ts (Day)',
      'H B Ts (Night)',
      'Total Theft',
      'Total M VThefts',
      'SAND THEFT',
      'Chain Snaching',
      'Mobile Thefts',
      'Cattel Theft',
      'Other Thefts',
      'Extcrtion',
      'Cheating',
      'Cr Br of Trust',
      'Mischief',
      'Rioting',
      'Unlawful Assembly',
      'Attempt to suicide',
      'Hurt',
      'Kidnapping',
      'Rape',
      'Assault on Govt-',
      'Molestation (354)',
      '304 (A) I P C',
      '498 (A) I P C',
      '509 I P C',
      'Othar I P C',
    };

    EdgeInsets classVCellPad({
      required bool denseTop,
      required bool denseBottom,
      double horizontal = 3,
    }) {
      const v = 3.0; // minimal vertical padding (was 4)
      return EdgeInsets.fromLTRB(
        horizontal,
        denseTop ? 0 : v,
        horizontal,
        denseBottom ? 0 : v,
      );
    }

    Map<String, dynamic> rowFor(String head) {
      for (final r in tableRows) {
        if (r['Heads'] == head) return r;
      }
      return <String, dynamic>{};
    }

    int vInt(Map<String, dynamic> r, String k) => (r[k] as int?) ?? 0;

    const flexAll = 20;
    const dataFlexes = <int>[2, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    const headerGroupFlexes = <int>[2, 7, 2, 2, 2, 2, 2, 1];

    Widget rowOfFlex(List<int> flexes, List<Widget> children) {
      assert(flexes.length == children.length);
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < flexes.length; i++)
              Expanded(
                flex: flexes[i],
                child: children[i],
              ),
          ],
        ),
      );
    }

    Widget cBox({
      required Widget child,
      EdgeInsets? padding,
      AlignmentGeometry alignment = Alignment.center,
    }) {
      return Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightBorder, width: 0.5),
        ),
        alignment: alignment,
        child: child,
      );
    }

    Widget cText(
      String s, {
      bool bold = false,
      bool alignLeft = false,
      double indent = 0,
      double fontSize = classVBodyFontSize,
    }) {
      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: Text(
          s,
          textAlign: alignLeft ? TextAlign.left : TextAlign.center,
          softWrap: true,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.lightText,
            height: 1.15,
          ),
        ),
      );
    }

    Widget cLink(
      int n,
      List<ModuleRecord> recs,
      String title, {
      bool bold = false,
      double fontSize = classVBodyFontSize,
    }) {
      final empty = recs.isEmpty;
      return InkWell(
        onTap: empty
            ? null
            : () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                    page: ReportCaseListScreen(title: title, records: recs),
                  ),
                );
              },
        child: Text(
          '$n',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: empty ? AppColors.lightSubText : AppColors.infoBlue,
            decoration: empty ? null : TextDecoration.underline,
            height: 1.15,
          ),
        ),
      );
    }

    List<ModuleRecord> detRecs(List<ModuleRecord> r) =>
        r.where((x) => x.status.toLowerCase() != 'open').toList();

    Widget buildScreenDataRow(Map<String, dynamic> def) {
      final headKey = def['head'] as String;
      final inTightBlock = classVTightRowHeads.contains(headKey);
      final denseTop = inTightBlock && headKey != 'Murder';
      final denseBottom = inTightBlock && headKey != 'Othar I P C';
      final src = rowFor(headKey);
      final bold = (def['bold'] as bool?) ?? false;
      final indent = ((def['indent'] as int?) ?? 0) * 12.0;
      final cmR = vInt(src, 'cm_R');
      final cmD = vInt(src, 'cm_D');
      final pmR = vInt(src, 'pm_R');
      final pmD = vInt(src, 'pm_D');
      final smlyR = vInt(src, 'smly_R');
      final smlyD = vInt(src, 'smly_D');
      final ycR = vInt(src, 'yc_R');
      final ycD = vInt(src, 'yc_D');
      final ypR = vInt(src, 'yp_R');
      final ypD = vInt(src, 'yp_D');
      final varVal = vInt(src, 'variation');
      final cmRecs =
          (src['cmRecords'] as List<ModuleRecord>?) ?? const <ModuleRecord>[];
      final pmRecs =
          (src['pmRecords'] as List<ModuleRecord>?) ?? const <ModuleRecord>[];
      final smlyRecs =
          (src['smlyRecords'] as List<ModuleRecord>?) ?? const <ModuleRecord>[];
      final ycRecs =
          (src['ycRecords'] as List<ModuleRecord>?) ?? const <ModuleRecord>[];
      final ypRecs =
          (src['ypRecords'] as List<ModuleRecord>?) ?? const <ModuleRecord>[];
      final label = def['label'] as String;
      final labelPad = classVCellPad(
        denseTop: denseTop,
        denseBottom: denseBottom,
        horizontal: 4,
      );

      return rowOfFlex(dataFlexes, [
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cText(def['sr'] as String, bold: bold),
        ),
        cBox(
          alignment: Alignment.centerLeft,
          padding: labelPad,
          child: cText(
            label,
            bold: bold,
            alignLeft: true,
            indent: indent,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(cmR, cmRecs, '$label • $cmDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(
            cmD,
            detRecs(cmRecs),
            '$label • $cmDateLabel • D',
            bold: bold,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(pmR, pmRecs, '$label • $pmDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(
            pmD,
            detRecs(pmRecs),
            '$label • $pmDateLabel • D',
            bold: bold,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child:
              cLink(smlyR, smlyRecs, '$label • $smlyDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(
            smlyD,
            detRecs(smlyRecs),
            '$label • $smlyDateLabel • D',
            bold: bold,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(ycR, ycRecs, '$label • $ycDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(
            ycD,
            detRecs(ycRecs),
            '$label • $ycDateLabel • D',
            bold: bold,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(ypR, ypRecs, '$label • $ypDateLabel • R', bold: bold),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cLink(
            ypD,
            detRecs(ypRecs),
            '$label • $ypDateLabel • D',
            bold: bold,
          ),
        ),
        cBox(
          padding: classVCellPad(
            denseTop: denseTop,
            denseBottom: denseBottom,
          ),
          child: cText('$varVal', bold: bold),
        ),
      ]);
    }

    Widget buildScreenTable() {
      return LayoutBuilder(
        builder: (context, constraints) {
          final barW =
              constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: barW,
                  child: Row(
                    children: [
                      Expanded(
                        child: cBox(
                          child: cText(
                            'Name of the Police Station',
                            bold: true,
                            fontSize: classVTitleFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                rowOfFlex(headerGroupFlexes, [
                  cBox(
                      child: cText('Sr.No',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: cText('Types of Crime',
                          bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child: Center(
                          child: cText(cmDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(pmDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(smlyDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(ycDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: Center(
                          child: cText(ypDateLabel,
                              bold: true, fontSize: classVBodyFontSize))),
                  cBox(
                      child: cText('Var.',
                          bold: true, fontSize: classVBodyFontSize)),
                ]),
                rowOfFlex(dataFlexes, [
                  cBox(
                      child:
                          cText('', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('R', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('D', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('R', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('D', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('R', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('D', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('R', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('D', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('R', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('D', bold: true, fontSize: classVBodyFontSize)),
                  cBox(
                      child:
                          cText('', bold: true, fontSize: classVBodyFontSize)),
                ]),
                for (final def in classVRowDefs) buildScreenDataRow(def),
              ],
            ),
          );
        },
      );
    }

    pw.Widget pCellBox(
      String text, {
      bool bold = false,
      bool alignLeft = false,
      int indentLevel = 0,
      double fontSize = 7,
    }) {
      return pw.Container(
        padding: pw.EdgeInsets.fromLTRB(
          2.0 + indentLevel * 6.0,
          2,
          2,
          2,
        ),
        alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Text(
          text,
          textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    pw.Widget pTableRow(List<int> flexes, List<pw.Widget> cells) {
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.4),
        columnWidths: {
          for (var i = 0; i < flexes.length; i++)
            i: pw.FlexColumnWidth(flexes[i].toDouble()),
        },
        children: [pw.TableRow(children: cells)],
      );
    }

    pw.Widget buildPdfDataRow(Map<String, dynamic> def) {
      final src = rowFor(def['head'] as String);
      final bold = (def['bold'] as bool?) ?? false;
      final indent = (def['indent'] as int?) ?? 0;
      final cmR = vInt(src, 'cm_R');
      final cmD = vInt(src, 'cm_D');
      final pmR = vInt(src, 'pm_R');
      final pmD = vInt(src, 'pm_D');
      final smlyR = vInt(src, 'smly_R');
      final smlyD = vInt(src, 'smly_D');
      final ycR = vInt(src, 'yc_R');
      final ycD = vInt(src, 'yc_D');
      final ypR = vInt(src, 'yp_R');
      final ypD = vInt(src, 'yp_D');
      final varVal = vInt(src, 'variation');
      String s(int n) => '$n';
      return pTableRow(dataFlexes, [
        pCellBox(def['sr'] as String, bold: bold),
        pCellBox(
          def['label'] as String,
          bold: bold,
          alignLeft: true,
          indentLevel: indent,
        ),
        pCellBox(s(cmR), bold: bold),
        pCellBox(s(cmD), bold: bold),
        pCellBox(s(pmR), bold: bold),
        pCellBox(s(pmD), bold: bold),
        pCellBox(s(smlyR), bold: bold),
        pCellBox(s(smlyD), bold: bold),
        pCellBox(s(ycR), bold: bold),
        pCellBox(s(ycD), bold: bold),
        pCellBox(s(ypR), bold: bold),
        pCellBox(s(ypD), bold: bold),
        pCellBox(s(varVal), bold: bold),
      ]);
    }

    Future<void> exportPdf() async {
      final doc = pw.Document();
      final body = <pw.Widget>[
        pTableRow([
          flexAll
        ], [
          pCellBox('Name of the Police Station', bold: true, fontSize: 9),
        ]),
        pTableRow(headerGroupFlexes, [
          pCellBox('Sr.No', bold: true),
          pCellBox('Types of Crime', bold: true),
          pCellBox(cmDateLabel, bold: true),
          pCellBox(pmDateLabel, bold: true),
          pCellBox(smlyDateLabel, bold: true),
          pCellBox(ycDateLabel, bold: true),
          pCellBox(ypDateLabel, bold: true),
          pCellBox('Var.', bold: true),
        ]),
        pTableRow(dataFlexes, [
          pCellBox('', bold: true),
          pCellBox('', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('R', bold: true),
          pCellBox('D', bold: true),
          pCellBox('', bold: true),
        ]),
        for (final def in classVRowDefs) buildPdfDataRow(def),
      ];
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape.copyWith(
            marginTop: 12,
            marginBottom: 12,
            marginLeft: 14,
            marginRight: 14,
          ),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: body,
          ),
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            const minW = 560.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: w < minW ? minW : w,
                child: buildScreenTable(),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => runWithPdfAuthGate(context, exportPdf),
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'Export Table PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildMonthlySummaryPhotoTable(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    bool isInMonth(ModuleRecord r) =>
        r.incidentDate.year == selectedYear &&
        r.incidentDate.month == selectedMonth;
    bool isInYear(ModuleRecord r) => r.incidentDate.year == selectedYear;

    bool isDetected(ModuleRecord r) =>
        r.status == 'Resolved' ||
        r.status == 'Closed' ||
        r.moduleKey == 'detected';

    List<ModuleRecord> monthRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords.where((r) => isInMonth(r) && test(r)).toList();
    List<ModuleRecord> yearRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords.where((r) => isInYear(r) && test(r)).toList();
    List<ModuleRecord> monthDetRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords
            .where((r) => isInMonth(r) && test(r) && isDetected(r))
            .toList();
    List<ModuleRecord> yearDetRecsWhere(bool Function(ModuleRecord) test) =>
        allRecords
            .where((r) => isInYear(r) && test(r) && isDetected(r))
            .toList();

    Widget cellBox(Widget child, {int flex = 1, bool alignLeft = false}) {
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightBorder, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
          constraints: const BoxConstraints(minHeight: 26),
          child: child,
        ),
      );
    }

    Widget headText(String s) => Text(
          s,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: AppColors.navyDark,
          ),
        );

    Widget labelText(String s, {bool bold = false}) => Text(
          s,
          textAlign: TextAlign.left,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.navyDark : AppColors.lightText,
          ),
        );

    Widget linkText(int n, List<ModuleRecord> recs, String title,
        {bool bold = false}) {
      return InkWell(
        onTap: recs.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                    page: ReportCaseListScreen(title: title, records: recs),
                  ),
                );
              },
        child: Text(
          '$n',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: recs.isEmpty ? AppColors.lightSubText : AppColors.infoBlue,
            decoration: recs.isEmpty ? null : TextDecoration.underline,
          ),
        ),
      );
    }

    Widget rowOf(List<Widget> cells) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        );

    Widget dataRow5(String label, bool Function(ModuleRecord) test,
        {bool bold = false, String detLabel = 'Detected'}) {
      final cmReg = monthRecsWhere(test);
      final cmDet = monthDetRecsWhere(test);
      final cyReg = yearRecsWhere(test);
      final cyDet = yearDetRecsWhere(test);
      return rowOf([
        cellBox(labelText(label, bold: bold), flex: 5, alignLeft: true),
        cellBox(linkText(
            cmReg.length, cmReg, '$label • Current Month • Registered',
            bold: bold)),
        cellBox(linkText(
            cmDet.length, cmDet, '$label • Current Month • $detLabel',
            bold: bold)),
        cellBox(linkText(
            cyReg.length, cyReg, '$label • Current Year • Registered',
            bold: bold)),
        cellBox(linkText(
            cyDet.length, cyDet, '$label • Current Year • $detLabel',
            bold: bold)),
      ]);
    }

    Widget dataRow3(String label, bool Function(ModuleRecord) test,
        {bool bold = false}) {
      final cmReg = monthRecsWhere(test);
      final cyReg = yearRecsWhere(test);
      return rowOf([
        cellBox(labelText(label, bold: bold), flex: 5, alignLeft: true),
        cellBox(
            linkText(cmReg.length, cmReg, '$label • Current Month • Registered',
                bold: bold),
            flex: 2),
        cellBox(
            linkText(cyReg.length, cyReg, '$label • Current Year • Registered',
                bold: bold),
            flex: 2),
      ]);
    }

    Widget groupHeader(String label) => rowOf([
          cellBox(headText(label), flex: 5),
          cellBox(headText('Current Month'), flex: 2),
          cellBox(headText('Current Year'), flex: 2),
        ]);

    Widget groupSubHeader(String regLabel, String detLabel) => rowOf([
          cellBox(headText(''), flex: 5),
          cellBox(headText(regLabel)),
          cellBox(headText(detLabel)),
          cellBox(headText(regLabel)),
          cellBox(headText(detLabel)),
        ]);

    bool isBnss(ModuleRecord r) =>
        r.moduleKey == 'bnss' || r.title.toLowerCase().contains('bnss');
    bool isOtherSection(ModuleRecord r) => r.moduleKey == 'it_act';
    bool isGambling(ModuleRecord r) =>
        r.moduleKey == 'coin' || r.title.toLowerCase().contains('gambl');
    bool isProhibition(ModuleRecord r) =>
        r.moduleKey == 'mpda' || r.title.toLowerCase().contains('prohibit');

    bool isAd(ModuleRecord r) => r.moduleKey == 'ad';
    bool isAccident(ModuleRecord r) => r.moduleKey == 'accident';
    bool isNc(ModuleRecord r) => r.moduleKey == 'nc';

    bool isSec186175Bnss(ModuleRecord r) => r.moduleKey == 'bnss';
    bool isSec128Bnss(ModuleRecord r) => r.moduleKey == 'bnss';
    bool isSec129Bnss(ModuleRecord r) => r.moduleKey == 'bnss';
    bool isSec93Ndps(ModuleRecord r) => r.moduleKey == 'ndps';
    bool isSec144Crpc(ModuleRecord r) =>
        r.moduleKey == 'gowans' || r.moduleKey == 'it_act';
    bool isSec55_57Police(ModuleRecord r) =>
        r.moduleKey == 'mpda' || r.moduleKey == 'coin';
    bool isCotpa(ModuleRecord r) => r.moduleKey == 'it_act';
    bool isSec122Police(ModuleRecord r) => r.moduleKey == 'mpda';
    bool isMpda(ModuleRecord r) => r.moduleKey == 'mpda';

    bool isMotorVehicleAct(ModuleRecord r) => r.moduleKey == 'traffic';
    bool isOtherMvAct(ModuleRecord r) => false;

    bool isMissingMale(ModuleRecord r) =>
        r.moduleKey == 'missing' &&
        (r.subCategory?.toLowerCase() == 'male' ||
            r.title.toLowerCase().contains('male'));
    bool isMissingFemale(ModuleRecord r) =>
        r.moduleKey == 'missing' &&
        (r.subCategory?.toLowerCase() == 'female' ||
            r.title.toLowerCase().contains('female'));
    bool isMissingTotal(ModuleRecord r) => r.moduleKey == 'missing';

    bool g1Total(ModuleRecord r) =>
        isBnss(r) || isOtherSection(r) || isGambling(r) || isProhibition(r);
    bool g1NcTotal(ModuleRecord r) => isAd(r) || isAccident(r) || isNc(r);
    bool g2Total(ModuleRecord r) =>
        isSec186175Bnss(r) ||
        isSec128Bnss(r) ||
        isSec129Bnss(r) ||
        isSec93Ndps(r) ||
        isSec144Crpc(r) ||
        isSec55_57Police(r) ||
        isCotpa(r) ||
        isSec122Police(r) ||
        isMpda(r);
    bool g3Total(ModuleRecord r) => isMotorVehicleAct(r) || isOtherMvAct(r);

    final monthYearLabel =
        DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));

    // SINGLE SOURCE OF TRUTH for the Monthly Summary table.
    // Both the on-screen table and the PDF export iterate this exact list,
    // so they cannot drift apart. Each entry kind:
    //   'h'  : group header   (label spans col 1; "Current Month" / "Current Year" span 2/2)
    //   's'  : group sub-head (empty col 1; reg/det reg/det)
    //   'd5' : 5-column data row (label + cmReg + cmDet + cyReg + cyDet)
    //   'd3' : 3-column data row (label + cmReg(span2) + cyReg(span2)) — col 3 & 5 merged
    //   'b'  : blank row separator
    final rowDefs = <Map<String, dynamic>>[
      {'k': 'h', 'l': 'Category'},
      {'k': 's', 'r': 'Registered', 'd': 'Detected'},
      {'k': 'd5', 'l': 'IPC/BNS', 't': isBnss, 'bold': true, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Section 6', 't': isOtherSection, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Gambling', 't': isGambling, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Prohibition', 't': isProhibition, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'Total', 't': g1Total, 'bold': true, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'AD', 't': isAd, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'N.C Injury', 't': isAccident, 'dl': 'Detected'},
      {'k': 'd5', 'l': 'N.C others', 't': isNc, 'dl': 'Detected'},
      {
        'k': 'd5',
        'l': 'N.C Total',
        't': g1NcTotal,
        'bold': true,
        'dl': 'Detected'
      },
      {'k': 'b'},
      {'k': 'h', 'l': 'Preventive'},
      {'k': 'd3', 'l': 'Sec. 126, 135(2) BNSS', 't': isSec186175Bnss},
      {'k': 'd3', 'l': 'Sec. 128 BNSS', 't': isSec128Bnss},
      {'k': 'd3', 'l': 'Sec. 129 BNSS', 't': isSec129Bnss},
      {'k': 'd3', 'l': 'Sec. 93 Prohibition Act', 't': isSec93Ndps},
      {'k': 'd3', 'l': 'Sec 144(1) BNSS act', 't': isSec144Crpc},
      {'k': 'd3', 'l': 'Sec. 55-57 MAH Police act', 't': isSec55_57Police},
      {'k': 'd3', 'l': 'COTPA', 't': isCotpa},
      {'k': 'd3', 'l': 'Sec 122 MAH Police act', 't': isSec122Police},
      {'k': 'd3', 'l': 'MPDA', 't': isMpda},
      {'k': 'd3', 'l': 'Total', 't': g2Total, 'bold': true},
      {'k': 'b'},
      {'k': 'h', 'l': 'MV Act'},
      {'k': 's', 'r': 'Registered', 'd': 'Fine'},
      {
        'k': 'd5',
        'l': 'Sec. 66/192 MV Act',
        't': isMotorVehicleAct,
        'dl': 'Fine'
      },
      {'k': 'd5', 'l': 'Other MV Act', 't': isOtherMvAct, 'dl': 'Fine'},
      {
        'k': 'd5',
        'l': 'Total MV Act',
        't': g3Total,
        'bold': true,
        'dl': 'Fine'
      },
      {'k': 'b'},
      {'k': 'h', 'l': 'Missing'},
      {'k': 's', 'r': 'Registered', 'd': 'Found'},
      {'k': 'd5', 'l': 'Male', 't': isMissingMale, 'dl': 'Found'},
      {'k': 'd5', 'l': 'Female', 't': isMissingFemale, 'dl': 'Found'},
      {
        'k': 'd5',
        'l': 'Total missing',
        't': isMissingTotal,
        'bold': true,
        'dl': 'Found'
      },
    ];

    Widget buildScreenRow(Map<String, dynamic> r) {
      switch (r['k'] as String) {
        case 'b':
          return const SizedBox(height: 8);
        case 'h':
          return groupHeader(r['l'] as String);
        case 's':
          return groupSubHeader(r['r'] as String, r['d'] as String);
        case 'd5':
          return dataRow5(
            r['l'] as String,
            r['t'] as bool Function(ModuleRecord),
            bold: (r['bold'] as bool?) ?? false,
            detLabel: (r['dl'] as String?) ?? 'Detected',
          );
        case 'd3':
          return dataRow3(
            r['l'] as String,
            r['t'] as bool Function(ModuleRecord),
            bold: (r['bold'] as bool?) ?? false,
          );
      }
      return const SizedBox.shrink();
    }

    final tableWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rowDefs.map(buildScreenRow).toList(),
    );

    Future<void> exportPdf() async {
      final doc = pw.Document();

      pw.Widget pCellBox(String text,
          {bool bold = false, bool alignLeft = false}) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
          constraints: const pw.BoxConstraints(minHeight: 11),
          child: pw.Text(
            text,
            textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );
      }

      // A single-row pw.Table whose columnWidths sum to the same total flex
      // (9 units) for every row kind — this guarantees column boundaries
      // line up vertically across the whole table even though some rows
      // use merged (colspan) cells.
      //   d5/s : widths 5, 1, 1, 1, 1   (5-col rows: label + 4 numbers)
      //   d3/h : widths 5, 2, 2         (3-col rows: label + 2 spans)
      pw.Widget pTableRow(List<int> flexes, List<pw.Widget> cells) {
        return pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.4),
          columnWidths: {
            for (var i = 0; i < flexes.length; i++)
              i: pw.FlexColumnWidth(flexes[i].toDouble()),
          },
          children: [pw.TableRow(children: cells)],
        );
      }

      pw.Widget buildPdfRow(Map<String, dynamic> r) {
        switch (r['k'] as String) {
          case 'b':
            return pw.SizedBox(height: 4);
          case 'h':
            return pTableRow([
              5,
              2,
              2
            ], [
              pCellBox(r['l'] as String, bold: true),
              pCellBox('Current Month', bold: true),
              pCellBox('Current Year', bold: true),
            ]);
          case 's':
            return pTableRow([
              5,
              1,
              1,
              1,
              1
            ], [
              pCellBox(''),
              pCellBox(r['r'] as String, bold: true),
              pCellBox(r['d'] as String, bold: true),
              pCellBox(r['r'] as String, bold: true),
              pCellBox(r['d'] as String, bold: true),
            ]);
          case 'd5':
            final test = r['t'] as bool Function(ModuleRecord);
            final bold = (r['bold'] as bool?) ?? false;
            return pTableRow([
              5,
              1,
              1,
              1,
              1
            ], [
              pCellBox(r['l'] as String, bold: bold, alignLeft: true),
              pCellBox('${monthRecsWhere(test).length}', bold: bold),
              pCellBox('${monthDetRecsWhere(test).length}', bold: bold),
              pCellBox('${yearRecsWhere(test).length}', bold: bold),
              pCellBox('${yearDetRecsWhere(test).length}', bold: bold),
            ]);
          case 'd3':
            final test = r['t'] as bool Function(ModuleRecord);
            final bold = (r['bold'] as bool?) ?? false;
            return pTableRow([
              5,
              2,
              2
            ], [
              pCellBox(r['l'] as String, bold: bold, alignLeft: true),
              pCellBox('${monthRecsWhere(test).length}', bold: bold),
              pCellBox('${yearRecsWhere(test).length}', bold: bold),
            ]);
        }
        return pw.SizedBox.shrink();
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1A2A4A),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MONTHLY SUMMARY REPORT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      monthYearLabel,
                      style: const pw.TextStyle(
                        color: PdfColor.fromInt(0xFFFFC107),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              ...rowDefs.map(buildPdfRow),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Monthly_Summary_${monthYearLabel.replaceAll(' ', '_')}.pdf',
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              const minW = 560.0;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: w < minW ? minW : w,
                  child: tableWidget,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => runWithPdfAuthGate(context, exportPdf),
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                'Export PDF',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMonthlyReportTableInternalVI(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    const heads = [
      'Arms Act',
      'Gambling Act',
      'Prohibition',
      'NDPS Act',
      '135 B Pact',
      '142 B Pact',
      '122 B Pact',
      'M V Act',
      'Miscellaneous',
    ];

    String getHead(ModuleRecord r) {
      final sub = (r.subCategory ?? '').toLowerCase();
      final key = r.moduleKey.toLowerCase();

      if (key != 'form_6') return 'Miscellaneous';

      if (sub.contains('arms')) return 'Arms Act';
      if (sub.contains('gambl')) return 'Gambling Act';
      if (sub.contains('prohib')) return 'Prohibition';
      if (sub.contains('ndps')) return 'NDPS Act';
      if (sub.contains('135')) return '135 B Pact';
      if (sub.contains('142')) return '142 B Pact';
      if (sub.contains('122')) return '122 B Pact';
      if (sub.contains('m v') || sub.contains('mv') || sub.contains('motor')) {
        return 'M V Act';
      }

      return 'Miscellaneous';
    }

    List<ModuleRecord> filterMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'form_6' &&
            r.incidentDate.year == y &&
            r.incidentDate.month == m)
        .toList();

    List<ModuleRecord> filterYearToMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'form_6' &&
            r.incidentDate.year == y &&
            r.incidentDate.month <= m)
        .toList();

    final currentMonthRecords = filterMonth(selectedMonth, selectedYear);
    final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final previousMonthRecords = filterMonth(prevMonth, prevYear);
    final sameMonthLastYearRecords =
        filterMonth(selectedMonth, selectedYear - 1);
    final yearCurrentRecords = filterYearToMonth(selectedMonth, selectedYear);
    final yearPreviousRecords =
        filterYearToMonth(selectedMonth, selectedYear - 1);

    final tableRows = <Map<String, dynamic>>[];
    int totalcmR = 0;
    int totalpmR = 0;
    int totalsmlyR = 0;
    int totalycR = 0;
    int totalypR = 0;

    for (int i = 0; i < heads.length; i++) {
      final head = heads[i];
      List<ModuleRecord> byHead(List<ModuleRecord> list) =>
          list.where((r) => getHead(r) == head).toList();

      final cm = byHead(currentMonthRecords);
      final pm = byHead(previousMonthRecords);
      final smly = byHead(sameMonthLastYearRecords);
      final yc = byHead(yearCurrentRecords);
      final yp = byHead(yearPreviousRecords);

      final cmR = cm.length;
      final pmR = pm.length;
      final smlyR = smly.length;
      final ycR = yc.length;
      final ypR = yp.length;
      final variation = ycR - ypR;

      tableRows.add({
        'N': i + 1,
        'Heads': head,
        'cm_R': cmR,
        'pm_R': pmR,
        'smly_R': smlyR,
        'yc_R': ycR,
        'yp_R': ypR,
        'variation': variation,
        'cmRecords': cm,
        'pmRecords': pm,
        'smlyRecords': smly,
        'ycRecords': yc,
        'ypRecords': yp,
      });

      totalcmR += cmR;
      totalpmR += pmR;
      totalsmlyR += smlyR;
      totalycR += ycR;
      totalypR += ypR;
    }

    tableRows.add({
      'N': '',
      'Heads': 'TOTAL',
      'cm_R': totalcmR,
      'pm_R': totalpmR,
      'smly_R': totalsmlyR,
      'yc_R': totalycR,
      'yp_R': totalypR,
      'variation': totalycR - totalypR,
      'cmRecords': currentMonthRecords,
      'pmRecords': previousMonthRecords,
      'smlyRecords': sameMonthLastYearRecords,
      'ycRecords': yearCurrentRecords,
      'ypRecords': yearPreviousRecords,
    });

    final prevMonth2 = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevMonthYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    String mLabel(DateTime d) {
      final m = DateFormat('MMM').format(d).toUpperCase();
      return '$m\n${d.year}';
    }

    final cmLabel = mLabel(DateTime(selectedYear, selectedMonth));
    final pmLabel = mLabel(DateTime(prevMonthYear, prevMonth2));
    final smlyLabel = mLabel(DateTime(selectedYear - 1, selectedMonth));
    final ycLabel = 'Year\n$selectedYear';
    final ypLabel = 'Year\n${selectedYear - 1}';

    DataColumn col(String label, {bool alignLeft = false}) => DataColumn(
          label: Text(
            label,
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDark,
            ),
          ),
        );

    DataCell cell(String text,
            {bool alignLeft = false, bool isBold = false, Color? color}) =>
        DataCell(
          Align(
            alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: color ??
                    (isBold ? AppColors.navyDark : AppColors.lightText),
              ),
            ),
          ),
        );

    DataCell clickableCell(
      String text,
      List<ModuleRecord> recs,
      String title, {
      bool alignLeft = false,
      bool isBold = false,
      Color? color,
    }) {
      return DataCell(
        Align(
          alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color:
                  color ?? (isBold ? AppColors.navyDark : AppColors.lightText),
            ),
          ),
        ),
        onTap: recs.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                    page: ReportCaseListScreen(title: title, records: recs),
                  ),
                );
              },
      );
    }

    DataCell navCell(String text, List<ModuleRecord> recs, String title,
        {bool isBold = false}) {
      return DataCell(
        InkWell(
          onTap: recs.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(
                      page: ReportCaseListScreen(title: title, records: recs),
                    ),
                  );
                },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color:
                    recs.isEmpty ? AppColors.lightSubText : AppColors.infoBlue,
                decoration: recs.isEmpty ? null : TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // Keep the monthly report table compact like a standard data table.
            final colSpace =
                w < 360 ? 6.0 : (w < 600 ? 8.0 : (w < 1000 ? 12.0 : 16.0));
            final margin = w < 360 ? 6.0 : (w < 1000 ? 8.0 : 12.0);
            final headingH = w < 360 ? 40.0 : (w < 1000 ? 44.0 : 48.0);
            final rowH = w < 360 ? 32.0 : (w < 1000 ? 34.0 : 38.0);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: w, // fill available width on PC
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.navyMid.withValues(alpha: 0.05),
                    ),
                    dataRowMinHeight: rowH,
                    dataRowMaxHeight: rowH,
                    headingRowHeight: headingH,
                    horizontalMargin: margin,
                    columnSpacing: colSpace,
                    border: TableBorder.all(
                      color: AppColors.lightBorder,
                      width: 0.5,
                    ),
                    columns: [
                      col('N'),
                      col('Heads', alignLeft: true),
                      col(cmLabel),
                      col(pmLabel),
                      col(smlyLabel),
                      col(ycLabel),
                      col(ypLabel),
                      col('var.'),
                    ],
                    rows: tableRows.map((row) {
                      final isTotal = row['Heads'] == 'TOTAL';
                      return DataRow(
                        color: isTotal
                            ? WidgetStateProperty.all(
                                AppColors.goldPrimary.withValues(alpha: 0.1),
                              )
                            : null,
                        cells: [
                          cell(row['N'].toString(), isBold: isTotal),
                          cell(row['Heads'].toString(),
                              alignLeft: true, isBold: true),
                          navCell(
                            '${row['cm_R']}',
                            (row['cmRecords'] as List<ModuleRecord>?) ??
                                const <ModuleRecord>[],
                            '${row['Heads']} • $cmLabel',
                            isBold: isTotal,
                          ),
                          navCell(
                            '${row['pm_R']}',
                            (row['pmRecords'] as List<ModuleRecord>?) ??
                                const <ModuleRecord>[],
                            '${row['Heads']} • $pmLabel',
                            isBold: isTotal,
                          ),
                          navCell(
                            '${row['smly_R']}',
                            (row['smlyRecords'] as List<ModuleRecord>?) ??
                                const <ModuleRecord>[],
                            '${row['Heads']} • $smlyLabel',
                            isBold: isTotal,
                          ),
                          navCell(
                            '${row['yc_R']}',
                            (row['ycRecords'] as List<ModuleRecord>?) ??
                                const <ModuleRecord>[],
                            '${row['Heads']} • $ycLabel',
                            isBold: isTotal,
                          ),
                          navCell(
                            '${row['yp_R']}',
                            (row['ypRecords'] as List<ModuleRecord>?) ??
                                const <ModuleRecord>[],
                            '${row['Heads']} • $ypLabel',
                            isBold: isTotal,
                          ),
                          clickableCell(
                            row['variation'].toString(),
                            (row['ycRecords'] as List<ModuleRecord>?) ??
                                const <ModuleRecord>[],
                            '${row['Heads']} • $ycLabel • Variation',
                            isBold: isTotal,
                            color: (row['variation'] as int) > 0
                                ? AppColors.dangerRed
                                : ((row['variation'] as int) < 0
                                    ? AppColors.successGreen
                                    : null),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final label = DateFormat('MMMM yyyy')
                  .format(DateTime(selectedYear, selectedMonth));
              runWithPdfAuthGate(
                context,
                () => ModulePdfHelper.generateMonthlyTablePdf(label, tableRows),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 18),
            label: Text(
              'Export Table PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildMonthlyReportTableInternalPreventive(
    BuildContext context,
    List<ModuleRecord> allRecords,
    int selectedMonth,
    int selectedYear,
  ) {
    const heads = [
      '107 Crpc/126 BNSS',
      '109 Crpc/128 BNSS',
      '110 Crpc/129 BNSS',
      '151 (3) Crpc/170(3) BNSS',
      '55 to 57 B P Act',
      'U/s 122  B P Act',
      'U/s 124  B P Act',
      '142 B P Act',
      'M H O R',
      '93 Pro Act',
      'N S A',
      'M P D A',
      'M.C.O.C.A.',
    ];

    String getHead(ModuleRecord r) {
      final key = r.moduleKey.toLowerCase();
      final sub = (r.subCategory ?? '').toLowerCase();
      if (key != 'preventive') return 'M H O R';

      if (sub.contains('107') || sub.contains('126')) {
        return '107 Crpc/126 BNSS';
      }
      if (sub.contains('109') || sub.contains('128')) {
        return '109 Crpc/128 BNSS';
      }
      if (sub.contains('110') || sub.contains('129')) {
        return '110 Crpc/129 BNSS';
      }
      if (sub.contains('151') || sub.contains('170')) {
        return '151 (3) Crpc/170(3) BNSS';
      }
      if (sub.contains('55') || sub.contains('56') || sub.contains('57')) {
        return '55 to 57 B P Act';
      }
      if (sub.contains('122')) return 'U/s 122  B P Act';
      if (sub.contains('124')) return 'U/s 124  B P Act';
      if (sub.contains('142')) return '142 B P Act';
      if (sub.contains('mhor') || sub.contains('m h o r')) return 'M H O R';
      if (sub.contains('93') || sub.contains('pro act')) return '93 Pro Act';
      if (sub.contains('nsa') || sub.contains('n s a')) return 'N S A';
      if (sub.contains('mpda') || sub.contains('m p d a')) return 'M P D A';
      if (sub.contains('mcoca') || sub.contains('m.c.o.c.a')) {
        return 'M.C.O.C.A.';
      }

      return 'M H O R';
    }

    List<ModuleRecord> filterMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'preventive' &&
            r.incidentDate.year == y &&
            r.incidentDate.month == m)
        .toList();

    List<ModuleRecord> filterYearToMonth(int m, int y) => allRecords
        .where((r) =>
            r.moduleKey == 'preventive' &&
            r.incidentDate.year == y &&
            r.incidentDate.month <= m)
        .toList();

    final currentMonthRecords = filterMonth(selectedMonth, selectedYear);
    final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
    final prevYear = selectedMonth == 1 ? selectedYear - 1 : selectedYear;
    final previousMonthRecords = filterMonth(prevMonth, prevYear);
    final sameMonthLastYearRecords =
        filterMonth(selectedMonth, selectedYear - 1);
    final yearCurrentRecords = filterYearToMonth(selectedMonth, selectedYear);
    final yearPreviousRecords =
        filterYearToMonth(selectedMonth, selectedYear - 1);

    final tableRows = <Map<String, dynamic>>[];
    int totalcm = 0, totalpm = 0, totalsmly = 0, totalyc = 0, totalyp = 0;

    for (int i = 0; i < heads.length; i++) {
      final head = heads[i];
      List<ModuleRecord> byHead(List<ModuleRecord> list) =>
          list.where((r) => getHead(r) == head).toList();

      final cmRecs = byHead(currentMonthRecords);
      final pmRecs = byHead(previousMonthRecords);
      final smlyRecs = byHead(sameMonthLastYearRecords);
      final ycRecs = byHead(yearCurrentRecords);
      final ypRecs = byHead(yearPreviousRecords);

      final cm = cmRecs.length;
      final pm = pmRecs.length;
      final smly = smlyRecs.length;
      final yc = ycRecs.length;
      final yp = ypRecs.length;
      final variation = yc - yp;

      tableRows.add({
        'N': i + 1,
        'Heads': head,
        'cm_R': cm,
        'pm_R': pm,
        'smly_R': smly,
        'yc_R': yc,
        'yp_R': yp,
        'variation': variation,
        'cmRecords': cmRecs,
        'pmRecords': pmRecs,
        'smlyRecords': smlyRecs,
        'ycRecords': ycRecs,
        'ypRecords': ypRecs,
      });

      totalcm += cm;
      totalpm += pm;
      totalsmly += smly;
      totalyc += yc;
      totalyp += yp;
    }

    tableRows.add({
      'N': '',
      'Heads': 'TOTAL',
      'cm_R': totalcm,
      'pm_R': totalpm,
      'smly_R': totalsmly,
      'yc_R': totalyc,
      'yp_R': totalyp,
      'variation': totalyc - totalyp,
      'cmRecords': currentMonthRecords,
      'pmRecords': previousMonthRecords,
      'smlyRecords': sameMonthLastYearRecords,
      'ycRecords': yearCurrentRecords,
      'ypRecords': yearPreviousRecords,
    });

    String mLabel(DateTime d) {
      final m = DateFormat('MMM').format(d).toUpperCase();
      return '$m\n${d.year}';
    }

    final prevMonthYear = prevYear;
    final cmLabel = mLabel(DateTime(selectedYear, selectedMonth));
    final pmLabel = mLabel(DateTime(prevMonthYear, prevMonth));
    final smlyLabel = mLabel(DateTime(selectedYear - 1, selectedMonth));
    final ycLabel = 'Year\n$selectedYear';
    final ypLabel = 'Year\n${selectedYear - 1}';

    DataColumn col(String label, {bool alignLeft = false}) => DataColumn(
          label: Text(
            label,
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.navyDark,
            ),
          ),
        );

    DataCell cell(String text, {bool alignLeft = false, bool isBold = false}) =>
        DataCell(
          Align(
            alignment: alignLeft ? Alignment.centerLeft : Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? AppColors.navyDark : AppColors.lightText,
              ),
            ),
          ),
        );

    DataCell navCell(String text, List<ModuleRecord> recs, String title,
        {bool isBold = false}) {
      return DataCell(
        InkWell(
          onTap: recs.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    AppTheme.fadeSlideRoute(
                      page: ReportCaseListScreen(title: title, records: recs),
                    ),
                  );
                },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color:
                    recs.isEmpty ? AppColors.lightSubText : AppColors.infoBlue,
                decoration: recs.isEmpty ? null : TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }

    String varText(dynamic v) {
      final n = (v as int?) ?? 0;
      if (n == 0) return '=';
      return n > 0 ? '+$n' : '$n';
    }

    DataCell clickableCell(
      String text,
      List<ModuleRecord> recs,
      String title, {
      bool isBold = false,
    }) {
      return DataCell(
        Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.navyDark : AppColors.lightText,
            ),
          ),
        ),
        onTap: recs.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  AppTheme.fadeSlideRoute(
                    page: ReportCaseListScreen(title: title, records: recs),
                  ),
                );
              },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            // Keep the monthly report table compact like a standard data table.
            final colSpace =
                w < 360 ? 6.0 : (w < 600 ? 8.0 : (w < 1000 ? 12.0 : 16.0));
            final margin = w < 360 ? 6.0 : (w < 1000 ? 8.0 : 12.0);
            final headingH = w < 360 ? 40.0 : (w < 1000 ? 44.0 : 48.0);
            final rowH = w < 360 ? 32.0 : (w < 1000 ? 34.0 : 38.0);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: w, // fill available width on PC
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: SizedBox(
                    width: w,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.navyMid.withValues(alpha: 0.05),
                      ),
                      dataRowMinHeight: rowH,
                      dataRowMaxHeight: rowH,
                      headingRowHeight: headingH,
                      horizontalMargin: margin,
                      columnSpacing: colSpace,
                      border: TableBorder.all(
                        color: AppColors.lightBorder,
                        width: 0.5,
                      ),
                      columns: [
                        col('SR'),
                        col('Heads', alignLeft: true),
                        col(cmLabel),
                        col(pmLabel),
                        col(smlyLabel),
                        col(ycLabel),
                        col(ypLabel),
                        col('var.'),
                      ],
                      rows: tableRows.map((row) {
                        final isTotal = row['Heads'] == 'TOTAL';
                        return DataRow(
                          color: isTotal
                              ? WidgetStateProperty.all(
                                  AppColors.goldPrimary.withValues(alpha: 0.1),
                                )
                              : null,
                          cells: [
                            cell(row['N'].toString(), isBold: isTotal),
                            cell(row['Heads'].toString(),
                                alignLeft: true, isBold: true),
                            navCell(
                              '${row['cm_R']}',
                              (row['cmRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $cmLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['pm_R']}',
                              (row['pmRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $pmLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['smly_R']}',
                              (row['smlyRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $smlyLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['yc_R']}',
                              (row['ycRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ycLabel',
                              isBold: isTotal,
                            ),
                            navCell(
                              '${row['yp_R']}',
                              (row['ypRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ypLabel',
                              isBold: isTotal,
                            ),
                            clickableCell(
                              varText(row['variation']),
                              (row['ycRecords'] as List<ModuleRecord>?) ??
                                  const <ModuleRecord>[],
                              '${row['Heads']} • $ycLabel • Variation',
                              isBold: isTotal,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final label = DateFormat('MMMM yyyy')
                  .format(DateTime(selectedYear, selectedMonth));
              runWithPdfAuthGate(
                context,
                () => ModulePdfHelper.generateMonthlyTablePdf(label, tableRows),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.white, size: 18),
            label: Text(
              'Export Table PDF',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _monthlyReportButtons(
      List<ModuleRecord> records, String title, String range) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.navyMid.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _reportBtn(
              'Class V',
              () {
                setState(() {
                  _showMonthlySummaryTable = false;
                  _showMonthlyClassVTable = !_showMonthlyClassVTable;
                  if (_showMonthlyClassVTable) {
                    _showMonthlyClassVITable = false;
                    _showMonthlyPreventiveTable = false;
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _reportBtn(
              'Class VI',
              () {
                setState(() {
                  _showMonthlySummaryTable = false;
                  _showMonthlyClassVITable = !_showMonthlyClassVITable;
                  if (_showMonthlyClassVITable) {
                    _showMonthlyClassVTable = false;
                    _showMonthlyPreventiveTable = false;
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _reportBtn(
              'Preventives',
              () {
                setState(() {
                  _showMonthlySummaryTable = false;
                  _showMonthlyPreventiveTable = !_showMonthlyPreventiveTable;
                  if (_showMonthlyPreventiveTable) {
                    _showMonthlyClassVTable = false;
                    _showMonthlyClassVITable = false;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportBtn(String label, VoidCallback? onTap) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyMid,
          disabledBackgroundColor: AppColors.lightBorder,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppColors.lightSubText,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // (intentionally removed) Monthly preview dialog: monthly screen is now table-driven.

  Widget _buildReportTile(_CalCategoryMeta meta) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            AppTheme.fadeSlideRoute(
                page: ModuleHubScreen(
              moduleLabel: meta.label,
              moduleKey: meta.moduleKey,
              subCategory: meta.subCategory,
              readOnly: true,
            )));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(children: [
                Text(meta.label,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightText)),
                const SizedBox(width: 8),
                Icon(Icons.open_in_new_rounded,
                    size: 14, color: AppColors.navyMid.withValues(alpha: 0.5)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${meta.count}',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReport() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(children: [
          Icon(Icons.analytics_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No data available for this range',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.lightSubText)),
        ]),
      ),
    );
  }
}

// ── Dashboard AppBar station switcher ─────────────────────────────────────────

// ignore: unused_element
class _DashboardStationSwitcher extends StatefulWidget {
  const _DashboardStationSwitcher({required this.auth});

  final AuthProvider auth;

  @override
  State<_DashboardStationSwitcher> createState() =>
      _DashboardStationSwitcherState();
}

class _DashboardStationSwitcherState extends State<_DashboardStationSwitcher> {
  final FirestoreService _firestore = FirestoreService();
  List<String> _stations = [];
  bool _loading = false;

  bool get _canSwitch =>
      SeniorOfficerRoles.canSwitchLocation(widget.auth.designation);

  @override
  void initState() {
    super.initState();
    if (_canSwitch) _loadStations();
  }

  @override
  void didUpdateWidget(covariant _DashboardStationSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_canSwitch &&
        oldWidget.auth.designation != widget.auth.designation &&
        _stations.isEmpty) {
      _loadStations();
    }
  }

  Future<void> _loadStations() async {
    setState(() => _loading = true);
    final names = await _firestore.getPoliceStationNames();
    if (!mounted) return;
    setState(() {
      _stations = names;
      _loading = false;
    });
  }

  List<String> _dropdownItems(String active) {
    final items = <String>{..._stations};
    if (active.trim().isNotEmpty) items.add(active.trim());
    final sorted = items.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.auth;
    final active = auth.activeStation.trim();
    final screenWidth = MediaQuery.of(context).size.width;
    final maxSwitcherWidth = screenWidth < 380
        ? 110.0
        : (screenWidth < 480 ? 130.0 : 220.0);
    final labelStyle = GoogleFonts.poppins(
      fontSize: screenWidth < 400 ? 10 : 11,
      fontWeight: FontWeight.w600,
      color: AppColors.navyDark,
    );

    if (!_canSwitch) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSwitcherWidth),
        child: Text(
          active.isNotEmpty ? active : '—',
          style: labelStyle.copyWith(color: AppColors.navyMid),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
        ),
      );
    }

    final items = _dropdownItems(active);
    final value = active.isNotEmpty && items.contains(active) ? active : null;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxSwitcherWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: auth.isViewingOtherStation
              ? AppColors.goldPrimary.withValues(alpha: 0.12)
              : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: auth.isViewingOtherStation
                ? AppColors.goldPrimary.withValues(alpha: 0.45)
                : AppColors.lightBorder,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth < 400 ? 6 : 10),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                _loading ? 'Loading…' : 'Select station',
                style: labelStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.navyMid,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                size: screenWidth < 400 ? 18 : 24,
                color: auth.isViewingOtherStation
                    ? AppColors.goldPrimary
                    : AppColors.navyMid,
              ),
              items: items
                  .map(
                    (station) => DropdownMenuItem<String>(
                      value: station,
                      child: Text(
                        station,
                        style: labelStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _loading
                  ? null
                  : (selected) {
                      if (selected == null || selected.isEmpty) return;
                      auth.switchStation(selected);
                    },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Station Switcher Bottom Sheet ─────────────────────────────────────────────

/// One district/commissionerate zone with selectable station (or location) names.
class _SwitcherZone {
  const _SwitcherZone({required this.zoneName, required this.entries});

  final String zoneName;
  final List<String> entries;
}

class _StationSwitcherSheet extends StatefulWidget {
  final FirestoreService firestore;
  final AuthProvider auth;

  const _StationSwitcherSheet({
    required this.firestore,
    required this.auth,
  });

  @override
  State<_StationSwitcherSheet> createState() => _StationSwitcherSheetState();
}

class _StationSwitcherSheetState extends State<_StationSwitcherSheet> {
  static const String _otherZoneName = 'Other Locations';

  List<_SwitcherZone> _zones = [];
  List<_SwitcherZone> _visibleZones = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() => _loading = true);

    try {
      await MaharashtraPoliceStationsRepository.initialize();
    } catch (_) {
      // CSV unavailable — still attempt Firestore-only grouping below.
    }

    final rawNames = await _collectRawAccessibleNames();
    final zones = _buildZones(rawNames);

    if (!mounted) return;
    setState(() {
      _zones = zones;
      _loading = false;
    });
    _applySearchFilter();
  }

  /// Fresh name set on every sheet open (Firestore re-fetched for non CP/SP roles).
  Future<Set<String>> _collectRawAccessibleNames() async {
    final designation = widget.auth.designation;
    final isCp = SeniorOfficerRoles.isCpLevel(designation);
    final isSp = SeniorOfficerRoles.isSpLevel(designation);
    final additional = widget.auth.additionalStations;
    final home = widget.auth.homeStationName.trim();

    final names = <String>{};
    if (home.isNotEmpty) names.add(home);
    names.addAll(additional.where((s) => s.trim().isNotEmpty));

    if (isCp || isSp) {
      final currentArea = _resolveCurrentArea(widget.auth.stationName);
      if (currentArea.isEmpty) {
        return names;
      }
      for (final station in MaharashtraPoliceStationsRepository.getStationsForDistrict(
        currentArea,
      )) {
        if (isCp && station.type != 'Commissionerate Police') continue;
        if (isSp && station.type != 'Superintendent of Police') continue;
        names.add(station.stationName);
      }
    } else if (SeniorOfficerRoles.canSwitchLocation(designation)) {
      final fetched = await widget.firestore.getPoliceStationNames();
      names.addAll(fetched.where((s) => s.trim().isNotEmpty));
    } else {
      final fetched = await widget.firestore.getAllStationNames();
      names.addAll(fetched.where((s) => s.trim().isNotEmpty));
    }

    names.removeWhere((s) => s.trim().isEmpty);
    return names;
  }

  List<_SwitcherZone> _buildZones(Set<String> rawNames) {
    if (!MaharashtraPoliceStationsRepository.isLoaded) {
      if (rawNames.isEmpty) return const [];
      final entries = rawNames.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return [_SwitcherZone(zoneName: _otherZoneName, entries: entries)];
    }

    final designation = widget.auth.designation;
    final isCp = SeniorOfficerRoles.isCpLevel(designation);
    final isSp = SeniorOfficerRoles.isSpLevel(designation);
    final additional = widget.auth.additionalStations;
    final currentArea = _resolveCurrentArea(widget.auth.stationName);

    final zoneEntries = <String, Set<String>>{};
    void addEntry(String zone, String entry) {
      if (entry.trim().isEmpty) return;
      zoneEntries.putIfAbsent(zone, () => {}).add(entry.trim());
    }

    String zoneForEntry(String name) =>
        _resolveDistrictForName(name) ?? _otherZoneName;

    bool districtExpanded(String district) {
      if (currentArea.isNotEmpty &&
          district.toLowerCase() == currentArea.toLowerCase()) {
        return true;
      }
      return additional.any((a) => a.trim().toLowerCase() == district.toLowerCase());
    }

    void addDistrictStations(String district) {
      if (!districtExpanded(district)) return;
      for (final station in MaharashtraPoliceStationsRepository.getStationsForDistrict(
        district,
      )) {
        if (isCp && station.type != 'Commissionerate Police') continue;
        if (isSp && station.type != 'Superintendent of Police') continue;
        addEntry(district, station.stationName);
      }
    }

    for (final name in rawNames) {
      if (_isDistrictName(name)) {
        final district = _canonicalDistrictName(name)!;
        addEntry(district, district);
        addDistrictStations(district);
      } else {
        addEntry(zoneForEntry(name), name);
      }
    }

    if (currentArea.isNotEmpty && _isDistrictName(currentArea)) {
      addDistrictStations(currentArea);
    }

    final sortedZoneNames = zoneEntries.keys.toList()
      ..sort(
        (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );

    return sortedZoneNames.map((zoneName) {
      final entries = zoneEntries[zoneName]!.toList()
        ..sort(_compareSwitcherEntries);
      return _SwitcherZone(zoneName: zoneName, entries: entries);
    }).where((zone) => zone.entries.isNotEmpty).toList();
  }

  int _compareSwitcherEntries(String a, String b) {
    final aIsDistrict = _isDistrictName(a);
    final bIsDistrict = _isDistrictName(b);
    if (aIsDistrict && !bIsDistrict) return -1;
    if (!aIsDistrict && bIsDistrict) return 1;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  void _applySearchFilter() {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) {
      if (!mounted) return;
      setState(() => _visibleZones = _zones);
      return;
    }

    final filtered = <_SwitcherZone>[];
    for (final zone in _zones) {
      if (zone.zoneName.toLowerCase().contains(q)) {
        filtered.add(zone);
        continue;
      }
      final matchingEntries = zone.entries
          .where((entry) => entry.toLowerCase().contains(q))
          .toList();
      if (matchingEntries.isNotEmpty) {
        filtered.add(
          _SwitcherZone(zoneName: zone.zoneName, entries: matchingEntries),
        );
      }
    }

    if (!mounted) return;
    setState(() => _visibleZones = filtered);
  }

  bool _isDistrictName(String name) {
    final value = name.trim();
    if (value.isEmpty) return false;
    if (!MaharashtraPoliceStationsRepository.isLoaded) return false;
    return MaharashtraPoliceStationsRepository.getDistricts().any(
      (d) => d.toLowerCase() == value.toLowerCase(),
    );
  }

  String? _canonicalDistrictName(String name) {
    final value = name.trim();
    if (value.isEmpty || !MaharashtraPoliceStationsRepository.isLoaded) {
      return null;
    }
    for (final district in MaharashtraPoliceStationsRepository.getDistricts()) {
      if (district.toLowerCase() == value.toLowerCase()) return district;
    }
    return null;
  }

  String? _resolveDistrictForName(String name) {
    final value = name.trim();
    if (value.isEmpty) return null;

    final asDistrict = _canonicalDistrictName(value);
    if (asDistrict != null) return asDistrict;

    if (!MaharashtraPoliceStationsRepository.isLoaded) return null;
    for (final station in MaharashtraPoliceStationsRepository.getAllStations()) {
      if (station.stationName.toLowerCase() == value.toLowerCase()) {
        return station.districtName;
      }
    }
    return null;
  }

  String _resolveCurrentArea(String activeName) {
    return _resolveDistrictForName(activeName) ?? '';
  }

  void _onSearch(String q) {
    setState(() => _search = q);
    _applySearchFilter();
  }

  bool get _hasVisibleEntries =>
      _visibleZones.any((zone) => zone.entries.isNotEmpty);

  Future<void> _confirmDeleteLocation(String location) async {
    final homeStation = widget.auth.homeStationName;
    if (location.trim().isEmpty) return;
    if (location == homeStation) return;
    if (!widget.auth.additionalStations.contains(location)) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Location'),
        content: const Text('Are you sure you want to remove this location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    if (SeniorOfficerRoles.canSwitchLocation(widget.auth.designation)) {
      await MaharashtraPoliceStationsRepository.initialize();
    }
    final active = widget.auth.stationName;
    final activeArea = _resolveCurrentArea(active);
    final isDeletingActive = active == location ||
        activeArea.toLowerCase() == location.toLowerCase();

    await widget.auth.removeStation(location);

    if (isDeletingActive) {
      widget.auth.switchStation(homeStation);
    }

    _loadStations();
  }

  Future<void> _onAddLocation() async {
    final isCp = SeniorOfficerRoles.isCpLevel(widget.auth.designation);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddLocationSheet(isCpLevel: isCp),
    );

    if (result != null && result.isNotEmpty) {
      await widget.auth.addStation(result);
      _loadStations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStation = widget.auth.stationName;
    final homeStation = widget.auth.homeStationName;
    final canAdd =
        SeniorOfficerRoles.canSwitchLocation(widget.auth.designation);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.navyMid.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: AppColors.navyMid, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Switch Policestation',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                        ),
                      ),
                      Text(
                        'Select a station to view its data',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.lightSubText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: _onSearch,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search zone or station...',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.lightSubText),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 20, color: AppColors.navyMid),
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.navyMid),
            )
          else if (!_hasVisibleEntries)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.location_off_rounded,
                      size: 40, color: AppColors.lightSubText),
                  const SizedBox(height: 8),
                  Text(
                    _search.trim().isNotEmpty
                        ? 'No zones or stations match "${_search.trim()}"'
                        : 'No stations found',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.lightSubText),
                  ),
                  if (canAdd) ...[
                    const SizedBox(height: 16),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.add_location_alt_rounded,
                        size: 20,
                        color: AppColors.goldPrimary,
                      ),
                      title: Text(
                        'Add Location',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                      onTap: _onAddLocation,
                    ),
                  ],
                ],
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (var zi = 0; zi < _visibleZones.length; zi++) ...[
                    if (zi > 0)
                      const Divider(height: 1, indent: 20, endIndent: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Text(
                        _visibleZones[zi].zoneName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDark,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    for (final station in _visibleZones[zi].entries)
                      _buildStationTile(
                        station: station,
                        activeStation: activeStation,
                        homeStation: homeStation,
                      ),
                  ],
                  if (canAdd)
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.add_location_alt_rounded,
                        size: 20,
                        color: AppColors.goldPrimary,
                      ),
                      title: Text(
                        'Add Location',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                      onTap: _onAddLocation,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStationTile({
    required String station,
    required String activeStation,
    required String homeStation,
  }) {
    final isActive = station == activeStation;
    final isHome = station == homeStation;
    final isAddedLocation =
        widget.auth.additionalStations.contains(station) && !isHome;

    return ListTile(
      dense: true,
      selected: isActive,
      selectedTileColor: AppColors.navyMid.withValues(alpha: 0.08),
      leading: Icon(
        isActive
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        size: 20,
        color: isActive ? AppColors.navyMid : AppColors.lightSubText,
      ),
      title: Text(
        station,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? AppColors.navyDark : AppColors.lightText,
        ),
      ),
      trailing: (isHome || isAddedLocation)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHome)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Home',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ),
                if (isAddedLocation)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Colors.red,
                    onPressed: () => _confirmDeleteLocation(station),
                  ),
              ],
            )
          : null,
      onTap: () {
        widget.auth.switchStation(station);
        Navigator.pop(context);
      },
    );
  }
}

// ── Add Location Bottom Sheet ──────────────────────────────────────────────────
class _AddLocationSheet extends StatefulWidget {
  /// When true, the picker is labeled as "City" (CP-level / commissionerate).
  /// When false, it is labeled as "District" (SP-level / rural). The
  /// underlying data source is the same — only the label differs.
  final bool isCpLevel;
  const _AddLocationSheet({this.isCpLevel = true});

  @override
  State<_AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<_AddLocationSheet> {
  // Senior officers operate at the city (CP) or district (SP) level: only
  // state + area are needed. Reuses the same data source as the
  // registration form's district picker.
  String? _state = 'Maharashtra'; // Default to Maharashtra
  String? _city;

  Map<String, List<String>> _districtsByState = {};
  List<String> _maharashtraDistricts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final map = await IndiaDistrictsRepository.load();
    await MaharashtraPoliceStationsRepository.initialize();
    if (!mounted) return;
    setState(() {
      _districtsByState = map;
      _maharashtraDistricts =
          MaharashtraPoliceStationsRepository.getDistricts();
      _loading = false;
    });
  }

  List<String> _getCities() {
    if (_state == 'Maharashtra') return _maharashtraDistricts;
    return _districtsByState[_state] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add New Location',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child:
                          CircularProgressIndicator(color: AppColors.navyMid),
                    ),
                  )
                else ...[
                  SearchablePickerField(
                    label: 'State',
                    hintText: 'Select State',
                    items: IndiaStates.all,
                    value: _state,
                    onChanged: (v) => setState(() {
                      _state = v;
                      _city = null;
                    }),
                    leadingIcon: Icons.map_rounded,
                  ),
                  SearchablePickerField(
                    label: widget.isCpLevel ? 'City' : 'District',
                    hintText:
                        widget.isCpLevel ? 'Select City' : 'Select District',
                    items: _getCities(),
                    value: _city,
                    onChanged: (v) => setState(() => _city = v),
                    enabled: _state != null,
                    leadingIcon: widget.isCpLevel
                        ? Icons.location_city_rounded
                        : Icons.map_rounded,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _city == null
                          ? null
                          : () => Navigator.pop(context, _city),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navyDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm & Add Location',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Case Bottom Sheet ─────────────────────────────────────────────────────
class _AddCaseBottomSheet extends StatefulWidget {
  final bool isDark;
  const _AddCaseBottomSheet({required this.isDark});

  @override
  State<_AddCaseBottomSheet> createState() => _AddCaseBottomSheetState();
}

class _AddCaseBottomSheetState extends State<_AddCaseBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = Classification.addMenuAll
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_task_rounded,
                      color: AppColors.goldPrimary, size: 24),
                ),
                const SizedBox(width: 16),
                Text('Unified Police Entry Menu',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDark)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.navyDark),
                decoration: InputDecoration(
                  hintText: 'Search entry types...',
                  hintStyle:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.82,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildGridItem(context, filteredItems[i]),
                      childCount: filteredItems.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Classification item) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (item.moduleKey == 'form_1_5') {
          Navigator.push(
              context,
              AppTheme.fadeSlideRoute(
                  page: const FormIVSelectionScreen(
                mode: FormIVSelectionMode.add,
              )));
        } else if (item.moduleKey == 'nc') {
          Navigator.push(
              context,
              AppTheme.fadeSlideRoute(
                page: NcFormScreen(
                  moduleLabel: item.name,
                ),
              ));
        } else if (item.moduleKey == 'missing') {
          Navigator.push(
              context,
              AppTheme.fadeSlideRoute(
                page: MissingFormScreen(
                  moduleLabel: item.name,
                ),
              ));
        } else if (moduleUsesCommonCrimeForm(item.moduleKey)) {
          Navigator.push(
              context,
              AppTheme.fadeSlideRoute(
                  page: CommonFormScreen(
                moduleLabel: item.name,
                moduleKey: item.moduleKey,
              )));
        } else {
          Navigator.push(
              context,
              AppTheme.fadeSlideRoute(
                  page: ModuleFormScreen(
                moduleLabel: item.name,
                moduleKey: item.moduleKey,
              )));
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Center(
                child: _buildGridIcon(
                  item.name,
                  _classIconFromName(item.iconName),
                  AppColors.goldPrimary,
                  28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Search Filter Bottom Sheet ────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final bool isDark;
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;

  const _FilterSheet(
      {required this.isDark, required this.filters, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SearchFilters _local;

  @override
  void initState() {
    super.initState();
    _local = widget.filters.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppColors.goldPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Search Filters',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDark)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _local = SearchFilters()),
                  child: Text('Reset',
                      style: GoogleFonts.poppins(
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Divider(color: AppColors.lightBorder, height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _check(
                        'Case Title / Subject',
                        Icons.title_rounded,
                        _local.byTitle,
                        (v) => setState(
                            () => _local = _local.copyWith(byTitle: v))),
                    _check(
                        'FIR / Case Number',
                        Icons.numbers_rounded,
                        _local.byFirNumber,
                        (v) => setState(
                            () => _local = _local.copyWith(byFirNumber: v))),
                    _check(
                        'Date (Incident Date)',
                        Icons.calendar_today_rounded,
                        _local.byDate,
                        (v) => setState(
                            () => _local = _local.copyWith(byDate: v))),
                    _check(
                        'Assigned Officer',
                        Icons.badge_rounded,
                        _local.byOfficer,
                        (v) => setState(
                            () => _local = _local.copyWith(byOfficer: v))),
                    _check(
                        'Crime Spot',
                        Icons.location_on_outlined,
                        _local.byLocation,
                        (v) => setState(
                            () => _local = _local.copyWith(byLocation: v))),
                    _check(
                        'Complainant Name',
                        Icons.person_add_alt_rounded,
                        _local.byComplainant,
                        (v) => setState(
                            () => _local = _local.copyWith(byComplainant: v))),
                    _check(
                        'Accused Name',
                        Icons.person_off_rounded,
                        _local.byAccused,
                        (v) => setState(
                            () => _local = _local.copyWith(byAccused: v))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_local);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                  child: Text('Apply Filters',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _check(
      String label, IconData icon, bool value, void Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(children: [
          Icon(icon,
              size: 20,
              color: value ? AppColors.goldPrimary : AppColors.lightSubText),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                    color:
                        value ? AppColors.navyDark : AppColors.lightSubText)),
          ),
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.goldPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ]),
      ),
    );
  }
}

// ── Search Results grouped by module ─────────────────────────────────────────
class _SearchModuleGroup extends StatelessWidget {
  final bool isDark;
  final String moduleLabel;
  final String moduleKey;
  final List<SearchResult> results;

  const _SearchModuleGroup({
    required this.isDark,
    required this.moduleLabel,
    required this.moduleKey,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final shown = results.take(5).toList();
    final overflow = results.length - 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              AppTheme.fadeSlideRoute(
                  page: ModuleHubScreen(
                      moduleLabel: moduleLabel, moduleKey: moduleKey))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.navyMid.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.navyMid.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.folder_copy_rounded,
                  size: 15, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Text(moduleLabel.toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.goldPrimary)),
              const Spacer(),
              Text('${results.length} match${results.length == 1 ? '' : 'es'}',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightSubText)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: AppColors.goldPrimary),
            ]),
          ),
        ),
        ...shown.map((r) => _resultCard(context, r)),
        if (overflow > 0)
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                AppTheme.fadeSlideRoute(
                    page: ModuleHubScreen(
                        moduleLabel: moduleLabel, moduleKey: moduleKey))),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text('+ $overflow more in $moduleLabel →',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.goldPrimary)),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _resultCard(BuildContext context, SearchResult r) {
    final record = r.record;
    final sc = _statusColor(record.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record.title,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Text(record.caseNumber,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.infoBlue,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('• ${DateFormat('dd MMM yyyy').format(record.incidentDate)}',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.lightSubText)),
            ]),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: sc.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sc.withValues(alpha: 0.3)),
          ),
          child: Text(record.status,
              style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w700, color: sc)),
        ),
      ]),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return AppColors.warningOrange;
      case 'Active':
        return AppColors.infoBlue;
      case 'Resolved':
        return AppColors.successGreen;
      case 'Closed':
        return const Color(0xFF607D8B);
      default:
        return AppColors.lightSubText;
    }
  }
}

dynamic _classIconFromName(String name) {
  switch (name) {
    case 'search':
      return Icons.search_rounded;
    case 'visibility_off':
      return Icons.visibility_off_rounded;
    case 'delete_forever':
      return Icons.delete_forever_rounded;
    case 'gavel':
      return Icons.gavel_rounded;
    case 'handcuffs':
      return Icons.link_rounded;
    case 'directions_run':
      return Icons.directions_run_rounded;
    case 'child_care':
      return Icons.child_care_rounded;
    case 'child_friendly':
      return Icons.child_friendly_rounded;
    case 'healing':
      return Icons.healing_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'woman':
      return Icons.woman_rounded;
    case 'description':
      return Icons.description_rounded;
    case 'article':
      return Icons.article_rounded;
    case 'badge':
      return Icons.badge_rounded;
    case 'assignment':
      return Icons.assignment_rounded;
    case 'traffic':
      return Icons.traffic_rounded;
    case 'inventory':
      return Icons.inventory_2_rounded;
    case 'two_wheeler':
      return Icons.two_wheeler_rounded;
    case 'calendar_month':
      return Icons.calendar_month_rounded;
    case 'pending_actions':
      return FontAwesomeIcons.solidClock;
    case 'local_hospital':
      return Icons.local_hospital_rounded;
    case 'no_encryption':
      return Icons.no_encryption_rounded;
    case 'terrain':
      return Icons.terrain_rounded;
    case 'report':
      return Icons.report_rounded;
    case 'security':
      return Icons.security_rounded;
    case 'person_search':
      return Icons.person_search_rounded;
    case 'car_crash':
      return Icons.car_crash_rounded;
    case 'balance':
      return Icons.balance_rounded;
    case 'medication':
      return Icons.medication_rounded;
    case 'home_work':
      return Icons.home_work_rounded;
    case 'computer':
      return Icons.computer_rounded;
    case 'policy':
      return Icons.policy_rounded;
    case 'account_balance':
      return Icons.account_balance_rounded;
    case 'admin_panel':
      return Icons.admin_panel_settings_rounded;
    case 'monetization_on':
      return Icons.monetization_on_rounded;
    default:
      return Icons.folder_rounded;
  }
}
