import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_activities_permitted/poc_activity_permit_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocActivitiesPermitted extends StatelessWidget {
  const PocActivitiesPermitted({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Activities Permitted',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            date: "14/12/2024",
            showBottomDivider: false,
            items: [
              PocDataItem(text: 'Complete Bedrest', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}