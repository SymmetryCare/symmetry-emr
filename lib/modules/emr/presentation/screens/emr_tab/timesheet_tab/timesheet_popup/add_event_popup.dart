import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/timesheet_tab_manager/timesheet_tab_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/emr_textfiled_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';


class AddEventPopup extends StatefulWidget {
  const AddEventPopup({super.key});

  @override
  State<AddEventPopup> createState() => _AddEventPopupState();
}

class _AddEventPopupState extends State<AddEventPopup> {
  final TextEditingController _eventTitleCtrl = TextEditingController(); // ← new
  final TextEditingController _dateCtrl       = TextEditingController();
  final TextEditingController _startTimeCtrl  = TextEditingController();
  final TextEditingController _endTimeCtrl    = TextEditingController();

  DateTime?  _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool       _isLoading = false;

  // ── Supervisor API State ──────────────────────────────────────────────────
  late Future<List<SupervisorData>> _supervisorFuture;
  int?    _selectedSupervisorId;
  String? _selectedSupervisorName;

  @override
  void initState() {
    super.initState();
    _supervisorFuture = _fetchSupervisors();
  }

  Future<List<SupervisorData>> _fetchSupervisors() async {
    final result = await getSupervisors(context: context);
    return result?.data ?? [];
  }

// ── Pickers ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await CalendarDialogHelperFeturedate.show(
      context: context,
      selectedDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day), // today onward only
    );
    if (d != null) {
      setState(() {
        _selectedDate = d;
        _dateCtrl.text = CalendarDialogHelperFeturedate.fmt(d);
      });
    }
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
        ),
        child: child!,
      ),
    );
    if (t != null) {
      setState(() {
        _selectedStartTime = t;
        _startTimeCtrl.text =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
        ),
        child: child!,
      ),
    );
    if (t != null) {
      setState(() {
        _selectedEndTime = t;
        _endTimeCtrl.text =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // ── Formatters ─────────────────────────────────────────────────────────────

  String _formatDateForApi(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  String _formatTimeForApi(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (_eventTitleCtrl.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Please enter an event title',
        ),
      );
      return;
    }
    if (_selectedDate == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Please select a date',
        ),
      );
      return;
    }
    if (_selectedSupervisorId == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Please select a supervisor',
        ),
      );
      return;
    }
    if (_selectedStartTime == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Please select a start time',
        ),
      );
      return;
    }
    if (_selectedEndTime == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          message: 'Please select an end time',
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await postClinicianEvent(
      context: context,
      eventTitle: _eventTitleCtrl.text.trim(),
      date: _formatDateForApi(_selectedDate!),
      supervisorId: _selectedSupervisorId ?? 0,
      startTime: _formatTimeForApi(_selectedStartTime!),
      endTime: _formatTimeForApi(_selectedEndTime!),
    );

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context, true);
      showDialog(
        context: context,
        builder: (_) => const EMRSuccessPopup(
          message: 'Event Added Successfully',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => EMRFailedPopup(
          message: result.message ?? 'Something went wrong!',
        ),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtons(
      width: 900,
      height:350,
      title: "Add Event",
      body: [
        Column(
          children: [
            const SizedBox(height: 5),
            // ── Two-column body ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Select Event (text field) ─────────────────────
                      _label('Select Event'),
                      EmrTextField(
                        height: 35,
                        controller: _eventTitleCtrl,
                        hintText: 'Enter event title',
                      ),

                      const SizedBox(height: 14),

                      // ── Select Date ───────────────────────────────────
                      _label('Select Date'),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: EmrTextField(
                            height: 35,
                            controller: _dateCtrl,
                            hintText: 'yyyy/mm/dd',
                            suffixIcon: Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: ColorManager.blueprime,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Select Supervisor ─────────────────────────────
                      _label('Select Supervisor'),
                      FutureBuilder<List<SupervisorData>>(
                        future: _supervisorFuture,
                        builder: (context, snapshot) {
                          final List<SupervisorData> list =
                              snapshot.data ?? [];
                          return EmrDropdownConst(
                            dropDownMenuList: list
                                .map((s) => DropdownMenuItem<String>(
                              value: s.name,
                              child: Text(s.name ?? ''),
                            ))
                                .toList(),
                            hintText: _selectedSupervisorName ?? 'Select',
                            height: 35,
                            onChanged: (val) {
                              if (val == null) return;
                              final match = list.firstWhere(
                                    (s) => s.name == val,
                                orElse: () => SupervisorData(
                                    employeeId: 0, name: val),
                              );
                              setState(() {
                                _selectedSupervisorId   = match.employeeId;
                                _selectedSupervisorName = match.name;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                // Right Column
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ── Select Start Time ─────────────────────────────
                      _label('Select Start Time'),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: _pickStartTime,
                        child: AbsorbPointer(
                          child: EmrTextField(
                            controller: _startTimeCtrl,
                            hintText: '12:00',
                            suffixIcon: Icon(
                              Icons.access_time,
                              size: 18,
                              color: ColorManager.blueprime,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Select End Time ───────────────────────────────
                      _label('Select End Time'),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: _pickEndTime,
                        child: AbsorbPointer(
                          child: EmrTextField(
                            controller: _endTimeCtrl,
                            hintText: '13:00',
                            suffixIcon: Icon(
                              Icons.access_time,
                              size: 18,
                              color: ColorManager.blueprime,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButtonTransparent(text: 'Cancel', onPressed: () => Navigator.pop(context)),
                const SizedBox(width: 16),
                _isLoading
                    ? SizedBox(
                  width: AppSize.s100,
                  height: AppSize.s35,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: ColorManager.blueprime,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                )
                    : SizedBox(
                  width: AppSize.s100,
                  height: AppSize.s35,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.blueprime,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child:  Text('Save',style:  BlueButtonTextConst.customTextStyle(context),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}