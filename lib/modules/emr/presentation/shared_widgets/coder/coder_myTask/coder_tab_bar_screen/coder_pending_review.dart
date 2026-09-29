import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/reload_button/reload_button_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/qa_coordinator_manager/qa_mytask_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/my_task/patient_form_myTask_data.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/form_builder_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/const_filter_task_dropdown.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_provider/coder_myTask_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_tab_bar_screen/coder_common_widgets/coder_listTile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_tab_bar_screen/coder_common_widgets/coder_list_head.dart';

class CoderPendingReview extends StatefulWidget {
  const CoderPendingReview({super.key});

  @override
  State<CoderPendingReview> createState() => _CoderPendingReviewState();
}

class _CoderPendingReviewState extends State<CoderPendingReview> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isLoading     = false;
  bool _isChatVisible = false;
  bool _initialized   = false;

  List<PatientFormTask> _patientFormList = [];
  List<PatientFormTask> _filteredList    = [];

  List<PatientForm> _allForms          = [];
  List<String>      _formNames         = [];
  List<String>      _selectedFormNames = [];
  String            _selectedFormId    = '';

  PatientFormTask? _chatItem;

  // ── Pagination ─────────────────────────────────────────────────────────────
  int _currentPage        = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_applyFilters);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllForms();
      _getPatientFormMyTaskList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_applyFilters);
    searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllForms() async {
    final forms = await FormBuilderManager().getAllFormsData(context);
    setState(() {
      _allForms  = forms;
      _formNames = forms.map((f) => f.formName ?? '').where((n) => n.isNotEmpty).toList();
    });
  }

  void _onFormFilterChanged(List<String> selected) {
    setState(() => _selectedFormNames = selected);
    if (selected.isEmpty) {
      _selectedFormId = '';
    } else {
      final matched = _allForms.firstWhere(
            (f) => f.formName == selected.first,
        orElse: () => PatientForm(formID: 0, formName: '', fillStatus: '', subForms: []),
      );
      _selectedFormId = matched.formID.toString();
    }
    _getPatientFormMyTaskList();
  }
  Future<void> _getPatientFormMyTaskList() async {
    setState(() => _isLoading = true);
    final result = await getPatientFormMyTaskList(
      context:      context,
      searchByText: searchController.text,

      tab:          'pending',
      page:         1,
      limit:        99999,
      formId:       _selectedFormId,
    );
    setState(() {
      _patientFormList = result.data;   // ← no ?? [] needed, non-nullable
      _isLoading       = false;
      _initialized     = true;
    });
    _applyFilters();
  }

  // Reload button — re-hits the same GET API as the initial load,
  // keeping the current search text and task/form filter.
  Future<void> _onReload() async {
    await _getPatientFormMyTaskList();
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw.trim() == '-') return null;
    try {
      final parts = raw.trim().split('/');
      if (parts.length != 3) return null;
      return DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  void _applyFilters() {
    if (!mounted || !_initialized) return;
    final provider = context.read<CoderMyTaskProvider>();
    final query    = searchController.text.trim().toLowerCase();

    setState(() {
      _filteredList = _patientFormList.where((item) {
        final matchesSearch = query.isEmpty ||
            item.patient.name.toLowerCase().contains(query) ||
            item.patient.mrn.toString().contains(query) ||
            item.formType.toLowerCase().contains(query) ||
            item.formDate.toLowerCase().contains(query) ||
            item.status.toLowerCase().contains(query) ||
            item.clinician.name.toLowerCase().contains(query) ||
            (item.codingStaff?.name.toLowerCase().contains(query) ?? false) ||
            (item.patient.primaryInsurance?.toLowerCase().contains(query) ?? false);

        final matchesForm = provider.savedFormNames.isEmpty ||
            provider.savedFormNames.contains(item.formType);

        bool matchesFromDate = true;
        if (provider.savedFromDate != null) {
          final filterDate     = DateTime(provider.savedFromDate!.year, provider.savedFromDate!.month, provider.savedFromDate!.day);
          final parsedFormDate = _parseDate(item.formDate);
          matchesFromDate = parsedFormDate != null && parsedFormDate == filterDate;
        }

        bool matchesDeadline = true;
        if (provider.savedDeadlineDate != null) {
          final filterDeadline = DateTime(provider.savedDeadlineDate!.year, provider.savedDeadlineDate!.month, provider.savedDeadlineDate!.day);
          final parsedDeadline = _parseDate(item.timelyFilingDeadline);
          matchesDeadline = parsedDeadline != null && parsedDeadline == filterDeadline;
        }

        final matchesPatient     = provider.savedPatientIds.isEmpty   || provider.savedPatientIds.contains(item.patient.ptId);
        final matchesClinician   = provider.savedClinicianIds.isEmpty  || provider.savedClinicianIds.contains(item.clinician.staffId);
        final matchesCodingStaff = provider.savedCoderIds.isEmpty      || provider.savedCoderIds.contains(item.codingStaff?.staffId);
        final matchesInsurance   = provider.savedInsuranceNames.isEmpty || provider.savedInsuranceNames.contains(item.patient.primaryInsurance ?? '');

        return matchesSearch && matchesForm && matchesFromDate &&
            matchesDeadline && matchesPatient && matchesClinician &&
            matchesCodingStaff && matchesInsurance;
      }).toList();

      final totalPages = (_filteredList.length / _itemsPerPage).ceil().clamp(1, 999999);
      if (_currentPage > totalPages) _currentPage = totalPages;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) _applyFilters();   // ← guard: skip before first load
  }

  void _toggleQaChat(PatientFormTask item) {
    setState(() {
      _chatItem      = item;
      _isChatVisible = !_isChatVisible;
    });
  }

  void _clearChatVisible() => setState(() => _isChatVisible = false);

  // ── Paginated slice ────────────────────────────────────────────────────────
  List<PatientFormTask> get _paginatedList {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end   = (start + _itemsPerPage).clamp(0, _filteredList.length);
    return _filteredList.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CoderMyTaskProvider>();
    return Padding(
      padding: const EdgeInsets.only(right: AppSizeConst.A40, left: AppSizeConst.A40, top: AppPadding.p10),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(child: LayoutBuilder(builder: (context, constraints){
                const double minContentWidth = 1200;
                final double contentWidth = constraints.maxWidth > minContentWidth
                    ? constraints.maxWidth
                    : minContentWidth;
                return CustomScrollbar(
                    controller: _horizontalScrollController,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppPadding.p10),
                        child: SizedBox(
                          width: contentWidth,
                          child: Column(
                            children: [
                              // ── Search + Filter + Task Dropdown ────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomSearchFieldSM(
                                        searchController: searchController,
                                        width: 350,
                                        onPressed: _applyFilters,
                                      ),
                                      const SizedBox(width: AppSize.s25),
                                      IconButton(
                                        hoverColor:     Colors.transparent,
                                        splashColor:    Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: () => context.read<CoderMyTaskProvider>().toggleFilter(),
                                        icon: Image.asset(
                                          "images/sm/sm_refferal/filter_icon.png",
                                          height: AppSize.s18,
                                          width:  AppSize.s16,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s25),
                                      ReloadIconButton(onTap: _onReload),
                                    ],
                                  ),
                                  ConstMultiSelectDropdown(
                                    width:         300,
                                    label:         'Tasks',
                                    items:         _formNames,
                                    selectedItems: _selectedFormNames,
                                    onChanged:     _onFormFilterChanged,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSize.s10),
                              CoderConstListHead(),
                              // ── List body ──────────────────────────────────────────────
                              Expanded(
                                child: _isLoading
                                    ? Center(child: CircularProgressIndicator(color: ColorManager.blueprime,))
                                    : _filteredList.isEmpty
                                    ? Center(child: Text("No pending review data available!",
                                  style: AllNoDataAvailable.customTextStyle(context),))
                                    : ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    itemCount: _paginatedList.length,
                                    itemBuilder: (context, index) => ListTileCoderWidget(
                                      item:          _paginatedList[index],
                                      patientImgUrl: _paginatedList[index].patient.ptImgUrl,
                                      onCallClick:   () => _toggleQaChat(_paginatedList[index]),
                                      onRefresh:     _getPatientFormMyTaskList,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));


              })),
              if (!_isLoading && _filteredList.isNotEmpty) ...[
                const SizedBox(height: AppSize.s10),
                PaginationControlsWidget(
                  currentPage:           _currentPage,
                  items:                 _filteredList,
                  itemsPerPage:          _itemsPerPage,
                  onPreviousPagePressed: () {
                    if (_currentPage > 1) setState(() => _currentPage--);
                  },
                  onPageNumberPressed: (page) {
                    setState(() => _currentPage = page);
                  },
                  onNextPagePressed: () {
                    final totalPages = (_filteredList.length / _itemsPerPage).ceil();
                    if (_currentPage < totalPages) setState(() => _currentPage++);
                  },
                ),
                const SizedBox(height: AppSize.s10),
              ],
            ],
          ),

          // ── Chat barrier ───────────────────────────────────────────────
          if (_isChatVisible)
            Positioned.fill(
              child: InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                onTap: _clearChatVisible,
                child: Container(color: Colors.transparent),
              ),
            ),

          // ── ChatBot overlay ────────────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _isChatVisible ? 0 : -500,
            right:  0,
            child: Container(
              decoration: BoxDecoration(
                color:        const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 450,
              width:  500,
              child: ChatBotContainer(
                onClose:              _clearChatVisible,
                receiverEmpId:        _chatItem?.clinician.staffId      ?? 0,
                receiverName:         _chatItem?.clinician.name         ?? '',
                receiverImageUrl:     _chatItem?.clinician.imgUrl       ?? '',
                receiverAbbreviation: _chatItem?.clinician.abbreviation ?? '',
                receiverColor:        _chatItem?.clinician.colorCode    ?? '#000000',
              ),
            ),
          ),
        ],
      ),
    );
  }
}