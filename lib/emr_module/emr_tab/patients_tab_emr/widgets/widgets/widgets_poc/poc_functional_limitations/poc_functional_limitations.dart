import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_functional_limitations/poc_functional_limit_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocFunctionalLimitations extends StatelessWidget {
  const PocFunctionalLimitations({super.key});

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
          //         builder: (context) => PocFunctionalLimitPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'FUNCTIONAL LIMITATIONS'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Functional Limitations',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            date: "2/3/2025",
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