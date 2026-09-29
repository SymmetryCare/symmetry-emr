
import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

///saloni///
class SchedularIconButtonConst extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double? width;
  final double? borderRadius;

  const SchedularIconButtonConst({
    this.text,
    this.icon,
    required this.onPressed,
    this.width,
    this.borderRadius,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon!, color: ColorManager.white, size: AppSize.s20)
            : const SizedBox.shrink(),
        label: Text(
          text!,
          style: TextStyle(
            fontSize: AppSize.s12,
            fontWeight: FontWeight.w600,
            color: ColorManager.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.s10, vertical: AppSize.s10),
          backgroundColor: ColorManager.blueprime,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: 4,
          shadowColor: ColorManager.black.withOpacity(0.4),
        ),
      ),
    );
  }
}

