import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import '../../../../../../../../../app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_miss_visit_manager.dart';
import '../../../../../../../em_module/widgets/button_constant.dart';
import '../../../../../../../em_module/widgets/dialogue_template.dart';
import '../../../../../emr_const/calender_popup_const.dart';
import '../../../../../emr_const/dropdown_const.dart';
import '../../../../../emr_const/sucess_failed_popup_const.dart';
import '../../../../../popup_const_emr.dart';

class RescheduleVisitTodaysVisit extends StatefulWidget {
  final int visitId;
  const RescheduleVisitTodaysVisit({super.key, required this.visitId});

  @override
  State<RescheduleVisitTodaysVisit> createState() =>
      _RescheduleVisitTodaysVisitState();
}

class _RescheduleVisitTodaysVisitState
    extends State<RescheduleVisitTodaysVisit> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // ── Reschedule reason from API ────────────────────────────────────────────
  late Future<List<RescheduleReasonData>> _rescheduleReasonsFuture;
  int?    _selectedReasonId;
  String? _selectedReasonText;

  bool _attemptedVisit = false;
  bool _isLoading      = false;

  String? _uploadedFileName;
  String? _uploadedBase64;

  @override
  void initState() {
    super.initState();
    _rescheduleReasonsFuture = getRescheduleReasonList(context);
  }

  Future<void> _pickDate() async {
    final picked = await CalendarDialogHelper.show(
      context: context,
      selectedDate: _selectedDate ?? DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _uploadedBase64    = base64Encode(bytes);
        _uploadedFileName  = file.name;
      });
    } catch (e) {
      print("Image pick error $e");
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Failed to pick image.\nPlease try again.',
        ),
      );
    }
  }

  String _buildDateTime(DateTime date, TimeOfDay time) {
    final local = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    return local.toUtc().toIso8601String(); // adds Z → 2026-05-31T14:16:00.000Z
  }

  Future<void> _submit() async {
    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _selectedReasonId == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Please fill all required fields.',
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    print("Submit started — visitId: ${widget.visitId}");

    try {
      if (_uploadedBase64 != null) {
        print("Uploading photo for visitId: ${widget.visitId}");
        final photoResult = await uploadVisitPhoto(
          context,
          widget.visitId,
          _uploadedBase64!,
        );
        print("Photo upload result: success=${photoResult.success}, message=${photoResult.message}");
        if (!photoResult.success) {
          showDialog(
            context: context,
            builder: (_) => EMRFailedPopup(message: photoResult.message),
          );
          setState(() => _isLoading = false);
          return;
        }
        print("Photo uploaded successfully");
      }

      final startDt = _buildDateTime(_selectedDate!, _startTime!);
      final endDt   = _buildDateTime(_selectedDate!, _endTime!);
      print("Rescheduling visit — start: $startDt, end: $endDt, reasonId: $_selectedReasonId, attempted: $_attemptedVisit");

      final result = await rescheduleVisit(
        context,
        widget.visitId,
        startDt,
        endDt,
        _selectedReasonId!,
        _attemptedVisit,
      );

      print(".....!!!!!.... Reschedule result: success=${result.success}, message=${result.message}");

      if (result.success) {
        showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            message: 'Visit rescheduled successfully.',
          ),
        ).then((_) => Navigator.pop(context, true));
      } else {
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(message: result.message),
        );
      }
    } catch (e) {
      print("Error in _submit: $e");
    } finally {
      print("Submit finished");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: AppSize.s800,
      height: AppSize.s420,
      title: "Reschedule",
      body: [
        // ── Row 1: Select Date | Reason for Reschedule ────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                '${_selectedDate!.year}'
                                : ' ',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                          const Icon(Icons.calendar_month_sharp, size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // ── Reason for Reschedule — API dropdown ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for Reschedule',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<List<RescheduleReasonData>>(
                    future: _rescheduleReasonsFuture,
                    builder: (context, snapshot) {
                      final List<RescheduleReasonData> list = snapshot.data ?? [];
                      return EmrDropdownConst(
                        dropDownMenuList: list
                            .map((e) => DropdownMenuItem<String>(
                          value: e.reason,
                          child: Text(e.reason),
                        ))
                            .toList(),
                        hintText: _selectedReasonText ?? 'Select',
                        height: 32,
                        onChanged: (val) {
                          if (val == null) return;
                          final match = list.firstWhere(
                                (e) => e.reason == val,
                            orElse: () => RescheduleReasonData(
                              rescheduleReasonId: 0,
                              reason: val,
                              createdAt: '',
                              updatedAt: '',
                            ),
                          );
                          setState(() {
                            _selectedReasonId   = match.rescheduleReasonId;
                            _selectedReasonText = match.reason;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Row 2: Start Time | End Time ──────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Start Time',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickTime(isStart: true),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startTime != null ? _startTime!.format(context) : ' ',
                            style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.mediumgrey),
                          ),
                          const Icon(Icons.access_time, size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select End Time',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickTime(isStart: false),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endTime != null ? _endTime!.format(context) : ' ',
                            style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.mediumgrey),
                          ),
                          const Icon(Icons.access_time, size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Row 3: Attempted Visit + Upload Photo ─────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _attemptedVisit,
                          activeColor: ColorManager.blueprime,
                          onChanged: (val) =>
                              setState(() => _attemptedVisit = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Attempted Visit',
                        style: TextStyle(
                            fontSize: FontSize.s12,
                            color: ColorManager.mediumgrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upload Photo',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickImage,
                    child: SizedBox(
                      width: 200,
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45),
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
                                    color: ColorManager.mediumgrey),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.upload_outlined,
                                size: 16, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
        const SizedBox(height: 30),

        // ── Submit Button ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(right: 30, top: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: _isLoading
                ? SizedBox(
              height: AppSize.s30,
              width: AppSize.s30,
              child: CircularProgressIndicator(
                  color: ColorManager.blueprime),
            )
                : CustomElevatedButton(
              height: AppSize.s30,
              width: AppSize.s120,
              text: 'Submit',
              onPressed: _submit,
            ),
          ),
        ),
      ],
    );
  }
}