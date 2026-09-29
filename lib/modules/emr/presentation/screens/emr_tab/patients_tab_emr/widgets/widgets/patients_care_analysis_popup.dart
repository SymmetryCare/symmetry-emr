import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class PatientsCareAnalysisPopup extends StatelessWidget {
  const PatientsCareAnalysisPopup({super.key});

  static const double _kDesignWidth = 855;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 30),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Care Analysis",
        body: [
          SingleChildScrollView(
            child: Padding(
                    padding: const EdgeInsets.only(bottom: AppPadding.p10),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                // ── Left Panel: PGBM + VBP + Other ──────────────────────
                Container(
                  width: 170,
                  padding: const EdgeInsets.only(right: AppPadding.p8),
                  margin: const EdgeInsets.only(right: AppPadding.p5),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: ColorManager.mediumgrey, width: 1),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('PGBM Details:'),
                      SizedBox(height: AppSize.s12),
                      _DetailText('Period 1'),
                      SizedBox(height: AppSize.s6),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailText('HHRG – 1IA1'),
                            _DetailText('LUPA – 6 visits'),
                            _DetailText('Community Early'),
                            _DetailText('MMTA – Endocrine'),
                            _DetailText('Functional Impairment – Low'),
                            _DetailText('Comorbidity Adj – None'),],
                        ),
                      ),
                      SizedBox(height: AppSize.s12),
                      _DetailText('Period 2'),
                      SizedBox(height: AppSize.s6),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailText('HHRG – 3IA1'),
                            _DetailText('LUPA – 3 visits'),
                            _DetailText('Community Late'),
                            _DetailText('MMTA – Endocrine'),
                            _DetailText('Functional Impairment – Low'),
                            _DetailText('Comorbidity Adj – None'),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSize.s16),
                      _SectionLabel('VBP Details:'),
                      SizedBox(height: AppSize.s6),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailText('DFS Actual – 44.6'),
                            _DetailText('DFS Expected – 50.3'),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSize.s16),
                      _SectionLabel('Other:'),
                      SizedBox(height: AppSize.s6),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailText('TIOC – met'),
                          ],
                        ),
                      )

                    ],
                  ),
                ),

                const SizedBox(width: AppSize.s12),

                // ── Center Panel: ADL + Frequency ───────────────────────
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Predicted ADL Improvement table
                      const _SectionLabel('Predicted ADL Improvement'),
                      const SizedBox(height: AppSize.s8),
                      _AdlTable(),
                      const SizedBox(height: AppSize.s20),

                      // Frequency Guidance
                      const _SectionLabel('Frequency Guidance'),
                      const SizedBox(height: AppSize.s8),
                      _FrequencyGuidanceSection(),
                    ],
                  ),
                ),

                const SizedBox(width: AppSize.s16),

                // ── Right Panel: Predicted Outcomes ─────────────────────
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Predicted Outcomes'),
                      const SizedBox(height: AppSize.s8),
                      _OutcomesTable(),
                    ],
                  ),
                ),
              ],
                    ),   // Row
                  ),     // Padding(bottom)
            ),           // SingleChildScrollView(vertical)
        ],
      ),
    );
  }
}

// ── ADL Table ────────────────────────────────────────────────────────────────
class _AdlTable extends StatelessWidget {
  static const List<Map<String, dynamic>> _rows = [
    {'item': 'M B1800 Grooming', 'score': '1', 'level': 'Low'},
    {'item': 'M B1810 UB Dressing', 'score': '2', 'level': 'High'},
    {'item': 'M B1820 LB Dressing', 'score': '2', 'level': 'High'},
    {'item': 'M B1830 Bathing', 'score': '3', 'level': 'High'},
    {'item': 'M B1840 Toilet Transfer', 'score': '1', 'level': 'High'},
    {'item': 'M B1850 Transferring', 'score': '2', 'level': 'High'},
    {'item': 'M B1860 Ambulation', 'score': '3', 'level': 'High'},
    {'item': 'M B1870 Oral Meds', 'score': '3', 'level': 'High'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: ColorManager.blueprime,
          ),
          child: const Row(
            children: [
              _TableHeader('OASIS Item', flex: 2),
              _TableHeader('Starting Score', flex: 1),
              _TableHeader('Probability of Improvement', flex: 2),
            ],
          ),
        ),
        // Rows
        ..._rows.map((row) {
          return Container(
            color: Colors.white,
            child: Row(
              children: [
                _TableCell(row['item'], flex: 2),
                _TableCell(row['score'], flex: 1, center: true),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p8, vertical: AppPadding.p6),
                    child: _LevelBadge(row['level']),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Outcomes Table ───────────────────────────────────────────────────────────
class _OutcomesTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // End of Episode
        _OutcomeSubTable(
          sectionTitle: 'End of Episode',
          rows: [
            {'label': 'Community Discharge', 'level': 'Medium'},
            {'label': 'Recertification', 'level': 'Medium'},
          ],
        ),
        SizedBox(height: AppSize.s12),
        // During Episode
        _OutcomeSubTable(
          sectionTitle: 'During Episode',
          rows: [
            {'label': 'Hospitalization', 'level': 'High'},
          ],
        ),
      ],
    );
  }
}

class _OutcomeSubTable extends StatelessWidget {
  final String sectionTitle;
  final List<Map<String, String>> rows;

