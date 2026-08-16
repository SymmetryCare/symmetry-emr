import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_advance_directives/poc_advanced_directives_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocAdvanceDirectives extends StatelessWidget {
  const PocAdvanceDirectives({super.key});

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
          //         builder: (context) => PocAdvancedDirectivesPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'ADVANCED DIRECTIVES'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── Advance Directives Data ────────────────────────────────
          SectionChildPocData(
            title: 'Advance Directives',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'DNI',       date: '4/12/2025'),
              PocDataItem(text: 'Full Code', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}