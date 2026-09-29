import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
// removed in extraction: import 'package:prohealth/modules/hr/presentation/screens/register/offer_letter_screen.dart';

import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/new_visit_request_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
class VisitRequestRejectPopup extends StatefulWidget {
  final int visitId;
  final VoidCallback onRefresh;

  const VisitRequestRejectPopup({
    super.key,
    required this.visitId,
    required this.onRefresh,
  });

  @override
  State<VisitRequestRejectPopup> createState() => _VisitRequestRejectPopupState();
}

class _VisitRequestRejectPopupState extends State<VisitRequestRejectPopup> {
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _startCtrl = TextEditingController();
  final TextEditingController _endCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _noteCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reasonCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final result = await rejectVisit(
          context,
          widget.visitId,
          _reasonCtrl.text.trim(),
          _noteCtrl.text.trim()
      );
      if (result.success) {
        widget.onRefresh();
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            title: 'Rejected',
            message: 'Visit rejected successfully.',
          ),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(
            title: 'Failed',
            message: result.message.isNotEmpty
                ? result.message
                : 'Failed to reject visit.',
          ),
        );
      }
    } catch (e) {
      print("Error $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      height: AppSize.s400,
      width: AppSize.s330,
      title: "Reject",
      body: [
        Center(
          child: Text(
            "Are you sure you want to reject the\nrequest?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
              color: ColorManager.mediumgrey,
            ),
          ),
        ),
        const SizedBox(height: AppSize.s20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SMTextFConst(
            controller: _reasonCtrl,
            text: "Reasons For Rejection",
            keyboardType: TextInputType.text,
          ),
        ),
        const SizedBox(height: AppSize.s16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SMTextFConst(
            controller: _noteCtrl,
            text: "Add Note To Scheduler",
            keyboardType: TextInputType.text,
          ),
        ),

      ],
      bottomButtons: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButtonTransparent(
              text: "Cancel",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: AppSize.s20),
            CustomElevatedButton(
              width: AppSize.s100,
              text: "Reject",
              style: const TextStyle(fontWeight: FontWeight.w500),
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}



///
///
///

class VisitRequestApprovePopup extends StatefulWidget {
  final int visitId;
  final VoidCallback onRefresh;
  final String patientName;
  final int mrn;
  final int patientAge;
  final String genderName;
  final String primaryDiagnosisName;
  final String patientAddress;
  final String visitType;
  final String requestType;
  final String visitTimeframeFrom;
  final String visitTimeframeTo;

  const VisitRequestApprovePopup({
    super.key,
    required this.visitId,
    required this.onRefresh,
    required this.patientName,
    required this.mrn,
    required this.patientAge,
    required this.genderName,
    required this.primaryDiagnosisName,
    required this.patientAddress,
    required this.visitType,
    required this.requestType,
    required this.visitTimeframeFrom,
    required this.visitTimeframeTo,
  });

  @override
  State<VisitRequestApprovePopup> createState() =>
      _VisitRequestApprovePopupState();
}

class _VisitRequestApprovePopupState extends State<VisitRequestApprovePopup> {
  DateTime _selectedDifferentDay = DateTime.now();
  DateTime? _visitDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isLoadingApprove = false;
  bool _isLoadingDifferentDay = false;

  String? startTimeError;
  String? endTimeError;

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '??';
  }

  Color _avatarTextColor(String initials) {
    const colors = [
      Color(0xFF0D9488),
      Color(0xFFE65100),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFF2E7D32),
    ];
    return colors[initials.codeUnitAt(0) % colors.length];
  }

  String _formatTimeframe(String from, String to) {
    final f = DateTime.tryParse(from)?.toLocal();
    final t = DateTime.tryParse(to)?.toLocal();
    if (f == null || t == null) return '';
    String fmt(DateTime d) =>
        '${d.month.toString().padLeft(2, '0')}/'
            '${d.day.toString().padLeft(2, '0')}/'
            '${d.year.toString().substring(2)}';
    return '${fmt(f)}-${fmt(t)}';
  }

  String _formatDate(String isoString) {
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return isoString;
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _to24h(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  /// Adds [minutes] to a TimeOfDay, wrapping correctly past midnight.
  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    final wrapped = totalMinutes % (24 * 60);
    return TimeOfDay(hour: wrapped ~/ 60, minute: wrapped % 60);
  }

  // ── Time pickers ─────────────────────────────────────────────────────────────

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        startTimeError = null;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _addMinutes(TimeOfDay.now(), 30),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        endTimeError = null;
      });
    }
  }

  bool _validate() {
    bool valid = true;
    if (_startTime == null) {
      setState(() => startTimeError = 'Start time is required');
      valid = false;
    }
    if (_endTime == null) {
      setState(() => endTimeError = 'End time is required');
      valid = false;
    }
    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      final gap = endMinutes - startMinutes;
      if (gap < 30) {
        setState(() => endTimeError = 'End time must be at least 30 minutes after start time.');
        valid = false;
      }
    }
    return valid;
  }

  // ── API calls ─────────────────────────────────────────────────────────────────

  Future<void> _approve() async {
    if (!_validate()) return;
    setState(() => _isLoadingApprove = true);
    try {
      final result = await approveRejectedVisit(
        context,
        widget.visitId,
        _to24h(_startTime!),
        _to24h(_endTime!),
      );
      if (result.success) {
        widget.onRefresh();
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            title: 'Approved',
            message: 'Visit approved successfully.',
          ),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(
            title: 'Failed',
            message: result.message.isNotEmpty
                ? result.message
                : 'Failed to approve visit.',
          ),
        );
      }
    } catch (e) {
      print("Error $e");
    } finally {
      if (mounted) setState(() => _isLoadingApprove = false);
    }
  }

  Future<void> _approveForDifferentDay() async {
    if (!_validate()) return;
    final picked = await CalendarDialogHelperFeturedate.show(
      context: context,
      selectedDate: _selectedDifferentDay,
      firstDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _selectedDifferentDay = picked;
      _isLoadingDifferentDay = true;
    });
    try {
      final newDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

      print("approveForDifferentDay — visitId: ${widget.visitId}");
      print("approveForDifferentDay — newDate: $newDate");
      print("approveForDifferentDay — startTime: ${_to24h(_startTime!)}");
      print("approveForDifferentDay — endTime: ${_to24h(_endTime!)}");

      final result = await approveVisitForDifferentDay(
        context,
        widget.visitId,
        newDate,
        _to24h(_startTime!),
        _to24h(_endTime!),
      );

      print("approveForDifferentDay — result.success: ${result.success}");
      print("approveForDifferentDay — result.message: ${result.message}");

      if (result.success) {
        widget.onRefresh();
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            title: 'Approved',
            message: 'Visit approved for different day.',
          ),
        );
      } else {
        print("approveForDifferentDay — FAILED: ${result.statusCode} | ${result.message}");
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(
            title: 'Failed',
            message: result.message.isNotEmpty
                ? result.message
                : 'Failed to approve visit for different day.',
          ),
        );
      }
    } catch (e) {
      print("Error $e");
    } finally {
      if (mounted) setState(() => _isLoadingDifferentDay = false);
    }
  }
  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final initials = _initials(widget.patientName);

    return DialogueTemplate(
      height: AppSize.s522,
      width: AppSize.s660,
      title: "Approve",
      body: [
        Text(
          "Are you sure you want to approve the request?",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppSize.s12,
            color: ColorManager.black,
          ),
        ),
        const SizedBox(height: 16),

        // ── Start Time & End Time ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [

              // ── Start Time ──────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.mediumgrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickStartTime,
                    child: Container(
                      width: 270,
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startTime != null
                                ? _startTime!.format(context)
                                : 'Select',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: _startTime != null
                                  ? ColorManager.mediumgrey
                                  : ColorManager.faintGrey,
                            ),
                          ),
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                  startTimeError != null
                      ? Text(startTimeError!,
                      style: CommonErrorMsg.customTextStyle(context))
                      : const SizedBox(height: AppSize.s12),
                ],
              ),
              const SizedBox(width: 20),

              // ── End Time ────────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.mediumgrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickEndTime,
                    child: Container(
                      width: 270,
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endTime != null
                                ? _endTime!.format(context)
                                : 'Select',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: _endTime != null
                                  ? ColorManager.mediumgrey
                                  : ColorManager.faintGrey,
                            ),
                          ),
                          const Icon(Icons.access_time,
                              size: 18, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),
                  endTimeError != null
                      ? Text(endTimeError!,
                      style: CommonErrorMsg.customTextStyle(context))
                      : const SizedBox(height: AppSize.s12),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Patient Details label ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Patient Details",
              style: TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.mediumgrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── ROW 1: Avatar + info | Address ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 270,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: ColorManager.circleColor,
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _avatarTextColor(initials),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patientName,
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.mediumgrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'MRN: ${widget.mrn}',
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                color: ColorManager.mediumgrey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_formatDate(widget.visitTimeframeFrom)} | ${widget.patientAge}y | ${widget.genderName}',
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                color: ColorManager.mediumgrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.primaryDiagnosisName,
                              style: const TextStyle(
                                fontSize: FontSize.s10,
                                color: Color(0xFF795548),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            color: ColorManager.blueprime, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.patientAddress.isNotEmpty
                                ? widget.patientAddress
                                : 'Address not available',
                            style: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.faintGrey,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── ROW 2: Visit Date | Visit Type ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Date',
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.mediumgrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final picked = await CalendarDialogHelperFeturedate.show(
                            context: context,
                            selectedDate: _visitDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _visitDate = picked);
                          }
                        },
                        child: Container(
                          width: 270,
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _visitDate != null
                                    ? '${_visitDate!.month.toString().padLeft(2, '0')}/'
                                    '${_visitDate!.day.toString().padLeft(2, '0')}/'
                                    '${_visitDate!.year}'
                                    : 'Select',
                                style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: _visitDate != null
                                      ? ColorManager.mediumgrey
                                      : ColorManager.faintGrey,
                                ),
                              ),
                              const Icon(Icons.calendar_month_sharp,
                                  size: 18, color: Colors.black45),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: _infoColumn("Visit Type:", widget.visitType),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── ROW 3: Request Type | Visit Timeframe ───────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 270,
                    child: _infoColumn("Request Type:", widget.requestType),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _infoColumn(
                      "Visit Time Frame:",
                      _formatTimeframe(
                          widget.visitTimeframeFrom, widget.visitTimeframeTo),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],

      // ── Bottom buttons ────────────────────────────────────────────────────────
      bottomButtons: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButtonTransparent(
              text: "Cancel",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: AppSize.s15),
            CustomElevatedButton(
              width: AppSize.s200,
              text: "Approve for a Different Day",
              style: const TextStyle(fontWeight: FontWeight.w500),
              onPressed: _approveForDifferentDay,
              isLoading: _isLoadingDifferentDay,
            ),
            const SizedBox(width: AppSize.s15),
            CustomElevatedButton(
              width: AppSize.s100,
              text: "Approve",
              style: const TextStyle(fontWeight: FontWeight.w500),
              onPressed: _approve,
              isLoading: _isLoadingApprove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, {double maxWidth = 130}) {
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.mediumgrey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: FontSize.s11,
                  color: ColorManager.faintGrey,
                  fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}