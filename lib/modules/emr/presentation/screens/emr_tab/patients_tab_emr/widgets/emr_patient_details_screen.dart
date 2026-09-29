import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/patient_chart_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/patient_data_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/oasis_plan_of_care_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/medications_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/physician_orders_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/care_coordination_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/skilled_nursing_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/physical_therapy_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/occupational_therapy_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/speech_therapy_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/home_health_aide_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/social_service_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/registered_dietician_notes_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/lab_results_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/visit_timeline_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_form_tab/patient_form_tab_home.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_profile_tab/patient_profile_tab_home.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patint_schedule_tab/patient_schedule_home.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/emr_chatbot_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/emr_clinical_group_chatbot.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/patients_tabs_container_header.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/emr_provider/emr_patient_provider.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_header_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_header_data.dart';

// ── Sub-tab labels ────────────────────────────────────────────────────────────
const _chartSubTabs = [
  'Patient Data', 'OASIS/Plan Of Care', 'Medications', 'Physician Orders',
  'Care Coordination', 'Skilled Nursing Notes', 'Physical Therapy Notes',
  'Occupational therapy Notes', 'Speech Therapy Notes', 'Home Health Aide Notes',
  'Social Service Notes', 'Registered Dietician Notes', 'Lab Results', 'Visit Timeline',
];

const _chartSubTabIcons = [
  'images/emr_clinician/patients_tab/file-document-multiple-outline 1.svg', // Patient Data
  'images/emr_clinician/patients_tab/file-sign 3.svg',                       // OASIS/Plan Of Care
  'images/emr_clinician/patients_tab/pill.svg',                               // Medications
  'images/emr_clinician/patients_tab/order-bool-ascending-variant 1.svg',    // Physician Orders
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Care Coordination
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Skilled Nursing Notes
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Physical Therapy Notes
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Occupational therapy Notes
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Speech Therapy Notes
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Home Health Aide Notes
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Social Service Notes
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Registered Dietician Notes
  'images/emr_clinician/patients_tab/file-account 1.svg',                    // Lab Results
  'images/emr_clinician/patients_tab/file-document-outline 1.svg',           // Visit Timeline
];

// ── Main screen ───────────────────────────────────────────────────────────────
class EMRPatientDetailsScreen extends StatefulWidget {
  const EMRPatientDetailsScreen({super.key});

  @override
  State<EMRPatientDetailsScreen> createState() =>
      _EMRPatientDetailsScreenState();
}

class _EMRPatientDetailsScreenState extends State<EMRPatientDetailsScreen> {
  int  _selectedMainTab = 0;
  bool _chartExpanded   = true;
  int  _selectedSubTab  = 0;
  bool _subTabActive    = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _rightPanelScrollController = ScrollController();

  // ── Header API state ───────────────────────────────────────────────────────
  PatientReferralHeaderData? _headerData;
  bool _headerLoading      = true;
  int? _loadedForPatientId;

