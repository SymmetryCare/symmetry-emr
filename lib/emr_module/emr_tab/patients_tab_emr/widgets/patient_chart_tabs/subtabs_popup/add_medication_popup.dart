import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../presentation/widgets/widgets/custom_scrollbar.dart';
import '../../../../../../em_module/widgets/button_constant.dart';

enum MedicationStatusType { existing, new_, changed }

// ── Reusable TextField ────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontSize: FontSize.s11,
          color: ColorManager.darkgrey,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: FontSize.s11,
            color: ColorManager.mediumgrey,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p8,
            vertical: AppPadding.p8,
          ),
          constraints: const BoxConstraints(
            minHeight: AppSize.s35,
            maxHeight: AppSize.s35,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.s4),
            borderSide: BorderSide(color: ColorManager.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.s4),
            borderSide: BorderSide(color: ColorManager.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.s4),
            borderSide: BorderSide(color: ColorManager.grey),
          ),
        ),
      ),
    );
  }
}

// ── Main Popup ────────────────────────────────────────────────────────────────
class AddMedicationPopup extends StatefulWidget {
  const AddMedicationPopup({super.key});

  @override
  State<AddMedicationPopup> createState() => _AddMedicationPopupState();
}

class _AddMedicationPopupState extends State<AddMedicationPopup> {
  MedicationStatusType _selectedStatus = MedicationStatusType.existing;
  final ScrollController _horizontalScrollController = ScrollController();

  final List<Map<String, dynamic>> _currentMedications = [
    {'name': 'Lisinopril 10 mg Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Metformin 500 mg Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Atorvastatin 20 mg Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Insulin Glargine (Lantus) 100 Units/ML', 'checked': false, 'needsOrder': false},
    {'name': 'Apixaban (Eliquis) 5 mg Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Acetaminophen 650 mg Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Vitamin D3 1000 IU Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Calcium Carbonate 500 mg Tablet', 'checked': false, 'needsOrder': false},
    {'name': 'Lasix 20 mg Tablet', 'checked': true, 'needsOrder': true},
  ];

  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _indicationController = TextEditingController();
  final TextEditingController _specialInstructionsController =
  TextEditingController();

