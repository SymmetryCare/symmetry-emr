import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/em_dashboard_theme.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_tab_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_tab_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/reload_button/reload_button_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/constants/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/emr_dashboard_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

// ── Controller — owns list/loading/filter/pagination state. Calling
// notifyListeners() here only rebuilds the AnimatedBuilder-wrapped sections
// below, NOT the whole EMRPatientsHomeScreen. ────────────────────────────────
class _EMRPatientsController extends ChangeNotifier {
  List<AssignedPatientData> allPatients = [];
  bool isLoading = true;
  String selectedFilter = 'Sort By';

  int currentPage = 1;
  final int itemsPerPage = 10;

  Future<void> loadPatients(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final result = await getAssignedPatients(
      context: context,
      statusFilter: selectedFilter == 'Sort By' ? "all" : selectedFilter,
    );

    allPatients = result ?? [];
    isLoading = false;
    notifyListeners();
  }

  void setFilter(BuildContext context, String value) {
    selectedFilter = value;
    currentPage = 1;
    loadPatients(context);
  }

  void resetPageForSearch() {
    currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void nextPage(int totalPages) {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }
}

class EMRPatientsHomeScreen extends StatefulWidget {
  const EMRPatientsHomeScreen({super.key});

  @override
  State<EMRPatientsHomeScreen> createState() => _EMRPatientsHomeScreenState();
}

class _EMRPatientsHomeScreenState extends State<EMRPatientsHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final _EMRPatientsController _controller = _EMRPatientsController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.loadPatients(context));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onReloadTap() async {
    await _controller.loadPatients(context);
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
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

  Color _avatarBg(int? id) => _avatarPairs[(id ?? 0) % _avatarPairs.length][0];
  Color _avatarText(int? id) => _avatarPairs[(id ?? 0) % _avatarPairs.length][1];

  String _episodeLabel(AssignedPatientEpisodeData? ep) {
    if (ep == null) return '';
    final from = ep.episodeFrom != null && ep.episodeFrom!.isNotEmpty
        ? _fmtDate(ep.episodeFrom!)
        : '';
    final to =
    ep.episodeTo != null && ep.episodeTo!.isNotEmpty ? _fmtDate(ep.episodeTo!) : '';
    final dateRange = (from.isEmpty && to.isEmpty) ? '' : '$from–$to';
    return dateRange.isEmpty
        ? 'Ch ${ep.chartId ?? '?'} Ep ${ep.episodeId ?? '?'}'
        : 'Ch ${ep.chartId ?? '?'} Ep ${ep.episodeId ?? '?'} $dateRange';
  }

