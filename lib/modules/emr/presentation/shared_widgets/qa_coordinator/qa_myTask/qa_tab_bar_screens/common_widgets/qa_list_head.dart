import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class QaListHead extends StatelessWidget {
  bool? isDateCurrectionShown;
   QaListHead({super.key,this.isDateCurrectionShown = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF8FC),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p20),
              child: Text(
                "Patient Name",
                maxLines: 2,
                // textAlign: TextAlign.center,
                // overflow: TextOverflow.ellipsis,
                style: CustomTextStylesCommon.commonStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.granitegray,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: AppPadding.p20),
              child: Text(
                "Form Type",
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStylesCommon.commonStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.granitegray,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p50),
              child: Text(
                "Form Date",
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStylesCommon.commonStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.granitegray,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Clinician Name",
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStylesCommon.commonStyle(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w700,
                color: ColorManager.granitegray,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p60),
              child: Text(
                "Primary Insurance",
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStylesCommon.commonStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.granitegray,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: AppPadding.p50),
              child: Text(
                "Timely Filing Deadline",
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStylesCommon.commonStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.granitegray,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "Coding Staff",
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStylesCommon.commonStyle(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w700,
                color: ColorManager.granitegray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}