  bool _purposeChecked = false;
  bool _directionsChecked = false;
  bool _sideEffectsChecked = false;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _medicationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _doseController.dispose();
    _frequencyController.dispose();
    _indicationController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
      '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p40, vertical: AppPadding.p20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title Bar ──────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.s8),
                  topRight: Radius.circular(AppSize.s8),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p16, vertical: AppPadding.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Medications',
                    style: TextStyle(
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: AppSize.s18),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.p16),
                  child: LayoutBuilder(builder: (context, constraints) {
                    const double minContentWidth = 1200;
                    final double contentWidth = constraints.maxWidth > minContentWidth
                        ? constraints.maxWidth
                        : minContentWidth;
                    return CustomScrollbar(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppPadding.p10),
                          child: SizedBox(
                            width: contentWidth,
                            child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── LEFT PANEL (flex: 3) ────────────────
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Current Medications:',
                                style: TextStyle(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.darkgrey,
                                ),
                              ),
                              const SizedBox(height: AppSize.s8),

                              // Medication list with spacing between items
                              ..._currentMedications.asMap().entries.map((e) {
                                final index = e.key;
                                final item = e.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSize.s12), // increased spacing
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: AppSize.s14,
                                            height: AppSize.s14,
                                            child: Checkbox(
                                              value: item['checked'],
                                              onChanged: (val) => setState(() =>
                                              _currentMedications[index]
                                              ['checked'] = val),
                                              activeColor:
                                              ColorManager.blueprime,
                                              materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                              visualDensity:
                                              VisualDensity.compact,
                                              side: BorderSide(
                                                  color:
                                                  ColorManager.mediumgrey,
                                                  width: 1.2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    AppSize.s2),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSize.s5),
                                          Flexible(
                                            child: Text(
                                              item['name'],
                                              style: TextStyle(
                                                fontSize: FontSize.s10,
                                                color: ColorManager.darkgrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item['needsOrder'] == true)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: AppSize.s20,
                                              top: AppSize.s2),
                                          child: Text(
                                            '*Needs Order',
                                            style: TextStyle(
                                              fontSize: FontSize.s9,
                                              color: ColorManager.red,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: AppSize.s12),

                              // Create Order Button
                              Center(
                                child: CustomElevatedButton(
                                    onPressed: () {},
                                    child: Text('Create Order',
                                        style: TextStyle(fontSize: FontSize.s10)),

                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── VERTICAL DIVIDER ──────────────────
                        Container(
                          width: 1,
                          color: ColorManager.grey,
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p14),
                        ),

                        // ── RIGHT PANEL (flex: 6) ──────────────
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // ── Medication row ──────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: AppSize.s80,
                                    child: Text(
                                      'Medication*',
                                      style: TextStyle(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w500,
                                        color: ColorManager.darkgrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.s6),
                                  SizedBox(width: 300,
                                    child: AppTextField(

                                      controller: _medicationController,
                                      hint:
                                      'type medication and select from list',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSize.s10),

                              // ── Radio + Fields section ──────
                              // Row 1: Radio (Existing) | Start Date field | Dose field
                              // Row 2: Radio (New)      | End Date field   | Frequency field
                              // Row 3: Radio (Changed)  | (empty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // ── Column A: Radio buttons only ──
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Row 1 – Existing
                                      SizedBox(
                                        height: AppSize.s35,
                                        child: _RadioOption(
                                          label: 'Existing',
                                          value: MedicationStatusType.existing,
                                          groupValue: _selectedStatus,
                                          onChanged: (v) => setState(
                                                  () => _selectedStatus = v!),
                                        ),
                                      ),
                                      const SizedBox(height: AppSize.s8),
                                      // Row 2 – New
                                      SizedBox(
                                        height: AppSize.s35,
                                        child: _RadioOption(
                                          label: 'New',
                                          value: MedicationStatusType.new_,
                                          groupValue: _selectedStatus,
                                          onChanged: (v) => setState(
                                                  () => _selectedStatus = v!),
                                        ),
                                      ),
                                      const SizedBox(height: AppSize.s8),
                                      // Row 3 – Changed
                                      SizedBox(
                                        height: AppSize.s35,
                                        child: _RadioOption(
                                          label: 'Changed',
                                          value: MedicationStatusType.changed,
                                          groupValue: _selectedStatus,
                                          onChanged: (v) => setState(
                                                  () => _selectedStatus = v!),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: AppSize.s10),

                                  // ── Column B: Date & Dose/Frequency fields ──
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        // Row 1: Start Date + Dose
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: AppSize.s60,
                                              child: Text(
                                                'Start Date*',
                                                style: TextStyle(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                  ColorManager.darkgrey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSize.s6),
                                            Expanded(
                                              child: AppTextField(
                                                controller:
                                                _startDateController,
                                                hint: 'mm/dd/yyyy',
                                                readOnly: true,
                                                onTap: () => _pickDate(
                                                    _startDateController),
                                                suffixIcon: Icon(
                                                  Icons
                                                      .calendar_month_outlined,
                                                  size: AppSize.s13,
                                                  color:
                                                  ColorManager.blueprime,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSize.s10),
                                            SizedBox(
                                              width: AppSize.s56,
                                              child: Text(
                                                'Dose*',
                                                style: TextStyle(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                  ColorManager.darkgrey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSize.s6),
                                            Expanded(
                                              child: AppTextField(
                                                controller: _doseController,
                                                hint: 'enter text',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSize.s8),

                                        // Row 2: End Date + Frequency
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: AppSize.s60,
                                              child: Text(
                                                'End Date*',
                                                style: TextStyle(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                  ColorManager.darkgrey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSize.s6),
                                            Expanded(
                                              child: AppTextField(
                                                controller: _endDateController,
                                                hint: 'mm/dd/yyyy',
                                                readOnly: true,
                                                onTap: () => _pickDate(
                                                    _endDateController),
                                                suffixIcon: Icon(
                                                  Icons
                                                      .calendar_month_outlined,
                                                  size: AppSize.s13,
                                                  color:
                                                  ColorManager.blueprime,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSize.s10),
                                            SizedBox(
                                              width: AppSize.s56,
                                              child: Text(
                                                'Frequency*',
                                                style: TextStyle(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                  ColorManager.darkgrey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: AppSize.s6),
                                            Expanded(
                                              child: AppTextField(
                                                controller:
                                                _frequencyController,
                                                hint: 'enter text',
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Row 3: empty (only radio "Changed" shows on left)
                                        const SizedBox(height: AppSize.s35 + AppSize.s8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSize.s10),

                              // ── Indication ──────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex:2,child: SizedBox()),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      'Indication*',
                                      style: TextStyle(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w500,
                                        color: ColorManager.darkgrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.s6),
                                  Expanded(
                                    flex: 4,
                                    child: AppTextField(
                                      controller: _indicationController,
                                      hint: 'enter text',
                                    ),
                                  ),
                                 // Expanded(flex:2,child: SizedBox()),
                                ],
                              ),
                              const SizedBox(height: AppSize.s8),
                              // ── Special Instructions ─────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex:2,child: SizedBox()),
                                  SizedBox(width: 100,
                                    child: Text(
                                      'Special Instructions',
                                      style: TextStyle(
                                        fontSize: FontSize.s10,
                                        fontWeight: FontWeight.w500,
                                        color: ColorManager.darkgrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.s6),
                                  Expanded(
                                    flex: 4,
                                    child: AppTextField(
                                      controller:
                                      _specialInstructionsController,
                                      hint: 'enter text',
                                    ),
                                  ),
                                  //Expanded(flex:2,child: SizedBox()),
                                ],
                              ),
                              const SizedBox(height: AppSize.s15),

                              // ── Medication Understanding ──────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Medication Understanding:',
                                    style: TextStyle(
                                      fontSize: FontSize.s10,
                                      fontWeight: FontWeight.w500,
                                      color: ColorManager.darkgrey,
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.s6),
                                  _CheckboxLabel(
                                    label: 'Purpose',
                                    value: _purposeChecked,
                                    onChanged: (v) =>
                                        setState(() => _purposeChecked = v!),
                                  ),
                                  const SizedBox(width: AppSize.s16),
                                  _CheckboxLabel(
                                    label: 'Directions For Use',
                                    value: _directionsChecked,
                                    onChanged: (v) => setState(
                                            () => _directionsChecked = v!),
                                  ),
                                  const SizedBox(width: AppSize.s16),
                                  _CheckboxLabel(
                                    label: 'Side Effects/Interactions',
                                    value: _sideEffectsChecked,
                                    onChanged: (v) => setState(
                                            () => _sideEffectsChecked = v!),
                                  ),
                                  const SizedBox(width: AppSize.s16),
                                ],
                              ),

                              const SizedBox(height: AppSize.s40),

                              // ── Bottom Buttons ───────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomButtonTransparent(
                                      text: "Cancel",
                                      onPressed: () =>
                                          Navigator.pop(context)),
                                  const SizedBox(width: AppSize.s10),
                                  CustomElevatedButton(
                                      onPressed: () {}, text: "Save"),
                                  const SizedBox(width: AppSize.s10),
                                  CustomElevatedButton(
                                    width: 200,
                                      onPressed: () {},
                                      text: "Save & Add Additional"),
                                ],
                              ),

                              const SizedBox(height: AppSize.s14),

                              // ── Legend ───────────────────────

                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: FontSize.s9,
                                        color: ColorManager.grey),
                                    children: [
                                      TextSpan(
                                        text: 'Existing',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: ColorManager.darkgrey),
                                      ),
                                      const TextSpan(
                                          text:
                                          ' – Medication added >30 days ago  '),
                                      TextSpan(
                                        text: 'New',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: ColorManager.darkgrey),
                                      ),
                                      const TextSpan(
                                          text:
                                          ' – Medication added within last 60 days  '),

                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSize.s4),

                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: FontSize.s9,
                                        color: ColorManager.grey),
                                    children: [
                                      TextSpan(
                                        text: 'Changed',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: ColorManager.darkgrey),
                                      ),
                                      const TextSpan(
                                          text:
                                          ' – Medication changed within last 60 days'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ), // IntrinsicHeight
                          ),   // SizedBox
                        ),     // Padding(bottom)
                      ),       // SingleChildScrollView(horizontal)
                    );         // CustomScrollbar
                  }),          // LayoutBuilder
                ),             // Padding(AppPadding.p16)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

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
          width: AppSize.s16,
          height: AppSize.s16,
          child: Radio<MedicationStatusType>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: ColorManager.blueprime,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: AppSize.s3),
        Text(label,
            style: TextStyle(
                fontSize: FontSize.s10, color: ColorManager.darkgrey)),
      ],
    );
  }
}

class _CheckboxLabel extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxLabel({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AppSize.s14,
          height: AppSize.s14,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: ColorManager.blueprime,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side:
            BorderSide(color: ColorManager.mediumgrey, width: 1.2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s2)),
          ),
        ),
        const SizedBox(width: AppSize.s3),
        Text(label,
            style: TextStyle(
                fontSize: FontSize.s10, color: ColorManager.darkgrey)),
      ],
    );
  }
}