import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_nutritional_requirements/poc_nutritional_requirements_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocNutritionalRequirements extends StatelessWidget {
  const PocNutritionalRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nutritional Requirements Data ──────────────────────────
          SectionChildPocData(
            title: 'Nutritional Requirements',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: [
              PocDataItem(text: 'Diet as Tolerated',              date: '4/12/2025'),
              PocDataItem(text: 'High Carbohydrate',              date: '4/12/2025'),
              PocDataItem(text: 'High Protein',                   date: '4/12/2025'),
              PocDataItem(text: 'Increase fluids to __ per day',  date: '4/12/2025'),
              PocDataItem(text: 'Nutritional Supplement',         date: '4/12/2025'),
              PocDataItem(text: 'Sip/Ice chips only',             date: '4/12/2025'),
              PocDataItem(text: '___ Gram Sodium',                date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}