  const _OutcomeSubTable({required this.sectionTitle, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        Container(
          decoration: BoxDecoration(
            color: ColorManager.blueprime,
          ),
          child: Row(
            children: [
              _TableHeader(sectionTitle, flex: 2),
              const _TableHeader('Probability of Outcome', flex: 2),
            ],
          ),
        ),
        ...rows.map((e) {
          return Column(
            children: [
              Row(
                children: [
                  _TableCell(e['label']!, flex: 2),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p8, vertical: AppPadding.p6),
                      child: _LevelBadge(e['level']!),
                    ),
                  ),
                ],
              ),
              const Divider(),

            ],
          );
        }),
      ],
    );
  }
}

// ── Frequency Guidance ───────────────────────────────────────────────────────
class _FrequencyGuidanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _FrequencyTable(title: 'If LOS is 1-30 Days', rows: [
              {'type': 'SN', 'visits': '4–6'},
              {'type': 'PT', 'visits': '0-1'},
              {'type': 'OT', 'visits': '0-1'},
            ])),
            SizedBox(width: AppSize.s12),
            Expanded(child: _FrequencyTable(title: 'If LOS is 1-30 Days', rows: [
              {'type': 'ST', 'visits': ''},
              {'type': 'MSW', 'visits': '✓'},
              {'type': 'HHA', 'visits': ''},
            ])),
          ],
        ),
        const SizedBox(height: AppSize.s12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _FrequencyTable(title: 'If LOS is 1-30 Days', rows: [
              {'type': 'SN', 'visits': '8-11'},
              {'type': 'PT', 'visits': '0-6'},
              {'type': 'OT', 'visits': '0-1'},
            ])),
            SizedBox(width: AppSize.s12),
            Expanded(child: _FrequencyTable(title: 'If LOS is 1-30 Days', rows: [
              {'type': 'ST', 'visits': ''},
              {'type': 'MSW', 'visits': '✓✓'},
              {'type': 'HHA', 'visits': '✓'},
            ])),
          ],
        ),
        const SizedBox(height: AppSize.s10),
        // Legend
        Row(
          children: [
            Icon(Icons.check, size: IconSize.I20, color: ColorManager.blueprime),
            const SizedBox(width: AppSize.s4),
            Text(
              'Moderate likelihood of at least one of this type of visit',
              style: TextStyle(fontSize: FontSize.s10, color: ColorManager.grey),
            ),
            const SizedBox(width: AppSize.s16),
            Icon(Icons.check, size: IconSize.I20, color: ColorManager.blueprime),
            Icon(Icons.check, size: IconSize.I20, color: ColorManager.blueprime),
            const SizedBox(width: AppSize.s4),
            Text(
              'High likelihood of at least one of this type of visit',
              style: TextStyle(fontSize: FontSize.s10, color: ColorManager.grey),
            ),
          ],
        ),
      ],
    );
  }
}

class _FrequencyTable extends StatelessWidget {
  final String title;
  final List<Map<String, String>> rows;

  const _FrequencyTable({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left:   BorderSide(color: ColorManager.mediumgrey, width: 1),
          right:  BorderSide(color: ColorManager.mediumgrey, width: 1),
          bottom: BorderSide(color: ColorManager.mediumgrey, width: 1),
        ),
        borderRadius: BorderRadius.circular(AppSize.s4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: ColorManager.blueprime,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSize.s4),
                topRight: Radius.circular(AppSize.s4),
              ),
            ),
            child: Row(
              children: [
                _TableHeader(title, flex: 2),
                const _TableHeader('Predicted Visits', flex: 2),
              ],
            ),
          ),
          // Rows
          ...rows.asMap().entries.map((e) {
            final String visits = e.value['visits']!;
            final int checkCount = visits.replaceAll(RegExp(r'[^✓]'), '').length;
            final bool isLast = e.key == rows.length - 1;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(color: ColorManager.mediumgrey, width: 1),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TableCell(e.value['type']!, flex: 2, center: true),
                    Container(width: 1, color: ColorManager.mediumgrey),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p8, vertical: AppPadding.p6),
                        child: checkCount > 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  checkCount,
                                  (_) => Icon(Icons.check,
                                      size: IconSize.I14,
                                      color: ColorManager.blueprime),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Shared Widgets ───────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeight.w700,
        color: ColorManager.darkgrey,
      ),
    );
  }
}

class _DetailText extends StatelessWidget {
  final String text;
  const _DetailText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.s2),
      child: Text(
        text,
        style: TextStyle(fontSize: FontSize.s11, color: ColorManager.grey),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeader(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p8, vertical: AppPadding.p6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w600,
            color: ColorManager.white,
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool center;
  const _TableCell(this.text, {this.flex = 1, this.center = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p8, vertical: AppPadding.p6),
        child: Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(fontSize: FontSize.s11, color: ColorManager.darkgrey),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge(this.level);

  Color get _color {
    switch (level.toLowerCase()) {
      case 'high':
        return ColorManager.green;
      case 'medium':
        return const Color(0xFFF5A623);
      case 'low':
        return ColorManager.red;
      default:
        return ColorManager.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p8, vertical: AppPadding.p4),
      decoration: BoxDecoration(
        color: _color,
      ),
      child: Text(
        level,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w600,
          color: ColorManager.white,
        ),
      ),
    );
  }
}

