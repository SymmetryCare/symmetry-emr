import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:provider/provider.dart';
import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/common_resources/em_dashboard_theme.dart';
import '../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../../app/services/api/managers/emr_module_manager/emr_patient_manager/patient_tab_manager.dart';
import '../../../../../data/api_data/emr_module_data/patient_tab_data/patient_tab_data.dart';
import '../../../em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../em_module/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import '../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../emr_dashbord/dashboard_middle_widget_component/widgets/widgets/constants/dropdown_const.dart';
import '../emr_dashbord/emr_dashboard_screen.dart';
import '../../../../../presentation/widgets/widgets/profile_bar/widget/pagination_widget.dart';
import '../../../../widgets/widgets/custom_scrollbar.dart';

class EMRPatientsHomeScreen extends StatefulWidget {
  const EMRPatientsHomeScreen({super.key});

  @override
  State<EMRPatientsHomeScreen> createState() => _EMRPatientsHomeScreenState();
}

class _EMRPatientsHomeScreenState extends State<EMRPatientsHomeScreen> {
  String _selectedFilter = 'Sort By';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();

  List<AssignedPatientData> _allPatients = [];
  bool _isLoading = true;

  int currentPage       = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    final result = await getAssignedPatients(
        context: context,
        statusFilter: _selectedFilter == 'Sort By' ? "all" : _selectedFilter);
    if (mounted) {
      setState(() {
        _allPatients = result ?? [];
        _isLoading   = false;
      });
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  static const _avatarPairs = [
    [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    [Color(0xFFFFF3E0), Color(0xFFE65100)],
    [Color(0xFFFCE4EC), Color(0xFFC62828)],
  ];

  Color _avatarBg(int? id)   => _avatarPairs[(id ?? 0) % _avatarPairs.length][0];
  Color _avatarText(int? id) => _avatarPairs[(id ?? 0) % _avatarPairs.length][1];

  String _episodeLabel(AssignedPatientEpisodeData? ep) {
    if (ep == null) return '—';
    final from = ep.episodeFrom != null && ep.episodeFrom!.isNotEmpty
        ? _fmtDate(ep.episodeFrom!) : '—';
    final to = ep.episodeTo != null && ep.episodeTo!.isNotEmpty
        ? _fmtDate(ep.episodeTo!) : '—';
    return 'Ch ${ep.chartId ?? '?'} Ep ${ep.episodeId ?? '?'} $from–$to';
  }

  String _fmtDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) { return iso; }
  }

