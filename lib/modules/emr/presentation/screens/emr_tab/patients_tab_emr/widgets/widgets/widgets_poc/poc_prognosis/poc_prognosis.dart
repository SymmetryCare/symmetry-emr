import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_prognosis/poc_prognosis_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocPrognosis extends StatelessWidget {
  const PocPrognosis({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Prognosis',
            date: "2/3/2025",
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: [
              PocDataItem(text: 'Good', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}