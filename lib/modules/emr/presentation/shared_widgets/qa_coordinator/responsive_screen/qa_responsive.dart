import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


import 'package:symmetry_emr/app/resources/screen_route_name.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/qa_deskstop_screen.dart';


class ButtonQACoordinatorController extends GetxController {
  var selectedIndex = 0.obs;
  void selectButton(int index) => selectedIndex.value = index;
}

class ResponsiveScreenQA extends StatelessWidget {
  static  String routeName = RouteStrings.qaDesktop;
  const ResponsiveScreenQA({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ButtonQACoordinatorController()).selectButton(0);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Padding(
            padding: MediaQuery.of(context).size.width > 1920
                ? EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 8)
                : EdgeInsets.zero,
            child: const QaCoordinatorDesktopScreen(),
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