  // ── uses savedInsurances (committed on Save) ───────────────────────────────
  List<AssignedPatientData> _filteredPatients(FilterDrawerProvider fp) {
    final query = _searchController.text.trim().toLowerCase();

    return _allPatients.where((p) {
      final status = p.patientStatus ?? '';

      final matchesFilter =
          _selectedFilter == 'Sort By' || status == _selectedFilter;

      final matchesSearch = query.isEmpty ||
          (p.patientName?.toLowerCase().contains(query) ?? false) ||
          (p.mrn?.toString().contains(query) ?? false) ||
          (p.physician?.name?.toLowerCase().contains(query) ?? false) ||
          (p.primaryDiagnosis?.toLowerCase().contains(query) ?? false) ||
          (p.insurance?.toLowerCase().contains(query) ?? false);

      final matchesInsurance = fp.savedInsurances.isEmpty ||
          fp.savedInsurances.contains(p.insurance ?? '');

      return matchesFilter && matchesSearch && matchesInsurance;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<FilterDrawerProvider>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final patients = _filteredPatients(filterProvider);

    if (patients.isNotEmpty) {
      final int totalPages = (patients.length / itemsPerPage).ceil();
      if (currentPage > totalPages) currentPage = totalPages;
    } else {
      currentPage = 1;
    }

    final List<AssignedPatientData> paginatedPatients = patients
        .skip((currentPage - 1) * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return Stack(
      children: [

        // ── Main content ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p60),
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
                    child: Column(
                      children: [
              const SizedBox(height: AppSize.s12),

              // ── Search & Filter row ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomSearchFieldSM(
                        width: 400,
                        searchController: _searchController,
                        onPressed: () => setState(() { currentPage = 1; }),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor:    Colors.transparent,
                        hoverColor:     Colors.transparent,
                        focusColor:     Colors.transparent,
                        onTap: () =>
                            context.read<FilterDrawerProvider>().toggleFilter(),
                        child: Image.asset(
                          "images/sm/sm_refferal/filter_icon.png",
                          height: AppSize.s18,
                          width:  AppSize.s16,
                        ),
                      ),
                    ],
                  ),
                  CustomDropdown(
                    items: const [
                      'Sort By', 'Admitted', 'Discharged',
                      'Transferred', 'Resumption', 'Recertified', 'Pre-Recert',
                    ],
                    initialValue: 'Sort By',
                    onChanged: (value) => setState(() {
                      _selectedFilter = value;
                      currentPage     = 1;
                      _loadPatients();
                    }),
                  ),
                ],
              ),

              const SizedBox(height: AppSize.s10),

              // ── Table header ─────────────────────────────────────────────
              Container(
                height: AppSize.s33,
                decoration: BoxDecoration(
                  color: ColorManager.SMFBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.only(left: AppPadding.p50),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text("Patient Name",
                        style: EMRListViewHead.customTextStyle(context))),
                    Expanded(flex: 2, child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text("MRN", textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)),
                    )),
                    Expanded(flex: 2, child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text("Current Episode",
                          style: EMRListViewHead.customTextStyle(context)),
                    )),
                    Expanded(flex: 2, child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text("Physician", textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)),
                    )),
                    Expanded(flex: 3, child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Text("Primary Diagnosis", textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)),
                    )),
                    Expanded(flex: 2, child: Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text("Insurance", textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)),
                    )),
                    const Expanded(flex: 1, child: SizedBox()),
                  ],
                ),
              ),

              const SizedBox(height: AppSize.s10),

              // ── Empty state ──────────────────────────────────────────────
              if (patients.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('No patients found!',
                        style: EMRListViewHead.customTextStyle(context).copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorManager.mediumgrey)),
                  ),
                )
              else ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ListView.builder(
                      itemCount: paginatedPatients.length,
                      itemBuilder: (context, index) {
                        final p              = paginatedPatients[index];
                        final status         = p.patientStatus ?? '';
                        final isAdmitted     = status == 'Admitted';
                        final isResumption    = status == "Resumption";
                        final isDischarge   = status == "Discharge";
                        final bgColor        = _avatarBg(p.patientId);
                        final textColor      = _avatarText(p.patientId);
                        final initials       = _initials(p.patientName);
                        final mrnStr         = p.mrn?.toString() ?? '—';
                        final physicianLabel =
                            '${p.physician?.name ?? '—'} | ${p.physician?.contact ?? '—'}';
                        final episodeLabel   = _episodeLabel(p.currentEpisode);
                        final isAuthorized   = p.authStatus?.isAuthorized ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSize.s10),
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<EMRNavigationController>()
                                  .openPatientDetail(
                                EMRSelectedPatient(
                                  patientId:       p.patientId ?? 0,
                                  name:            p.patientName ?? '',
                                  initials:        initials,
                                  avatarBgValue:   bgColor.value,
                                  avatarTextValue: textColor.value,
                                  mrn:             mrnStr,
                                  episode:         episodeLabel,
                                  physician:       physicianLabel,
                                  diagnosis:       p.primaryDiagnosis ?? '',
                                  insurance:       p.insurance ?? '',
                                  authorization:   isAuthorized ? 'A' : 'N',
                                  status:          status,
                                  chartId:   p.currentEpisode!.chartId!,
                                  episodeId: p.currentEpisode!.episodeId!,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorManager.white,
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade400, width: 1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (status.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: AppPadding.p20,
                                              vertical: AppPadding.p2),
                                          decoration: BoxDecoration(
                                            color: isAdmitted
                                                ? ColorManager.greenDark
                                                : isResumption
                                                ? ColorManager.orangeheading
                                                : isDischarge
                                                ? Color(0xFFC62828)
                                                : Colors.yellow,
                                          ),
                                          child: Text(status,
                                              style: GeneralSettingTextStyle
                                                  .customTextStyle(context)
                                                  .copyWith(
                                                  fontSize: FontSize.s10)),
                                        ),
                                      ],
                                    ),
                                  // ToDo Paused treatment badge and functionality remaining
                                  // p.treatmentPause == true ? Align(
                                  //   alignment: Alignment.centerRight,
                                  //   child: Container(
                                  //     height: 20,
                                  //     width: 140,
                                  //     decoration:  BoxDecoration(
                                  //         color: ColorManager.pieChartYellow,
                                  //       borderRadius: const BorderRadius.only(
                                  //         topLeft: Radius.circular(5),
                                  //         bottomLeft: Radius.circular(5)
                                  //       )
                                  //     ),
                                  //     child: Center(
                                  //       child: Text('Paused treatment',style:EMRListViewHead
                                  //           .customTextStyle(context)
                                  //           .copyWith(
                                  //           fontWeight:
                                  //           FontWeight.w500),),
                                  //     ),
                                  //   ),
                                  // ) : const Offstage(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor: bgColor,
                                                child: Text(initials,
                                                    style: TextStyle(
                                                        color: textColor,
                                                        fontWeight:
                                                        FontWeight.bold)),
                                              ),
                                              const SizedBox(width: AppSize.s10),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(p.patientName ?? '—',
                                                      style: EMRListViewHead
                                                          .customTextStyle(
                                                          context)),
                                                  const SizedBox(
                                                      height: AppSize.s5),
                                                  Text(
                                                      "DOB: ${p.dob != null && p.dob!.isNotEmpty ? _fmtDate(p.dob!) : '—'}",
                                                      style: EMRListViewHead
                                                          .customTextStyle(
                                                          context)
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight
                                                              .w400)),
                                                  const SizedBox(
                                                      height: AppSize.s5),
                                                  Text(
                                                      "Kaiser ${p.kaiserNo != null && p.kaiserNo!.isNotEmpty ? p.kaiserNo : '--'}",
                                                      style: EMRListViewHead
                                                          .customTextStyle(
                                                          context)
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight
                                                              .w400)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Text(mrnStr,
                                                textAlign: TextAlign.center,
                                                style: EMRListViewHead
                                                    .customTextStyle(context)
                                                    .copyWith(
                                                    fontWeight:
                                                    FontWeight.w400)),
                                          ),
                                        ),
                                        const SizedBox(width: 40),
                                        Expanded(
                                          flex: 3,
                                          child: Text(episodeLabel,
                                              style: EMRListViewHead
                                                  .customTextStyle(context)
                                                  .copyWith(
                                                  fontWeight:
                                                  FontWeight.w400)),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(physicianLabel,
                                              style: EMRListViewHead
                                                  .customTextStyle(context)
                                                  .copyWith(
                                                  fontWeight:
                                                  FontWeight.w400),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(p.primaryDiagnosis ?? '—',
                                              style: EMRListViewHead
                                                  .customTextStyle(context)
                                                  .copyWith(
                                                  fontWeight:
                                                  FontWeight.w400),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(p.insurance ?? '—',
                                              textAlign: TextAlign.center,
                                              style: EMRListViewHead
                                                  .customTextStyle(context)
                                                  .copyWith(
                                                  fontWeight:
                                                  FontWeight.w400)),
                                        ),
                                        _AuthBadge(patient: p),

                                        // ToDO Api integration and funtionality remaning
                                        // InkWell(
                                        //   splashColor: Colors.transparent,
                                        //   highlightColor: Colors.transparent,
                                        //   hoverColor: Colors.transparent,
                                        //   onTap: () {
                                        //     showDialog(
                                        //       context: context,
                                        //       builder: (context) =>
                                        //           StatefulBuilder(
                                        //             builder: (BuildContext context, void Function(void Function()) setState) {
                                        //               return
                                        //                 DeletePopup(
                                        //                     text: p.treatmentPause == true ?
                                        //                     "Are you sure you want to resume treatment this patient?":
                                        //                     "Are you sure you want to pause treatment this patient?",
                                        //                     title: p.treatmentPause == true?
                                        //                     "Resumed treatment":
                                        //                     "Paused treatment",
                                        //                     btnText: "Yes",
                                        //                     onCancel: () {
                                        //                       Navigator.pop(context);
                                        //                     },
                                        //                     onDelete: () async {
                                        //                       try{
                                        //                         final response = await patchTreatmentPause(context: context,
                                        //                             id: p.patientId!, treatmentPause: p.treatmentPause == true ? false : true);
                                        //                         if (response.statusCode == 200 || response.statusCode == 201) {
                                        //                           Navigator.pop(context, true);
                                        //                           showDialog(
                                        //                             context: context,
                                        //                             builder: (BuildContext context) {
                                        //                               return  AddSuccessPopup(
                                        //                                 message: p.treatmentPause == true ?
                                        //                                 'Treatment Resumed Successfully':
                                        //                                 'Treatment Paused Successfully',
                                        //                               );
                                        //                             },
                                        //                           );
                                        //                           // pass true so parent can refresh
                                        //                         } else {
                                        //                           showDialog(
                                        //                             context: context,
                                        //                             builder: (BuildContext context) {
                                        //                               return const AddErrorPopup(
                                        //                                 message: 'Something went wrong!',
                                        //                               );
                                        //                             },
                                        //                           );
                                        //                         }
                                        //                       }finally {
                                        //                         _loadPatients();
                                        //                       }
                                        //                     }
                                        //                 );
                                        //             },
                                        //           ),
                                        //     );
                                        //   },
                                        //     child: Icon(Icons.more_vert,color: ColorManager.mediumgrey)),
                                        const SizedBox(width: 20),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                PaginationControlsWidget(
                  currentPage:  currentPage,
                  items:        patients,
                  itemsPerPage: itemsPerPage,
                  onPreviousPagePressed: () {
                    setState(() {
                      currentPage = currentPage > 1 ? currentPage - 1 : 1;
                    });
                  },
                  onPageNumberPressed: (pageNumber) {
                    setState(() { currentPage = pageNumber; });
                  },
                  onNextPagePressed: () {
                    final totalPages = (patients.length / itemsPerPage).ceil();
                    setState(() {
                      currentPage = currentPage < totalPages
                          ? currentPage + 1
                          : totalPages;
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
                    ),       // Column
                  ),         // SizedBox
                ),           // Padding
              ),             // SingleChildScrollView
            );               // CustomScrollbar
          }),                // LayoutBuilder
        ),

        // ── Barrier — close on outside tap ────────────────────────────────
        if (filterProvider.isFilterOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.read<FilterDrawerProvider>().closeFilter(),
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

        // ── Filter panel ──────────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: filterProvider.isFilterOpen ? 0 : -320,
          top: 0,
          bottom: 0,
          width: 300,
          child: EMRFilterDrawer(
            onClose: () => context.read<FilterDrawerProvider>().closeFilter(),
          ),
        ),
      ],
    );
  }
}

