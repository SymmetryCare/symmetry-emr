import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/services/token/token_manager.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/authorization_status_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/late_documentation_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/need_correction_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/new_visit_request_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/pending_documentation_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/recreate_reassessment_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/constants/dropdown_const.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/assitant_review_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/discharge_visit.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/mised_visit_discharge.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/recert_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/reschedule_visit_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/miss_visit_popup.dart';
import 'package:provider/provider.dart';

import '../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../../app/services/api/managers/clinical_manager_manager/my_task_order_tab_manager.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/new_visit_request_manager.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/emr_patient_manager/patient_tab_manager.dart';
import '../../../../../../data/api_data/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import '../../../../../../oasis_form_builder/widgets/popup/pending_forms_popup.dart';
import '../../../../em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../../em_module/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';

// ── Poll interval (adjust as needed) ─────────────────────────────────────────
const Duration _kPollInterval = Duration(seconds: 3);

class DashboardTodaysVisitMidleColumnWidgets extends StatefulWidget {
  const DashboardTodaysVisitMidleColumnWidgets({super.key});

  @override
  State<DashboardTodaysVisitMidleColumnWidgets> createState() =>
      _DashboardTodaysVisitMidleColumnWidgetsState();
}

class _DashboardTodaysVisitMidleColumnWidgetsState
    extends State<DashboardTodaysVisitMidleColumnWidgets>
    with WidgetsBindingObserver {
  // ── Filter state ───────────────────────────────────────────────────────────
  String _selectedFilter = 'All';

  // ── Visits data state ──────────────────────────────────────────────────────
  List<EmrPatientVisitModel> _allVisits = [];
  bool _isLoading = true;
  bool _isRefreshing = false; // silent background refresh flag
  String? _errorMessage;

  // ── Stat counts ────────────────────────────────────────────────────────────
  int _newVisitRequestCount = 0;
  int _needCorrectionCount = 0;

  // ── Polling timer + lifecycle guard ────────────────────────────────────────
  Timer? _pollTimer;
  bool _disposed = false;

  // ── Computed filtered list ─────────────────────────────────────────────────
  List<EmrPatientVisitModel> get _filteredVisits => _applyFilter(_allVisits);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial full load
    _loadAll(showFullLoader: true);
    // Start polling
    _startPolling();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── Lifecycle: pause polling when app is not visible/resumed ────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _loadAll(); // silent refresh on return
    } else {
      _stopPolling();
    }
  }

  // ── Polling control ─────────────────────────────────────────────────────────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) {
      if (mounted && !_disposed) _loadAll();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Safe setState (blocks renders after teardown) ───────────────────────────
  void _safeSetState(VoidCallback fn) {
    if (!mounted || _disposed) return;
    setState(fn);
  }

  // ── Master load function ───────────────────────────────────────────────────
  /// [showFullLoader] true  → shows the spinner (first load / manual refresh)
  /// [showFullLoader] false → silent background update
  Future<void> _loadAll({bool showFullLoader = false}) async {
    if (!mounted || _disposed) return;

    if (showFullLoader) {
      _safeSetState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      _safeSetState(() => _isRefreshing = true);
    }

    await Future.wait([
      _loadVisits(),
      _loadStatCounts(),
    ]);

    _safeSetState(() {
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  // ── Load today's visits (all from API, filter client-side) ─────────────────
  Future<void> _loadVisits() async {
    try {
      // Always fetch 'all' from API; filtering is applied client-side so
      // switching the dropdown never triggers a new network call.
      final result = await getEmrPatientVisitList(
        context: context,
        searchFilter: 'all',
      );
      _safeSetState(() {
        _allVisits = result.visits;
        _errorMessage = null;
      });
    } catch (e) {
      _safeSetState(() =>
      _errorMessage = 'Failed to load visits. Tap refresh to retry.');
      debugPrint('Error loading visits: $e');
    }
  }

  // ── Load stat-card counts ──────────────────────────────────────────────────
  Future<void> _loadStatCounts() async {
    try {
      final clinicianId = await TokenManager.getEmployeeId();
      final visitData = await getRequestVisitList(
        context,
        clinicianId: clinicianId,
        visitStatus: 'pending',
        patientName: 'all',
      );
      final taskData = await getMyTasksList(
        context,
        tab: 'needs_correction',
        page: 1,
        limit: 99999,
      );
      _safeSetState(() {
        _newVisitRequestCount = visitData?.visits.length ?? 0;
        _needCorrectionCount = taskData.data?.length ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading stat counts: $e');
    }
  }

  // ── Manual refresh (shows spinner) ────────────────────────────────────────
  void _manualRefresh() => _loadAll(showFullLoader: true);

  // ── Filter change (instant — no network call) ─────────────────────────────
  void _onFilterChanged(String value) {
    _safeSetState(() => _selectedFilter = value);
  }

  // ── Client-side filter ─────────────────────────────────────────────────────
  List<EmrPatientVisitModel> _applyFilter(List<EmrPatientVisitModel> all) {
    switch (_selectedFilter) {
      case 'Scheduled':
        return all
            .where((v) =>
        !v.isVisitCompleted && !v.isVisitMissed && !v.isRescheduled)
            .toList();
      case 'Missed':
        return all.where((v) => v.isVisitMissed).toList();
      case 'Rescheduled':
        return all.where((v) => v.isRescheduled).toList();
      case 'All':
      default:
        return all;
    }
  }

  // ── Safe initials helper (fixes RangeError on empty/multi-space names) ──────
  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+')) // collapse any run of whitespace
        .where((p) => p.isNotEmpty) // drop empty segments
        .toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Stat cards ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _statCard(
                        'New Visit Request',
                        '$_newVisitRequestCount',
                        Colors.blue,
                        'images/emr_clinician/account_plus.png',
                            () {
                          showDialog(
                            context: context,
                            builder: (_) => const NewVisitRequestPopup(),
                          ).then((_) => _loadAll());
                        },
                      ),
                    ),
                    Expanded(
                      child: _statCard(
                        'Recerts, Reassessments,\nSupervisory Visits',
                        '26',
                        ColorManager.purpleBlack,
                        'images/emr_clinician/text_box.png',
                            () => showDialog(
                          context: context,
                          builder: (_) => const RecertReassessmentPopup(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _statCard(
                        'Authorization\nStatus',
                        '16',
                        ColorManager.skini,
                        'images/emr_clinician/check_all.png',
                            () => showDialog(
                          context: context,
                          builder: (_) => const AuthorizationStatusPopup(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _statCard(
                        'Late Documentation',
                        '16',
                        Colors.red,
                        'images/emr_clinician/clock_alert.png',
                            () => showDialog(
                          context: context,
                          builder: (_) => LateDocumentationPopup(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _statCard(
                        'Needs Corrections',
                        '$_needCorrectionCount',
                        ColorManager.purpleBlack,
                        'images/emr_clinician/circle_edit.png',
                            () => showDialog(
                          context: context,
                          builder: (_) => const NeedCorrectionPopup(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _statCard(
                        'Pending Documentation',
                        '26',
                        ColorManager.pink,
                        'images/emr_clinician/clock.png',
                            () =>
                                // showDialog(context: context,
                                //     builder: (_)=> ActionNeededPopup(
                                //       onCancel: () {  },
                                //       onDelete: () {  },
                                //       title: 'Action needed',
                                //       text: "Do you want tp fill out the Discipline Follow-up Visit Note Form (PT/OT/ST) for this visit?",))
                                showDialog(
                          context: context,
                          builder: (_) => const PendingDocumentationPopup(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Visits list ────────────────────────────────────────────────────
        Expanded(child: _buildVisitsList()),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  VISITS LIST
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildVisitsList() {
    return Column(
      children: [
        // ── Header row ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title + silent-refresh indicator
              Row(
                children: [
                  const Text(
                    "Today's Visits",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  // if (_isRefreshing) ...[
                  //   const SizedBox(width: 8),
                  //   const SizedBox(
                  //     width: 12,
                  //     height: 12,
                  //     child: CircularProgressIndicator(strokeWidth: 1.5),
                  //   ),
                  // ],
                ],
              ),

              // Alert legend
              Row(
                children: [
                  _alertLegend(Colors.red, 'Patient Alert'),
                  const SizedBox(width: 10),
                  _alertLegend(Colors.orange, 'Visit Alert'),
                  const SizedBox(width: 10),
                  _alertLegend(Colors.purple, 'Vita/Med Alert'),
                ],
              ),

              // Refresh + filter
              Row(
                children: [
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: _manualRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    color: Colors.grey.shade500,
                    tooltip: 'Refresh',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  CustomDropdown(
                    items: const ['All', 'Scheduled', 'Missed', 'Rescheduled'],
                    initialValue: _selectedFilter,
                    // Filter is instant — no network round-trip
                    onChanged: (v) => _onFilterChanged(v ?? 'All'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Body ─────────────────────────────────────────────────────────
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    // Full-screen loader on first load
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error — show only when list is empty (so stale data stays visible)
    if (_errorMessage != null && _allVisits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _manualRefresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final visits = _filteredVisits;

    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 32, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'All'
                  ? 'No visits found!'
                  : 'No $_selectedFilter visits found',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 12),
        itemCount: visits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildVisitCard(visits[i]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  VISIT CARD
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildVisitCard(EmrPatientVisitModel visit) {
    // Alert dot color
    Color alertColor = Colors.green;
    if (visit.alerts.patientAlert) {
      alertColor = Colors.red;
    } else if (visit.alerts.visitAlert) {
      alertColor = Colors.orange;
    } else if (visit.alerts.disciplineAlert) {
      alertColor = Colors.purple;
    }

    // Left accent color by visit type
    Color cardColor = Colors.blue;
    if (visit.visitTypeName == 'SOC') {
      cardColor = Colors.orange;
    } else if (visit.visitTypeName == 'ROC') {
      cardColor = Colors.green;
    } else if (visit.visitTypeName == 'RECERT') {
      cardColor = Colors.red;
    }

    // Initials (safe — handles empty names and multiple/leading/trailing spaces)
    final initials = _initialsFor(visit.patientName);

    // Time range
    String formattedTime = '';
    try {
      final from = DateTime.parse(visit.visiteDateTimeFrom).toLocal();
      final to = DateTime.parse(visit.visitDateTimeTo).toLocal();
      final fmt = DateFormat('h:mma');
      formattedTime = '${fmt.format(from)}-${fmt.format(to)}';
    } catch (_) {}

    return GestureDetector(
      // ── Disable tap when PAUSED or MISSED ──
      onTap: (visit.treatmentPause == "PAUSE" || visit.isVisitMissed == true)
          ? null
          : () {
        context
            .read<EMRNavigationController>()
            .passVisitId(id: visit.visitId);
        context
            .read<EMRNavigationController>()
            .openScheduleVisit();
      },
      child: Opacity(
        // ── Gray out entire card when MISSED ──
        opacity: visit.isVisitMissed == true ? 0.45 : 1.0,
        child: AbsorbPointer(
          // ── Block all child taps when MISSED ──
          absorbing: visit.isVisitMissed == true,
          child: Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Colored left accent bar
                    Container(
                      width: 18,
                      height: 80,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        // ── Gray accent bar when MISSED ──
                        color: visit.isVisitMissed == true ? Colors.grey : cardColor,
                      ),
                      alignment: Alignment.center,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          visit.visitTypeName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 5,
                            children: [
                              // ── Missed badge ──
                              if (visit.isVisitMissed == true)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    height: 20,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withAlpha(50),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Visit missed',
                                        style: EMRListViewHead
                                            .customTextStyle(context)
                                            .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              // ── Paused badge ──
                              else if (visit.treatmentPause == "PAUSE")
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    height: 20,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color:
                                      ColorManager.greenDark.withAlpha(70),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Visit paused',
                                        style: EMRListViewHead
                                            .customTextStyle(context)
                                            .copyWith(
                                          color: ColorManager.greenDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Offstage(),

                              // Alert dot
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin:
                                  const EdgeInsets.only(right: 8, top: 0),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: alertColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                cardColor.withOpacity(0.15),
                                backgroundImage:
                                visit.patientImgUrl.isNotEmpty
                                    ? NetworkImage(visit.patientImgUrl)
                                    : null,
                                child: visit.patientImgUrl.isEmpty
                                    ? Text(
                                  initials,
                                  style: TextStyle(
                                    color: cardColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Patient info
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VISIT ${visit.visitId}',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      visit.patientName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      visit.primaryDiagnosis,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              // Charge
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '\$${visit.visitCharge.toStringAsFixed(1)}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Alert badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: alertColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: alertColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Time
                              Expanded(
                                flex: 2,
                                child: Text(
                                  formattedTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // ── Start Visit (disabled when PAUSED or MISSED) ──
                              _actionItem(
                                Icons.play_arrow,
                                'Start Visit',
                                (visit.treatmentPause == "PAUSE" ||
                                    visit.isVisitMissed == true)
                                    ? Colors.grey
                                    : Colors.blue,
                                onTap: (visit.treatmentPause == "PAUSE" ||
                                    visit.isVisitMissed == true)
                                    ? null
                                    : () => _showStartVisit(visit),
                              ),
                              const SizedBox(width: 18),

                              // ── Pause / Resume (disabled when MISSED) ──
                              _actionItem(
                                visit.treatmentPause == "PAUSE"
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                visit.treatmentPause == "PAUSE"
                                    ? "Resume Visit"
                                    : "Paused Visit",
                                visit.isVisitMissed == true
                                    ? Colors.grey
                                    : visit.treatmentPause == "PAUSE"
                                    ? ColorManager.yellowBright
                                    : Colors.blue,
                                onTap: visit.isVisitMissed == true
                                    ? null
                                    : () => _showPauseVisit(visit),
                              ),
                              const SizedBox(width: 18),

                              // ── Reschedule (disabled when PAUSED or MISSED) ──
                              InkWell(
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: (visit.treatmentPause == "PAUSE" ||
                                    visit.isVisitMissed == true)
                                    ? null
                                    : () => showDialog(
                                  context: context,
                                  builder: (_) =>
                                      RescheduleVisitTodaysVisit(
                                          visitId: visit.visitId),
                                ).then((_) => _loadAll()),
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                      "images/emr_clinician/mdi_reschedule.svg",
                                      colorFilter: (visit.treatmentPause ==
                                          "PAUSE" ||
                                          visit.isVisitMissed == true)
                                          ? const ColorFilter.mode(
                                          Colors.grey, BlendMode.srcIn)
                                          : null,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Reschedule',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: (visit.treatmentPause ==
                                            "PAUSE" ||
                                            visit.isVisitMissed == true)
                                            ? Colors.grey
                                            : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),

                              // ── Miss Visit (disabled when PAUSED or MISSED) ──
                              _actionItem(
                                Icons.cancel_outlined,
                                'Miss Visit',
                                (visit.treatmentPause == "PAUSE" ||
                                    visit.isVisitMissed == true)
                                    ? Colors.grey
                                    : Colors.red,
                                onTap: (visit.treatmentPause == "PAUSE" ||
                                    visit.isVisitMissed == true)
                                    ? null
                                    : () => showDialog(
                                  context: context,
                                  builder: (_) => MissVisitTodaysVisit(
                                    visitId: visit.visitId,
                                    ptId: visit.patientId,
                                  ),
                                ).then((_) => _loadAll()),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  START VISIT DIALOG
  // ══════════════════════════════════════════════════════════════════════════
  void _showStartVisit(EmrPatientVisitModel visit) {
    showDialog<bool>(
      context: context,
      builder: (_) =>  //PendingReviewFormPopup()
          FutureBuilder<VisitPrefillByIdModel>(
        future:
        getVisitDataUsingVisitId(context: context, visitId: visit.visitId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            );
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load visit data',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            );
          }
          return
              snapshot.data!.pendingAssistantFormIds.isNotEmpty ?
            PendingReviewFormPopup(
            visitId: snapshot.data!.visitId,
            patientId:snapshot.data!.ptId,
            visitData: snapshot.data!,
            isLastEpisode: snapshot.data!.isSecoundLastEpisodeVisit ?? false,):
                snapshot.data!.episodeTriggerType == "CALENDAR"?
                RecertFormDialog(
                  visitId:  snapshot.data!.visitId,
                  visitData:  snapshot.data!,):
          snapshot.data!.isSecoundLastEpisodeVisit == true ?
          DischargeVisitTypePopup(
            visitData: snapshot.data!,
            onNevigate: () {
              showDialog(context: context,
                  builder: (_) =>
                      ViewStartVisit(
                        visitData: snapshot.data!,
                        onRefresh: (){},
                        // visitType: visitTypeString,
                      ));
            },):
          // DischargeVisitTypePopup(
          //   visitData: snapshot.data!,
          //   onNevigate: () {  },):
          ViewStartVisit(
            visitData: snapshot.data!,
            onRefresh: () => _loadAll(),
          );
        },
      ),
    );
  }
  void _showPauseVisit(EmrPatientVisitModel visit) {
    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setState) {
              return
                DeletePopup(
                    text: visit.treatmentPause == "PAUSE" ?
                    "Are you sure you want to resume treatment this visit?":
                    "Are you sure you want to pause treatment this visit?",
                    title: visit.treatmentPause == "PAUSE" ?
                    "Resumed treatment":
                    "Paused treatment",
                    btnText: "Yes",
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onDelete: () async {
                      try{
                        final response = await patchTreatmentPauseVisit(context: context,
                            id: visit.visitId, treatmentPause: visit.treatmentPause == "PAUSE" ? false : true);
                        if (response.statusCode == 200 || response.statusCode == 201) {
                          if(response.pauseEpisodeEnd == true){
                            Navigator.pop(context, true);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return  DischargeMissedVisitTypePopup(
                                  visitId: response.pauseLastVisitId != 0 ?
                                  response.pauseLastVisitId! :
                                  response.pauseSecoundVisitId!,
                                  onNevigate: () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              },
                            );
                          }
                          Navigator.pop(context, true);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return  AddSuccessPopup(
                                message: visit.treatmentPause == "PAUSE" ?
                                'Treatment Resumed Successfully':
                                'Treatment Paused Successfully',
                              );
                            },
                          );
                          // pass true so parent can refresh
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AddErrorPopup(
                                message: 'Something went wrong!',
                              );
                            },
                          );
                        }
                      }finally {
                        _loadVisits();
                      }
                    }
                );
            },
          ),
    );
  }


  // ══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _statCard(
      String title,
      String count,
      Color color,
      String iconAsset,
      VoidCallback onTap,
      ) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border(top: BorderSide(color: color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: color),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: color),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                  ),
                  child: Image.asset(iconAsset,
                      width: 24, height: 24, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      //borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 4),
      ],
    );
  }
}