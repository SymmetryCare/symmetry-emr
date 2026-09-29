import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class AddReminderPopup extends StatefulWidget {
  @override
  _AddReminderPopupState createState() => _AddReminderPopupState();
}

class _AddReminderPopupState extends State<AddReminderPopup> {
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedEndTime;
  DateTime? _selectedDate;
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  String _priority = "High";
  bool _isLoading = false;

  // ── Validation error states ───────────────────────────────────────────────
  String? _titleError;
  String? _dateError;
  String? _startTimeError;
  String? _endTimeError;

  // ── Pickers ───────────────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: ColorManager.blueprime),
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
    final now = TimeOfDay.now();
    final nowPlus10 = TimeOfDay(
      hour: (now.hour + (now.minute + 10) ~/ 60) % 24,
      minute: (now.minute + 10) % 60,
    );

    final t = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? nowPlus10,
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: ColorManager.blueprime),
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: ColorManager.blueprime),
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
  Future<void> _onSetReminder() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final result = await addToDoReminder(
      context: context,
      title: _noteCtrl.text.trim(),
      date: _formatDateForApi(_selectedDate!),
      startTime: _formatTimeForApi(_selectedTime!),
      endTime: _formatTimeForApi(_selectedEndTime!),
      priority: _priority,
      isCompleted: false,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context, true);
      showDialog(
        context: context,
        builder: (_) => const AddSuccessPopup(
          message: 'Reminder Added Successfully',
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
      color: Colors.grey.shade300,
      width: 1.0,
    ),
    borderRadius: BorderRadius.circular(10),
  );

  /// Always reserves 18px — layout never shifts when error appears/disappears
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
      padding: const EdgeInsets.symmetric(horizontal: 210),
      child: DialogueTemplateNoButtons(
        width: AppSize.s700,
        height: AppSize.s380,
        title: "Add Reminder",
        body: [
          Column(
            children: [
              const SizedBox(width: AppSize.s10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left Column — Title & Priority ────────────────
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Title",
                            style: AllPopupHeadings.customTextStyle(context)),
                        const SizedBox(height: 6),
                        Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: _fieldDecoration(_titleError),
                          child: Center(
                            child: TextField(
                              controller: _noteCtrl,
                              style: DocumentTypeDataStyle.customTextStyle(context),
                              cursorColor: ColorManager.mediumgrey,
                              onChanged: (_) {
                                if (_titleError != null) {
                                  setState(() => _titleError = null);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Enter reminder note",
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
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

                      const SizedBox(height: AppSize.s10),

                      Text("Priority",
                          style: AllPopupHeadings.customTextStyle(context)),
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

                const SizedBox(width: 30),

                // ── Right Column — Date, Start Time, End Time ─────
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date
                      Text("Select Date",
                          style: AllPopupHeadings.customTextStyle(context)),
                      const SizedBox(height: 6),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: _pickDate,
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: _fieldDecoration(_dateError),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _dateCtrl.text.isNotEmpty
                                      ? _dateCtrl.text
                                      : 'DD/MM/YYYY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: FontSize.s13,
                                    color: _dateCtrl.text.isNotEmpty
                                        ? ColorManager.mediumgrey
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.calendar_today,
                                  size: 16,
                                  color: ColorManager.blueprime),
                            ],
                          ),
                        ),
                      ),
                      _errorText(_dateError),
                      const SizedBox(height: AppSize.s10),
                      Text("Start Time",
                          style: AllPopupHeadings.customTextStyle(context)),
                      const SizedBox(height: 6),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: _pickTime,
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: _fieldDecoration(_startTimeError),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : '09:00 AM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: FontSize.s13,
                                    color: _selectedTime != null
                                        ? ColorManager.mediumgrey
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.access_time,
                                  size: 18,
                                  color: ColorManager.blueprime),
                            ],
                          ),
                        ),
                      ),
                      _errorText(_startTimeError),
                      const SizedBox(height: AppSize.s10),
                      Text("End Time",
                          style: AllPopupHeadings.customTextStyle(context)),
                      const SizedBox(height: 6),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: _pickEndTime,
                        child: Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: _fieldDecoration(_endTimeError),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedEndTime != null
                                      ? _selectedEndTime!.format(context)
                                      : '10:00 AM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: FontSize.s13,
                                    color: _selectedEndTime != null
                                        ? ColorManager.mediumgrey
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.access_time,
                                  size: 18,
                                  color: ColorManager.blueprime),
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
                CustomElevatedButton(
                  onPressed: _onSetReminder,
                  text: "Set Reminder",
                  isLoading: _isLoading,
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
          activeColor: ColorManager.blueprime,
          onChanged: (val) => setState(() => _priority = val!),
        ),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: FontSize.s13,
          color: ColorManager.mediumgrey,
        ),),
      ],
    );
  }
}