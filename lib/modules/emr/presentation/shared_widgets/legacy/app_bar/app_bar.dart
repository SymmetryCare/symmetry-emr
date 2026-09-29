import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/app_bar_mobile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/app_bar_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/app_bar_web.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/responsive_app_bar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/sm_app_bar.dart';

import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/hh_emr_appbar.dart';

class ApplicationAppBar extends StatelessWidget {
   ApplicationAppBar({super.key, required this.headingText, this.paddingLogo, this.paddingLogoRight,
     this.onChnageScreen});
  final String headingText;
  final double? paddingLogo;
  final double? paddingLogoRight;
  VoidCallback? onChnageScreen;


  @override
  Widget build(BuildContext context) {
    return ResponsiveAppBar(
        mobile: const AppBarMobile(),
        web: AppBarWeb(
          onMove: onChnageScreen,
          headingText: headingText,
          paddingLogo: paddingLogo,
          paddingLogoRight: paddingLogoRight,
        ),
        tablet: const AppBarTab());
  }
}

/// Sm App Bar only
class ApplicationSMAppBar extends StatelessWidget {
  const ApplicationSMAppBar({super.key, required this.headingText,required this.body,});
  final String headingText;
  final List<Widget> body;


  @override
  Widget build(BuildContext context) {
    return ResponsiveAppBar(
        mobile: const AppBarMobile(),
        web: SmAppBar(
          headingText: headingText, body: body,

        ),
        tablet: const AppBarTab());
  }
}


///communication appbar  in module
///emr app bar use in em hr emr all module
///emr app bar
class ApplicationEmrAppBar extends StatelessWidget {
  ApplicationEmrAppBar({
    super.key,
    required this.headingText,
    required this.body,
    this.isHrModule = false,
    this.isEmrClinicianModule = false,
    this.hideNameOnSmallScreen = false,
    this.shortHeadingText, // ✅ NEW — shown instead of headingText when
    // hideNameOnSmallScreen is true and screen width < 1200
  });

  final String headingText;
  final List<Widget> body;
  bool? isHrModule;
  bool? isEmrClinicianModule;
  bool? hideNameOnSmallScreen;
  final String? shortHeadingText; // ✅ NEW

  @override
  Widget build(BuildContext context) {
    return ResponsiveAppBar(
        mobile: const AppBarMobile(),
        web: EmrAppBar(
          isHrModule: isHrModule!,
          isEmrClinicianModule: isEmrClinicianModule!,
          hideNameOnSmallScreen: hideNameOnSmallScreen!,
          shortHeadingText: shortHeadingText, // ✅ NEW
          headingText: headingText,
          body: body,
        ),
        tablet: const AppBarTab());
  }
}