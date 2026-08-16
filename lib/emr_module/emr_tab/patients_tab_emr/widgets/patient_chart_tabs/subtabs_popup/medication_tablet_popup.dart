import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/theme_manager.dart';

import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../em_module/widgets/button_constant.dart';
import '../../../../../../hr_module/manage/widgets/custom_icon_button_constant.dart';
import 'chnage_madication_popup.dart';
import 'discontinue_madication_popup.dart';
import 'hold_medication_popup.dart';


class MedicationTabletPopup extends StatelessWidget {
  const MedicationTabletPopup({super.key});

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
                color: ColorManager.bluebottom,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.s8),
                  topRight: Radius.circular(AppSize.s8),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p5, horizontal: AppPadding.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Row(
                    children: [
                      Text(
                        'Lisinopril 10 mg tablet',
                        style: PopupBlueBarText.customTextStyle(context),
                      ),
                      const SizedBox(width: AppSize.s10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p8, vertical: AppPadding.p2),
                        decoration: BoxDecoration(
                          color: ColorManager.green,
                          borderRadius: BorderRadius.circular(AppSize.s4),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: FontSize.s10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
              padding: const EdgeInsets.all(AppPadding.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Date
                  _DetailRow(label: 'Start Date:', value: '08/15/2024'),
                  const SizedBox(height: AppSize.s12),

                  // Dose + Frequency + Route
                  Row(
                    children: [
                      _InlineDetail(label: 'Dose:', value: '10 mg'),
                      const SizedBox(width: AppSize.s24),
                      _InlineDetail(label: 'Frequency:', value: 'Daily'),
                      const SizedBox(width: AppSize.s24),
                      _InlineDetail(label: 'Route:', value: 'Oral'),
                    ],
                  ),
                  const SizedBox(height: AppSize.s12),

                  // Indication
                  _DetailRow(label: 'Indication:', value: 'Hypertension'),
                  const SizedBox(height: AppSize.s12),

                  // Classification
                  _DetailRow(
                    label: 'Classification:',
                    value: 'ACE Inhibitor/Antihypertensive',
                  ),
                  const SizedBox(height: AppSize.s12),

                  // Special Instruction
                  _DetailRow(label: 'Special Instruction:', value: 'N/A'),
                  const SizedBox(height: AppSize.s16),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: AppSize.s12),

                  // Medication Understanding
                  _DetailRow(
                    label: 'Medication Understanding:',
                    value:
                    'Purpose - Y, Directions for Use - Y, Side Effects/Interactions - Y',
                  ),
                ],
              ),
            ),

            // ── Bottom buttons ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                  right: AppPadding.p20, bottom: AppPadding.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const HoldMedicationPopup(),
                      );
                    },
                    text: "Hold",
                  ),
                  const SizedBox(width: AppSize.s12),
                  CustomElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ChnageMadicationPopup(),
                      );
                    },
                    text: "Change",
                  ),
                  const SizedBox(width: AppSize.s12),
                  CustomElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const DiscontinueMadicationPopup(),
                      );
                    },
                    text: "Discontinue",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              fontWeight: FontWeight.w400,
              color: ColorManager.grey,
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