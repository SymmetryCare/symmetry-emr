import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_activities_permitted/poc_activity_permit_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocActivitiesPermitted extends StatelessWidget {
  const PocActivitiesPermitted({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ─────────────────────────────────────────
          // InkWell(
          //   onTap: () {
          //     showDialog(
          //         context: context,
          //         builder: (context) => PocActivityPermitPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'ACTIVITIES PERMITTED'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Activities Permitted',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            date: "14/12/2024",
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Complete Bedrest', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}