// ── Authorization badge with popup ────────────────────────────────────────────
class _AuthBadge extends StatefulWidget {
  final AssignedPatientData patient;
  const _AuthBadge({required this.patient});

  @override
  State<_AuthBadge> createState() => _AuthBadgeState();
}

class _AuthBadgeState extends State<_AuthBadge> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlay;

  void _toggle() {
    if (_overlay != null) { _close(); return; }

    final box    = _key.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size   = box.size;

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: offset.dx - 160,
            top:  offset.dy + size.height + 6,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorManager.blueprime,
                        borderRadius: const BorderRadius.only(
                          topLeft:  Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Auth Status',
                              style: TextStyle(
                                  color:      ColorManager.white,
                                  fontSize:   FontSize.s12,
                                  fontWeight: FontWeight.w600)),
                          InkWell(
                            onTap: _close,
                            child: Icon(Icons.close, color: ColorManager.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _PopupRow(
                            label: '# of Auth Remaining:',
                            value: widget.patient.authStatus?.authRemaining
                                ?.isNotEmpty ==
                                true
                                ? widget.patient.authStatus!.authRemaining!
                                : '—',
                          ),
                          const SizedBox(height: 20),
                          _PopupRow(
                            label: 'Auth Expiration Date:',
                            value: widget.patient.authStatus?.lastChecked
                                ?.isNotEmpty ==
                                true
                                ? widget.patient.authStatus!.lastChecked!
                                : '—',
                          ),
                          const SizedBox(height: 10),
                        ],
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

    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _toggle,
      child: Container(
        width: 30,
        margin: const EdgeInsets.only(right: 30, left: 30),
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p6, vertical: AppPadding.p2),
        decoration: BoxDecoration(
          color: ColorManager.SMFBlue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'A',
            style: GeneralSettingTextStyle.customTextStyle(context).copyWith(
              fontSize: FontSize.s10,
              color: ColorManager.bluebottom,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Popup row ─────────────────────────────────────────────────────────────────
class _PopupRow extends StatelessWidget {
  final String label;
  final String value;
  const _PopupRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: TextStyle(
                  fontSize:   FontSize.s10,
                  fontWeight: FontWeight.w600,
                  color:      Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize:   FontSize.s10,
                  fontWeight: FontWeight.w400,
                  color:      Colors.grey.shade800)),
        ),
      ],
    );
  }
}