import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';
import 'package:prohealth/presentation/screens/scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../../../../em_module/widgets/dialogue_template.dart';
import '../../../../../em_module/widgets/text_form_field_const.dart';
import '../../../../../hr_module/manage/widgets/custom_icon_button_constant.dart';

class AuthorizationStatusPopup extends StatelessWidget {
  const AuthorizationStatusPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 200),
      child: DialogueTemplateNoButtons(width: double.infinity, height: double.infinity,
          body: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomSearchFieldSM(onPressed: (){}),
              ],
            ),
            const SizedBox(height: AppSize.s10),
            Container(
              height: AppSize.s33,
              decoration: BoxDecoration(
                  color: ColorManager.SMFBlue,
                  borderRadius: BorderRadius.circular(4)
              ),
              padding: EdgeInsets.only(left: AppPadding.p60,right: AppPadding.p10),
              // margin: EdgeInsets.symmetric(vertical: AppPadding.p8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text("Patient Name", style: EMRListViewHead.customTextStyle(context))),
                  Expanded(flex: 2, child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p30),
                    child: Text("Current Auth",textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context)),
                  )),
                  Expanded(flex: 2, child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p30),
                    child: Text("Requested Auth", textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context)),
                  )),
                  Expanded(flex: 2, child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p0),
                    child: Text("Visits Without Auth",textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context)),
                  )),
                  Expanded(flex: 2, child: Text("Auth Status",textAlign: TextAlign.end, style: EMRListViewHead.customTextStyle(context))),

                ],
              ),

            ),
            const SizedBox(height: AppSize.s10),
            Container(
              height: 370,
              child: ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p12, top: AppPadding.p10,bottom: AppPadding.p10),
                    child: Row(
                      children: [
                        // ── Patient Info ───────────────────────
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.orange.shade100,
                                child: Text(
                                  "LG",
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSize.s10),

                              // Details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:  [
                                  Text(
                                      "Lucas Garcia",
                                      style: EMRListViewHead.customTextStyle(context)
                                  ),
                                  SizedBox(height: AppSize.s2),
                                  Text("MRN: 659653454", style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                                  Text("05/08/2001 | 24y", style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                                  Text("Anxiety", style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ── End of Episode ─────────────────────
                        Expanded(
                          flex: 2,
                          child: Text("0",textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("2",textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("2",textAlign: TextAlign.center, style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                        ),
                        // ── Recert Window ──────────────────────
                        Expanded(
                          flex: 2,
                          child: Text("Pending", textAlign: TextAlign.end, style: EMRListViewHead.customTextStyle(context).copyWith(fontWeight: FontWeight.w400)),
                        ),
                        SizedBox(width: 20,)
                      ],
                    ),
                  );
                },
              ),
            ),
          ], title: "Patients Waiting For Auth"),
    );
  }
}
