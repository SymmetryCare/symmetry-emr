import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class RecentActivityscreenCommunication extends StatelessWidget {
  final VoidCallback onImgTap;
  const RecentActivityscreenCommunication({super.key, required this.onImgTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImgTap,
      child: Center(
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("images/communication/recent_activity.svg",width: AppSize.s180,),
              const SizedBox(height: AppSize.s10),
              Text(
                "No Recent Activity",
                style: CustomTextStylesCommon.commonStyle(
                    color: ColorManager.mediumgrey,
                    fontSize: FontSize.s30,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSize.s10),
              Text(
                "Start your communication and make things happen.",
                style: CustomTextStylesCommon.commonStyle(
                    color: ColorManager.bordercolor,
                    fontSize: FontSize.s18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          )
      ),
    );
  }
}
