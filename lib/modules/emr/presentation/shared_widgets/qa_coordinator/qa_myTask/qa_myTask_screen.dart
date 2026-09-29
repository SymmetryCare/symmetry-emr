import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/pending_review.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/qa_completed.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/qa_corrected.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_myTask/qa_tab_bar_screens/qa_send_correction.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/insurance_filter_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/qa_coordinator_manager/qa_coader_patient_filter_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/qa_coader_patient_filter_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/intake_main_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_dashboard_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_my_task_provider.dart' hide QaDashboardProvider;
import 'package:symmetry_emr/modules/emr/data/api/managers/qa_coordinator_manager/qa_coader_filter_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/qa_coader_filter_data.dart';

class QaMytaskScreen extends StatefulWidget {
  const QaMytaskScreen({super.key});

  @override
  State<QaMytaskScreen> createState() => _QaMytaskScreenState();
}

class _QaMytaskScreenState extends State<QaMytaskScreen> {
  List<FormData>                       _allForms      = [];
  List<PatientFormStaffData>           _allClinicians = [];
  List<PatientFormStaffData>           _allCoders     = [];
  List<SupplyOrderPatientDropdownData> _allPatients   = [];
  List<DistinctInsuranceProviderData>  _allInsurances = <DistinctInsuranceProviderData>[];

  String _formSearch      = '';
  String _clinicianSearch = '';
  String _coderSearch     = '';
  String _patientSearch   = '';
  String _insuranceSearch = '';

  List<FormData> get _visibleForms => _formSearch.isEmpty
      ? _allForms
      : _allForms
      .where((f) => f.formName.toLowerCase().contains(_formSearch.toLowerCase()))
      .toList();

  List<PatientFormStaffData> get _visibleClinicians => _clinicianSearch.isEmpty
      ? _allClinicians
      : _allClinicians
      .where((c) => c.name.toLowerCase().contains(_clinicianSearch.toLowerCase()))
      .toList();

  List<PatientFormStaffData> get _visibleCoders => _coderSearch.isEmpty
      ? _allCoders
      : _allCoders
      .where((c) => c.name.toLowerCase().contains(_coderSearch.toLowerCase()))
      .toList();

  List<SupplyOrderPatientDropdownData> get _visiblePatients => _patientSearch.isEmpty
      ? _allPatients
      : _allPatients
      .where((p) => p.name.toLowerCase().contains(_patientSearch.toLowerCase()))
      .toList();

  List<DistinctInsuranceProviderData> get _visibleInsurances => _insuranceSearch.isEmpty
      ? _allInsurances
      : _allInsurances
      .where((i) => i.providerName.toLowerCase().contains(_insuranceSearch.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFilterData());
  }

  Future<void> _loadFilterData() async {
    final forms      = await getFormList(context);
    final clinicians = await getPatientFormStaff(context, type: 'clinician');
    final coders     = await getPatientFormStaff(context, type: 'coder');
    final patients   = await getSupplyOrderPatientDropdown(context, 'qa-coordinator');
    final insurances = await getDistinctInsuranceProviders(context);
    if (!mounted) return;
    setState(() {
      _allForms      = forms;
      _allClinicians = clinicians.data ?? [];
      _allCoders     = coders.data ?? [];
      _allPatients   = patients;
      _allInsurances = List<DistinctInsuranceProviderData>.from(insurances);
    });
  }

