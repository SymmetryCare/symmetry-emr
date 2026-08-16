import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../app/resources/screen_route_name.dart';
import '../emr_tab/emr_dashbord/emr_desktop_screen.dart';

class ButtonSelectionEMRController extends GetxController {
  var selectedIndex = 0.obs;
  void selectButton(int index) => selectedIndex.value = index;
}

class ResponsiveScreenEMR extends StatelessWidget {
  static String routeName = RouteStrings.emrDesktop;
  const ResponsiveScreenEMR({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ButtonSelectionEMRController()).selectButton(0);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
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