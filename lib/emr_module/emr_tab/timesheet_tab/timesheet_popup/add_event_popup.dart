import 'package:flutter/material.dart';

import '../../../../../../app/resources/color.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/timesheet_tab_manager/timesheet_tab_manager.dart';
import '../../../../../../data/api_data/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import '../../emr_const/calender_popup_const.dart';
import '../../emr_const/dropdown_const.dart';
import '../../emr_const/emr_textfiled_const.dart';
import '../../emr_const/sucess_failed_popup_const.dart';
import '../../popup_const_emr.dart';


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
    final d = await CalendarDialogHelper.show(
      context: context,
      selectedDate: _selectedDate ?? DateTime.now(),
    );
    if (d != null) {
      setState(() {
        _selectedDate = d;
        _dateCtrl.text = CalendarDialogHelper.fmt(d);
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 210, vertical: 130),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Add Event",
        body: [
          Column(
            children: [
              // ── Two-column body ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
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
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: EmrTextField(
                              height: 35,
                              controller: _dateCtrl,
                              hintText: 'MM/DD/YYYY',
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey.shade500,
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

                  const SizedBox(width: 20),

                  // Right Column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 35),

                        // ── Select Start Time ─────────────────────────────
                        _label('Select Start Time'),
                        GestureDetector(
                          onTap: _pickStartTime,
                          child: AbsorbPointer(
                            child: EmrTextField(
                              controller: _startTimeCtrl,
                              hintText: '12:00',
                              suffixIcon: Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Select End Time ───────────────────────────────
                        _label('Select End Time'),
                        GestureDetector(
                          onTap: _pickEndTime,
                          child: AbsorbPointer(
                            child: EmrTextField(
                              controller: _endTimeCtrl,
                              hintText: '13:00',
                              suffixIcon: Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Action buttons ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorManager.bluebottom),
                      foregroundColor: ColorManager.bluebottom,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  _isLoading
                      ? SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                      strokeWidth: 2.5,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.bluebottom,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}