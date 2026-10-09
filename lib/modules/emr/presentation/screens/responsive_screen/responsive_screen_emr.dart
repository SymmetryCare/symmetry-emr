import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:symmetry_emr/app/resources/screen_route_name.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/emr_desktop_screen.dart';

class ButtonSelectionEMRController extends GetxController {
  var selectedIndex = 0.obs;
  void selectButton(int index) => selectedIndex.value = index;
}

class ResponsiveScreenEMR extends StatelessWidget {
  static String routeName = RouteStrings.emrDesktop;
  const ResponsiveScreenEMR({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial tab is restored by EMRDesktopScreen (TabMemory), not forced to 0.
    Get.put(ButtonSelectionEMRController());
    // Root screen of this app: on web a pop arrives from the browser — Back,
    // or Chrome's Enter in the address bar on a `#` URL — and an unhandled pop
    // on the root route exits the app to the tab's previous page.
    return PopScope(
      canPop: false,
      child: _buildScreen(),
    );
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