import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class PocFrequencies extends StatelessWidget {
  const PocFrequencies({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ─────────────────────────────────────────
          // GestureDetector(
          //   onTap: () {
          //     context.read<EMRNavigationController>().openFrequencyDetail();
          //   },
          //   child: const SectionHeaderPOC(label: 'FREQUENCY & DURATION'),
          // ),
          //
          // const SizedBox(height: AppSize.s16),

          // ── PT Frequency ──────────────────────────────────────────
          SectionChildPocData(
            title: 'PT Frequency',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'PT',
            date: '4/12/2025',
            items: const [
              PocDataItem(text: '2 x week for 2 weeks', date: '4/12/2025'),
              PocDataItem(text: '1 x week for 3 weeks', date: '4/12/2025'),
            ],
          ),

          const SizedBox(height: AppSize.s16),

          // ── OT Frequency ──────────────────────────────────────────
          SectionChildPocData(
            title: 'OT Frequency',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'OT',
            date: '4/12/2025',
            items: const [
              PocDataItem(text: '1 x week for 5 weeks', date: '4/12/2025'),
            ],
          ),

          const SizedBox(height: AppSize.s16),

          // ── ST Frequency ──────────────────────────────────────────
          SectionChildPocData(
            title: 'ST Frequency',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'ST',
            date: '4/12/2025',
            items: const [
              PocDataItem(text: '1 x week for 4 weeks', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}