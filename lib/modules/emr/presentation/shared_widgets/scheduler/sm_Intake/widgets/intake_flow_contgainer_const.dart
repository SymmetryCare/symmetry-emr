import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class IntakeFlowContainerConst extends StatelessWidget {
  final double? height;
  final Widget child;
  final bool? isColorVisible;
  final Color? dividerColor;
   EdgeInsetsGeometry? containerPadding;
   IntakeFlowContainerConst({super.key,
     this.containerPadding,
     this.dividerColor ,
     this.isColorVisible = false,this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:containerPadding ?? const EdgeInsets.symmetric(horizontal: AppPadding.p30, vertical: AppPadding.p30),
      child: Container(
        height: height ?? AppSize.s500,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30,),
        decoration: BoxDecoration(
          color: ColorManager.white,
          border: Border(
            bottom: BorderSide(width: 0.5,color: ColorManager.lightGrey,
            ),
              ),
        ),
        child: child,
      ),
    );
  }
}
