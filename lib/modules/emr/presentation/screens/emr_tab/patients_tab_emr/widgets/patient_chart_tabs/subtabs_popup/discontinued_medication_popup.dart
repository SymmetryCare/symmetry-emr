import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';

class DiscontinuedMedicationPopup extends StatelessWidget {
  const DiscontinuedMedicationPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtons(
      width: AppSize.s600,
      height: AppSize.s350,
      title: "Discontinued Medications",
      body: [
      ListViewContainerConstantEMR(
      paddingLeft: AppPadding.p20,
      paddingBottom: AppPadding.p10,
      paddingTop: AppPadding.p10,
      paddingRight: AppPadding.p20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medication name (blue link style)
          Text(
            'Apixaban (Eliquis) 5 Mg Tablet',
            style: TextStyle(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w600,
              color: ColorManager.blueprime,
              decoration: TextDecoration.underline,
              decorationColor: ColorManager.blueprime,
            ),
          ),

          const SizedBox(height: AppSize.s16),
          // Start Date
          const _DetailRow(label: 'Start Date:', value: '08/15/2024'),
          const SizedBox(height: AppSize.s12),

          // Dose + Frequency + Route
          const Row(
            children: [
              _InlineDetail(label: 'Dose:', value: '5 mg'),
              SizedBox(width: AppSize.s45),
              _InlineDetail(label: 'Frequency:', value: 'Daily'),
              SizedBox(width: AppSize.s45),
              _InlineDetail(label: 'Route:', value: 'Oral'),
            ],
          ),
          const SizedBox(height: AppSize.s12),

          // Indication
          const _DetailRow(label: 'Indication:', value: 'Hypertension'),
          const SizedBox(height: AppSize.s12),

          // Classification
          const _DetailRow(
              label: 'Classification:',
              value: 'ACE Inhibitor/Antihypertensive'),
          const SizedBox(height: AppSize.s12),

          // Special Instruction
          const _DetailRow(label: 'Special Instruction:', value: 'N/A'),
          const SizedBox(height: AppSize.s25),

          // Medication Understanding
          const _DetailRow(
            label: 'Medication Understanding:',
            value: 'Purpose – Y, Directions for Use – Y, Side Effects/Interactions – Y',
          ),

          const SizedBox(height: AppSize.s16),
                   // Discontinued date
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'DISCONTINUED DATE: ',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.red,
                      ),
                    ),
                    TextSpan(
                      text: '01/16/2026',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      )

      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
              color: ColorManager.darkgrey,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: FontSize.s12,
              color: ColorManager.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineDetail extends StatelessWidget {
  final String label;
  final String value;
  const _InlineDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkgrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s12,
            color: ColorManager.grey,
          ),
        ),
      ],
    );
  }
}