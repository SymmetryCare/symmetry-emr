import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_rehab_potential/poc_rehab_potential_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocRehabPotential extends StatelessWidget {
  const PocRehabPotential({super.key});

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
          //         builder: (context) => PocRehabPotentialPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'REHAB POTENTIAL'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── SN Rehab Potential ─────────────────────────────────────
          SectionChildPocData(
            title: 'SN Rehab Potential',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: "2/3/2025",
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Good', date: '4/12/2025'),
            ],
          ),

          const SizedBox(height: AppSize.s16),

          // ── OT Rehab Potential ─────────────────────────────────────
          SectionChildPocData(
            title: 'OT Rehab Potential',
            formName: 'OT plan of care',
            clinicianName: 'Jane Doe',
            date: "2/3/2025",
            abbreviation: 'OT',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Fair', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}