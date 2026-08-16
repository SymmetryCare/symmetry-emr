import 'package:flutter/material.dart';
import 'package:prohealth/app/services/token/token_manager.dart';
import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../app/services/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import '../../../../../../../../../app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/visit_details_type_manager.dart';
import '../../../../../../../../../data/api_data/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import '../../../../../../../../../data/api_data/emr_module_data/emr_dash_data/visist_type_data.dart';
import '../../../../../../../../../oasis_form_builder/model/chart_patient_referral_data_model.dart';
import '../../../../../../../../../oasis_form_builder/model/patient_form_model.dart';
import '../../../../../../../../../oasis_form_builder/oasis_form_mapper.dart';
import '../../../../../../../../../oasis_form_builder/services/api/managers/patient_form_manager.dart';
import '../../../../../emr_const/sucess_failed_popup_const.dart';
import '../../../../../popup_const_emr.dart';
import 'discharge_visit.dart';

class ViewStartVisit extends StatefulWidget {
  final VisitPrefillByIdModel visitData;
  final VoidCallback onRefresh;
   String? visitType;
   ViewStartVisit(
      {super.key, this.visitType,required this.visitData, required this.onRefresh});

  @override
  State<ViewStartVisit> createState() => _ViewStartVisitState();
}

class _ViewStartVisitState extends State<ViewStartVisit> {
  bool _isStartingVisit = false;

  PatientPrefillModel get _patient => widget.visitData.patient;

  String get _fullName =>
      '${_patient.ptFirstName} ${_patient.ptLastName}'.trim();

  String get _initials {
    final first =
    _patient.ptFirstName.isNotEmpty ? _patient.ptFirstName[0] : '';
    final last =
    _patient.ptLastName.isNotEmpty ? _patient.ptLastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get _dob {
    if (_patient.ptDateOfBirth.isEmpty) return '--';
    final dt = DateTime.tryParse(_patient.ptDateOfBirth);
    if (dt == null) return '--';
    final age = DateTime.now().year - dt.year;
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.year} | ${age}y';
  }

  String get _formattedDate {
    if (widget.visitData.visiteDateTimeFrom.isEmpty) return '--';
    final dt = DateTime.tryParse(widget.visitData.visiteDateTimeFrom);
    if (dt == null) return widget.visitData.visiteDateTimeFrom;
    return '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${m}$period';
  }

  String get _formattedTimeRange {
    final from = DateTime.tryParse(widget.visitData.visiteDateTimeFrom);
    final to = DateTime.tryParse(widget.visitData.visitDateTimeTo);
    if (from == null || to == null) return '--';
    return '${_formatTime(from)}-${_formatTime(to)}';
  }

