import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/view_history_popup.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/time_off_data.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/setting_profile_manager/time_off_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/emr_textfiled_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';

class TimeOffScreen extends StatefulWidget {
  final int employeeId;
  const TimeOffScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<TimeOffScreen> createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {

  // ── API futures ──────────────────────────────────────────────
  late Future<List<TimeOffTypeData>> _timeOffTypeFuture;
  late Future<List<LeaveTypeData>>   _leaveTypeFuture;

  // ── Reset key ────────────────────────────────────────────────
  int _dropdownResetKey = 0;

  // ── Selected state ───────────────────────────────────────────
  int?    _selectedTimeOffTypeId;
  String? _selectedTimeOffTypeName;

  int?    _selectedLeaveTypeId;
  String? _selectedLeaveTypeName;

  bool _isFirstHalf  = false;
  bool _isSubmitting = false;

  // ── Date & Time state ────────────────────────────────────────
  DateTime?  _startDate;
  DateTime?  _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // ── Controllers ──────────────────────────────────────────────
  final TextEditingController _reasonController    = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController   = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController   = TextEditingController();

  // ── Leave mode getter ────────────────────────────────────────
  String get _leaveMode {
    final name = _selectedLeaveTypeName?.toLowerCase() ?? '';
    if (name.contains('hourly')) return 'hourly';
    if (name.contains('half'))   return 'half';
    if (name.contains('one'))    return 'one';
    return 'multi';
  }

  @override
  void initState() {
    super.initState();
    _timeOffTypeFuture = getTimeOffTypes(context: context);
    _leaveTypeFuture   = getLeaveTypes(context: context);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // ── Format helpers ───────────────────────────────────────────
  String _formatDate(DateTime? date) =>
      date != null
          ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
          : '';

  String _formatTime(TimeOfDay? time) =>
      time != null
          ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
          : '';

  // ── Helper: compares only year/month/day, ignoring time ──────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Popup helpers ─────────────────────────────────────────────
  void _showFailed(String message) {
    showDialog(
      context: context,
      builder: (_) => EMRFailedPopup(
        title: 'Failed',
        message: message,
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (_) => EMRSuccessPopup(
        title: 'Success',
        message: message,
      ),
    );
  }

  // ── Pickers ──────────────────────────────────────────────────
// ── Pickers ──────────────────────────────────────────────────
  Future<void> _pickDate({required bool isStart}) async {
    final DateTime todayOnly = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // ── Start date: hide everything before today ──
    // ── End date: hide everything up to and including Start date ──
    final DateTime minAllowed = isStart
        ? todayOnly
        : (_startDate != null
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
        .add(const Duration(days: 1))
        : todayOnly);

    final DateTime? picked = await CalendarDialogHelperFeturedate.show(
      context: context,
      selectedDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: minAllowed,
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate                = picked;
        _startDateController.text = CalendarDialogHelperFeturedate.fmt(picked);

        // ── If the newly picked Start date invalidates the ──
        // ── already-selected End date, clear the End date. ──
        if (_endDate != null &&
            (_isSameDay(_endDate!, picked) || _endDate!.isBefore(picked))) {
          _endDate = null;
          _endDateController.clear();
        }
      } else {
        _endDate                  = picked;
        _endDateController.text   = CalendarDialogHelperFeturedate.fmt(picked);
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue.shade700),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime                = picked;
        _startTimeController.text = _formatTime(picked);
      } else {
        _endTime                  = picked;
        _endTimeController.text   = _formatTime(picked);
      }
    });
  }

  // ── Reset dynamic fields ─────────────────────────────────────
  void _resetDynamicFields() {
    _startDate               = null;
    _endDate                 = null;
    _startTime               = null;
    _endTime                 = null;
    _isFirstHalf             = false;
    _startDateController.clear();
    _endDateController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
  }

