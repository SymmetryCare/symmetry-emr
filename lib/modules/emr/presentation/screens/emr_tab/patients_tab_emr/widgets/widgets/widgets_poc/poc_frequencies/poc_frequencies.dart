import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocFrequencies extends StatelessWidget {
  const PocFrequencies({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PT Frequency ──────────────────────────────────────────
          SectionChildPocData(
            title: 'PT Frequency',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'PT',
            date: '4/12/2025',
            items: [
              PocDataItem(text: '2 x week for 2 weeks', date: '4/12/2025'),
              PocDataItem(text: '1 x week for 3 weeks', date: '4/12/2025'),
            ],
          ),

          SizedBox(height: AppSize.s16),

          // ── OT Frequency ──────────────────────────────────────────
          SectionChildPocData(
            title: 'OT Frequency',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'OT',
            date: '4/12/2025',
            items: [
              PocDataItem(text: '1 x week for 5 weeks', date: '4/12/2025'),
            ],
          ),

          SizedBox(height: AppSize.s16),

          // ── ST Frequency ──────────────────────────────────────────
          SectionChildPocData(
            title: 'ST Frequency',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'ST',
            date: '4/12/2025',
            items: [
              PocDataItem(text: '1 x week for 4 weeks', date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}