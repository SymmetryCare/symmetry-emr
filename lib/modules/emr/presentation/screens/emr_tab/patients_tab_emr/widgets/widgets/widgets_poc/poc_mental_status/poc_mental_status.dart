import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_mental_status/poc_mental_status_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocMentalStatus extends StatelessWidget {
  const PocMentalStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mental Status Data ─────────────────────────────────────
          SectionChildPocData(
            title: 'Mental Status',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: [
              PocDataItem(text: 'Agitated', date: '4/12/2025'),
              PocDataItem(text: 'Alert',    date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}