import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/qa_coordinator_manager/qa_mytask_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/reload_button/reload_button_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/my_task/patient_form_myTask_data.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/form_builder_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_my_task_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/const_filter_task_dropdown.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/listTileQa_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/list_tile_qa_correction.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/common_widgets/qa_list_head.dart';

// ── Controller — owns everything the list/dropdown/chat panel needs.
// Calling notifyListeners() here only rebuilds the AnimatedBuilder-wrapped
// sections below, NOT the whole QaSendCorrection screen. ─────────────────────
class _QaSendCorrectionController extends ChangeNotifier {
  bool isLoading = false;
  bool initialized = false;

  List<PatientFormTask> patientFormList = [];
  List<PatientFormTask> filteredList = [];

  List<PatientForm> allForms = [];
  List<String> formNames = [];
  List<String> selectedFormNames = [];
  String selectedFormId = '';

  PatientFormTask? chatItem;
  bool isChatVisible = false;

  int currentPage = 1;
  final int itemsPerPage = 10;

  List<PatientFormTask> get paginatedList {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filteredList.length);
    return filteredList.sublist(start, end);
  }

  Future<void> loadAllForms(BuildContext context) async {
    final forms = await FormBuilderManager().getAllFormsData(context);
    allForms = forms;
    formNames =
        forms.map((f) => f.formName ?? '').where((n) => n.isNotEmpty).toList();
    notifyListeners();
  }

  void setFormFilter(
      BuildContext context,
      List<String> selected, {
        required TextEditingController searchController,
        required QaMyTaskProvider qaProvider,
      }) {
    selectedFormNames = selected;
    if (selected.isEmpty) {
      selectedFormId = '';
    } else {
      final matched = allForms.firstWhere(
            (f) => f.formName == selected.first,
        orElse: () =>
            PatientForm(formID: 0, formName: '', fillStatus: '', subForms: []),
      );
      selectedFormId = matched.formID.toString();
    }
    loadTasks(context, searchController: searchController, qaProvider: qaProvider);
  }

  Future<void> loadTasks(
      BuildContext context, {
        required TextEditingController searchController,
        required QaMyTaskProvider qaProvider,
      }) async {
    isLoading = true;
    notifyListeners();

    final result = await getPatientFormMyTaskList(
      context: context,
      searchByText: searchController.text,
      tab: 'sent_for_correction',
      page: 1,
      limit: 99999,
      formId: selectedFormId,
    );

    patientFormList = result.data ?? [];
    isLoading = false;
    initialized = true;
    applyFilters(searchController: searchController, qaProvider: qaProvider);
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw.trim() == '-') return null;
    try {
      final parts = raw.trim().split('/');
      if (parts.length != 3) return null;
      return DateTime(
          int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  void applyFilters({
    required TextEditingController searchController,
    required QaMyTaskProvider qaProvider,
  }) {
    if (!initialized) return;
    final query = searchController.text.trim().toLowerCase();

    filteredList = patientFormList.where((item) {
      final matchesSearch = query.isEmpty ||
          item.patient.name.toLowerCase().contains(query) ||
          item.patient.mrn.toString().contains(query) ||
          item.formType.toLowerCase().contains(query) ||
          item.formDate.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query) ||
          item.clinician.name.toLowerCase().contains(query) ||
          (item.codingStaff?.name.toLowerCase().contains(query) ?? false) ||
          (item.patient.primaryInsurance?.toLowerCase().contains(query) ??
              false);

      final matchesForm = qaProvider.savedFormIds.isEmpty ||
          qaProvider.savedFormIds.contains(allForms
              .where((f) => f.formName == item.formType)
              .map((f) => f.formID)
              .firstOrNull ??
              -1);

      bool matchesFromDate = true;
      if (qaProvider.savedFromDate != null) {
        final filterDate = DateTime(qaProvider.savedFromDate!.year,
            qaProvider.savedFromDate!.month, qaProvider.savedFromDate!.day);
        final parsedFormDate = _parseDate(item.formDate);
        matchesFromDate = parsedFormDate != null && parsedFormDate == filterDate;
      }

      bool matchesDeadline = true;
      if (qaProvider.savedDeadlineDate != null) {
        final filterDeadline = DateTime(
            qaProvider.savedDeadlineDate!.year,
            qaProvider.savedDeadlineDate!.month,
            qaProvider.savedDeadlineDate!.day);
        final parsedDeadline = _parseDate(item.timelyFilingDeadline);
        matchesDeadline =
            parsedDeadline != null && parsedDeadline == filterDeadline;
      }

      final matchesPatient = qaProvider.savedPatientIds.isEmpty ||
          qaProvider.savedPatientIds.contains(item.patient.ptId);
      final matchesClinician = qaProvider.savedClinicianIds.isEmpty ||
          qaProvider.savedClinicianIds.contains(item.clinician.staffId);
      final matchesCodingStaff = qaProvider.savedCoderIds.isEmpty ||
          qaProvider.savedCoderIds.contains(item.codingStaff?.staffId);
      final matchesInsurance = qaProvider.savedInsuranceNames.isEmpty ||
          qaProvider.savedInsuranceNames
              .contains(item.patient.primaryInsurance ?? '');

      return matchesSearch &&
          matchesForm &&
          matchesFromDate &&
          matchesDeadline &&
          matchesPatient &&
          matchesClinician &&
          matchesCodingStaff &&
          matchesInsurance;
    }).toList();

    final totalPages =
    (filteredList.length / itemsPerPage).ceil().clamp(1, 999999);
    if (currentPage > totalPages) currentPage = totalPages;

    notifyListeners();
  }

  // - Clicking a NEW item -> always opens the chat with that item.
  // - Clicking the SAME item again -> closes the chat.
  void toggleChat(PatientFormTask item) {
    final isSameItem = chatItem?.clinician.staffId == item.clinician.staffId;
    if (isSameItem && isChatVisible) {
      isChatVisible = false;
    } else {
      chatItem = item;
      isChatVisible = true;
    }
    notifyListeners();
  }

  void clearChat() {
    isChatVisible = false;
    notifyListeners();
  }

  void previousPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    final totalPages = (filteredList.length / itemsPerPage).ceil();
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }
}

