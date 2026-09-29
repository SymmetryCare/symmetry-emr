import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/qa_dashboard_screen.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/app_bar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/bottom_row.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_myTask_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/communication_chat_module.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_dashboard_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/responsive_screen/qa_responsive.dart';

class QaCoordinatorDesktopScreen extends StatelessWidget {
  const QaCoordinatorDesktopScreen({super.key});

  // ✅ NEW — tiered breakpoints for the side spacers
  static const double _wideBreakpoint = 1200;
  static const double _narrowBreakpoint = 1000;

  // ✅ NEW — returns the right spacer widget for the current width:
  // >=1200 → flex:2, 800-1199 → flex:1, <800 → nothing
  Widget _sideSpacer(double screenWidth) {
    if (screenWidth >= _wideBreakpoint) {
      return const Expanded(flex: 2, child: SizedBox());
    } else if (screenWidth >= _narrowBreakpoint) {
      return const Expanded(flex: 1, child: SizedBox());
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<EMRNavigationController>();
    final coordinator = context.watch<QaCoordinatorProvider>();
    final bool anyOverlay =
        nav.isViewingVisit || nav.isViewingMap || nav.isScheduleVisit;

    // ✅ NEW — screen width check
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (coordinator.showChat) {
          context.read<QaCoordinatorProvider>().jumpTo(0);
          return false;
        }
        if (nav.isViewingMap) {
          nav.closeMap();
          return false;
        }
        if (nav.isViewingVisit) {
          nav.closeVisit();
          return false;
        }
        if (nav.isScheduleVisit) {
          nav.closeScheduleVisit();
          return false;
        }
        if (coordinator.pageIdx > 0) {
          context.read<QaCoordinatorProvider>().jumpTo(coordinator.pageIdx - 1);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── APP BAR ──────────────────────────────────────────────
            ApplicationEmrAppBar(
              headingText: anyOverlay ? ' ' : 'QA Coordinator',
              body: [
                if (anyOverlay) ...[
                  const Expanded(
                    child: Center(
                      child: Text(
                        'QA Coordinator',
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff3E3B3B),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 16),
                  // ✅ NEW — tiered spacer: flex:2 (>=1200), flex:1 (800-1199), none (<800)
                  _sideSpacer(screenWidth),
                  Obx(() => Expanded(
                    child: CustomTitleButtonemr(
                      height: AppSize.s30,
                      width: AppSize.s100,
                      text: 'Dashboard',
                      onPressed: () =>
                          context.read<QaCoordinatorProvider>().jumpTo(0),
                      isSelected:
                      coordinator.tabCtrl.selectedIndex.value == 0,
                    ),
                  )),
                  const SizedBox(width: 16),
                  Obx(() => Expanded(
                    child: CustomTitleButtonemr(
                      height: AppSize.s30,
                      width: AppSize.s100,
                      text: 'My Tasks',
                      onPressed: () {
                        context
                            .read<QaDashboardProvider>()
                            .selectButton(0);
                        context
                            .read<QaCoordinatorProvider>()
                            .jumpTo(1);
                      },
                      isSelected:
                      coordinator.tabCtrl.selectedIndex.value == 1,
                    ),
                  )),
                  // ✅ NEW — tiered spacer: flex:2 (>=1200), flex:1 (800-1199), none (<800)
                  _sideSpacer(screenWidth),
                  AppBarIconWithImage(
                    iconImage: "images/sm/contact_sv.svg",
                    onPressed: () =>
                        context.read<QaCoordinatorProvider>().jumpTo(2),
                  ),
                  const SizedBox(width: 16),
                ],
              ],
            ),

            // ── BODY ─────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // PageView — hidden when chat is open
                  Offstage(
                    offstage: anyOverlay || coordinator.showChat,
                    child: PageView(
                      key: const PageStorageKey('qa_coordinator_pageview'),
                      controller: coordinator.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) =>
                          context.read<QaCoordinatorProvider>().jumpTo(i),
                      children: [
                        QaDashboardScreen(
                          onTap: (int subTabIndex) {
                            context
                                .read<QaDashboardProvider>()
                                .selectButton(subTabIndex);
                            context
                                .read<QaCoordinatorProvider>()
                                .jumpTo(1);
                          },
                        ),
                        const QaMytaskScreen(),
                        // Removed QACommunicationChat from PageView
                      ],
                    ),
                  ),

                  // ── Chat: right-to-left slide animation ─────────────
                  AnimatedSlide(
                    offset: coordinator.showChat
                        ? Offset.zero
                        : const Offset(1.0, 0.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      opacity: coordinator.showChat ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 350),
                      child: QACommunicationChat(
                        onTap: (int p1) =>
                            context.read<QaCoordinatorProvider>().jumpTo(0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const BottomBarRow(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class AppBarIcon extends StatelessWidget {
  const AppBarIcon({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: ColorManager.mediumgrey),
      ),
    );
  }
}

class AppBarIconWithImage extends StatelessWidget {
  const AppBarIconWithImage({required this.iconImage, required this.onPressed});
  final String iconImage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        // ✅ SizedBox wrapper removed — back to plain SvgPicture.asset
        child: SvgPicture.asset(iconImage),
      ),
    );
  }
}