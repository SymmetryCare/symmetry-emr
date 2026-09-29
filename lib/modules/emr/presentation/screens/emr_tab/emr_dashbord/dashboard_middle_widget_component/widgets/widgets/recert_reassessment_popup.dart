import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';

import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';

class RecertDCDecisions extends StatelessWidget {
  const RecertDCDecisions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Container(
          height: AppSize.s33,
          decoration: BoxDecoration(
            color: ColorManager.SMFBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.only(right: AppPadding.p12),
          child: Row(
            children: [
              // Patient Name
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p5),
                  child: Text(
                    "Patient Name",
                    textAlign: TextAlign.center,
                    style: EMRListViewHead.customTextStyle(context),
                  ),
                ),
              ),
              // End of Episode
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppPadding.p10),
                  child: Text(
                    "End of Episode",
                    textAlign: TextAlign.center,
                    style: EMRListViewHead.customTextStyle(context),
                  ),
                ),
              ),
              // Recert Window
              Expanded(
                flex: 4,
                child: Text(
                  "Recert Window",
                  textAlign: TextAlign.center,
                  style: EMRListViewHead.customTextStyle(context),
                ),
              ),
              // Actions (empty header)
              const Expanded(flex: 3, child: SizedBox()),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s10),
        // Centered message
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p40),
              child: Text(
                'Dependency on forms builder which is under development!',
                textAlign: TextAlign.center,
                style: AllNoDataAvailable.customTextStyle(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RecertPopup extends StatelessWidget {
  RecertPopup({super.key});

  final TextEditingController resons = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s240,
      body: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15),
          child: SMTextFConst(
            controller: resons,
            text: "Skilled Need for Recertification",
            keyboardType: TextInputType.text,
          ),
        ),
      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButtonTransparent(text: "Cancel", onPressed: () {}),
          const SizedBox(width: AppSize.s20),
          CustomElevatedButton(
            width: AppSize.s100,
            onPressed: () {},
            text: "Save",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      title: "Mark As Recert",
    );
  }
}

class DischargePopup extends StatelessWidget {
  DischargePopup({super.key});

  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s400,
      height: AppSize.s280,
      body: [
        Center(
          child: Text(
            "Are you sure you want to discharge?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w500,
              color: ColorManager.mediumgrey,
            ),
          ),
        ),
        const SizedBox(height: AppSize.s20),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15),
          child: HhermTextFConstCalender(
            controller: dateController,
            text: "Select Discharge Visit",
            keyboardType: TextInputType.text,
            showDatePicker: true,
          ),
        ),
      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButtonTransparent(text: "Cancel", onPressed: () {}),
          const SizedBox(width: AppSize.s20),
          CustomElevatedButton(
            width: AppSize.s100,
            onPressed: () {},
            text: "Confirm",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      title: "Mark As Discharge",
    );
  }
}