import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/visit_details_type_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/calender_map_data/calender_map_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/visist_type_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/emr_calender_screen.dart';

class EditDetailsDialog extends StatefulWidget {
  final ClinicianCalendarVisitData visit;
  const EditDetailsDialog({super.key, required this.visit});

  @override
  State<EditDetailsDialog> createState() => _EditDetailsDialogState();
}

class _EditDetailsDialogState extends State<EditDetailsDialog> {
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  late Future<List<VisitListData>> _visitListFuture;
  int? _selectedVisitId;
  String? _selectedVisitType;
  bool _isSaving = false;
  final TextEditingController _dateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedVisitType = widget.visit.visitTypeName;
    _visitListFuture = getVisitList(context);

    if (widget.visit.visiteDateTimeFrom != null &&
        widget.visit.visiteDateTimeFrom!.isNotEmpty) {
      try {
        final dt =
        DateTime.parse(widget.visit.visiteDateTimeFrom!).toLocal();
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        final dd = dt.day.toString().padLeft(2, '0');
        final mm = dt.month.toString().padLeft(2, '0');
        _dateCtrl.text = '$dd/$mm/${dt.year}';
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  // ── Build ISO datetime string from selected date + time ──────────────────
  String _buildDateTime(TimeOfDay time) {
    final date = _selectedDate ?? DateTime.now();
    final dt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    return dt.toUtc().toIso8601String();
  }

  Future<void> _onSave() async {
    if (_selectedVisitId == null) return;
    setState(() => _isSaving = true);
    try {
      // ── build from/to datetimes ───────────────────────────────────
      String fromStr = '';
      String toStr = '';
      if (_selectedTime != null) {
        fromStr = _buildDateTime(_selectedTime!);
        // to = from + 1 hour by default
        final toTime = TimeOfDay(
          hour: (_selectedTime!.hour + 1) % 24,
          minute: _selectedTime!.minute,
        );
        toStr = _buildDateTime(toTime);
      } else if (widget.visit.visiteDateTimeFrom != null &&
          widget.visit.visiteDateTimeFrom!.isNotEmpty) {
        fromStr = widget.visit.visiteDateTimeFrom!;
        toStr = widget.visit.visitDateTimeTo ?? '';
      }

      final result = await updatePatientVisitcalender(
        context,
        (widget.visit.visitId ?? 0).toString(),
        widget.visit.patientId ?? 0,
        _selectedVisitId!,
        visiteDateTimeFrom: fromStr,
        visitDateTimeTo: toStr,
      );
      print("=== updatePatientVisitcalender ===");
      print("visitId: ${widget.visit.visitId}");
      print("patientId: ${widget.visit.patientId}");
      print("selectedVisitId: $_selectedVisitId");
      print("fromStr: $fromStr");
      print("toStr: $toStr");

      if (!mounted) return;
      Navigator.pop(context);
      if (result.success) {
        showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            title: 'Success',
            message: 'Visit updated successfully.',
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
          ColorScheme.light(primary: ColorManager.blueprime),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
          ColorScheme.light(primary: ColorManager.blueprime),
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
      });
    }
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700),
  );

  @override
  Widget build(BuildContext context) {
    // ✅ Switched from a hand-rolled Dialog/header to the shared
    // DialogueTemplate widget so this popup matches the rest of the app's
    // popup chrome (blue title bar, close icon, consistent padding) instead
    // of duplicating that structure locally.
    return DialogueTemplate(
      width: 400,
      height: 430,
      title: 'Edit Details',
      isScrollable: false,
      body: [
        // ── Patient name (read-only) ──────────────────────
        if (widget.visit.patientName != null &&
            widget.visit.patientName!.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: _fieldLabel('Patient'),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.visit.patientName!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // ── Select Time ───────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: _fieldLabel('Select Time'),
        ),
        const SizedBox(height: 6),
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: _pickTime,
          child: Container(
            width: double.infinity,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : '9:00 AM',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedTime != null
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(Icons.access_time,
                    color: ColorManager.blueprime, size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // ── Select Date ───────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: _fieldLabel('Select Date'),
        ),
        const SizedBox(height: 6),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dateCtrl.text.isNotEmpty
                        ? _dateCtrl.text
                        : '02/12/2026',
                    style: TextStyle(
                      fontSize: 13,
                      color: _dateCtrl.text.isNotEmpty
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today,
                    color: ColorManager.blueprime, size: 16),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // ── Visit Type ────────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: _fieldLabel('Visit Type'),
        ),
        const SizedBox(height: 6),
        FutureBuilder<List<VisitListData>>(
          future: _visitListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                height: 35,
                padding:
                const EdgeInsets.only(bottom: 3, top: 5, left: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedVisitType ??
                          widget.visit.visitTypeName ??
                          'Select',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                    ),
                    const Icon(Icons.arrow_drop_down_sharp,
                        color: Colors.grey),
                  ],
                ),
              );
            }
            final List<VisitListData> list = snapshot.data ?? [];
            if (list.isEmpty) {
              return const SizedBox(
                height: 35,
                child: Center(
                  child: Text(
                    'No visit types found',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              );
            }
            return VisitTypeDropdown(
              hintText: _selectedVisitType ??
                  widget.visit.visitTypeName ??
                  'Select',
              items: list,
              height: 35,
              onChanged: (visitId, typeOfVisit) {
                setState(() {
                  _selectedVisitId = visitId;
                  _selectedVisitType = typeOfVisit;
                });
              },
            );
          },
        ),
      ],
      bottomButtons: _isSaving
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: ColorManager.blueprime),
      )
          : SizedBox(
        width: 80,
        height: 30,
        child: ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.blueprime,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text(
            "Save",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}