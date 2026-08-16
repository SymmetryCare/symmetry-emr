import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';

import '../../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../em_module/widgets/button_constant.dart';
import '../../../../../../em_module/widgets/text_form_field_const.dart';

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
              Expanded(flex: 3, child: const SizedBox()),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s10),

        // ── List ────────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p12,
                  vertical: AppPadding.p10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Patient Info ─────────────────────────────────
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.shade100,
                            child: Text(
                              "LG",
                              style: TextStyle(
                                color: ColorManager.mediumgrey,
                                fontWeight: FontWeight.w700,
                                fontSize: FontSize.s12
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lucas Garcia",
                                style: EMRListViewHead.customTextStyle(context),
                              ),
                              const SizedBox(height: AppSize.s3),
                              Text(
                                "MRN: 659653454",
                                style: EMRListViewHead.customTextStyle(context)
                                    .copyWith(fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "05/08/2001 | 24y",
                                style: EMRListViewHead.customTextStyle(context)
                                    .copyWith(fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "Anxiety",
                                style: EMRListViewHead.customTextStyle(context)
                                    .copyWith(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── End of Episode ───────────────────────────────
                    Expanded(
                      flex: 3,
                      child: Text(
                        "05/04/2025",
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),

                    // ── Recert Window ────────────────────────────────
                    Expanded(
                      flex: 4,
                      child: Text(
                        "03/01/2025 - 03/06/2025",
                        textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),

                    // ── Actions ──────────────────────────────────────
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButtonTransparent(
                            width: 80,
                            text: "Recert",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => RecertPopup(),
                              );
                            },
                            borderRadius: 4,
                            verticalPadding: AppPadding.p5,
                            style: TransparentButtonTextConst.customTextStyle(context)
                                .copyWith(fontSize: FontSize.s12),
                          ),
                          const SizedBox(width: AppSize.s20),
                          CustomButtonTransparent(
                            width: 90,
                            text: "Discharge",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => DischargePopup(),
                              );
                            },
                            borderRadius: 4,
                            verticalPadding: AppPadding.p5,
                            style: TransparentButtonTextConst.customTextStyle(context)
                                .copyWith(fontSize: FontSize.s12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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