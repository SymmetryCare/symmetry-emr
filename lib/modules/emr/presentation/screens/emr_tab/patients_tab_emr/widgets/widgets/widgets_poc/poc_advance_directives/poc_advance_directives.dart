import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_advance_directives/poc_advanced_directives_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocAdvanceDirectives extends StatelessWidget {
  const PocAdvanceDirectives({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Advance Directives Data ────────────────────────────────
          SectionChildPocData(
            title: 'Advance Directives',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: [
              PocDataItem(text: 'DNI',       date: '4/12/2025'),
              PocDataItem(text: 'Full Code', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}