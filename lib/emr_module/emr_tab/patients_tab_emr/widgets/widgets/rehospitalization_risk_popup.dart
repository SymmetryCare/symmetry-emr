import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';

class RehospitalizationRiskPopup extends StatefulWidget {
  const RehospitalizationRiskPopup({super.key});

  @override
  State<RehospitalizationRiskPopup> createState() =>
      _RehospitalizationRiskPopupState();
}

class _RehospitalizationRiskPopupState
    extends State<RehospitalizationRiskPopup> {
  // Left column checkboxes
  final List<Map<String, dynamic>> _leftItems = [
    {'label': 'Has had a hospital admission or emergency room visit in the last 6 months', 'checked': false},
    {'label': 'Has primary diagnosis of Stroke, Heart Failure, CHF, COPD, Cardiac, Diabetes', 'checked': false},
    {'label': 'Needs assistance with ADLs', 'checked': false},
    {'label': 'Has 10 or more medications', 'checked': false},
    {'label': 'Needs assistance with taking medications', 'checked': true},
    {'label': 'Needs assistance with respiratory treatments', 'checked': false},
  ];

  // Right column checkboxes
  final List<Map<String, dynamic>> _rightItems = [
    {'label': 'Has confusion or problems remembering or organizing', 'checked': false},
    {'label': 'Has learning barrier', 'checked': false},
    {'label': 'Lives alone', 'checked': false},
    {'label': 'Had a fall in the last year', 'checked': true},
    {'label': 'Has a skin ulcer', 'checked': false},
  ];

  int get _score =>
      [..._leftItems, ..._rightItems].where((e) => e['checked'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100.0,horizontal: 180),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Risk for Rehospitalization / Emergency Room Visit",
        body: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select all that apply',
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.grey,
                  ),
                ),
                const SizedBox(height: AppSize.s8),
                Text(
                  'Patient:',
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkgrey,
                  ),
                ),
                const SizedBox(height: AppSize.s12),

                // Two-column checkbox grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _leftItems.asMap().entries.map((e) {
                          return _CheckboxRow(
                            label: e.value['label'],
                            checked: e.value['checked'],
                            onChanged: (val) =>
                                setState(() => _leftItems[e.key]['checked'] = val),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(width: AppSize.s24),

                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._rightItems.asMap().entries.map((e) {
                            return _CheckboxRow(
                              label: e.value['label'],
                              checked: e.value['checked'],
                              onChanged: (val) =>
                                  setState(() => _rightItems[e.key]['checked'] = val),
                            );
                          }),
                          // Score row
                          Row(
                            children: [
                              Text(
                                'Score:',
                                style: TextStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.darkgrey,
                                ),
                              ),
                              const SizedBox(width: AppSize.s10),
                              Container(
                                width: 60,
                                height: 28,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFCCCCCC)),
                                  borderRadius: BorderRadius.circular(AppSize.s4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$_score',
                                  style: TextStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.darkgrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSize.s10),
                          // Legend
                          Text(
                            '5+ more checked boxes = high risk (select appropriate interventions/goals to reduce risk of hospitalization or emergency department visit).',
                            style: TextStyle(
                              fontSize: FontSize.s10,
                              color: ColorManager.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSize.s20),


              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _CheckboxRow({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSize.s18,
            height: AppSize.s18,
            child: Checkbox(
              value: checked,
              splashRadius: 0,
              onChanged: (val) => onChanged(val ?? false),
              activeColor: ColorManager.blueprime,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: ColorManager.mediumgrey, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s2),
              ),
            ),
          ),
          const SizedBox(width: AppSize.s8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.darkgrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
