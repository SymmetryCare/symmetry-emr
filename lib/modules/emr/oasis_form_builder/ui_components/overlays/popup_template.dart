import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/constants/app_colors.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/constants/app_text_style.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class PopupTemplate extends StatelessWidget {
  final double? maxWidth;
  final double? maxHeight;
  final String title;
  final Widget? headerWidget;
  final Widget? volumWidget;
  final List<Widget> body;
  final Widget? bottomButtons;
  VoidCallback? onClear;

  PopupTemplate({
    super.key,
    this.onClear,
    this.maxHeight,
    this.maxWidth,
    this.headerWidget,
    this.volumWidget,
    required this.body,
    required this.bottomButtons,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
          maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryAppLightColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.r),
                  topRight: Radius.circular(15.r),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p2, horizontal: AppPadding.p15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p10),
                    child: Text(
                      title,
                      style: FormBuilderTextStyle.bold10Style
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: onClear ??
                        () {
                          Navigator.pop(context);
                        },
                    icon: Icon(
                      Icons.close,
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
            if (headerWidget != null) headerWidget!,
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p15,
                  horizontal: AppPadding.p15,
                ),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: body,
                      ),
                      volumWidget ?? Container()
                    ],
                  ),
                ),
              ),
            ),

            if (bottomButtons != null) const SizedBox(height: AppSize.s15),

            ///button
            if (bottomButtons != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppPadding.p20),
                child: Center(
                  child: bottomButtons,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
