import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_allergies/poc_allergies_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocAllergies extends StatefulWidget {
  const PocAllergies({super.key});

  @override
  State<PocAllergies> createState() => _PocAllergiesState();
}

class _PocAllergiesState extends State<PocAllergies> {
  List<Widget> nonComprehensiveQtn = [];

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
          //         builder: (context) => PocAllergiesPopup());
          //   },
          //   child:
          //  const SectionHeaderPOC(label: 'ALLERGIES'),
         // ),

          const SizedBox(height: AppSize.s16),

          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Allergies',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Penicillin-rash', date: '14/12/2006'),
              PocDataItem(text: 'No known food or latex allergies', date: '01/01/2008'),
            ], date: '01/01/2022',
          ),
        ],
      ),
    );
  }
}