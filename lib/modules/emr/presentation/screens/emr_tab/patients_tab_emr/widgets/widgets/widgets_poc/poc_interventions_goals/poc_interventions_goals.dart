import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/widgets/widgets_poc/const_components.dart';

class PocInterventionsGoals extends StatelessWidget {
  const PocInterventionsGoals({super.key});

  static const _sampleItems = [
    PocDataItem(
      text: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      date: '4/12/2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftColumn(),
                const SizedBox(height: AppSize.s16),
                _buildRightColumn(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLeftColumn()),
              const SizedBox(width: AppSize.s24),
              Expanded(child: _buildRightColumn()),
            ],
          );
        },
      ),
    );
  }

  // ── Left column: SN / OT / PT Interventions ───────────────────────
  Widget _buildLeftColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       SectionChildPocData(
          title: 'SN Interventions',
          formName: 'RN plan of care',
          clinicianName: 'John Smith',
          date: '2/3/2025',
          abbreviation: 'RN',
          showBottomDivider: false,
          items: _sampleItems,
        ),

        SizedBox(height: AppSize.s20),

        SectionChildPocData(
          title: 'OT Interventions',
          formName: 'OT plan of care',
          clinicianName: 'Jane Doe',
          date: '2/3/2025',
          abbreviation: 'OT',
          showBottomDivider: false,
          items: _sampleItems,
        ),

        SizedBox(height: AppSize.s20),

       SectionChildPocData(
          title: 'PT Interventions',
          formName: 'PT plan of care',
          clinicianName: 'Bob Lee',
          date: '2/3/2025',
          abbreviation: 'PT',
          showBottomDivider: false,
          items: _sampleItems,
        ),
      ],
    );
  }

  // ── Right column: SN / OT / PT Goals ──────────────────────────────
  Widget _buildRightColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       SectionChildPocData(
          title: 'SN Goals',
          formName: 'RN plan of care',
          clinicianName: 'John Smith',
          date: '2/3/2025',
          abbreviation: 'RN',
          showBottomDivider: false,
          items: _sampleItems,
        ),

        SizedBox(height: AppSize.s20),

        SectionChildPocData(
          title: 'OT Goals',
          formName: 'OT plan of care',
          clinicianName: 'Jane Doe',
          date: '2/3/2025',
          abbreviation: 'OT',
          showBottomDivider: false,
          items: _sampleItems,
        ),

        SizedBox(height: AppSize.s20),

         SectionChildPocData(
          title: 'PT Goals',
          formName: 'PT plan of care',
          clinicianName: 'Bob Lee',
          date: '2/3/2025',
          abbreviation: 'PT',
          showBottomDivider: false,
          items: _sampleItems,
        ),
      ],
    );
  }
}