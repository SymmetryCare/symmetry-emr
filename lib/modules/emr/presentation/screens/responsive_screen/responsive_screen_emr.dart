import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:symmetry_emr/app/resources/screen_route_name.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/emr_desktop_screen.dart';

class ButtonSelectionEMRController extends GetxController {
  var selectedIndex = 0.obs;
  void selectButton(int index) => selectedIndex.value = index;
}

class ResponsiveScreenEMR extends StatelessWidget {
  static String routeName = RouteStrings.emrDesktop;
  const ResponsiveScreenEMR({super.key, required this.location});

  /// The page and open patient screens the URL names; see EmrRouter.
  final EmrLocation location;

  @override
  Widget build(BuildContext context) {
    // The tab comes from the URL, set by EMRDesktopScreen, not forced to 0.
    // Browser Back is a URL change too, which EMRDesktopScreen follows —
    // nothing here intercepts a pop.
    Get.put(ButtonSelectionEMRController());
    return _buildScreen();
  }

  Widget _buildScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 855) {
          return Padding(
            padding: constraints.maxWidth > 1920
                ? EdgeInsets.symmetric(
                horizontal: constraints.maxWidth / 8)
                : EdgeInsets.zero,
            child: EMRDesktopScreen(
              screenWidth: constraints.maxWidth, // ← pass width
              location: location,
            ),
          );
        }
        return Material(
          color: Colors.white,
          child: Center(
            child: SvgPicture.asset(
              'images/tablet.svg',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}