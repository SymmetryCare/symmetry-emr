import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_nutritional_requirements/poc_nutritional_requirements_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocNutritionalRequirements extends StatelessWidget {
  const PocNutritionalRequirements({super.key});

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
          //         builder: (context) => PocNutritionalRequirementsPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'NUTRITIONAL REQUIREMENTS'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Nutritional Requirements Data ──────────────────────────
          SectionChildPocData(
            title: 'Nutritional Requirements',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
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