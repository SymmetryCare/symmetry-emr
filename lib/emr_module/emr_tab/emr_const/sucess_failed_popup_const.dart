import 'package:flutter/material.dart';
import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../app/resources/value_manager.dart';

// ── Success Popup (auto-closes in 2 seconds) ──────────────────────────────────
class EMRSuccessPopup extends StatefulWidget {
  final String? title;
  final String? message;

  const EMRSuccessPopup({
    super.key,
    this.title,
    this.message,
  });

  @override
  State<EMRSuccessPopup> createState() => _EMRSuccessPopupState();
}

class _EMRSuccessPopupState extends State<EMRSuccessPopup> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s300,
        height: AppSize.s150,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: ColorManager.bluebottom,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      widget.title ?? 'Success',
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: ColorManager.white),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Message ─────────────────────────────────────────────────
            Center(
              child: SizedBox(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Text(
                  widget.message ?? 'Operation completed\nsuccessfully.',
                  textAlign: TextAlign.center,
                  style: ConstTextFieldRegister.customTextStyle(context)
                      .copyWith(color: ColorManager.mediumgrey),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Failed Popup ──────────────────────────────────────────────────────────────
class EMRFailedPopup extends StatefulWidget {
  final String? title;
  final String? message;

  const EMRFailedPopup({
    super.key,
    this.title,
    this.message,
  });

  @override
  State<EMRFailedPopup> createState() => _EMRFailedPopupState();
}

class _EMRFailedPopupState extends State<EMRFailedPopup> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s300,
        height: AppSize.s150,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      widget.title ?? 'Failed',
                      style: PopupBlueBarText.customTextStyle(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: ColorManager.white),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Message ─────────────────────────────────────────────────
            Center(
              child: SizedBox(
                height: AppSize.s50,
                width: AppSize.s210,
                child: Text(
                  widget.message ?? 'Something went wrong.\nPlease try again.',
                  textAlign: TextAlign.center,
                  style: ConstTextFieldRegister.customTextStyle(context)
                      .copyWith(color: ColorManager.mediumgrey),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}


