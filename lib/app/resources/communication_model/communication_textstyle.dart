import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';

///Chat info
class ChatMoreInfoText {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s13,
      color: ColorManager.mediumgrey,
      fontWeight: FontWeight.w400,
    );
  }
}