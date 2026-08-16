import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';
import 'package:provider/provider.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../app/services/api/managers/clinical_manager_manager/my_task_order_tab_manager.dart';
import '../../../../../../../app/services/token/token_manager.dart';
import '../../../../../../../data/api_data/clinical_manager_data/my_task_order_tab_data.dart';
import '../../../../../../../oasis_form_builder/model/chart_patient_referral_data_model.dart';
import '../../../../../../../oasis_form_builder/model/patient_form_model.dart';
import '../../../../../../../oasis_form_builder/oasis_form_mapper.dart';
import '../../../../../../../oasis_form_builder/services/api/managers/patient_form_manager.dart';
import '../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../emr_dashboard_screen.dart';

class NeedCorrectionPopup extends StatefulWidget {
  const NeedCorrectionPopup({super.key});

  @override
  State<NeedCorrectionPopup> createState() => _NeedCorrectionPopupState();
}

class _NeedCorrectionPopupState extends State<NeedCorrectionPopup> {

  bool _isLoading = true;
  String? _error;
  List<PhysicianOrderData> _items = [];

  int _page       = 1;
  int _totalPages = 1;
  static const int _limit = 20;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading &&
        _page < _totalPages) {
      _fetchData(loadMore: true);
    }
  }

  Future<void> _fetchData({bool loadMore = false}) async {
    if (_isLoading && loadMore) return;

    setState(() {
      _isLoading = true;
      _error     = null;
      if (!loadMore) _page = 1;
    });

    try {
      final result = await getMyTasksList(
        context,
        tab:   'needs_correction',
        page:  loadMore ? _page + 1 : 1,
        limit: _limit,
      );

      final total = result.total ?? 0;

      setState(() {
        if (loadMore) {
          _items.addAll(result.data ?? []);
          _page++;
        } else {
          _items = result.data ?? [];
          _page  = 1;
        }
        _totalPages = (total / _limit).ceil();
        _isLoading  = false;
      });
    } catch (e) {
      setState(() {
        _error     = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onTap({
    required int patientFormId,
    required int chartNo,
    required int patientID,
  }) async {
    final result = await getPatientFormByPatientID(
      context,
      patientFormId: patientFormId,
    );
    String role = await TokenManager.getRole();
    if (result == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OasisFormMapper(
          form: PatientForm(
            formID:     result.formId,
            formName:   result.formName,
            fillStatus: result.status,
            subForms: result.subForms
                .map((e) => PatientSubForm(
              formID:        result.formId,
              subFormID:     e.id,
              subFormName:   e.subFormName,
              patientFormID: result.patientFormId,
              fillStatus:    e.isFilled,
              commentCount:  e.comment_count,
            ))
                .toList(),
          ),
          subForm: PatientSubForm(
            formID:        result.formId,
            subFormID:     result.subForms.isNotEmpty ? result.subForms.first.id : 0,
            subFormName:   result.subForms.isNotEmpty ? result.subForms.first.subFormName : '',
            patientFormID: result.patientFormId,
            fillStatus:    result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
            commentCount:  result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
          ),
          patient: ChartPatientReferral(
            patientId:     patientID,
            firstName:     result.referralData.patientFirstname,
            lastName:      result.referralData.patientLastname,
            contactNumber: result.referralData.patientPhone,
            address:       result.referralData.patientAddress,
            imageUrl:      result.referralData.patientImageUrl,
            gender:        Gender(genderID: 1, genderName: 'Male'),
            dateOfBirth:   DateTime.tryParse(result.referralData.patientDob ?? '') ?? DateTime.now(),
            chartNo:       result.referralData.patientChartNo,
            episodes:      [],
          ),
          userRole:     role,
          appBarString: 'EMR - Clinical',
          formStatus:   "needs_correction",
        ),
      ),
    );
    if (!mounted) return;
    _fetchData();
  }

  // ── uses savedFormNames / savedInsurances (committed on Save) ─────────────
  List<PhysicianOrderData> _applyFilters(
      List<PhysicianOrderData> items,
      FilterDrawerProvider provider,
      ) {
    return items.where((item) {
      final formMatch = provider.savedFormNames.isEmpty ||
          provider.savedFormNames.contains(item.formType ?? '');
      final insuranceMatch = provider.savedInsurances.isEmpty ||
          provider.savedInsurances.contains(item.patient?.primaryInsurance ?? '');
      return formMatch && insuranceMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<FilterDrawerProvider>();

    return Stack(
      children: [

        // ── Main dialog ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 220.0),
          child: DialogueTemplateNoButtons(
            width:  double.infinity,
            height: double.maxFinite,
            title:  "Needs Correction",
            body: [
              Column(
                children: [

                  // ── Search & Filter ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomSearchFieldSM(onPressed: () {}),
                      const SizedBox(width: 20),
                      IconButton(
                        highlightColor: Colors.transparent,
                        splashColor:    Colors.transparent,
                        hoverColor:     Colors.transparent,
                        focusColor:     Colors.transparent,
                        onPressed: () =>
                            context.read<FilterDrawerProvider>().toggleFilter(),
                        icon: Image.asset(
                          "images/sm/sm_refferal/filter_icon.png",
                          height: AppSize.s18,
                          width:  AppSize.s16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.s10),

                  // ── Table header ────────────────────────────────────
                  Container(
                    height: AppSize.s33,
                    decoration: BoxDecoration(
                      color: ColorManager.SMFBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.only(
                        left: AppPadding.p50, right: AppPadding.p30),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text("Patient Name",
                              style: EMRListViewHead.customTextStyle(context)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppPadding.p0),
                            child: Text("Form Name",
                                textAlign: TextAlign.center,
                                style: EMRListViewHead.customTextStyle(context)),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p35),
                            child: Text("Form Date",
                                textAlign: TextAlign.center,
                                style: EMRListViewHead.customTextStyle(context)),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: AppPadding.p45),
                            child: Text("Insurance",
                                textAlign: TextAlign.center,
                                style: EMRListViewHead.customTextStyle(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSize.s10),

                  // ── List body ───────────────────────────────────────
                  SizedBox(
                    height: 400,
                    child: _isLoading && _items.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null && _items.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade300, size: 36),
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.red)),
                          const SizedBox(height: 8),
                          TextButton(
                              onPressed: _fetchData,
                              child: const Text('Retry')),
                        ],
                      ),
                    )
                        : Builder(
                      builder: (context) {
                        final filtered =
                        _applyFilters(_items, filterProvider);

                        if (filtered.isEmpty) {
                          return const Center(
                            child: Text(
                              'No need correction data found!',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount:
                          filtered.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filtered.length) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                    child:
                                    CircularProgressIndicator()),
                              );
                            }
                            final item = filtered[index];
                            return _CorrectionRow(
                              item: item,
                              onTap: () => _onTap(
                                patientFormId:
                                item.patientFormId ?? 0,
                                chartNo: item.patient?.chartNo ?? 0,
                                patientID: item.patient?.ptId ?? 0,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Barrier — close on outside tap ────────────────────────────
        if (filterProvider.isFilterOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.read<FilterDrawerProvider>().closeFilter(),
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

        // ── Filter panel ──────────────────────────────────────────────
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

// ─── Single row widget ────────────────────────────────────────────────────────

class _CorrectionRow extends StatefulWidget {
  final PhysicianOrderData item;
  final void Function() onTap;
  const _CorrectionRow({required this.item, required this.onTap});

  @override
  State<_CorrectionRow> createState() => _CorrectionRowState();
}

class _CorrectionRowState extends State<_CorrectionRow> {

  String get _initials {
    final parts = (widget.item.patient?.name ?? '').trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.s10),
      child: Row(
        children: [

          // Patient Name + MRN + Form Date + Diagnosis
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFFFE0B2),
                  child: Text(_initials,
                      style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: AppSize.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.patient?.name ?? '-',
                          style: EMRListViewHead.customTextStyle(context),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppSize.s2),
                      Text("MRN: ${item.patient?.mrn ?? '-'}",
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis),
                      Text(item.formDate ?? '-',
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis),
                      Text(item.patient?.primaryDiagnosis?.dgnName ?? '-',
                          style: EMRListViewHead.customTextStyle(context)
                              .copyWith(fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form Name
          Expanded(
            flex: 4,
            child: InkWell(
              splashColor:    Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor:     Colors.transparent,
              onTap: widget.onTap,
              child: Text(
                item.formType ?? '-',
                textAlign: TextAlign.center,
                style: EMRListViewHead.customTextStyle(context).copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorManager.blueprime,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),

          // Form Date
          Expanded(
            flex: 3,
            child: Text(item.formDate ?? '-',
                style: EMRListViewHead.customTextStyle(context)
                    .copyWith(fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis),
          ),

          // Insurance
          Expanded(
            flex: 3,
            child: Text(
              item.patient?.primaryInsurance ?? '-',
              textAlign: TextAlign.center,
              style: EMRListViewHead.customTextStyle(context)
                  .copyWith(fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}