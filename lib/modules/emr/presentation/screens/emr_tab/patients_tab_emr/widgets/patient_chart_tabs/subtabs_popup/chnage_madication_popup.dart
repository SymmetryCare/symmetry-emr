import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/add_medication_popup.dart';

enum MedicationStatusType { existing, new_, changed }

class ChnageMadicationPopup extends StatefulWidget {
  const ChnageMadicationPopup({super.key});

  @override
  State<ChnageMadicationPopup> createState() => _ChnageMadicationPopupState();
}

class _ChnageMadicationPopupState extends State<ChnageMadicationPopup> {

  TextStyle get _labelStyle => TextStyle(
    fontSize: FontSize.s11,
    fontWeight: FontWeight.w600,
    color: ColorManager.darkgrey,
  );

  MedicationStatusType _selectedStatus = MedicationStatusType.changed;
  bool _purposeChecked = true;
  bool _directionsChecked = true;
  bool _sideEffectsChecked = true;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _changeDate = DateTime.now();

  final TextEditingController _medicationController =
  TextEditingController(text: 'Lisinopril 10 mg Tablet');
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _indicationController =
  TextEditingController(text: 'Hypertension');
  final TextEditingController _changeDateController = TextEditingController();
  final TextEditingController _specialInstructionsController =
  TextEditingController(text: 'N/A');

  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await CalendarDialogHelper.show(
      context: context,
      selectedDate: selectedDate,
    );
    if (picked != null) {
      onPicked(picked);
      controller.text = CalendarDialogHelper.fmt(picked);
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _doseController.dispose();
    _frequencyController.dispose();
    _indicationController.dispose();
    _changeDateController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s700,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Blue header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.s8),
                  topRight: Radius.circular(AppSize.s8),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p5, horizontal: AppPadding.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Change Medication',
                    style: PopupBlueBarText.customTextStyle(context),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: ColorManager.white),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Medication row ───────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: AppSize.s80,
                        child: Text('Medication*', style: _labelStyle),
                      ),
                      const SizedBox(width: AppSize.s6),
                      SizedBox(
                        width: 300,
                        child: AppTextField(
                          controller: _medicationController,
                          hint: 'enter medication',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.s12),

                  // ── Radio + Fields ───────────────────────────────
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Row 1: Existing + Start Date + Dose
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: AppSize.s15,
                            child: _RadioOption(
                              label: 'Existing',
                              value: MedicationStatusType.existing,
                              groupValue: _selectedStatus,
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          SizedBox(
                            width: AppSize.s60,
                            child: Text('Start Date*', style: _labelStyle),
                          ),
                          const SizedBox(width: AppSize.s6),
                          SizedBox(
                            width: 150,
                            child: AppTextField(
                              controller: _startDateController,
                              hint: 'mm/dd/yyyy',
                              readOnly: true,
                              onTap: () => _pickDate(
                                controller: _startDateController,
                                selectedDate: _startDate,
                                onPicked: (d) =>
                                    setState(() => _startDate = d),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                size: AppSize.s13,
                                color: ColorManager.blueprime,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          SizedBox(
                            width: AppSize.s100,
                            child: Text('Dose*', style: _labelStyle),
                          ),
                          const SizedBox(width: AppSize.s6),
                          SizedBox(
                            width: 150,
                            child: AppTextField(
                              controller: _doseController,
                              hint: 'enter text',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSize.s8),

                      // Row 2: New + End Date + Frequency
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: AppSize.s35,
                            child: _RadioOption(
                              label: 'New',
                              value: MedicationStatusType.new_,
                              groupValue: _selectedStatus,
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          SizedBox(
                            width: AppSize.s60,
                            child: Text('End Date*', style: _labelStyle),
                          ),
                          const SizedBox(width: AppSize.s6),
                          SizedBox(
                            width: 150,
                            child: AppTextField(
                              controller: _endDateController,
                              hint: 'mm/dd/yyyy',
                              readOnly: true,
                              onTap: () => _pickDate(
                                controller: _endDateController,
                                selectedDate: _endDate,
                                onPicked: (d) =>
                                    setState(() => _endDate = d),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                size: AppSize.s13,
                                color: ColorManager.blueprime,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          SizedBox(
                            width: AppSize.s100,
                            child: Text('Frequency*', style: _labelStyle),
                          ),
                          const SizedBox(width: AppSize.s6),
                          SizedBox(
                            width: 150,
                            child: AppTextField(
                              controller: _frequencyController,
                              hint: 'enter text',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSize.s8),

                      // Row 3: Changed + Indication
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: AppSize.s35,
                            child: _RadioOption(
                              label: 'Changed',
                              value: MedicationStatusType.changed,
                              groupValue: _selectedStatus,
                              onChanged: (v) =>
                                  setState(() => _selectedStatus = v!),
                            ),
                          ),
                          const SizedBox(width: AppSize.s30),
                          SizedBox(
                            width: AppSize.s100,
                            child: Text('Indication*', style: _labelStyle),
                          ),
                          const SizedBox(width: AppSize.s6),
                          SizedBox(
                            width: 300,
                            child: AppTextField(
                              controller: _indicationController,
                              hint: 'enter text',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.s10),

                  // ── Change Date + Special Instructions ───────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: AppSize.s100,
                            child: Text('Change Date*', style: _labelStyle),
                          ),
                          const SizedBox(height: AppSize.s6),
                          SizedBox(
                            width: 120,
                            child: AppTextField(
                              controller: _changeDateController,
                              hint: 'mm/dd/yyyy',
                              readOnly: true,
                              onTap: () => _pickDate(
                                controller: _changeDateController,
                                selectedDate: _changeDate,
                                onPicked: (d) =>
                                    setState(() => _changeDate = d),
                              ),
                              suffixIcon: Icon(
                                Icons.calendar_month_outlined,
                                size: AppSize.s13,
                                color: ColorManager.blueprime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSize.s10),
                      SizedBox(
                        width: 100,
                        child: Text('Special Instructions:', style: _labelStyle),
                      ),
                      const SizedBox(width: AppSize.s6),
                      SizedBox(
                        width: 300,
                        child: AppTextField(
                          controller: _specialInstructionsController,
                          hint: 'enter text',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.s30),

                  // ── Medication Understanding ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Medication Understanding:', style: _labelStyle),
                      const SizedBox(width: AppSize.s12),
                      _buildCheckbox(
                        'Purpose',
                        _purposeChecked,
                            (val) => setState(() => _purposeChecked = val!),
                      ),
                      const SizedBox(width: AppSize.s8),
                      _buildCheckbox(
                        'Directions For Use',
                        _directionsChecked,
                            (val) => setState(() => _directionsChecked = val!),
                      ),
                      const SizedBox(width: AppSize.s8),
                      _buildCheckbox(
                        'Side Effects/Interactions',
                        _sideEffectsChecked,
                            (val) => setState(() => _sideEffectsChecked = val!),
                      ),
                      const SizedBox(width: AppSize.s8),
                    ],
                  ),

                  const SizedBox(height: AppSize.s30),

                  // ── Buttons ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorManager.blueprime),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p24,
                              vertical: AppPadding.p10),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: ColorManager.blueprime,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.s12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.blueprime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p24,
                              vertical: AppPadding.p10),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.s12),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: handle save & add additional
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.blueprime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p24,
                              vertical: AppPadding.p10),
                        ),
                        child: Text(
                          'Save & Add Additional',
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.s8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppSize.s18,
          height: AppSize.s18,
          child: Checkbox(
            value: value,
            activeColor: ColorManager.blueprime,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSize.s6),
        Text(label, style: _labelStyle),
      ],
    );
  }
}

// ── _RadioOption widget ──────────────────────────────────────────────────────
class _RadioOption extends StatelessWidget {
  final String label;
  final MedicationStatusType value;
  final MedicationStatusType groupValue;
  final ValueChanged<MedicationStatusType?> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppSize.s20,
          height: AppSize.s20,
          child: Radio<MedicationStatusType>(
            value: value,
            groupValue: groupValue,
            activeColor: ColorManager.blueprime,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSize.s6),
        Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s10,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkgrey,
          ),
        ),
      ],
    );
  }
}