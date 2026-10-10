import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/router/emr_router.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/dashboard_notification_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_bar/app_bar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/bottom_row.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/qa_deskstop_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/communication_chat_module.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/responsive_screen/responsive_screen_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/emr_calender_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/visit_details_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/emr_dashboard_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/emr_patient_details_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_protocol_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_alerts_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/plan_of_care.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_frequencies/poc_frequency_detail_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/emr_patients_home_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/timesheet_tab/timesheet_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_left_widget_components/full_map_screen_hhemr.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/schedule_visit_details.dart'
    hide VisitDetailsScreen;
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/emr_notification_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Self-contained notification badge
// ─────────────────────────────────────────────────────────────────────────────
class _NotifBadge extends StatefulWidget {
  final VoidCallback onTap;
  const _NotifBadge({super.key, required this.onTap});

  @override
  State<_NotifBadge> createState() => _NotifBadgeState();
}

class _NotifBadgeState extends State<_NotifBadge> {
  bool _hasUnread = false;
  int _lastSeenId = 0;
  bool _firstCheck = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    try {
      final data = await getNotificationData(context);
      if (!mounted || data.isEmpty) return;
      final newestId = data.first.notificationId;
      setState(() {
        if (_firstCheck) {
          _lastSeenId = newestId;
          _firstCheck = false;
        } else {
          _hasUnread = newestId > _lastSeenId;
        }
      });
    } catch (_) {}
  }

  Future<void> markSeen() async {
    try {
      final data = await getNotificationData(context);
      if (!mounted) return;
      setState(() {
        if (data.isNotEmpty) _lastSeenId = data.first.notificationId;
        _hasUnread = false;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_none_rounded, color: ColorManager.redDark),
        if (_hasUnread)
          Positioned(
            top: -2,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: ColorManager.redDark,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab bar buttons — responsive: full row ≥ 1200, hamburger < 1200
// ─────────────────────────────────────────────────────────────────────────────
class _TabButtons extends StatefulWidget {
  final ButtonSelectionEMRController tabCtrl;
  final void Function(int) jumpTo;
  final GlobalKey<_NotifBadgeState> badgeKey;
  final VoidCallback onBellTap;
  final double screenWidth;
  // Hamburger callbacks — managed in parent (EMRDesktopScreen)
  final GlobalKey menuButtonKey;
  final VoidCallback onMenuTap;

  static const List<String> _tabs = [
    'Dashboard',
    'Calendar',
    'Patients',
    'Timesheet',
  ];

  const _TabButtons({
    required this.tabCtrl,
    required this.jumpTo,
    required this.badgeKey,
    required this.onBellTap,
    required this.screenWidth,
    required this.menuButtonKey,
    required this.onMenuTap,
  });

  @override
  State<_TabButtons> createState() => _TabButtonsState();
}

class _TabButtonsState extends State<_TabButtons> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = widget.tabCtrl.selectedIndex.value;

      if (widget.screenWidth >= 1200) {
        // ── Full tab row ────────────────────────────────────────────
        return Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: CustomTitleButtonemr(
                height: AppSize.s30,
                width: AppSize.s100,
                text: 'Dashboard',
                onPressed: () => widget.jumpTo(0),
                isSelected: selected == 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTitleButtonemr(
                height: AppSize.s30,
                width: AppSize.s100,
                text: 'Calendar',
                onPressed: () => widget.jumpTo(1),
                isSelected: selected == 1,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTitleButtonemr(
                height: AppSize.s30,
                width: AppSize.s100,
                text: 'Patients',
                onPressed: () => widget.jumpTo(2),
                isSelected: selected == 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTitleButtonemr(
                height: AppSize.s30,
                width: AppSize.s100,
                text: 'Timesheet',
                onPressed: () => widget.jumpTo(3),
                isSelected: selected == 3,
              ),
            ),
            const SizedBox(width: 16),
            AppBarIconWithImage(
              iconImage: "images/sm/contact_sv.svg",
              onPressed: () => widget.jumpTo(4),
            ),
            const SizedBox(width: 16),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: widget.onBellTap,
              child: _NotifBadge(key: widget.badgeKey, onTap: widget.onBellTap),
            ),
          ],
        );
      } else {
        // ── Hamburger + active tab name ─────────────────────────────
        // index 4 = chat (contact icon), treat as no label
        final tabLabel = selected < _TabButtons._tabs.length ? _TabButtons._tabs[selected] : 'Chat';
        return Row(
          children: [
            const SizedBox(width: 8),
            GestureDetector(
              key: widget.menuButtonKey,
              onTap: widget.onMenuTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p10,
                  vertical: AppPadding.p6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(AppSize.s6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu, size: AppSize.s18, color: ColorManager.darkgrey),
                    const SizedBox(width: 6),
                    Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.darkgrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '— $tabLabel',
                style: TextStyle(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.blueprime,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: widget.onBellTap,
              child: _NotifBadge(key: widget.badgeKey, onTap: widget.onBellTap),
            ),
            const SizedBox(width: 8),
          ],
        );
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PageView body
// ─────────────────────────────────────────────────────────────────────────────
class _PageBody extends StatelessWidget {
  final PageController pageController;
  final ButtonSelectionEMRController tabCtrl;

  const _PageBody({
    required this.pageController,
    required this.tabCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (i) {
        tabCtrl.selectButton(i);
      },
      children: const [
        _KeepAlive(child: EMRDashboardScreen()),
        _KeepAlive(child: EMRCalendarScreen()),
        _KeepAlive(child: EMRPatientsHomeScreen()),
        _KeepAlive(child: TimesheetScreen()),
      ],
    );
  }
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay state value object
// ─────────────────────────────────────────────────────────────────────────────
class _OverlayState {
  final bool isViewingVisit;
  final bool isViewingMap;
  final bool isScheduleVisit;
  final bool isViewingPatientDetail;
  final bool isViewingProtocol;
  final bool isViewingAlerts;
  final bool isViewingPlanOfCare;
  final bool isViewingFrequencyDetail;

  const _OverlayState({
    required this.isViewingVisit,
    required this.isViewingMap,
    required this.isScheduleVisit,
    required this.isViewingPatientDetail,
    required this.isViewingProtocol,
    required this.isViewingAlerts,
    required this.isViewingPlanOfCare,
    required this.isViewingFrequencyDetail,
  });

  bool get any =>
      isViewingVisit ||
          isViewingMap ||
          isScheduleVisit ||
          isViewingPatientDetail ||
          isViewingProtocol ||
          isViewingAlerts ||
          isViewingPlanOfCare ||
          isViewingFrequencyDetail;

  @override
  bool operator ==(Object other) =>
      other is _OverlayState &&
          isViewingVisit == other.isViewingVisit &&
          isViewingMap == other.isViewingMap &&
          isScheduleVisit == other.isScheduleVisit &&
          isViewingPatientDetail == other.isViewingPatientDetail &&
          isViewingProtocol == other.isViewingProtocol &&
          isViewingAlerts == other.isViewingAlerts &&
          isViewingPlanOfCare == other.isViewingPlanOfCare &&
          isViewingFrequencyDetail == other.isViewingFrequencyDetail;

  @override
  int get hashCode => Object.hash(
    isViewingVisit,
    isViewingMap,
    isScheduleVisit,
    isViewingPatientDetail,
    isViewingProtocol,
    isViewingAlerts,
    isViewingPlanOfCare,
    isViewingFrequencyDetail,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main desktop screen
// ─────────────────────────────────────────────────────────────────────────────
/// The clinician desktop. Which page shows — and which patient and visit
/// screens are open over it — is the URL's call ([location], from EmrRouter):
/// the tabs change the URL and this follows it, so refresh, Back/Forward and
/// a copied link land on the right page, and Back closes a patient screen
/// before it leaves the page, as it always did.
class EMRDesktopScreen extends StatefulWidget {
  final double screenWidth;

  /// The page and open patient screens the URL names.
  final EmrLocation location;

  const EMRDesktopScreen({
    super.key,
    required this.screenWidth,
    required this.location,
  });

  @override
  State<EMRDesktopScreen> createState() => _EMRDesktopScreenState();
}

class _EMRDesktopScreenState extends State<EMRDesktopScreen> {
  late final PageController _pageController;
  late final EMRNavigationController _nav;

  /// History entries this screen added for patient screens it opened, so
  /// closing one in the app can step back over its entry instead of leaving
  /// a dead Back step behind.
  int _overlayEntries = 0;
  final ButtonSelectionEMRController _tabCtrl =
  Get.put(ButtonSelectionEMRController());
  final GlobalKey<_NotifBadgeState> _badgeKey = GlobalKey<_NotifBadgeState>();

  // Hamburger menu overlay
  OverlayEntry? _menuOverlay;
  final GlobalKey _menuButtonKey = GlobalKey();

  static const List<String> _tabLabels = [
    'Dashboard',
    'Calendar',
    'Patients',
    'Timesheet',
  ];

  final ValueNotifier<bool> _showChat         = ValueNotifier(false);
  final ValueNotifier<bool> _showNotification = ValueNotifier(false);
  final ValueNotifier<int>  _notifPanelKey    = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    // Start on the page the URL names. Chat is a panel over the pages, which
    // then start on the Dashboard under it.
    final EmrPage page = widget.location.page;
    _pageController = PageController(
      initialPage: page == EmrPage.chat ? 0 : page.slot,
    );
    _tabCtrl.selectButton(page.slot);
    _showChat.value = page == EmrPage.chat;
    _nav = context.read<EMRNavigationController>();
    _nav.addListener(_onOverlaysChanged);
    // Clears overlay/detail state only — the tab index is not touched here.
    // A refresh lands here with the URL still naming the patient screens it
    // was on; the patient is gone, so _onOverlaysChanged takes them off it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nav.reset();
    });
  }

  @override
  void didUpdateWidget(covariant EMRDesktopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location == oldWidget.location) return;
    final EmrPage from = oldWidget.location.page;
    // After the frame: it moves a PageController and notifies providers.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLocation(from));
  }

  /// The patient and visit screens open now, bottom to top.
  List<EmrOverlay> _openOverlays() => <EmrOverlay>[
        if (_b(_nav.isScheduleVisit)) EmrOverlay.scheduledVisit,
        if (_b(_nav.isViewingVisit)) EmrOverlay.visit,
        if (_b(_nav.isViewingMap)) EmrOverlay.map,
        if (_b(_nav.isViewingPatientDetail)) EmrOverlay.patient,
        if (_b(_nav.isViewingPlanOfCare)) EmrOverlay.planOfCare,
        if (_b(_nav.isViewingFrequencyDetail)) EmrOverlay.frequency,
        if (_b(_nav.isViewingAlerts)) EmrOverlay.alerts,
        if (_b(_nav.isViewingProtocol)) EmrOverlay.protocol,
      ];

  void _close(EmrOverlay overlay) {
    switch (overlay) {
      case EmrOverlay.scheduledVisit:
        _nav.closeScheduleVisit();
      case EmrOverlay.visit:
        _nav.closeVisit();
      case EmrOverlay.map:
        _nav.closeMap();
      case EmrOverlay.patient:
        _nav.closePatientDetail();
      case EmrOverlay.planOfCare:
        _nav.closePlanOfCare();
      case EmrOverlay.frequency:
        _nav.closeFrequencyDetail();
      case EmrOverlay.alerts:
        _nav.closeAlerts();
      case EmrOverlay.protocol:
        _nav.closeProtocol();
    }
  }

  static bool _startsWith(List<EmrOverlay> list, List<EmrOverlay> prefix) {
    if (prefix.length > list.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (list[i] != prefix[i]) return false;
    }
    return true;
  }

  /// A patient or visit screen opened or closed in the app: put it in the
  /// URL. Opening one is a Back step, so Back closes it; closing one with
  /// its own back button steps back over that entry.
  void _onOverlaysChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.location.page == EmrPage.chat) return;
      final List<EmrOverlay> open = _openOverlays();
      final List<EmrOverlay> named = widget.location.overlays;
      final EmrLocation now = widget.location.withOverlays(open);
      if (now == widget.location) return;
      if (open.length > named.length && _startsWith(open, named)) {
        _overlayEntries++;
        EmrRouter.open(context, now);
      } else if (open.length + 1 == named.length &&
          _startsWith(named, open) &&
          _overlayEntries > 0) {
        _overlayEntries--;
        html.window.history.back();
      } else {
        EmrRouter.replace(context, now);
      }
    });
  }

  /// Show what the URL now names — after a tab tap, or browser Back/Forward.
  void _showLocation(EmrPage from) {
    if (!mounted) return;
    final EmrLocation at = widget.location;
    final List<EmrOverlay> open = _openOverlays();

    if (at.page != from) {
      // As every tab change always has.
      context.read<FilterDrawerProvider>().clearFilters();
      _showNotification.value = false;
      _tabCtrl.selectButton(at.page.slot);
      if (at.page == EmrPage.chat) {
        _showChat.value = true;
      } else {
        _showChat.value = false;
        if (_pageController.hasClients) _pageController.jumpToPage(at.page.slot);
      }
      if (open.isNotEmpty) {
        // A page change under open patient screens: they belonged to the
        // page being left.
        _overlayEntries = 0;
        _nav.reset();
      }
      return;
    }

    if (at.overlays.length < open.length && _startsWith(open, at.overlays)) {
      // Back: close the screens the URL no longer names, top first.
      if (_overlayEntries > 0) _overlayEntries--;
      for (final EmrOverlay o in open.sublist(at.overlays.length).reversed) {
        _close(o);
      }
    } else if (!_startsWith(open, at.overlays) ||
        open.length != at.overlays.length) {
      // Forward to a screen that was closed, or a refresh on one: the patient
      // or visit it was opened with is gone. Show the URL of what is open.
      EmrRouter.replace(context, at.withOverlays(open));
    }
  }

  @override
  void dispose() {
    _nav.removeListener(_onOverlaysChanged);
    _closeMenu();
    _pageController.dispose();
    _showChat.dispose();
    _showNotification.dispose();
    _notifPanelKey.dispose();
    super.dispose();
  }

  /// A tab (or Chat) was picked: go to its URL, a Back step like any
  /// website. The page changes in [_showLocation]. Picking the page already
  /// showing only clears the filters, as it always did.
  void _jumpTo(int index) {
    final EmrPage page = EmrPage.of(EmrDesktop.clinician, index);
    if (page == widget.location.page) {
      context.read<FilterDrawerProvider>().clearFilters();
      return;
    }
    EmrRouter.open(context, EmrLocation(page));
  }

  void _toggleNotification() {
    final opening = !_showNotification.value;
    if (opening) {
      _showChat.value = false;
      _notifPanelKey.value++;
    }
    _showNotification.value = opening;
    if (opening) _badgeKey.currentState?.markSeen();
  }

  // ── Hamburger menu ──────────────────────────────────────────────────────
  void _openMenu() {
    if (_menuOverlay != null) {
      _closeMenu();
      return;
    }

    final renderBox =
    _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final selected = _tabCtrl.selectedIndex.value;

    _menuOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSize.s8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Regular tabs (0–3)
                    ...List.generate(_tabLabels.length, (i) {
                      final isSelected = selected == i;
                      return InkWell(
                        onTap: () {
                          _jumpTo(i);
                          _closeMenu();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p16,
                            vertical: AppPadding.p10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorManager.blueprime.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: i == 0
                                ? const BorderRadius.vertical(
                                top: Radius.circular(AppSize.s8))
                                : BorderRadius.zero,
                          ),
                          child: Text(
                            _tabLabels[i],
                            style: TextStyle(
                              fontSize: FontSize.s13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? ColorManager.blueprime
                                  : ColorManager.darkgrey,
                            ),
                          ),
                        ),
                      );
                    }),
                    // Chat item (index 4)
                    InkWell(
                      onTap: () {
                        _jumpTo(4);
                        _closeMenu();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p16,
                          vertical: AppPadding.p10,
                        ),
                        decoration: BoxDecoration(
                          color: selected == 4
                              ? ColorManager.blueprime.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(AppSize.s8),
                          ),
                        ),
                        child: Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: FontSize.s13,
                            fontWeight: selected == 4
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected == 4
                                ? ColorManager.blueprime
                                : ColorManager.darkgrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _closeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  static bool _b(bool? v) => v ?? false;

  @override
  Widget build(BuildContext context) {
    return Selector<EMRNavigationController, _OverlayState>(
      selector: (_, nav) => _OverlayState(
        isViewingVisit:           _b(nav.isViewingVisit),
        isViewingMap:             _b(nav.isViewingMap),
        isScheduleVisit:          _b(nav.isScheduleVisit),
        isViewingPatientDetail:   _b(nav.isViewingPatientDetail),
        isViewingProtocol:        _b(nav.isViewingProtocol),
        isViewingAlerts:          _b(nav.isViewingAlerts),
        isViewingPlanOfCare:      _b(nav.isViewingPlanOfCare),
        isViewingFrequencyDetail: _b(nav.isViewingFrequencyDetail),
      ),
      builder: (context, overlay, _) {
        final anyOverlay = overlay.any;
        final nav = context.read<EMRNavigationController>();

        // Browser Back is a URL change, which _showLocation follows: it closes
        // the top patient screen first, then leaves the page.
        return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // ── APP BAR ─────────────────────────────────────────────
                ApplicationEmrAppBar(
                  isEmrClinicianModule: true,
                  headingText: anyOverlay ? ' ' : 'EMR - Clinical',
                  body: [
                    if (anyOverlay)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'EMR - clinician',
                            style: TextStyle(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff3E3B3B),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: _TabButtons(
                          tabCtrl: _tabCtrl,
                          jumpTo: _jumpTo,
                          badgeKey: _badgeKey,
                          onBellTap: _toggleNotification,
                          screenWidth: widget.screenWidth,
                          menuButtonKey: _menuButtonKey,
                          onMenuTap: _openMenu,
                        ),
                      ),
                  ],
                ),

                // ── BODY ────────────────────────────────────────────────
                Expanded(
                  child: Stack(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _showChat,
                        builder: (_, chatVisible, child) => Offstage(
                          offstage: anyOverlay || chatVisible,
                          child: child,
                        ),
                        child: _PageBody(
                          pageController: _pageController,
                          tabCtrl: _tabCtrl,
                        ),
                      ),

                      // ── Chat ───────────────────────────────────────
                      ValueListenableBuilder<bool>(
                        valueListenable: _showChat,
                        builder: (_, visible, child) => AnimatedSlide(
                          offset: visible
                              ? Offset.zero
                              : const Offset(1.0, 0.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: AnimatedOpacity(
                            opacity: visible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: child,
                          ),
                        ),
                        child: QACommunicationChat(onTap: (_) => _jumpTo(0)),
                      ),

                      // ── Notification panel ─────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.4,
                          heightFactor: 1.0,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _showNotification,
                            builder: (_, visible, __) =>
                                ValueListenableBuilder<int>(
                                  valueListenable: _notifPanelKey,
                                  builder: (_, panelKey, __) => AnimatedSlide(
                                    offset: visible
                                        ? Offset.zero
                                        : const Offset(1.0, 0.0),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: AnimatedOpacity(
                                      opacity: visible ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: KeyedSubtree(
                                        key: ValueKey(panelKey),
                                        child: EMRNotificationPanel(
                                          onClose: () =>
                                          _showNotification.value = false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),

                      // ── Overlays ───────────────────────────────────
                      ///calender visit
                      if (overlay.isViewingVisit)
                        VisitDetailsScreen(visitId: nav.visitId),

                      ///dashbord today visit
                      if (overlay.isScheduleVisit)
                        ScheduleVisitDetails(visitId: nav.visitId),
                      if (overlay.isViewingMap)
                        const TodaysVisitsMapScreen(),
                      if (overlay.isViewingPatientDetail)
                        const EMRPatientDetailsScreen(),
                      if (overlay.isViewingProtocol)
                        PatientsProtocolScreen(
                            ptId: nav.selectedPatient!.patientId),
                      if (overlay.isViewingAlerts)
                        PatientsAlertsScreen(
                            ptId: nav.selectedPatient!.patientId),
                      if (overlay.isViewingPlanOfCare)
                        PlanOfCareScreen(
                            ptId: nav.selectedPatient!.patientId),
                      if (overlay.isViewingFrequencyDetail)
                        const FrequencyDetailScreen(),
                    ],
                  ),
                ),

                const BottomBarRow(),
              ],
            ),
        );
      },
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