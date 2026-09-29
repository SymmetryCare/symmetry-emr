import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_allergies/poc_allergies_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocAllergies extends StatefulWidget {
  const PocAllergies({super.key});

  @override
  State<PocAllergies> createState() => _PocAllergiesState();
}

class _PocAllergiesState extends State<PocAllergies> {
  List<Widget> nonComprehensiveQtn = [];

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSize.s16),

          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Allergies',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: [
              PocDataItem(text: 'Penicillin-rash', date: '14/12/2006'),
              PocDataItem(text: 'No known food or latex allergies', date: '01/01/2008'),
            ], date: '01/01/2022',
          ),
        ],
      ),
    );
  }
}