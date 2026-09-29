import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/reschedule_visit_popup.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_miss_visit_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/chart_patient_referral_data_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/oasis_form_mapper.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/patient_form_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/mised_visit_discharge.dart';

// ─────────────────────────────────────────────
//  MISS VISIT FORM POPUP
// ─────────────────────────────────────────────
class MissVisitFormPopup extends StatefulWidget {
  final int visitId;
  // ── NEW: params required by _onTap ──────────────────────────────────────
  final int ptId;
  final String lastFormFillByAssist;

  const MissVisitFormPopup({
    super.key,
    required this.visitId,
    required this.ptId,
    required this.lastFormFillByAssist,
  });

  @override
  State<MissVisitFormPopup> createState() => _MissVisitFormPopupState();
}

class _MissVisitFormPopupState extends State<MissVisitFormPopup> {
  final TextEditingController _reasonController = TextEditingController();
  bool _attemptedVisit = false;
  bool _isLoading = false;

  // ── Photo ─────────────────────────────────────────────────────────────────
  String? _uploadedFileName;
  String? _uploadedBase64;

  // Notifications
  DateTime? _notificationDate;
  TimeOfDay? _notificationTime;
  bool _clinicalManager = true;
  bool _physician = false;
  bool _phone = false;
  bool _fax = false;
  bool _other = false;

  // Actions taken
  bool _contactedRep = false;
  bool _rescheduled = false;
  bool _contactedPhysician = false;
  bool _actionOther = false;

  Future<void> _pickDate() async {
    final picked = await CalendarDialogHelperFeturedate.show(
      context: context,
      selectedDate: _notificationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
    );
    if (picked != null) setState(() => _notificationDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _notificationTime = picked);
  }

