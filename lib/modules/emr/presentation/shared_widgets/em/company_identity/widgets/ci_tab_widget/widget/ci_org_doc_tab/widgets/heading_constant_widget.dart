import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
///stateless
class TableHeadingConst extends StatelessWidget {
  const TableHeadingConst({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s30,
      margin: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
      padding: const EdgeInsets.only(left: AppPadding.p50,right: AppPadding.p50),
      decoration: BoxDecoration(
        color: ColorManager.fmediumgrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: Text(
                AppStringEM.srNo,
                textAlign: TextAlign.center,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Text(
                AppStringEM.docID,
                textAlign: TextAlign.center,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 60.0),
              child: Text(
                AppStringEM.name,
                textAlign: TextAlign.start,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: Text(
                AppStringEM.reminderthershold,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 40.0),
              child: Text(
                AppStringEM.actions,
                textAlign: TextAlign.center,
                style: TableHeading.customTextStyle(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

