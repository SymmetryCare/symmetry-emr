import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/poc_eligibility/poc_eligibility_popup.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocEligibility extends StatelessWidget {
  const PocEligibility({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card with all sections ──────────────────────────────
          Column(
            children: [
              // Homebound Status section
              SectionChildPocData(
                title: 'Homebound Status',
                formName: "RN plan of care",
                clinicianName: "john SMith",
                abbreviation: "RN",
                date: "15/12/2023",
                showBottomDivider: true,
                items: [
                  PocDataItem(
                    text: 'This patient is currently homebound due to weakness as determined by skilled assessment. The patient needs standby assistance of another person to leave their place of residence and requires the use of DWW for safety with mobility. The patient is a fall risk as determined by scoring a 4 on the MAHC-10 standardized assessment. Additionally, the patient has severe cognitive deficits 2/2 Alzheimer\'s Disease causing the patient to be homebound at this time.',
                    date: '4/12/2025',
                  ),
                ],
                child: Column(
                  children: [

                    // Level 1 Criteria
                    _CollapsibleRow(
                        title: 'Level 1 Criteria (Assistance/Condition)'),

                    // Level 2 Criteria
                    _CollapsibleRow(
                        title: 'Level 2 Criteria (Inability/Taxing Effort)'),

                  ],
                ),
              ),
              SizedBox(height: 15,),
              SectionChildPocData(
                title: 'Face to Face Encounter',
                formName: "RN Start of care",
                clinicianName: "Michel SMith",
                abbreviation: "RN",
                date: "14/12/2023",
                showBottomDivider: true,
                items: [
                  PocDataItem(
                    text: 'I certify/recertify that the above-stated patient is homebound and that upon completion of the FTF encounter, has a need/continued need for intermittent skilled nursing, physical therapy, and/or speech or occupational therapy services in their home for their current diagnosis as outlined in their initial plan of care. This patient is under my care, and I will periodically review and update the plan of care as required. I further certify that this patient had a face-to-face on 04/19/2025 that was related to the primary reason the patient requires home health services.',
                          date: '4/12/2025',
                  ),
                ],
              ),

            ],
          ),
        ],
      ),
    );
  }
}

class _CollapsibleRow extends StatefulWidget {
  final String title;
  const _CollapsibleRow({required this.title});

  @override
  State<_CollapsibleRow> createState() => _CollapsibleRowState();
}

class _CollapsibleRowState extends State<_CollapsibleRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p16, vertical: AppPadding.p14),
          child: Row(
            children: [
              Container(
                width: AppSize.s8,
                height: AppSize.s8,
                decoration: BoxDecoration(
                  color: ColorManager.faintGrey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSize.s10),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkgrey,
                  ),
                ),
              ),
              Icon(
                _expanded
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                size: AppSize.s20,
                color: ColorManager.blueprime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}