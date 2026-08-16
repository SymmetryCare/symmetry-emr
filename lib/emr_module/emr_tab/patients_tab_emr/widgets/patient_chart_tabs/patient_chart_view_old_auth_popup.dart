import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';

class PatientChartViewOldAuthPopup extends StatelessWidget {
  const PatientChartViewOldAuthPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtons(width: 600, height: 200,
        body: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authorization #2',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.mediumgrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: AppSize.s10),
                    Text(
                      'Admin: 4/15/2025, OrderedBy: Nursing, Rebecca',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.faintGrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: AppSize.s10),
                    Text(
                      'Effective: 2/15/2025 - 7/5/2025',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.mediumgrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              // Authorized / Used / Remaining columns
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _AuthColumn(header: 'Authorized', value: '1'),
                    const SizedBox(width: AppSize.s16),
                    _AuthColumn(header: 'Used', value: '1'),
                    const SizedBox(width: AppSize.s16),
                    _AuthColumn(header: 'Remaining', value: '4'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s30,),
        ], title: "View Old Auth");
  }
}
class _AuthColumn extends StatelessWidget {
  final String header;
  final String value;
  const _AuthColumn({required this.header, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          header,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w500,
            color: ColorManager.mediumgrey,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w500,
            color: ColorManager.mediumgrey,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
