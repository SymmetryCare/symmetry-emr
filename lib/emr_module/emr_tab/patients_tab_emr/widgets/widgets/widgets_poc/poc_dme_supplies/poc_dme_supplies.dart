import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_dme_supplies/poc_suplies_popup.dart';

import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocDmeSupplies extends StatelessWidget {
  const PocDmeSupplies({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Supplies Section ───────────────────────────────────────
          // InkWell(
          //   onTap: () {
          //     showDialog(
          //         context: context,
          //         builder: (context) => PocDmeSupliesPopup());
          //   },
          //   child: const SectionHeaderPOC(label: 'DME/SUPPLIES'),
          // ),
          // ── DME Section ────────────────────────────────────────────

          SectionChildPocData(
            title: 'DME',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Bedside Commode', date: '4/12/2025'),
            ],
          ),



          const SizedBox(height: AppSize.s10),
          SectionChildPocData(
            title: 'Supplies',
            formName: 'RN plan of care',
            clinicianName: 'John Smith',
            date: '2/3/2025',
            abbreviation: 'RN',
            showBottomDivider: false,
            items: const [
              PocDataItem(text: 'Gauze',              date: '4/12/2025'),
              PocDataItem(text: 'Wound Cleanser',     date: '4/12/2025'),
              PocDataItem(text: 'Non-sterile Gloves', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}