  String _fmtDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}/${dt.month}/${dt.day}';
    } catch (_) {
      return iso;
    }
  }

  // ── uses savedInsurances (committed on Save) ───────────────────────────────
  List<AssignedPatientData> _filteredPatients(FilterDrawerProvider fp) {
    final query = _searchController.text.trim().toLowerCase();

    return _controller.allPatients.where((p) {
      final status = p.patientStatus ?? '';

      final matchesFilter =
          _controller.selectedFilter == 'Sort By' || status == _controller.selectedFilter;

      final matchesSearch = query.isEmpty ||
          (p.patientName?.toLowerCase().contains(query) ?? false) ||
          (p.mrn?.toString().contains(query) ?? false) ||
          (p.physician?.name?.toLowerCase().contains(query) ?? false) ||
          (p.primaryDiagnosis?.toLowerCase().contains(query) ?? false) ||
          (p.insurance?.toLowerCase().contains(query) ?? false);

      final matchesInsurance =
          fp.savedInsurances.isEmpty || fp.savedInsurances.contains(p.insurance ?? '');

      return matchesFilter && matchesSearch && matchesInsurance;
    }).toList();
  }

  // ── Static table header — never rebuilds on state changes ────────────────
  // NOTE: flex ratios, fixed gaps, and text alignment below are kept in sync
  // with the data Row in itemBuilder so columns line up. Do not change one
  // without mirroring the other.
  Widget _buildTableHeader() {
    return Container(
      height: AppSize.s33,
      decoration: BoxDecoration(
        color: ColorManager.SMFBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      // matches data row offset: 20 (outer Expanded Padding) + 10 (inner Padding)
      padding: const EdgeInsets.only(left: 35),
      child: Row(
        children: [
          Expanded(
            flex: 3, // matches avatar+name Expanded(flex:3) in data row
            child: Padding(
              padding: const EdgeInsets.only(left: 45),
              child:
              Text("Patient Name", style: EMRListViewHead.customTextStyle(context)),
            ),
          ),
          Expanded(
            flex: 1, // matches MRN Expanded(flex:1) in data row
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0), // matches data row's right padding
              child: Text("MRN",
                  textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context)),
            ),
          ),
          const SizedBox(width: 40), // matches SizedBox(width: 40) in data row
          Expanded(
            flex: 3, // matches Current Episode Expanded(flex:3) in data row
            child: Text("Current Episode     ",
                textAlign: TextAlign.center, // matches data row's centered text
                style: EMRListViewHead.customTextStyle(context)),
          ),
          Expanded(
            flex: 3, // matches Physician Expanded(flex:3) in data row
            child: Text("Physician",
                textAlign: TextAlign.center, // matches data row's centered text
                style: EMRListViewHead.customTextStyle(context)),
          ),
          Expanded(
            flex: 2, // matches Primary Diagnosis Expanded(flex:2) in data row
            child: Text("Primary Diagnosis",
                textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context)),
          ),
          Expanded(
            flex: 2, // matches Insurance Expanded(flex:2) in data row
            child: Text("Insurance",
                textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context)),
          ),
          const SizedBox(
              width: 90), // reserves space matching _AuthBadge column (30 width + 30+30 margins)
          const SizedBox(width: 20), // matches trailing SizedBox(width: 20) in data row
        ],
      ),
    );
  }

  // ── Single row widget — used by the AnimatedBuilder-wrapped ListView.builder ─
  Widget _buildPatientRow(BuildContext context, AssignedPatientData p) {
    final status = p.patientStatus ?? '';
    final isAdmitted = status == 'Admitted';
    final isResumption = status == "Resumption";
    final isDischarge = status == "Discharge";
    final bgColor = _avatarBg(p.patientId);
    final textColor = _avatarText(p.patientId);
    final initials = _initials(p.patientName);
    final mrnStr = p.mrn?.toString() ?? '—';
    final physicianName = p.physician?.name;
    final physicianContact = p.physician?.contact;
    final physicianLabel = (physicianName != null &&
        physicianName.isNotEmpty &&
        physicianContact != null &&
        physicianContact.isNotEmpty)
        ? '$physicianName | $physicianContact'
        : "--";
    final episodeLabel = _episodeLabel(p.currentEpisode);
    final isAuthorized = p.authStatus?.isAuthorized ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.s10),
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: () {
          context.read<EMRNavigationController>().openPatientDetail(
            EMRSelectedPatient(
              patientId: p.patientId ?? 0,
              name: p.patientName ?? '',
              initials: initials,
              avatarBgValue: bgColor.value,
              avatarTextValue: textColor.value,
              mrn: mrnStr,
              episode: episodeLabel,
              physician: physicianLabel,
              diagnosis: p.primaryDiagnosis ?? '',
              insurance: p.insurance ?? '',
              authorization: isAuthorized ? 'A' : 'N',
              status: status,
              chartId: p.currentEpisode!.chartId!,
              episodeId: p.currentEpisode!.episodeId!,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade400, width: 1),
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
                          horizontal: AppPadding.p20, vertical: AppPadding.p2),
                      decoration: BoxDecoration(
                        color: isAdmitted
                            ? ColorManager.greenDark
                            : isResumption
                            ? ColorManager.orangeheading
                            : isDischarge
                            ? const Color(0xFFC62828)
                            : ColorManager.SMYellow,
                      ),
                      child: Text(status,
                          style: GeneralSettingTextStyle.customTextStyle(context)
                              .copyWith(fontSize: FontSize.s10)),
                    ),
                  ],
                ),
              // ToDo Paused treatment badge and functionality remaining
              Padding(
                padding: const EdgeInsets.only(left: 30),
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
                                    color: textColor, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: AppSize.s10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.patientName ?? '—',
                                  style: EMRListViewHead.customTextStyle(context)),
                              const SizedBox(height: AppSize.s5),
                              Text(
                                  "DOB: ${p.dob != null && p.dob!.isNotEmpty ? _fmtDate(p.dob!) : '—'}",
                                  style: EMRListViewHead.customTextStyle(context)
                                      .copyWith(fontWeight: FontWeight.w400)),
                              const SizedBox(height: AppSize.s5),
                              Text(
                                  "Kaiser ${p.kaiserNo != null && p.kaiserNo!.isNotEmpty ? p.kaiserNo : '--'}",
                                  style: EMRListViewHead.customTextStyle(context)
                                      .copyWith(fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(mrnStr,
                            textAlign: TextAlign.center,
                            style: EMRListViewHead.customTextStyle(context)
                                .copyWith(fontWeight: FontWeight.w400)),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 3,
                      child: Text(episodeLabel,
                          textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(physicianLabel,
                          textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(p.primaryDiagnosis ?? '—',
                          textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(p.insurance ?? '—',
                          textAlign: TextAlign.center,
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400)),
                    ),
                    _AuthBadge(patient: p),

                    // ToDO Api integration and funtionality remaning
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
  }

  @override
  Widget build(BuildContext context) {
    // ── context.read only — this build() does not subscribe to
    // FilterDrawerProvider, so notifyListeners() (open/close filter, saved
    // insurances) does NOT rerun this whole method. Only the
    // AnimatedBuilder-wrapped widgets below react. ───────────────────────
    final filterProvider = context.read<FilterDrawerProvider>();

    return Stack(
      children: [
        // ── Main content ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
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

                        // ── Search & Filter row — static, never rebuilds ────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CustomSearchFieldSM(
                                  width: 400,
                                  hintText: "Name",
                                  searchController: _searchController,
                                  onPressed: _controller.resetPageForSearch,
                                ),
                                const SizedBox(width: 25),
                                ReloadIconButton(onTap: _onReloadTap),
                                ///dont delete filter code
                                // const SizedBox(width: 20),

                                // InkWell(
                                //   highlightColor: Colors.transparent,
                                //   splashColor:    Colors.transparent,
                                //   hoverColor:     Colors.transparent,
                                //   focusColor:     Colors.transparent,
                                //   onTap: () =>
                                //       context.read<FilterDrawerProvider>().toggleFilter(),
                                //   child: Image.asset(
                                //     "images/sm/sm_refferal/filter_icon.png",
                                //     height: AppSize.s18,
                                //     width:  AppSize.s16,
                                //   ),
                                // ),
                              ],
                            ),
                            CustomDropdown(
                              items: const [
                                'Sort By',
                                'Admitted',
                                'Discharged',
                                'Transferred',
                                'Resumption',
                                'Recertified',
                                'Pre-Recert',
                              ],
                              initialValue: 'Sort By',
                              onChanged: (value) =>
                                  _controller.setFilter(context, value),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSize.s10),

                        // ── Table header — static ────────────────────────
                        _buildTableHeader(),

                        const SizedBox(height: AppSize.s10),

                        // ── List body — ONLY this rebuilds on
                        // reload/filter/search/saved-insurance changes ─────
                        Expanded(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_controller, filterProvider]),
                            builder: (context, _) {
                              if (_controller.isLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final patients = _filteredPatients(filterProvider);

                              if (patients.isNotEmpty) {
                                final int totalPages =
                                (patients.length / _controller.itemsPerPage).ceil();
                                if (_controller.currentPage > totalPages) {
                                  _controller.currentPage = totalPages;
                                }
                              } else {
                                _controller.currentPage = 1;
                              }

                              final paginatedPatients = patients
                                  .skip((_controller.currentPage - 1) *
                                  _controller.itemsPerPage)
                                  .take(_controller.itemsPerPage)
                                  .toList();

                              if (patients.isEmpty) {
                                return Center(
                                  child: Text('No patients found!',
                                      style: AllNoDataAvailable.customTextStyle(context)),
                                );
                              }

                              return ScrollConfiguration(
                                behavior:
                                const ScrollBehavior().copyWith(scrollbars: false),
                                child: ListView.builder(
                                  itemCount: paginatedPatients.length,
                                  itemBuilder: (context, index) =>
                                      _buildPatientRow(context, paginatedPatients[index]),
                                ),
                              );
                            },
                          ),
                        ),

                        // ── Pagination — same merged listenable ─────────────
                        AnimatedBuilder(
                          animation: Listenable.merge([_controller, filterProvider]),
                          builder: (context, _) {
                            if (_controller.isLoading) return const SizedBox.shrink();
                            final patients = _filteredPatients(filterProvider);
                            if (patients.isEmpty) return const SizedBox.shrink();
                            final totalPages =
                            (patients.length / _controller.itemsPerPage).ceil();
                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                PaginationControlsWidget(
                                  currentPage: _controller.currentPage,
                                  items: patients,
                                  itemsPerPage: _controller.itemsPerPage,
                                  onPreviousPagePressed: _controller.previousPage,
                                  onPageNumberPressed: _controller.setPage,
                                  onNextPagePressed: () =>
                                      _controller.nextPage(totalPages),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ],
                    ), // Column
                  ), // SizedBox
                ), // Padding
              ), // SingleChildScrollView
            ); // CustomScrollbar
          }), // LayoutBuilder
        ),

        // ── Barrier — close on outside tap. Only reacts to filterProvider ───
        AnimatedBuilder(
          animation: filterProvider,
          builder: (context, _) {
            if (!filterProvider.isFilterOpen) return const SizedBox.shrink();
            return Positioned.fill(
              child: GestureDetector(
                onTap: () => filterProvider.closeFilter(),
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            );
          },
        ),

        // ── Filter panel — only reacts to filterProvider ─────────────────
        AnimatedBuilder(
          animation: filterProvider,
          builder: (context, _) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: filterProvider.isFilterOpen ? 0 : -320,
              top: 0,
              bottom: 0,
              width: 300,
              child: EMRFilterDrawer(
                onClose: () => filterProvider.closeFilter(),
              ),
            );
          },
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
    if (_overlay != null) {
      _close();
      return;
    }

    final box = _key.currentContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

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
            top: offset.dy + size.height + 6,
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
                          horizontal: AppPadding.p12, vertical: AppPadding.p4),
                      decoration: BoxDecoration(
                        color: ColorManager.blueprime,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Auth Status',
                            style: PopupBlueBarText.customTextStyle(context),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            onTap: _close,
                            child: Icon(Icons.close, color: ColorManager.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p12, vertical: AppPadding.p10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _PopupRow(
                            label: '# of Auth Remaining:',
                            value: widget.patient.authStatus?.authRemaining?.isNotEmpty ==
                                true
                                ? widget.patient.authStatus!.authRemaining!
                                : '—',
                          ),
                          const SizedBox(height: AppSizeConst.A20),
                          _PopupRow(
                            label: 'Auth Expiration Date:',
                            value: widget.patient.authStatus?.lastChecked?.isNotEmpty ==
                                true
                                ? widget.patient.authStatus!.lastChecked!
                                : '—',
                          ),
                          const SizedBox(height: AppSize.s10),
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
        margin: const EdgeInsets.only(right: AppPadding.p30, left: AppPadding.p30),
        padding:
        const EdgeInsets.symmetric(horizontal: AppPadding.p6, vertical: AppPadding.p2),
        decoration: BoxDecoration(
          color: ColorManager.SMFBlue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'A',
            style: GeneralSettingTextStyle.customTextStyle(context).copyWith(
              fontSize: FontSize.s10,
              color: ColorManager.blueprime,
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
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.mediumgrey)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.mediumgrey)),
        ),
      ],
    );
  }
}



///