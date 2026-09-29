import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_discharge_planning/poc_discharge_planning_popup.dart';

import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocDischargePlanning extends StatelessWidget {
  const PocDischargePlanning({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SN Discharge Plan ──────────────────────────────────────
          SectionChildPocData(
            title: 'SN Discharge Plan',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'SN',
            date: '4/12/2025',
            items: [
              PocDataItem(
                  text: 'Discharge to care of: Self/Caregiver/Physician',
                  date: '4/12/2025'),
              PocDataItem(
                  text: 'Discharge to facility (specify): ____',
                  date: '4/12/2025'),
            ],
          ),

          SizedBox(height: AppSize.s16),

          // ── PT Discharge Plan ──────────────────────────────────────
          SectionChildPocData(
            title: 'PT Discharge Plan',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'PT',
            date: '4/12/2025',
            items: [
              PocDataItem(
                  text: 'Discharge when patient/team goals met',
                  date: '4/12/2025'),
            ],
          ),

          SizedBox(height: AppSize.s16),

          // ── OT Discharge Plan ──────────────────────────────────────
          SectionChildPocData(
            title: 'OT Discharge Plan',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'OT',
            date: '4/12/2025',
            items: [
              PocDataItem(
                  text: 'Patient\'s discharge goal: ____', date: '4/12/2025'),
            ],
          ),

          SizedBox(height: AppSize.s16),

          // ── ST Discharge Plan ──────────────────────────────────────
          SectionChildPocData(
            title: 'ST Discharge Plan',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'ST',
            date: '4/12/2025',
            items: [
              PocDataItem(text: 'DC ST', date: '4/12/2025'),
            ],
          ),

          SizedBox(height: AppSize.s16),

          // ── MSW Discharge Plan ─────────────────────────────────────
          SectionChildPocData(
            title: 'MSW Discharge Plan',
            formName: 'Plan of Care',
            clinicianName: 'James Smith',
            abbreviation: 'MSW',
            date: '4/12/2025',
            items: [
              PocDataItem(
                  text: 'Medical Social Services Evaluation Only',
                  date: '4/12/2025'),
            ],
          ),
        ],
      ),
    );
  }
}