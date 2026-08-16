import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_safety_measures/poc_safety_measure_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocSafetyMeasures extends StatelessWidget {
  const PocSafetyMeasures({super.key});

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
          //         builder: (context) => PocSafetyMeasurePopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'SAFETY MEASURES'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Safety Measures Data ───────────────────────────────────
          SectionChildPocData(
            title: 'DME',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: '24 hr. supervision',        date: '4/12/2025'),
              PocDataItem(text: 'Anticoagulant Precautions', date: '4/12/2025'),
              PocDataItem(text: 'Aspiration Precautions',    date: '4/12/2025'),
              PocDataItem(text: 'Elevate Head of Bed',       date: '4/12/2025'),
              PocDataItem(text: 'Keep Pathways Clear',       date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}