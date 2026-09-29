import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';

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
              padding: const EdgeInsets.only(left: AppPadding.p60,right: AppPadding.p10),
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
            // Centered message
            Container(
              height: 300,
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
          ], title: "Patients Waiting For Auth"),
    );
  }
}
