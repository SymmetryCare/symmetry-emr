import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/services/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import '../../../../../../../../../data/api_data/emr_module_data/emr_dash_data/reminder_model.dart';
import '../../../../../../../em_module/company_identity/widgets/whitelabelling/success_popup.dart';

class EditCheckboxListPopupRightWidget extends StatefulWidget {
  final ReminderDataPrefill preFillData;
  const EditCheckboxListPopupRightWidget({super.key, required this.preFillData});

  @override
  State<EditCheckboxListPopupRightWidget> createState() =>
      _EditCheckboxListPopupRightWidgetState();
}

class _EditCheckboxListPopupRightWidgetState
    extends State<EditCheckboxListPopupRightWidget> {

  late TextEditingController _noteCtrl;
  late TextEditingController _dateCtrl;
  late String _priority;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedEndTime;
  DateTime? _selectedDate;
  bool _isLoading = false;

  // ── Validation error states ───────────────────────────────────────────────
  String? _titleError;
  String? _dateError;
  String? _startTimeError;
  String? _endTimeError;

  // ── Robust time parser ────────────────────────────────────────────────────
  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim().toUpperCase();
    final formats = ['hh:mm a', 'h:mm a', 'HH:mm:ss', 'HH:mm'];
    for (final fmt in formats) {
      try {
        final t = DateFormat(fmt).parse(s);
        return TimeOfDay(hour: t.hour, minute: t.minute);
      } catch (_) {}
    }
    debugPrint("_parseTime: could not parse '$raw'");
    return null;
  }

  @override
  void initState() {
    super.initState();
    final data = widget.preFillData.data;

    _noteCtrl = TextEditingController(text: data?.title ?? '');

    final raw = data?.priority ?? 'High';
    _priority = raw.isNotEmpty
        ? raw[0].toUpperCase() + raw.substring(1).toLowerCase()
        : 'High';

    _dateCtrl = TextEditingController();
    if (data?.date != null && data!.date.isNotEmpty) {
      try {
        final parsed = DateFormat('yyyy-MM-dd').parse(data.date);
        _selectedDate = parsed;
        final dd = parsed.day.toString().padLeft(2, '0');
        final mm = parsed.month.toString().padLeft(2, '0');
        _dateCtrl.text = '$dd/$mm/${parsed.year}';
      } catch (_) {}
    }

    _selectedTime    = _parseTime(data?.startTime);
    _selectedEndTime = _parseTime(data?.endTime);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // ── Pickers ───────────────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
        ),
        child: child!,
      ),
    );
    if (t != null) {
      setState(() {
        _selectedTime = t;
        _startTimeError = null;
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
        _endTimeError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        _selectedDate = d;
        final dd = d.day.toString().padLeft(2, '0');
        final mm = d.month.toString().padLeft(2, '0');
        _dateCtrl.text = '$dd/$mm/${d.year}';
        _dateError = null;
      });
    }
  }

  // ── Formatters ────────────────────────────────────────────────────────────
  String _formatTimeForApi(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDateForApi(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    bool valid = true;

    if (_noteCtrl.text.trim().isEmpty) {
      _titleError = "Title is required";
      valid = false;
    } else if (_noteCtrl.text.trim().length < 3) {
      _titleError = "Title must be at least 3 characters";
      valid = false;
    } else {
      _titleError = null;
    }

    if (_selectedDate == null) {
      _dateError = "Please select a date";
      valid = false;
    } else {
      _dateError = null;
    }

    if (_selectedTime == null) {
      _startTimeError = "Please select a start time";
      valid = false;
    } else {
      _startTimeError = null;
    }

    if (_selectedEndTime == null) {
      _endTimeError = "Please select an end time";
      valid = false;
    } else {
      _endTimeError = null;
    }

    if (_selectedTime != null && _selectedEndTime != null) {
      final startMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
      final endMinutes   = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
      if (endMinutes <= startMinutes) {
        _endTimeError = "End time must be after start time";
        valid = false;
      }
    }

    setState(() {});
    return valid;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _onUpdateReminder() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final result = await patchToDoReminder(
      context: context,
      reminderId: widget.preFillData.data!.reminderId,
      title: _noteCtrl.text.trim(),
      date: _formatDateForApi(_selectedDate!),
      startTime: _formatTimeForApi(_selectedTime!),
      endTime: _formatTimeForApi(_selectedEndTime!),
      priority: _priority,
      isCompleted: widget.preFillData.data?.isCompleted ?? false,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context, true);
      showDialog(
        context: context,
        builder: (_) => const AddSuccessPopup(
          message: 'Reminder Updated Successfully',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const AddErrorPopup(
          message: 'Something went wrong!',
        ),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  BoxDecoration _fieldDecoration(String? error) => BoxDecoration(
    border: Border.all(
      color: error != null ? Colors.red.shade400 : Colors.grey.shade300,
      width: error != null ? 1.4 : 1.0,
    ),
    borderRadius: BorderRadius.circular(10),
  );

  /// Always reserves 18px height so layout never shifts
  Widget _errorText(String? error) {
    return SizedBox(
      height: 18,
      child: error != null
          ? Padding(
        padding: const EdgeInsets.only(top: 3, left: 4),
        child: Text(
          error,
          style: TextStyle(fontSize: 11, color: Colors.red.shade600),
        ),
      )
          : null,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 210, vertical: 150),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Edit",
        body: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left Column — Title & Priority ────────────────
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Title",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: _fieldDecoration(_titleError),
                          child: Center(
                            child: TextField(
                              controller: _noteCtrl,
                              style: const TextStyle(fontSize: 13),
                              cursorColor: Colors.grey.shade400,
                              onChanged: (_) {
                                if (_titleError != null) {
                                  setState(() => _titleError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Enter reminder note",
                                hintStyle: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade400),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        _errorText(_titleError),

                        // Space between title-error row and Priority label
                        const SizedBox(height: 4),

                        const Text("Priority",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _priorityRadio("High"),
                            _priorityRadio("Medium"),
                            _priorityRadio("Low"),
                            const SizedBox(width: 50),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 60),

                  // ── Right Column — Date, Start Time, End Time ─────
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        const Text("Select Date",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: _fieldDecoration(_dateError),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16,
                                    color: _dateError != null
                                        ? Colors.red.shade400
                                        : Colors.blue.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _dateCtrl.text.isNotEmpty
                                        ? _dateCtrl.text
                                        : 'DD/MM/YYYY',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _dateCtrl.text.isNotEmpty
                                          ? Colors.black87
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _errorText(_dateError),

                        // Start Time
                        const Text("Start Time",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: _fieldDecoration(_startTimeError),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 18,
                                    color: _startTimeError != null
                                        ? Colors.red.shade400
                                        : Colors.blue.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : '09:00 AM',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedTime != null
                                          ? Colors.black87
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _errorText(_startTimeError),

                        // End Time
                        const Text("End Time",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickEndTime,
                          child: Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: _fieldDecoration(_endTimeError),
                            child: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 18,
                                    color: _endTimeError != null
                                        ? Colors.red.shade400
                                        : Colors.blue.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedEndTime != null
                                        ? _selectedEndTime!.format(context)
                                        : '10:00 AM',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedEndTime != null
                                          ? Colors.black87
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _errorText(_endTimeError),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _isLoading
                      ? SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: ColorManager.blueprime,
                    ),
                  )
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.bluebottom,
                    ),
                    onPressed: _onUpdateReminder,
                    child: const Text("Set Reminder"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priorityRadio(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          hoverColor: Colors.transparent,
          splashRadius: 0,
          value: value,
          groupValue: _priority,
          activeColor: Colors.blue,
          onChanged: (val) => setState(() => _priority = val!),
        ),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}