class QaSendCorrection extends StatefulWidget {
  const QaSendCorrection({super.key});

  @override
  State<QaSendCorrection> createState() => _QaSendCorrectionState();
}

class _QaSendCorrectionState extends State<QaSendCorrection> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  final _QaSendCorrectionController _controller = _QaSendCorrectionController();

  // Saved reference — read once, used safely in dispose()
  QaMyTaskProvider? _qaMyTaskProvider;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _qaMyTaskProvider = context.read<QaMyTaskProvider>(); // saved here
      _qaMyTaskProvider!.addListener(_onProviderChanged);
      _controller.loadAllForms(context);
      _controller.loadTasks(context,
          searchController: searchController, qaProvider: _qaMyTaskProvider!);
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _horizontalScrollController.dispose();
    _qaMyTaskProvider?.removeListener(_onProviderChanged); // no context.read here
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_qaMyTaskProvider == null) return;
    _controller.applyFilters(
        searchController: searchController, qaProvider: _qaMyTaskProvider!);
  }

  void _onProviderChanged() {
    if (_qaMyTaskProvider == null) return;
    _controller.applyFilters(
        searchController: searchController, qaProvider: _qaMyTaskProvider!);
  }

  Future<void> _onReloadTap() async {
    if (_qaMyTaskProvider == null) return;
    await _controller.loadTasks(context,
        searchController: searchController, qaProvider: _qaMyTaskProvider!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Padding(
        padding: const EdgeInsets.only(
            right: AppSizeConst.A40, left: AppSizeConst.A40, top: 10),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
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
                              // ── Search + filter + reload — static, never
                              // rebuilds on list/filter/chat changes ────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomSearchFieldSM(
                                        searchController: searchController,
                                        width: 350,
                                        onPressed: _onSearchChanged,
                                      ),
                                      const SizedBox(width: AppSize.s20),
                                      IconButton(
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: () => context
                                            .read<QaMyTaskProvider>()
                                            .toggleFilter(),
                                        icon: Image.asset(
                                          "images/sm/sm_refferal/filter_icon.png",
                                          height: AppSize.s18,
                                          width: AppSize.s16,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s12),
                                      ReloadIconButton(onTap: _onReloadTap),
                                    ],
                                  ),
                                  // ── Task filter dropdown — only this
                                  // rebuilds when form list/selection changes ─
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, _) {
                                      return ConstMultiSelectDropdown(
                                        width: 300,
                                        label: 'Tasks',
                                        items: _controller.formNames,
                                        selectedItems:
                                        _controller.selectedFormNames,
                                        onChanged: (selected) =>
                                            _controller.setFormFilter(
                                              context,
                                              selected,
                                              searchController: searchController,
                                              qaProvider: _qaMyTaskProvider ??
                                                  context.read<QaMyTaskProvider>(),
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizeConst.A20),
                               QaListHeadCorrection(),
                              // ── List body — ONLY this rebuilds on
                              // reload/search/filter/provider changes ───────
                              Expanded(
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, _) {
                                    if (_controller.isLoading) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                            color: ColorManager.blueprime),
                                      );
                                    }
                                    if (_controller.filteredList.isEmpty) {
                                      return Center(
                                        child: Text(
                                          "No send for correction data available!",
                                          style: AllNoDataAvailable
                                              .customTextStyle(context),
                                        ),
                                      );
                                    }
                                    return ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(scrollbars: false),
                                      child: ListView.builder(
                                        itemCount:
                                        _controller.paginatedList.length,
                                        itemBuilder: (context, index) {
                                          final item =
                                          _controller.paginatedList[index];
                                          return ListTileQaWidgetCorrection(
                                            item: item,
                                            patientImgUrl:
                                            item.patient.ptImgUrl,
                                            onCallClick: () =>
                                                _controller.toggleChat(item),
                                            onRefresh: _onReloadTap,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })),
                // ── Pagination — only this rebuilds on list/page changes ────
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    if (_controller.isLoading || _controller.filteredList.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: AppSize.s10),
                        PaginationControlsWidget(
                          currentPage: _controller.currentPage,
                          items: _controller.filteredList,
                          itemsPerPage: _controller.itemsPerPage,
                          onPreviousPagePressed: _controller.previousPage,
                          onPageNumberPressed: _controller.goToPage,
                          onNextPagePressed: _controller.nextPage,
                        ),
                        const SizedBox(height: AppSize.s10),
                      ],
                    );
                  },
                ),
              ],
            ),
            // ── Chat overlay — only this rebuilds on chat toggle ────────────
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (!_controller.isChatVisible) return const SizedBox.shrink();
                return Positioned.fill(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: _controller.clearChat,
                    child: Container(color: Colors.transparent),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: _controller.isChatVisible ? 0 : -500,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 450,
                    width: 500,
                    // Key forces Flutter to rebuild ChatBotContainer from
                    // scratch (re-running initState) whenever the receiver
                    // changes, instead of reusing the old widget instance/state.
                    child: ChatBotContainer(
                      key: ValueKey(_controller.chatItem?.clinician.staffId ?? 0),
                      onClose: _controller.clearChat,
                      receiverEmpId:
                      _controller.chatItem?.clinician.staffId ?? 0,
                      receiverName: _controller.chatItem?.clinician.name ?? '',
                      receiverImageUrl:
                      _controller.chatItem?.clinician.imgUrl ?? '',
                      receiverAbbreviation:
                      _controller.chatItem?.clinician.abbreviation ?? '',
                      receiverColor:
                      _controller.chatItem?.clinician.colorCode ??
                          '#000000',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}