  // ── Half day radio helper ────────────────────────────────────
  Widget _halfOption({required String label, required bool value}) {
    final selected = _isFirstHalf == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isFirstHalf = value),
        child: Row(
          children: [
            Radio<bool>(
              value: value,
              groupValue: _isFirstHalf,
              activeColor: ColorManager.blueprime,
              onChanged: (val) => setState(() => _isFirstHalf = val!),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected
                    ? ColorManager.blueprime
                    : const Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit handler ───────────────────────────────────────────
  Future<void> _handleSubmit() async {
    if (_selectedTimeOffTypeId == null) {
      _showFailed('Please select a\nTime Off type.');
      return;
    }
    if (_selectedLeaveTypeId == null) {
      _showFailed('Please select a\nLeave type.');
      return;
    }
    if (_leaveMode == 'half' && _startDate == null) {
      _showFailed('Please select\na date.');
      return;
    }
    if (_leaveMode == 'one' && _startDate == null) {
      _showFailed('Please select\na date.');
      return;
    }
    if (_leaveMode == 'multi' && _startDate == null) {
      _showFailed('Please select\na Start date.');
      return;
    }
    if (_leaveMode == 'multi' && _endDate == null) {
      _showFailed('Please select\nan End date.');
      return;
    }
    if (_leaveMode == 'hourly' && _startTime == null) {
      _showFailed('Please select\na Start time.');
      return;
    }
    if (_leaveMode == 'hourly' && _endTime == null) {
      _showFailed('Please select\nan End time.');
      return;
    }

    print("---- employeeId from TokenManager: $widget.employeeId ----");
    print("---- _handleSubmit CALLED ----");
    print("employeeId     : $widget.employeeId");
    print("timeOffTypeId  : $_selectedTimeOffTypeId");
    print("timeOffTypeName: $_selectedTimeOffTypeName");
    print("leaveTypeId    : $_selectedLeaveTypeId");
    print("leaveTypeName  : $_selectedLeaveTypeName");
    print("leaveMode      : $_leaveMode");
    print("startDate      : ${_formatDate(_startDate)}");
    print("endDate        : ${_formatDate(_endDate)}");
    print("startTime      : ${_formatTime(_startTime)}");
    print("endTime        : ${_formatTime(_endTime)}");
    print("isFirstHalf    : $_isFirstHalf");
    print("reason         : ${_reasonController.text.trim()}");
    print("------------------------------");

    setState(() => _isSubmitting = true);

    final result = await addTimeOff(
      context: context,
      employeeId: widget.employeeId,
      timeOffTypeId: _selectedTimeOffTypeId!,
      leaveTypeId: _selectedLeaveTypeId!,
      startDate: _leaveMode == 'hourly'
          ? _formatTime(_startTime)
          : _formatDate(_startDate),
      endDate: _leaveMode == 'hourly'
          ? _formatTime(_endTime)
          : _leaveMode == 'one' || _leaveMode == 'half'
          ? _formatDate(_startDate)
          : _formatDate(_endDate),
      reason: _reasonController.text.trim(),
      firstHalf: _isFirstHalf,
    );

    print("---- _handleSubmit RESULT ----");
    print("success   : ${result.success}");
    print("statusCode: ${result.statusCode}");
    print("message   : ${result.message}");
    print("------------------------------");

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      _showSuccess('Time off request\nsubmitted successfully.');
      print("---- Form Reset ----");
      setState(() {
        _selectedTimeOffTypeId   = null;
        _selectedTimeOffTypeName = null;
        _selectedLeaveTypeId     = null;
        _selectedLeaveTypeName   = null;
        _dropdownResetKey++;           // ← forces dropdowns to remount
        _resetDynamicFields();
      });
      _reasonController.clear();
    } else {
      _showFailed(result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Left sidebar ─────────────────────────────────────
            Container(
              width: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FB),
                  borderRadius: BorderRadius.circular(5)
              ),
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Available Time Off',
                    style: TextStyle(fontSize: 12, color: ColorManager.blueprime),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '36.0 hours',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.blueprime,
                    ),
                  ),
                ],
              ),
            ),

            // ── Main content ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Request Time Off',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ViewHistoryPopup(
                                  employeeId: widget.employeeId),
                            );
                          },
                          icon: const Icon(Icons.history, size: 16),
                          label: const Text(
                            'View history',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF555555),
                            backgroundColor: const Color(0xFFE8F4FB),
                            side: const BorderSide(color: Color(0xFFBBDEFB)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Two column layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Column 1 ────────────────────────────
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ── Time Off Type ──────────────────
                              const Text(
                                'Time Off type',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              KeyedSubtree(
                                key: ValueKey('timeOffType_$_dropdownResetKey'),
                                child: FutureBuilder<List<TimeOffTypeData>>(
                                  future: _timeOffTypeFuture,
                                  builder: (context, snapshot) {
                                    final List<TimeOffTypeData> list =
                                        snapshot.data ?? [];
                                    return EmrDropdownConst(
                                      dropDownMenuList: list
                                          .map((t) => DropdownMenuItem<String>(
                                        value: t.name,
                                        child: Text(t.name!),
                                      ))
                                          .toList(),
                                      hintText:
                                      _selectedTimeOffTypeName ?? 'Select',
                                      height: 35,
                                      onChanged: (newValue) {
                                        if (newValue == null) return;
                                        final match = list.firstWhere(
                                              (t) => t.name == newValue,
                                          orElse: () => TimeOffTypeData(
                                              id: 0, name: newValue),
                                        );
                                        setState(() {
                                          _selectedTimeOffTypeId   = match.id;
                                          _selectedTimeOffTypeName = match.name;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Leave Type ─────────────────────
                              const Text(
                                'Leave type',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              KeyedSubtree(
                                key: ValueKey('leaveType_$_dropdownResetKey'),
                                child: FutureBuilder<List<LeaveTypeData>>(
                                  future: _leaveTypeFuture,
                                  builder: (context, snapshot) {
                                    final List<LeaveTypeData> list =
                                        snapshot.data ?? [];
                                    return EmrDropdownConst(
                                      dropDownMenuList: list
                                          .map((t) => DropdownMenuItem<String>(
                                        value: t.name,
                                        child: Text(t.name!),
                                      ))
                                          .toList(),
                                      hintText:
                                      _selectedLeaveTypeName ?? 'Select',
                                      height: 35,
                                      onChanged: (newValue) {
                                        if (newValue == null) return;
                                        final match = list.firstWhere(
                                              (t) => t.name == newValue,
                                          orElse: () =>
                                              LeaveTypeData(id: 0, name: newValue),
                                        );
                                        setState(() {
                                          _selectedLeaveTypeId   = match.id;
                                          _selectedLeaveTypeName = match.name;
                                          _resetDynamicFields();
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),

                              // ── Dynamic fields by leave mode ───
                              if (_selectedLeaveTypeName != null) ...[
                                const SizedBox(height: 20),

                                // HOURLY ── Time Range
                                if (_leaveMode == 'hourly') ...[
                                  const Text(
                                    'Time Range',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _pickTime(isStart: true),
                                          child: AbsorbPointer(
                                            child: EmrTextField(
                                              controller: _startTimeController,
                                              height: 35,
                                              hintText: '00:00',
                                              suffixIcon: const Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          'To',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              _pickTime(isStart: false),
                                          child: AbsorbPointer(
                                            child: EmrTextField(
                                              controller: _endTimeController,
                                              height: 35,
                                              hintText: '00:00',
                                              suffixIcon: const Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                // HALF DAY ── Radio + Date
                                if (_leaveMode == 'half') ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        _halfOption(
                                            label: 'First half', value: true),
                                        _halfOption(
                                            label: 'Second half', value: false),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _pickDate(isStart: true),
                                    child: AbsorbPointer(
                                      child: EmrTextField(
                                        controller: _startDateController,
                                        height: 35,
                                        hintText: 'Select date',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // ONE DAY ── Single Date
                                if (_leaveMode == 'one') ...[
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _pickDate(isStart: true),
                                    child: AbsorbPointer(
                                      child: EmrTextField(
                                        controller: _startDateController,
                                        height: 35,
                                        hintText: 'Select date',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // MULTI DAY ── Start & End Date
                                if (_leaveMode == 'multi') ...[
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _pickDate(isStart: true),
                                    child: AbsorbPointer(
                                      child: EmrTextField(
                                        controller: _startDateController,
                                        height: 35,
                                        hintText: 'Select start date',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'End Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _pickDate(isStart: false),
                                    child: AbsorbPointer(
                                      child: EmrTextField(
                                        controller: _endDateController,
                                        height: 35,
                                        hintText: 'Select end date',
                                        suffixIcon: const Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],

                              const SizedBox(height: 20),

                              // ── Reason ─────────────────────────
                              const Text(
                                'Reason for Time Off (optional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              EmrTextField(
                                controller: _reasonController,
                                height: 35,
                              ),
                              const SizedBox(height: 28),

                              // ── Cancel / Submit ────────────────
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isSubmitting ? null : () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                        ColorManager.blueprime,
                                        side:  BorderSide(
                                            color: ColorManager.blueprime),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                      ),
                                      child:  Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ColorManager.blueprime,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _handleSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        ColorManager.blueprime,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                        elevation: 0,
                                        disabledBackgroundColor: const Color(0xFFBFBFBF),
                                        disabledForegroundColor: Colors.white,
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                          : const Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // ── Column 2 (empty) ─────────────────────
                        const Expanded(flex: 5, child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}