import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';

import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../em_module/widgets/button_constant.dart';

class PatientFormTabPopp extends StatelessWidget {
  final String formTitle;
  const PatientFormTabPopp({super.key, required this.formTitle});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s400,
      title: "Confirm Details",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Patient Details label
              Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.darkgrey,
                ),
              ),
              const SizedBox(height: AppSize.s20),

              // Avatar + patient info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: AppSize.s20,
                    backgroundColor: const Color(0xFFE0C99A),
                    child: Text(
                      'JS',
                      style: TextStyle(
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Scott',
                        style: TextStyle(
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.darkgrey,
                        ),
                      ),
                      Text(
                        '05/08/2001 | 25y',
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.grey,
                        ),
                      ),
                      Text(
                        'Anxiety',
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSize.s16),

              // MRN + Address row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MRN
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MRN:',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                        Text(
                          'TFGH#23984512',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            color: ColorManager.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Address
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: AppSize.s14, color: ColorManager.blueprime),
                        const SizedBox(width: AppSize.s4),
                        Flexible(
                          child: Text(
                            '132 My Street, Kingston,\nNew York 12401',
                            style: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSize.s16),

              // Form Type + Date row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Form type label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form Type:',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                        Text(
                          formTitle,
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            color: ColorManager.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Date picker field
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(AppSize.s6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '08/05/2025',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.darkgrey,
                            ),
                          ),
                          const SizedBox(width: AppSize.s8),
                          Icon(Icons.calendar_month_outlined,
                              size: AppSize.s16, color: ColorManager.blueprime),
                        ],
                      ),
                    ),
                  SizedBox(width: 60,)
                ],
              ),

              const SizedBox(height: AppSize.s20),

              // Confirmation question
              Center(
                child: Text(
                  'Do you really want to open this form?',
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.darkgrey,
                  ),
                ),
              ),
            ],
          ),
        )

      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButtonTransparent(text: "Cancel", onPressed: () {}),
          const SizedBox(width: AppSize.s12),
          CustomElevatedButton(
            width: AppSize.s105,
            height: AppSize.s30,
            text: "Yes",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class PatientFormTabPopupIncidentReport extends StatefulWidget {
  const PatientFormTabPopupIncidentReport({super.key});

  @override
  State<PatientFormTabPopupIncidentReport> createState() =>
      _PatientFormTabPopupIncidentReportState();
}

class _PatientFormTabPopupIncidentReportState
    extends State<PatientFormTabPopupIncidentReport> {
  String? _selectedForm;
  DateTime? _selectedDate;

  static const List<String> _formOptions = [
    'Incident Report',
    'Care Coordination Note',
    'Physician Order',
    'Supervisory Visit',
    'Infection Control Report',
  ];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _formattedDate {
    if (_selectedDate == null) return '08/05/2025';
    return '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s420,
      title: "Confirm Details",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Details label
              Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: FontSize.s13,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.darkgrey,
                ),
              ),
              const SizedBox(height: AppSize.s20),

              // Avatar + patient info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: AppSize.s20,
                    backgroundColor: const Color(0xFFE0C99A),
                    child: Text(
                      'JS',
                      style: TextStyle(
                        fontSize: FontSize.s13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Scott',
                        style: TextStyle(
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.darkgrey,
                        ),
                      ),
                      Text(
                        '05/08/2001 | 25y',
                        style: TextStyle(fontSize: FontSize.s12, color: ColorManager.grey),
                      ),
                      Text(
                        'Anxiety',
                        style: TextStyle(fontSize: FontSize.s12, color: ColorManager.grey),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSize.s16),
              // MRN + Address row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MRN:',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                        Text(
                          'TFGH#23984512',
                          style: TextStyle(fontSize: FontSize.s11, color: ColorManager.grey),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: AppSize.s14, color: ColorManager.blueprime),
                        const SizedBox(width: AppSize.s4),
                        Flexible(
                          child: Text(
                            '132 My Street, Kingston,\nNew York 12401',
                            style: TextStyle(fontSize: FontSize.s11, color: ColorManager.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSize.s16),

              // Select Form dropdown + Date picker row
              Row(mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Form dropdown
                  Expanded(
                    child: Container(
                      height: AppSize.s36,
                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCCCCCC)),
                        borderRadius: BorderRadius.circular(AppSize.s6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedForm,
                          hint: Text(
                            'Select Form',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.grey,
                            ),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down,
                              size: AppSize.s18, color: ColorManager.grey),
                          isExpanded: true,
                          items: _formOptions
                              .map((form) => DropdownMenuItem(
                            value: form,
                            child: Text(
                              form,
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.darkgrey,
                              ),
                            ),
                          ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedForm = val),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSize.s60),

                  // Date picker
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: AppSize.s36,
                        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCCCCC)),
                          borderRadius: BorderRadius.circular(AppSize.s6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formattedDate,
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.darkgrey,
                              ),
                            ),
                            const SizedBox(width: AppSize.s8),
                            Icon(Icons.calendar_month_outlined,
                                size: AppSize.s16, color: ColorManager.blueprime),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 60,)
                ],
              ),

              const SizedBox(height: AppSize.s20),

              // Confirmation question
              Center(
                child: Text(
                  'Do you really want to open this form?',
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.darkgrey,
                  ),
                ),
              ),
            ],
          ),
        )

      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButtonTransparent(text: "Cancel", onPressed: () => Navigator.pop(context)),
          const SizedBox(width: AppSize.s12),
          CustomElevatedButton(
            width: AppSize.s105,
            height: AppSize.s30,
            text: "Yes",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}