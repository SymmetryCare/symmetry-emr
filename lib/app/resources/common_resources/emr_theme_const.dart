import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';

class EMRListViewHead {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w700,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

class EMRListViewData {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w500,
      color: ColorManager.mediumgrey,
      decoration: TextDecoration.none,
    );
  }
}

class PatientsFormsHeadData {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: FontSize.s12,
      fontWeight: FontWeight.w700,
      color: ColorManager.greenDark,
      decoration: TextDecoration.none,
    );
  }
}

class PatientsFormsSubData {
  static TextStyle customTextStyle(BuildContext context) {
    return TextStyle(
        fontSize: FontSize.s10,
        color: ColorManager.mediumgrey,
        decoration: TextDecoration.none,
        fontStyle: FontStyle.italic
    );
  }
}

