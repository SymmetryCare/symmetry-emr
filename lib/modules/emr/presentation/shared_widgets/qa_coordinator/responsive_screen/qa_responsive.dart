import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/screen_route_name.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';
import 'package:symmetry_emr/app/router/role_page_sync.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_dashboard_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/qa_deskstop_screen.dart';

class ButtonQACoordinatorController extends GetxController {
  var selectedIndex = 0.obs;
  void selectButton(int index) => selectedIndex.value = index;
}

class ResponsiveScreenQA extends StatelessWidget {
  static String routeName = RouteStrings.qaDesktop;
  const ResponsiveScreenQA({super.key, required this.page});

  /// The QA page the URL names (Dashboard, My Tasks or Chat); see EmrRouter.
  final EmrPage page;

  @override
  Widget build(BuildContext context) {
    // The tab highlight follows the URL through RolePageSync; resetting it to
    // Dashboard here would undo that on every URL change.
    Get.put(ButtonQACoordinatorController());
    final QaCoordinatorProvider coordinator =
        context.read<QaCoordinatorProvider>();
    return RolePageSync(
      page: page,
      listenable: coordinator,
      current: () => coordinator.pageIdx,
      jumpTo: coordinator.jumpTo,
      child: LayoutBuilder(
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
      ),
    );
  }
}
