import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/qa_dashboard_screen.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/qa_coordinator_resource/const_string_qa.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/app_bar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/bottom_row.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/communication_chat_module.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_myTask_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_provider/coder_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_dashboard/coder_dashboard.dart';

class CoderDesktopScreen extends StatelessWidget {
  const CoderDesktopScreen({super.key});

  // ✅ NEW — tiered breakpoints for the side spacers (same as QA Coordinator)
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
    final coordinator = context.watch<CoderProvider>();
    final bool anyOverlay =
        nav.isViewingVisit || nav.isViewingMap || nav.isScheduleVisit;

    // ✅ NEW — screen width check
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (coordinator.showChat) {
          context.read<CoderProvider>().jumpTo(0);
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
        if (coordinator.pageIdx > 0 && coordinator.pageIdx < 2) {
          context.read<CoderProvider>().jumpTo(coordinator.pageIdx - 1);
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
              headingText: anyOverlay ? ' ' : '         Coder',
              body: [
                if (anyOverlay) ...[
                  Expanded(
                    child: Center(
                      child: Text(
                        ConstStringQa.coder,
                        style: const TextStyle(
                          fontSize: FontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff3E3B3B),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: AppSize.s16),
                  // ✅ NEW — tiered spacer replaces plain Spacer()
                  _sideSpacer(screenWidth),

                  Expanded(
                    child: CustomTitleButtonemr(
                      height: AppSize.s30,
                      width: AppSize.s100,
                      text: ConstStringQa.dashboard,
                      onPressed: () => context.read<CoderProvider>().jumpTo(0),
                      // ✅ only highlight when pageIdx is exactly 0
                      isSelected: coordinator.pageIdx == 0,
                    ),
                  ),
                  const SizedBox(width: AppSize.s16),
                  Expanded(
                    child: CustomTitleButtonemr(
                      height: AppSize.s30,
                      width: AppSize.s100,
                      text: ConstStringQa.myTasks,
                      onPressed: () {
                        context.read<CoderDashboardProvider>().selectButton(0);
                        context.read<CoderProvider>().jumpTo(1);
                      },
                      // ✅ only highlight when pageIdx is exactly 1
                      isSelected: coordinator.pageIdx == 1,
                    ),
                  ),
                  // ✅ NEW — tiered spacer replaces plain Spacer()
                  _sideSpacer(screenWidth),
                  AppBarIconWithImage(
                    iconImage: "images/sm/contact_sv.svg",
                    onPressed: () => context.read<CoderProvider>().jumpTo(2),
                  ),
                  const SizedBox(width: AppSize.s16),
                ],
              ],
            ),

            // ── BODY ─────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Offstage(
                    offstage: anyOverlay || coordinator.showChat,
                    child: KeyedSubtree(
                      key: ValueKey(coordinator.pageController),
                      child: PageView(
                        controller: coordinator.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          CoderDashboardScreen(
                            onTap: (int subTabIndex) {
                              context
                                  .read<CoderDashboardProvider>()
                                  .selectButton(subTabIndex);
                              context.read<CoderProvider>().jumpTo(1);
                            },
                          ),
                          const CoderMytaskScreen(),
                        ],
                      ),
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
                            context.read<CoderProvider>().jumpTo(0),
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
        child: SvgPicture.asset(iconImage),
      ),
    );
  }
}