  Future<void> _onTap({
    required int patientFormId,
    required int ptId,
    required int chartNo,
  }) async {
    setState(() => _isStartingVisit = true);

    try {
      final result = await getPatientFormByPatientID(
        context,
        patientFormId: patientFormId,
      );
      String userRole = await TokenManager.getRole();

      if (!mounted) return;
      setState(() => _isStartingVisit = false);

      // ✅ Guard: bail out if result or critical data is null
      if (result == null) {
        debugPrint('_onTap: result is null — aborting navigation');
        // _showErrorSnackbar('Could not load patient form. Please try again.');
        return;
      }

      print('patinet DOB ${result.referralData.patientDob }');
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OasisFormMapper(
            form: PatientForm(
              formID: result.formId,
              formName: result.formName,
              fillStatus: result.status,
              subForms: result.subForms
                  .map((e) => PatientSubForm(
                formID: result.formId,
                subFormID: e.id,
                subFormName: e.subFormName,
                patientFormID: result.patientFormId,
                fillStatus: e.isFilled,
                commentCount: e.comment_count
              ))
                  .toList(),
            ),
            subForm: PatientSubForm(
              formID: result.formId,
              subFormID: result.subForms.isNotEmpty ? result.subForms.first.id : 0,
              subFormName: result.subForms.isNotEmpty ? result.subForms.first.subFormName : '',
              patientFormID: result.patientFormId,
              commentCount: result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
              fillStatus: result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
            ),
            patient: ChartPatientReferral(
              patientId: ptId,
              firstName: result.referralData.patientFirstname,
              lastName: result.referralData.patientLastname,
              contactNumber: result.referralData.patientPhone,
              address: result.referralData.patientAddress,
              imageUrl: result.referralData.patientImageUrl,
              gender: Gender(genderID: 1, genderName: 'Male'),
              dateOfBirth: DateTime.tryParse(result.referralData.patientDob ?? '') ?? DateTime.now(),
              chartNo: result.referralData.patientChartNo,
              episodes: [],
            ),
            appBarString: 'EMR - Clinical',
            userRole: userRole,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('_onTap error: $e\n$stack');
      if (mounted) setState(() => _isStartingVisit = false);
    }
  }

  // ── Start visit handler ──────────────────────────────────────────────────

  Future<void> _handleStartVisit() async {
    setState(() => _isStartingVisit = true);

    final result = await patchStartVisit(
      context: context,
      visitId: widget.visitData.visitId,
      onWay: true,
      // visitTypeData: widget.visitType == null ? "" : widget.visitType!,
      // isLastVisit: widget.visitData.isSecoundLastEpisodeVisit == true ? true : false
    );

    if (!mounted) return;
    setState(() => _isStartingVisit = false);

    if (result.success) {
      // if(result.episodeEndDecision == true){
      //   showDialog(
      //     context: context,
      //     builder: (_) => DischargeVisitTypePopup(
      //         visitData: widget.visitData,
      //       onNevigate:()=> _onTap(
      //       patientFormId: result.ptFormId!,
      //       ptId: result.ptId!,
      //       chartNo: widget.visitData.patient.ptChartNo,
      //     ),),
      //   );
      //
      // }else{
      //
      // }
      _onTap(
        patientFormId: result.ptFormId!,
        ptId: result.ptId!,
        chartNo: widget.visitData.patient.ptChartNo,
      );

    } else {
      showDialog(
        context: context,
        builder: (_) => EMRSuccessPopup(
          title: "Error",
          message: result.message,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      title: 'View Start Visit',
      width: 400,
      height: 425,
      body: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Patient Details label ─────────────────────────────────
              const Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              // ── Avatar + Name / DOB / Summary ─────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF4CAF93),
                    backgroundImage: _patient.ptImgUrl.isNotEmpty
                        ? NetworkImage(_patient.ptImgUrl)
                        : null,
                    child: _patient.ptImgUrl.isEmpty
                        ? Text(_initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName.isNotEmpty ? _fullName : '--',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(_dob,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(
                        _patient.ptSummary.isNotEmpty
                            ? _patient.ptSummary
                            : '--',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Address + MRN ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _patient.ptAddress.isNotEmpty
                                ? _patient.ptAddress
                                : 'No address on file',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MRN:',
                            style: TextStyle(
                                fontSize: 11, color: Colors.black54)),
                        Text(
                          _patient.ptMRN > 0
                              ? _patient.ptMRN.toString()
                              : '--',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // ── Visit Date/Time + Type ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time,
                            size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formattedDate,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87)),
                            Text(_formattedTimeRange,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Type of Visit:',
                            style: TextStyle(
                                fontSize: 11, color: Colors.black54)),
                        Text(
                          widget.visitData.typeOfVisitName.isNotEmpty
                              ? widget.visitData.typeOfVisitName
                              : '--',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Note section ──────────────────────────────────────────
              Text(
                'Note',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.redd),
              ),
              const SizedBox(height: 6),
              Text(
                'Patient MR#: ${_patient.ptMRN > 0 ? _patient.ptMRN : '--'}'
                    '\n${_patient.ptMedicalNote.isNotEmpty ? _patient.ptMedicalNote : 'No medical note available.'}',
                style:
                const TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // ── Confirmation question ─────────────────────────────────
              const Center(
                child: Text(
                  'Do you really want to continue this patient?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),

              // ── Buttons ───────────────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isStartingVisit
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorManager.bluebottom),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: ColorManager.bluebottom,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Yes — calls patchStartVisit
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                      //     (){
                      //   showDialog(context: context,
                      //       builder: (_)=>DischargeVisitTypePopup(visitId: null,));
                      // },
                       _isStartingVisit ? null : _handleStartVisit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.bluebottom,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: _isStartingVisit
                          ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Yes',
                          style: TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),

    //               // Change Visit Type
    //               Expanded(
    //                 flex: 2,
    //                 child: ElevatedButton(
    //                   onPressed: _isStartingVisit
    //                       ? null
    //                       : (){
    //                     showDialog(context: context,
    //                         builder: (_)=>DischargeVisitTypePopup());
    // //() => _showChangeVisitTypeConfirm(context),
    // },
    //                   style: ElevatedButton.styleFrom(
    //                     backgroundColor: ColorManager.bluebottom,
    //                     shape: RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(8)),
    //                     padding:
    //                     const EdgeInsets.symmetric(vertical: 10),
    //                   ),
    //                   child: const Text('Change Visit Type',
    //                       style: TextStyle(
    //                           color: Colors.white, fontSize: 12)),
    //                 ),
    //               ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChangeVisitTypeConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      size: 18, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to change the visit type?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorManager.bluebottom),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    child: Text('No',
                        style: TextStyle(
                            color: ColorManager.bluebottom,
                            fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final rootContext = context;
                      final future = getVisitList(rootContext);
                      Navigator.pop(context);
                      Future.microtask(() => showDialog(
                        context: rootContext,
                        builder: (_) => _ChangeVisitTypeDialog(
                          currentVisitType:
                          widget.visitData.typeOfVisitName,
                          visitId: widget.visitData.visitId,
                          ptId: widget.visitData.patient.ptId,
                          visitListFuture: future,
                        ),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.bluebottom,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    child: const Text('Yes',
                        style:
                        TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChangeVisitTypeDialog extends StatefulWidget {
  final String currentVisitType;
  final int visitId;
  final int ptId;
  final Future<List<VisitListData>> visitListFuture;
  const _ChangeVisitTypeDialog({
    required this.currentVisitType,
    required this.visitId,
    required this.ptId,
    required this.visitListFuture,
  });

  @override
  State<_ChangeVisitTypeDialog> createState() =>
      _ChangeVisitTypeDialogState();
}

class _ChangeVisitTypeDialogState extends State<_ChangeVisitTypeDialog> {
  int? _selectedVisitId;
  String? _selectedVisitType;
  bool _isLoading = false;

  Future<void> _onSubmit() async {
    if (_selectedVisitId == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await updatePatientVisit(
        context,
        widget.visitId.toString(),
        widget.ptId,
        _selectedVisitId!,
      );
      if (!mounted) return;
      Navigator.pop(context, _selectedVisitType);
      if (result.success) {
        showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            title: 'Success',
            message: 'Visit type updated successfully.',
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(
            title: 'Failed',
            message: result.message,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      title: 'Change Visit Type',
      width: 340,
      height: 230,
      body: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visit Type',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),

              // ── Visit Type Dropdown ───────────────────────────────────
              FutureBuilder<List<VisitListData>>(
                future: widget.visitListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return VisitTypeDropdown(
                      hintText: "Loading...",
                      items: [],
                      height: 32,
                      onChanged: (visitId, typeOfVisit) {

                      },
                    );
                  }
                  final List<VisitListData> list =
                      snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          'No visit types found',
                          style: TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    );
                  }
                  return VisitTypeDropdown(
                    hintText: widget.currentVisitType,
                    items: list,
                    height: 32,
                    onChanged: (visitId, typeOfVisit) {
                      setState(() {
                        _selectedVisitId = visitId;
                        _selectedVisitType = typeOfVisit;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Submit ────────────────────────────────────────────────
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.bluebottom,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 10),
                  ),
                  child: const Text('Submit',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Visit Type Dropdown ───────────────────────────────────────────────────────
class VisitTypeDropdown extends StatefulWidget {
  final String hintText;
  final List<VisitListData> items;
  final void Function(int visitId, String typeOfVisit)? onChanged;
  final double? height;
  final double? width;

  const VisitTypeDropdown({
    Key? key,
    required this.hintText,
    required this.items,
    this.onChanged,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<VisitTypeDropdown> createState() => _VisitTypeDropdownState();
}

class _VisitTypeDropdownState extends State<VisitTypeDropdown> {
  String? _selectedLabel;

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final int itemCount = widget.items.length;
    final double itemHeight = 48.0;
    final double maxHeight =
    itemCount > 4 ? itemHeight * 4 : itemHeight * itemCount;

    final result = await showDialog<VisitListData>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: widget.width ?? size.width,
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return ListTile(
                        title: Text(
                          item.typeOfVisit,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() => _selectedLabel = result.typeOfVisit);
      widget.onChanged?.call(result.visitId, result.typeOfVisit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? AppSize.s31,
      child: GestureDetector(
        onTap: widget.items.isEmpty ? null : _showDropdownDialog,
        child: Container(
          padding:
          const EdgeInsets.only(bottom: 3, top: 5, left: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedLabel ?? widget.hintText,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down_sharp,
                  color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}