  Widget _buildActiveTab(int index) {
    switch (index) {
      case 0: return const QaPendingReview();
      case 1: return const QaCorrected();
      case 2: return const QaSendCorrection();
      case 3: return const QaCompleted();
      default: return const QaPendingReview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider    = context.watch<QaDashboardProvider>();
    final filterProvider = context.watch<QaMyTaskProvider>();

    return Stack(
        children: [
          Column(
            children: [
              // ── Tab Bar ─────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: AppPadding.p8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SMTabbar(
                      width: 100,
                      onTap: (_) {
                        context.read<QaMyTaskProvider>().clearAll();
                        context.read<QaDashboardProvider>().selectButton(0);
                      },
                      index: 0,
                      grpIndex: tabProvider.selectedIndex,
                      heading: "Pending Review",
                    ),
                    SMTabbar(
                      width: 100,
                      onTap: (_) {
                        context.read<QaMyTaskProvider>().clearAll();
                        context.read<QaDashboardProvider>().selectButton(1);
                      },
                      index: 1,
                      grpIndex: tabProvider.selectedIndex,
                      heading: "Corrected",
                    ),
                    SMTabbar(
                      width: 150,
                      onTap: (_) {
                        context.read<QaMyTaskProvider>().clearAll();
                        context.read<QaDashboardProvider>().selectButton(2);
                      },
                      index: 2,
                      grpIndex: tabProvider.selectedIndex,
                      heading: "Sent For Correction",
                    ),
                    SMTabbar(
                      width: 100,
                      onTap: (_) {
                        context.read<QaMyTaskProvider>().clearAll();
                        context.read<QaDashboardProvider>().selectButton(3);
                      },
                      index: 3,
                      grpIndex: tabProvider.selectedIndex,
                      heading: "Completed",
                    ),
                  ],
                ),
              ),

              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(tabProvider.selectedIndex),
                  child: _buildActiveTab(tabProvider.selectedIndex),
                ),
              ),
            ],
          ),

          // ── Filter barrier ───────────────────────────────────────────────
          if (filterProvider.isFilterOpen)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: filterProvider.toggleFilter,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  color: Colors.black.withOpacity(0.0),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

          // ── Filter panel ─────────────────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: filterProvider.isFilterOpen ? 0 : -320,
            top: 10,
            bottom: 0,
            child: Container(
              width: 250,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Header ─────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: filterProvider.toggleFilter,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.menu_open),
                                      const SizedBox(width: AppSize.s10),
                                      Text(
                                        "Filters",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.mediumgrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    filterProvider.clearAll();
                                    setState(() {
                                      _formSearch      = '';
                                      _clinicianSearch = '';
                                      _coderSearch     = '';
                                      _patientSearch   = '';
                                      _insuranceSearch = '';
                                    });
                                  },
                                  child: const Text("CLEAR ALL"),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),

                          // ── Form Name ──────────────────────────────────
                          InkWell(
                            onTap: filterProvider.toggleFromType,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Form Name",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.fromTypeVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.fromTypeVisible) ...[
                            TextFormField(
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: CustomTextStylesCommon.commonStyle(
                                  fontSize: 12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const SizedBox(
                                  height: 20, width: 20,
                                  child: Icon(Icons.search, size: 16,
                                      color: Colors.grey),
                                ),
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                              ),
                              onChanged: (val) =>
                                  setState(() => _formSearch = val),
                            ),
                            ..._visibleForms.map((form) {
                              final isSelected = filterProvider.selectedFormIds
                                  .contains(form.formId);
                              return Row(
                                children: [
                                  Checkbox(
                                    splashRadius: 0,
                                    activeColor: ColorManager.blueprime,
                                    value: isSelected,
                                    onChanged: (checked) {
                                      final ids = List<int>.from(
                                          filterProvider.selectedFormIds);
                                      final names = List<String>.from(
                                          filterProvider.selectedFormNames);
                                      if (checked == true) {
                                        ids.add(form.formId);
                                        names.add(form.formName);
                                      } else {
                                        ids.remove(form.formId);
                                        names.remove(form.formName);
                                      }
                                      filterProvider.setSelectedForms(ids, names);
                                    },
                                  ),
                                  Flexible(
                                    child: Text(
                                      form.formName,
                                      style: DocDefineTableDataID.customTextStyle(
                                          context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                          const Divider(),

                          // ── From Date ──────────────────────────────────
                          InkWell(
                            onTap: filterProvider.toggleFromDate,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("From Date",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.fromDateVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.fromDateVisible)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p10,
                                  vertical: AppPadding.p8),
                              child: InkWell(
                                onTap: () async {
                                  final picked = await CalendarDialogHelper.show(
                                    context: context,
                                    selectedDate:
                                    filterProvider.fromDate ?? DateTime.now(),
                                  );
                                  if (picked != null)
                                    filterProvider.setFromDate(picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p10,
                                      vertical: AppPadding.p12),
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14,
                                          color: ColorManager.blueprime),
                                      const SizedBox(width: 8),
                                      Text(
                                        filterProvider.fromDate != null
                                            ? CalendarDialogHelper.fmt(
                                            filterProvider.fromDate!)
                                            : 'Select Date',
                                        style: CustomTextStylesCommon.commonStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: filterProvider.fromDate != null
                                              ? ColorManager.mediumgrey
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const Divider(),

                          // ── Patient Name ───────────────────────────────
                          InkWell(
                            onTap: filterProvider.togglePatientName,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Patient Name",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.patientNameVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.patientNameVisible) ...[
                            TextFormField(
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: CustomTextStylesCommon.commonStyle(
                                  fontSize: 12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const SizedBox(
                                  height: 20, width: 20,
                                  child: Icon(Icons.search, size: 16,
                                      color: Colors.grey),
                                ),
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                              ),
                              onChanged: (val) =>
                                  setState(() => _patientSearch = val),
                            ),
                            ..._visiblePatients.map((patient) {
                              final isSelected = filterProvider.selectedPatientIds
                                  .contains(patient.patientId);
                              return Row(
                                children: [
                                  Checkbox(
                                    splashRadius: 0,
                                    activeColor: ColorManager.blueprime,
                                    value: isSelected,
                                    onChanged: (checked) {
                                      final ids = List<int>.from(
                                          filterProvider.selectedPatientIds);
                                      final names = List<String>.from(
                                          filterProvider.selectedPatientNames);
                                      if (checked == true) {
                                        ids.add(patient.patientId);
                                        names.add(patient.name);
                                      } else {
                                        ids.remove(patient.patientId);
                                        names.remove(patient.name);
                                      }
                                      filterProvider.setSelectedPatients(
                                          ids, names);
                                    },
                                  ),
                                  Flexible(
                                    child: Text(
                                      patient.name,
                                      style: DocDefineTableDataID.customTextStyle(
                                          context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                          const Divider(),

                          // ── Clinician Name ─────────────────────────────
                          InkWell(
                            onTap: filterProvider.toggleClinicalName,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Clinician Name",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.clinitianNameVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.clinitianNameVisible) ...[
                            TextFormField(
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: CustomTextStylesCommon.commonStyle(
                                  fontSize: 12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const SizedBox(
                                  height: 20, width: 20,
                                  child: Icon(Icons.search, size: 16,
                                      color: Colors.grey),
                                ),
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                              ),
                              onChanged: (val) =>
                                  setState(() => _clinicianSearch = val),
                            ),
                            ..._visibleClinicians.map((clinician) {
                              final isSelected = filterProvider.selectedClinicianIds
                                  .contains(clinician.employeeId);
                              return Row(
                                children: [
                                  Checkbox(
                                    splashRadius: 0,
                                    activeColor: ColorManager.blueprime,
                                    value: isSelected,
                                    onChanged: (checked) {
                                      final ids = List<int>.from(
                                          filterProvider.selectedClinicianIds);
                                      final names = List<String>.from(
                                          filterProvider.selectedClinicianNames);
                                      if (checked == true) {
                                        ids.add(clinician.employeeId);
                                        names.add(clinician.name);
                                      } else {
                                        ids.remove(clinician.employeeId);
                                        names.remove(clinician.name);
                                      }
                                      filterProvider.setSelectedClinicians(
                                          ids, names);
                                    },
                                  ),
                                  Flexible(
                                    child: Text(
                                      clinician.name,
                                      style: DocDefineTableDataID.customTextStyle(
                                          context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                          const Divider(),

                          // ── Primary Insurance (API) ────────────────────
                          InkWell(
                            onTap: filterProvider.togglePrimaryInsurance,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Primary Insurance",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.primaryInsuranceVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.primaryInsuranceVisible) ...[
                            TextFormField(
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: CustomTextStylesCommon.commonStyle(
                                  fontSize: 12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const SizedBox(
                                  height: 20, width: 20,
                                  child: Icon(Icons.search, size: 16,
                                      color: Colors.grey),
                                ),
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                              ),
                              onChanged: (val) =>
                                  setState(() => _insuranceSearch = val),
                            ),
                            if (_allInsurances.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: ColorManager.blueprime,),
                                  ),
                                ),
                              )
                            else
                              ..._visibleInsurances
                                  .map((DistinctInsuranceProviderData ins) {
                                final isSelected = filterProvider
                                    .selectedInsuranceNames
                                    .contains(ins.providerName);
                                return Row(
                                  children: [
                                    Checkbox(
                                      splashRadius: 0,
                                      activeColor: ColorManager.blueprime,
                                      value: isSelected,
                                      onChanged: (checked) {
                                        final names = List<String>.from(
                                            filterProvider.selectedInsuranceNames);
                                        if (checked == true) {
                                          names.add(ins.providerName);
                                        } else {
                                          names.remove(ins.providerName);
                                        }
                                        filterProvider
                                            .setSelectedInsurances(names);
                                      },
                                    ),
                                    Flexible(
                                      child: Text(
                                        ins.providerName,
                                        style: DocDefineTableDataID.customTextStyle(
                                            context),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          ],
                          const Divider(),

                          // ── Timely Filing Deadline ─────────────────────
                          InkWell(
                            onTap: filterProvider.toggleDeadLine,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Timely Filing Deadline",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.deadLineVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.deadLineVisible)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p10,
                                  vertical: AppPadding.p8),
                              child: InkWell(
                                onTap: () async {
                                  final picked = await CalendarDialogHelper.show(
                                    context: context,
                                    selectedDate: filterProvider.deadlineDate ??
                                        DateTime.now(),
                                  );
                                  if (picked != null)
                                    filterProvider.setDeadlineDate(picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p10,
                                      vertical: AppPadding.p12),
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 14,
                                          color: ColorManager.blueprime),
                                      const SizedBox(width: 8),
                                      Text(
                                        filterProvider.deadlineDate != null
                                            ? CalendarDialogHelper.fmt(
                                            filterProvider.deadlineDate!)
                                            : 'Select Date',
                                        style: CustomTextStylesCommon.commonStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color:
                                          filterProvider.deadlineDate != null
                                              ? ColorManager.mediumgrey
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const Divider(),

                          // ── Coding Staff ───────────────────────────────
                          InkWell(
                            onTap: filterProvider.toggleCodingStaff,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p10, right: AppPadding.p13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Coding Staff",
                                      style: Filterhead.customTextStyle(context)),
                                  Icon(
                                    filterProvider.codingStaffVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filterProvider.codingStaffVisible) ...[
                            TextFormField(
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: CustomTextStylesCommon.commonStyle(
                                  fontSize: 12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const SizedBox(
                                  height: 20, width: 20,
                                  child: Icon(Icons.search, size: 16,
                                      color: Colors.grey),
                                ),
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                              ),
                              onChanged: (val) =>
                                  setState(() => _coderSearch = val),
                            ),
                            ..._visibleCoders.map((coder) {
                              final isSelected = filterProvider.selectedCoderIds
                                  .contains(coder.employeeId);
                              return Row(
                                children: [
                                  Checkbox(
                                    splashRadius: 0,
                                    activeColor: ColorManager.blueprime,
                                    value: isSelected,
                                    onChanged: (checked) {
                                      final ids = List<int>.from(
                                          filterProvider.selectedCoderIds);
                                      final names = List<String>.from(
                                          filterProvider.selectedCoderNames);
                                      if (checked == true) {
                                        ids.add(coder.employeeId);
                                        names.add(coder.name);
                                      } else {
                                        ids.remove(coder.employeeId);
                                        names.remove(coder.name);
                                      }
                                      filterProvider.setSelectedCoders(ids, names);
                                    },
                                  ),
                                  Flexible(
                                    child: Text(
                                      coder.name,
                                      style: DocDefineTableDataID.customTextStyle(
                                          context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                          const Divider(),
                        ],
                      ),
                    ),
                  ),

                  // ── Save button pinned at bottom ───────────────────────
                  const Divider(height: 1),
                  Padding(
                    padding:
                    const EdgeInsets.only(bottom: 15, top: 10, right: 15),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () {
                          filterProvider.onFilterSaved();
                          filterProvider.toggleFilter();
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: ColorManager.blueprime,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: ColorManager.blueprime,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }
}