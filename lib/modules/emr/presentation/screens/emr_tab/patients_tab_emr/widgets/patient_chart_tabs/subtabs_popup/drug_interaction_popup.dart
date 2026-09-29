
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';

class DrugInteractionPopup extends StatelessWidget {
  const DrugInteractionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s750,
      height: AppSize.s460,
      title: "Drug Interactions",
      body: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListViewContainerConstantEMR(
                  paddingLeft: AppPadding.p30,
                  paddingRight: AppPadding.p30,
                  paddingBottom: AppPadding.p20,
                  paddingTop: AppPadding.p20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Duplicate Therapy", style: CustomTextStylesCommon.commonStyle(),),
                      const SizedBox(height: AppSize.s20,),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.darkgrey),
                            children: const [
                              TextSpan(
                                text: 'Hydrocodone/Acetaminophen 5 mg/325 mg tablet',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' with '),
                              TextSpan(
                                text: 'Acetaminophen 650 mg tablet',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSize.s20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.darkgrey),
                              children: const [
                                TextSpan(
                                  text: 'Potential Abuse – ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                    text: 'No Abuse/Dependency Potential'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSize.s16),

            ListViewContainerConstantEMR(
              paddingLeft: AppPadding.p30,
              paddingRight: AppPadding.p30,
              paddingBottom: AppPadding.p20,
              paddingTop: AppPadding.p20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Moderate Interaction', style: CustomTextStylesCommon.commonStyle(color: ColorManager.orange),),
                      const SizedBox(height: AppSize.s20,),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.darkgrey),
                            children: [
                              const TextSpan(
                                text: 'Metformin 500 mg tablet',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const TextSpan(text: ' with '),
                              TextSpan(
                                text: 'Lisinopril 10 mg tablet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: ColorManager.darkgrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSize.s20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.darkgrey),
                              children: const [
                                TextSpan(
                                  text: 'Action – ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                    text:
                                    'Assess the risk to the patient and take action as needed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButtonTransparent(
            width: 160,
            text: "Copy Interactions",
            onPressed: () {},
          ),
          const SizedBox(width: AppSize.s12),
          CustomElevatedButton(
            onPressed: (){
            },
            text: "Done",
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────
class _InteractionSection extends StatelessWidget {
  final String sectionTitle;
  final Color titleColor;
  final List<Widget> children;

  const _InteractionSection({
    required this.sectionTitle,
    required this.titleColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: AppSize.s8),
        ...children,
      ],
    );
  }
}
