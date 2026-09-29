import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_miss_visit_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

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

  // ── Date picker — past dates blocked ───────────────────────────────────────
  Future<void> _pickDate() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final picked = await CalendarDialogHelperFeturedate.show(
      context: context,
      selectedDate: _selectedDate ?? todayOnly,
      firstDate: todayOnly,
    );
    if (picked == null) return;

    setState(() => _selectedDate = picked);
  }

  // ── Start time picker ────────────────────────────────────────────────────
  Future<void> _pickStartTime() async {
    final now = TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? now,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  // ── End time picker — defaults to 30 min after current time ────────────────
  Future<void> _pickEndTime() async {
    final now = TimeOfDay.now();
    final nowPlus30 = TimeOfDay(
      hour: (now.hour + (now.minute + 30) ~/ 60) % 24,
      minute: (now.minute + 30) % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? nowPlus30,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
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

    // ── Start/End time gap validation — minimum 30 minutes ──────────────────
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes   = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes - startMinutes < 30) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'End time must be at least 30 minutes after start time.',
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
                    onTap: _pickStartTime,
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
                    onTap: _pickEndTime,
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
    );
  }
}