  // ── Clinical group chat visibility (Care Team Chat button) ─────────────────
  bool _clinicalChatVisible = false;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _rightPanelScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final patient = context.read<EMRNavigationController>().selectedPatient;
    if (patient != null && patient.patientId != _loadedForPatientId) {
      _loadedForPatientId = patient.patientId;
      _loadHeader(patient.patientId);
    }
  }

  Future<void> _loadHeader(int patientId) async {
    setState(() => _headerLoading = true);
    final data = await getPatientReferralHeader(context, patientId);
    if (!mounted) return;
    setState(() {
      _headerData    = data;
      _headerLoading = false;
    });
  }

  void _showGroupIdMissingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _GroupIdMissingDialog(),
    );
  }

  void _selectMain(int i) {
    setState(() {
      _selectedMainTab = i;
      if (i == 0) {
        _chartExpanded = true;
        _subTabActive  = false;
      }
    });
  }

  void _toggleClinicalChat() {
    setState(() => _clinicalChatVisible = !_clinicalChatVisible);
  }

  void _closeClinicalChat() {
    setState(() => _clinicalChatVisible = false);
  }

  Widget _buildRightContent(EMRSelectedPatient patient) {
    if (_selectedMainTab == 0) {
      if (!_subTabActive) return const PatientChartScreen();
      switch (_selectedSubTab) {
        case 0:  return  PatientDataScreen(patientId: patient.patientId,);
        case 1:  return OasisPlanOfCareScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 2:  return MedicationsScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 3:  return PhysicianOrdersScreen(
          patientId: 221,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 4:  return CareCoordinationScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 5:  return SkilledNursingNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 6:  return PhysicalTherapyNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 7:  return OccupationalTherapyNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 8:  return SpeechTherapyNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 9:  return HomeHealthAideNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 10: return SocialServiceNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 11: return RegisteredDieticianNotesScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 12: return LabResultsScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        case 13: return VisitTimelineScreen(
          patientId: patient.patientId,
          chartId:   patient.chartId,
          episodeId: patient.episodeId,
        );
        default: return  PatientDataScreen(patientId: patient.patientId,);
      }
    }
    switch (_selectedMainTab) {
      case 1:  return PatientSchedulePage( ptId: patient.patientId,);
      case 2:  return PatientProfilePage(patient: patient);
      case 3:  return PatientFormsPage(
        patientID: patient.patientId,
        chartID: patient.chartId,
        episodeID: patient.episodeId,);
      default: return const SizedBox.shrink();
    }
  }

  bool get _hasPatientGroup =>
      _headerData != null && _headerData!.patientGroupId != null;

  @override
  Widget build(BuildContext context) {
    final nav     = context.watch<EMRNavigationController>();
    final patient = nav.selectedPatient;
    if (patient == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: LayoutBuilder(builder: (context, constraints) {
        const double minContentWidth = 1200;
        final double contentWidth = constraints.maxWidth > minContentWidth
            ? constraints.maxWidth
            : minContentWidth;
        return CustomScrollbar(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p10),
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

          // ── Left sidebar ───────────────────────────────────────────────
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () =>
                      context.read<EMRNavigationController>().closePatientDetail(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p16, vertical: AppPadding.p0),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back,
                            size: IconSize.I22, color: ColorManager.mediumgrey),
                        const SizedBox(width: AppSize.s15),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize:   FontSize.s12,
                            fontWeight: FontWeight.w600,
                            color:      ColorManager.mediumgrey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        _MainNavItem(
                          svgPath:     'images/emr_clinician/patients_tab/poll.svg',
                          label:       'Patient Chart',
                          isSelected:  _selectedMainTab == 0,
                          hasDropdown: true,
                          isExpanded:  _chartExpanded,
                          onTap:       () => _selectMain(0),
                          onDropdownTap: () => setState(() {
                            if (_selectedMainTab == 0) {
                              _chartExpanded = !_chartExpanded;
                            } else {
                              _selectedMainTab = 0;
                              _chartExpanded   = true;
                            }
                          }),
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: _chartExpanded
                              ? Column(
                            children: List.generate(
                              _chartSubTabs.length,
                                  (i) => _SubNavItem(
                                svgPath:    _chartSubTabIcons[i],
                                label:      _chartSubTabs[i],
                                isSelected: _selectedMainTab == 0 &&
                                    _subTabActive &&
                                    _selectedSubTab == i,
                                onTap: () => setState(() {
                                  _selectedMainTab = 0;
                                  _selectedSubTab  = i;
                                  _subTabActive    = true;
                                }),
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),

                        _MainNavItem(
                          svgPath:    'images/emr_clinician/patients_tab/clock-outline 1.svg',
                          label:      'Patient Schedule',
                          isSelected: _selectedMainTab == 1,
                          onTap:      () => _selectMain(1),
                        ),

                        _MainNavItem(
                          svgPath:    'images/emr_clinician/patients_tab/account-outline 1.svg',
                          label:      'Patient Profile',
                          isSelected: _selectedMainTab == 2,
                          onTap:      () => _selectMain(2),
                        ),

                        _MainNavItem(
                          svgPath:    'images/emr_clinician/patients_tab/text-box-outline 1.svg',
                          label:      'Patient Forms',
                          isSelected: _selectedMainTab == 3,
                          onTap:      () => _selectMain(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          VerticalDivider(width: 1, color: Colors.grey.shade200),

          // ── Right side ─────────────────────────────────────────────────
          Expanded(
            child: _headerLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<EmrPatientProvider>(
              builder: (context, patientEmrProvider, child) {
                return Stack(
                  children: [
                    CustomScrollbar(
                      controller: _rightPanelScrollController,
                      child: SingleChildScrollView(
                        controller: _rightPanelScrollController,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 11,
                                  child: PatientConstantHeader(
                                    patient:    patient,
                                    headerData: _headerData,
                                    hasGroup:   _hasPatientGroup,
                                  ),
                                ),

                                // ── Care Team Chat vertical button ─────────
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: AppPadding.p10),
                                    child: InkWell(
                                    splashColor:    Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor:     Colors.transparent,
                                    onTap: _toggleClinicalChat,
                                    child: Container(
                                      width:  28,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: ColorManager.blueprime,
                                        borderRadius: const BorderRadius.only(
                                          topLeft:    Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                        ),
                                      ),
                                      child: Center(
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(
                                            'Care Team Chat',
                                            style: TextStyle(
                                              color:         ColorManager.white,
                                              fontSize:      11,
                                              fontWeight:    FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ),
                                ),
                              ],
                            ),

                          _buildRightContent(patient),
                        ],
                                            ),
                                          ),
                    ),

                    // ── Backdrop for patient chat (EmrChatBotContainer) ───
                    if (patientEmrProvider.isChatVisible)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: patientEmrProvider.clearChatVisible,
                          child: Container(color: Colors.transparent),
                        ),
                      ),

                    // ── Patient Chat panel — opened by Patient Chat image button
                    if (_hasPatientGroup)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve:    Curves.easeInOut,
                        bottom:   0,
                        right:    patientEmrProvider.isChatVisible ? 15 : -820,
                        child: Container(
                          decoration: BoxDecoration(
                            color:        const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 500,
                          width:  800,
                          child: Builder(
                            builder: (context) {
                              print("======================================");
                              print("PatientChat ptGroupId → ${_headerData!.patientGroupId!}");
                              print("======================================");
                              return EmrChatBotContainer(
                                ptGroupId: _headerData!.patientGroupId!,
                              );
                            },
                          ),
                        ),
                      ),

                    // ── Backdrop for clinical group chat ──────────────────
                    if (_clinicalChatVisible)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _closeClinicalChat,
                          child: Container(color: Colors.transparent),
                        ),
                      ),

                    // ── Clinical Group Chat panel — opened by Care Team Chat button
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve:    Curves.easeInOut,
                      bottom:   0,
                      right:    _clinicalChatVisible ? 15 : -820,
                      child: Container(
                        decoration: BoxDecoration(
                          color:        const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 500,
                        width:  800,
                        child: Builder(
                          builder: (context) {
                            print("======================================");
                            print("ClinicalGroupChat ptId → ${patient.patientId}");
                            print("======================================");
                            return ClinicalGroupChatBot(
                              ptId: patient.patientId,
                              onClose: _closeClinicalChat,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
                ),          // Row
              ),             // SizedBox
            ),               // Padding
          ),                 // SingleChildScrollView
        );                   // CustomScrollbar
      }),                    // LayoutBuilder
    );
  }
}

// ── Group ID missing dialog ───────────────────────────────────────────────────
class _GroupIdMissingDialog extends StatelessWidget {
  const _GroupIdMissingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSize.s16),
            const Text(
              "Group Assignment Missing",
              style: TextStyle(
                fontSize:   FontSize.s16,
                fontWeight: FontWeight.w700,
                color:      Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSize.s8),
            Text(
              "This patient does not have a Patient Group or Clinician Group assigned. "
                  "Some features like Care Team Chat may not be available until groups are configured.",
              style: TextStyle(
                fontSize: FontSize.s12,
                color:    ColorManager.mediumgrey,
                height:   1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSize.s24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blueprime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p12),
                ),
                child: const Text(
                  "OK, Got it",
                  style: TextStyle(
                    color:      Colors.white,
                    fontSize:   FontSize.s13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main nav item ─────────────────────────────────────────────────────────────
class _MainNavItem extends StatelessWidget {
  final String       svgPath;
  final String       label;
  final bool         isSelected;
  final bool         hasDropdown;
  final bool         isExpanded;
  final VoidCallback  onTap;
  final VoidCallback? onDropdownTap;

  const _MainNavItem({
    required this.svgPath,
    required this.label,
    required this.isSelected,
    this.hasDropdown   = false,
    this.isExpanded    = false,
    required this.onTap,
    this.onDropdownTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ColorManager.blueprime : ColorManager.mediumgrey;
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16, vertical: AppPadding.p12),
        margin: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
        decoration: BoxDecoration(
          color: isSelected ? ColorManager.SMFBlue : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? ColorManager.blueprime : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize:   FontSize.s14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? ColorManager.blueprime
                      : ColorManager.mediumgrey,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (hasDropdown)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDropdownTap,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    isExpanded
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    size: 16,
                    color: isSelected
                        ? ColorManager.blueprime
                        : ColorManager.mediumgrey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-nav item ──────────────────────────────────────────────────────────────
class _SubNavItem extends StatelessWidget {
  final String       svgPath;
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;

  const _SubNavItem({
    required this.svgPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ColorManager.blueprime : ColorManager.mediumgrey;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
            left:   AppPadding.p30,
            right:  AppPadding.p12,
            top:    AppPadding.p10,
            bottom: AppPadding.p10),
        margin: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
        decoration: BoxDecoration(
          color: isSelected ? ColorManager.SMFBlue : Colors.transparent,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize:   FontSize.s12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: color,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}