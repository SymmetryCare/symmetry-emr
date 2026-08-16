import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_prognosis/poc_prognosis_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocPrognosis extends StatelessWidget {
  const PocPrognosis({super.key});

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
          //         builder: (context) => PocPrognosisPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'PROGNOSIS'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Section Data ───────────────────────────────────────────
          SectionChildPocData(
            title: 'Prognosis',
            date: "2/3/2025",
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Good', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}