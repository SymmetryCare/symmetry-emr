import 'package:flutter/material.dart';

import 'package:symmetry_emr/presentation/shared/widgets/button_constant.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

///provider
class DeletePopupProvider extends StatelessWidget {
  final VoidCallback onCancel;
  final Future<void> Function() onDelete;
  final bool? loadingDuration;
  final String title;
  final String? text;
  final String? btnText;

  const DeletePopupProvider({
    Key? key,
    required this.onCancel,
    required this.onDelete,
    required this.loadingDuration,
    required this.title,
    this.text,
    this.btnText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s400,
        height: AppSize.s181,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              height: 35,
              child: Padding(
                padding:  const EdgeInsets.only(left: AppPadding.p15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onPressed: onCancel,
                      icon: Icon(Icons.close, color: ColorManager.white,size: IconSize.I20,),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSize.s20),
            // Text Content
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppPadding.p20,
                    horizontal: AppPadding.p15,
                  ),
                  child: Text(
                    text ?? 'Do you really want to delete?',
                    style: PopupTextConst.customTextStyle(context),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Action Buttons (Cancel and Delete)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p24),
                  child: SizedBox(
                    width: AppSize.s100,
                    child: ElevatedButton(
                      onPressed: loadingDuration == true ? null : onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        overlayColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: ColorManager.blueprime,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TransparentButtonTextConst.customTextStyle(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.s20),
                Padding(
                  padding:  const EdgeInsets.only(
                    bottom: AppPadding.p24,
                    right: AppPadding.p15,
                  ),
                  child: CustomElevatedButton(
                    width: AppSize.s105,
                    height: AppSize.s30,
                    text: btnText ?? AppStringEM.delete,
                    isLoading: loadingDuration == true,
                    onPressed: () async {
                      await onDelete();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