  // ── Pick image → base64 ───────────────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _uploadedBase64 = base64Encode(bytes);
        _uploadedFileName = file.name;
      });
    } catch (e) {
      print("Image pick error $e");
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          title: 'Failed',
          message: 'Failed to pick image.\nPlease try again.',
        ),
      );
    }
  }

  // ── Build actionsTaken list ───────────────────────────────────────────────
  List<String> get _actionsTaken {
    final list = <String>[];
    if (_contactedRep) list.add('contracted_representative');
    if (_rescheduled) list.add('rescheduled');
    if (_contactedPhysician) list.add('contacted_physician');
    if (_actionOther) list.add('other');
    return list;
  }

  // ── Build individualsNotified list ────────────────────────────────────────
  List<String> get _individualsNotified {
    final list = <String>[];
    if (_clinicalManager) list.add('clinical_manager');
    if (_physician) list.add('physician');
    return list;
  }

  // ── Build notificationMethods list ───────────────────────────────────────
  List<String> get _notificationMethods {
    final list = <String>[];
    if (_phone) list.add('phone');
    if (_fax) list.add('fax');
    if (_other) list.add('other');
    return list;
  }

  // ── Format date ───────────────────────────────────────────────────────────
  String get _formattedDate {
    if (_notificationDate == null) return '';
    return '${_notificationDate!.year}-'
        '${_notificationDate!.month.toString().padLeft(2, '0')}-'
        '${_notificationDate!.day.toString().padLeft(2, '0')}';
  }

  // ── Format time ───────────────────────────────────────────────────────────
  String get _formattedTime {
    if (_notificationTime == null) return '';
    return _notificationTime!.format(context);
  }

  // ── Open patient form (called automatically after successful submit) ───────
  Future<void> _openPatientForm({required int patientFormId}) async {
    try {
      final result = await getPatientFormByPatientID(
        context,
        patientFormId: patientFormId,
      );

      String userRole = await TokenManager.getRole();

      if (!mounted) return;

      // Guard: bail out if result is null
      if (result == null) {
        debugPrint('_openPatientForm: result is null — aborting navigation');
        return;
      }

      // Close this popup, then push the form screen
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
                  .map(
                    (e) => PatientSubForm(
                  formID: result.formId,
                  subFormID: e.id,
                  subFormName: e.subFormName,
                  patientFormID: result.patientFormId,
                  fillStatus: e.isFilled,
                  commentCount: e.comment_count,
                ),
              )
                  .toList(),
            ),
            subForm: PatientSubForm(
              formID: result.formId,
              subFormID:
              result.subForms.isNotEmpty ? result.subForms.first.id : 0,
              subFormName: result.subForms.isNotEmpty
                  ? result.subForms.first.subFormName
                  : '',
              patientFormID: result.patientFormId,
              commentCount: result.subForms.isNotEmpty
                  ? result.subForms.first.comment_count
                  : 0,
              fillStatus: result.subForms.isNotEmpty
                  ? result.subForms.first.isFilled
                  : false,
            ),
            patient: ChartPatientReferral(
              patientId: widget.ptId,
              firstName: result.referralData.patientFirstname,
              lastName: result.referralData.patientLastname,
              contactNumber: result.referralData.patientPhone,
              address: result.referralData.patientAddress,
              imageUrl: result.referralData.patientImageUrl,
              gender: Gender(genderID: 1, genderName: 'Male'),
              dateOfBirth:
              DateTime.tryParse(result.referralData.patientDob ?? '') ??
                  DateTime.now(),
              chartNo: result.referralData.patientChartNo,
              episodes: [],
            ),
            appBarString: 'EMR - Clinical',
            userRole: userRole,
            lastFormFillByAssist: widget.lastFormFillByAssist,
            visitId: widget.visitId,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('_openPatientForm error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      // Step 1 — upload photo if selected
      String? photoUrl;
      if (_uploadedBase64 != null) {
        final photoResult = await uploadVisitPhoto(
          context,
          widget.visitId,
          _uploadedBase64!,
        );
        if (!photoResult.success) {
          showDialog(
            context: context,
            builder: (_) => EMRFailedPopup(
              title: 'Failed',
              message: photoResult.message,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        print("Photo uploaded successfully");
        photoUrl = photoResult.message;
      }

      // Step 2 — mark visit missed
      final result = await markVisitMissed(
        context,
        widget.visitId,
        reason: _reasonController.text.trim(),
        isAttemptedVisit: _attemptedVisit,
        photoUrl: photoUrl,
        actionsTaken: _actionsTaken,
        notificationDate: _formattedDate,
        notificationTime: _formattedTime,
        individualsNotified: _individualsNotified,
        notificationMethods: _notificationMethods,
      );

      if (result.success) {
        // ── Step 3: automatically open the patient form ──────────────────
        if(result.requiredEpisodEnd == true){
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (_) => DischargeMissedVisitTypePopup(
              visitId: widget.visitId,
              onNevigate: () async {
                await _openPatientForm(patientFormId: result.missVisitFormID!);
              },
              patientFormId: result.missVisitFormID!,
            ),
          );
          return;
        }
        await _openPatientForm(patientFormId:
        result.missVisitFormID != 0 ?
        result.missVisitFormID! :
        result.dischardeFormPatientId!);
      } else {
        Navigator.pop(context);
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
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: 700,
      height: 460,
      title: 'Miss Visit',
      body: [
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT COLUMN ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason for  Missed Visit',
                        style: TextStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.mediumgrey),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 28,
                        child: TextField(
                          controller: _reasonController,
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.mediumgrey),
                          decoration: InputDecoration(
                            hintText: 'Enter Text',
                            hintStyle: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.faintGrey),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                              const BorderSide(color: Colors.black45),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                              const BorderSide(color: Colors.black45),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Attempted Visit
                      Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              value: _attemptedVisit,
                              activeColor: ColorManager.blueprime,
                              onChanged: (v) =>
                                  setState(() => _attemptedVisit = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Attempted Visit',
                              style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ── Upload Photo ──────────────────────────────────
                      Text('Upload Photo',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.mediumgrey)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickImage,
                        child: SizedBox(
                          width: 200,
                          child: Container(
                            height: 28,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black45,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _uploadedFileName ?? 'Upload',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: FontSize.s12,
                                      color: _uploadedBase64 != null
                                          ? ColorManager.blueprime
                                          : Colors.black45,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.upload_outlined,
                                  size: 16,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 46),

                      // Actions Taken
                      Text('Actions taken',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.mediumgrey)),
                      const SizedBox(height: 8),
                      _checkRow(
                          value: _contactedRep,
                          label:
                          'Contracted authorized representative, caregivers, family, friends',
                          onChanged: (v) =>
                              setState(() => _contactedRep = v ?? false)),
                      const SizedBox(height: 6),
                      _checkRow(
                          value: _rescheduled,
                          label: 'Rescheduled for later in week',
                          onChanged: (v) =>
                              setState(() => _rescheduled = v ?? false)),
                      const SizedBox(height: 6),
                      _checkRow(
                          value: _contactedPhysician,
                          label: 'Contacted Physician',
                          onChanged: (v) => setState(
                                  () => _contactedPhysician = v ?? false)),
                      const SizedBox(height: 6),
                      _checkRow(
                          value: _actionOther,
                          label: 'Other',
                          onChanged: (v) =>
                              setState(() => _actionOther = v ?? false)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // ── RIGHT COLUMN ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notification(s)',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.mediumgrey)),
                      const SizedBox(height: 30),

                      // Date of notification
                      Row(
                        children: [
                          Text('Date of notification:',
                              style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                height: 28,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _notificationDate != null
                                          ? '${_notificationDate!.month.toString().padLeft(2, '0')}/'
                                          '${_notificationDate!.day.toString().padLeft(2, '0')}/'
                                          '${_notificationDate!.year}'
                                          : ' ',
                                      style: TextStyle(
                                          fontSize: FontSize.s12,
                                          color: ColorManager.mediumgrey),
                                    ),
                                    const Icon(Icons.calendar_month_sharp,
                                        size: 18, color: Colors.black45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Time of notification
                      Row(
                        children: [
                          Text('Time of notification:',
                              style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickTime,
                              child: Container(
                                height: 28,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _notificationTime != null
                                          ? _notificationTime!.format(context)
                                          : ' ',
                                      style: TextStyle(
                                          fontSize: FontSize.s12,
                                          color: ColorManager.mediumgrey),
                                    ),
                                    const Icon(Icons.access_time,
                                        size: 18, color: Colors.black45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Individuals notified
                      Text('Individuals notified:',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.mediumgrey)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _checkRow(
                              value: _clinicalManager,
                              label: 'Clinical Manager',
                              onChanged: (v) => setState(
                                      () => _clinicalManager = v ?? false)),
                          const SizedBox(width: 12),
                          _checkRow(
                              value: _physician,
                              label: 'Physician',
                              onChanged: (v) =>
                                  setState(() => _physician = v ?? false)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Method of notification
                      Text('Method(s) of notification:',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.mediumgrey)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _checkRow(
                              value: _phone,
                              label: 'Phone',
                              onChanged: (v) =>
                                  setState(() => _phone = v ?? false)),
                          const SizedBox(width: 10),
                          _checkRow(
                              value: _fax,
                              label: 'Fax',
                              onChanged: (v) =>
                                  setState(() => _fax = v ?? false)),
                          const SizedBox(width: 10),
                          _checkRow(
                              value: _other,
                              label: 'Other',
                              onChanged: (v) =>
                                  setState(() => _other = v ?? false)),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Submit ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 30, top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: CustomElevatedButton(
                  height: AppSize.s30,
                  width: AppSize.s120,
                  text: 'Submit',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _checkRow({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            splashRadius: 0,
            focusColor: Colors.transparent,
            value: value,
            activeColor: ColorManager.blueprime,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
            child: Text(label,
                style: TextStyle(
                    fontSize: FontSize.s11, color: ColorManager.mediumgrey))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  MISS VISIT CONFIRMATION POPUP
// ─────────────────────────────────────────────
class MissVisitTodaysVisit extends StatelessWidget {
  final int visitId;
  // ── NEW: forwarded to MissVisitFormPopup ────────────────────────────────
  final int ptId;

  const MissVisitTodaysVisit({
    super.key,
    required this.visitId,
    required this.ptId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 380,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: ColorManager.mediumgrey),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to miss this visit or\nwould you like to reschedule instead?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.mediumgrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorManager.blueprime),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.blueprime,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        // ── Pass all new params through ──────────────────
                        builder: (_) => MissVisitFormPopup(
                          visitId: visitId,
                          ptId: ptId,
                          lastFormFillByAssist: "Clinical",
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorManager.blueprime,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Miss',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) =>
                            RescheduleVisitTodaysVisit(visitId: visitId),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorManager.blueprime,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Reschedule',
                          style: TextStyle(
                              fontSize: FontSize.s12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
            ],
          ),
        ),
      ),
    );
  }
}