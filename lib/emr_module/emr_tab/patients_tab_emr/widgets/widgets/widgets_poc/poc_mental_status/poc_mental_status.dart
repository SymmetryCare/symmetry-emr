import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_mental_status/poc_mental_status_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocMentalStatus extends StatelessWidget {
  const PocMentalStatus({super.key});

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
          //         builder: (context) => PocMentalStatusPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'MENTAL STATUS'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Mental Status Data ─────────────────────────────────────
          SectionChildPocData(
            title: 'Mental Status',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Agitated', date: '4/12/2025'),
              PocDataItem(text: 'Alert',    date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}