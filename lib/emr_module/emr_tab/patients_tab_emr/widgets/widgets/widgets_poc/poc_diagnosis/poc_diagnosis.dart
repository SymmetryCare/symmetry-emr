import 'package:flutter/material.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../const_components.dart';

class _DiagnosisEntry {
  final String title;
  final String code;
  final String date;
  const _DiagnosisEntry({
    required this.title,
    required this.code,
    required this.date,
  });
}

class PocDiagnosis extends StatelessWidget {
  const PocDiagnosis({super.key});

  static const List<_DiagnosisEntry> _diagnoses = [
    _DiagnosisEntry(
      title: 'a. Essential (primary) hypertension',
      code: 'I10',
      date: '4/12/2025',
    ),
    _DiagnosisEntry(
      title: 'b. Other chronic pain',
      code: 'G89.29',
      date: '4/12/2025',
    ),
    _DiagnosisEntry(
      title: 'c. Low back pain, unspecified',
      code: 'M54.50',
      date: '4/12/2025',
    ),
    _DiagnosisEntry(
      title: 'd. Type 2 diabetes mellitus without complications',
      code: 'E11.9',
      date: '4/12/2025',
    ),
    _DiagnosisEntry(
      title: 'e. Mild cognitive impairment of uncertain or unknown etiology',
      code: 'G31.84',
      date: '4/12/2025',
    ),
    _DiagnosisEntry(
      title: 'f. Long-term (current) use of injectable non-insulin antidiabetic drugs',
      code: 'Z79.85',
      date: '4/12/2025',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppPadding.p20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ─────────────────────────────────────────
          // const SectionHeaderPOC(label: 'DIAGNOSES'),
          //
          // const SizedBox(height: AppSize.s16),

          // ── One card per diagnosis ─────────────────────────────────
          ..._diagnoses.map((diagnosis) => Padding(
            padding: const EdgeInsets.only(bottom: AppSize.s12),
            child: SectionChildPocData(
              title: diagnosis.title,
              formName: 'RN plan of care',
              clinicianName: 'John Smith',
              date: '2/3/2025',
              abbreviation: 'RN',
              showBottomDivider: false,
              items: [
                PocDataItem(text: diagnosis.code, date: diagnosis.date),
              ],
            ),
          )),
        ],
      ),
    );
  }
}