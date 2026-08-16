import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/patients_data_summary_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/patients_tab_emr/widgets/widgets/constant_components.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';

class PatientDataScreen extends StatefulWidget {
  const PatientDataScreen({super.key});

  @override
  State<PatientDataScreen> createState() => _PatientDataScreenState();
}

class _PatientDataScreenState extends State<PatientDataScreen> {
  // Track expanded state per section
  final Map<String, bool> _expanded = {
    'Referral Paperwork': true,
    'Face-to-Face Encounter': true,
    'Insurance Verification/Authorization': true,
    'Signature Forms': true,
  };

  final List<_SectionData> _sections = [
    _SectionData(
      title: 'Referral Paperwork',
      items: [
        _DocItem(name: 'PDF Documents', person: 'Sarah Galindo (Intake)', date: '08/05/2025'),
      ],
    ),
    _SectionData(
      title: 'Face-to-Face Encounter',
      items: [
        _DocItem(name: 'F2F Encounter Note', person: 'Sarah Galindo (Intake)', date: '08/05/2025'),
      ],
    ),
    _SectionData(
      title: 'Insurance Verification/Authorization',
      items: [
        _DocItem(name: 'Insurance Verification/CWF', person: 'Ashley Foreman (Authorizations)', date: '08/05/2025'),
        _DocItem(name: 'PDFs Of Auth', person: 'Ashley Foreman (Authorizations)', date: '08/05/2025'),
      ],
    ),
    _SectionData(
      title: 'Signature Forms',
      items: [
        _DocItem(name: 'Admission Consent', person: 'Sarah Galindo (Intake)', date: '08/05/2025'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Patient Data',
              style: PatientsFormsHeadData.customTextStyle(context)
            ),
            const SizedBox(height: AppSize.s10),
            Text(
              'Updated on 04/08/2024 | 8:33 AM',
              style: PatientsFormsSubData.customTextStyle(context),
            ),
            const SizedBox(height: AppSize.s25),

            // Sections
            ...List.generate(_sections.length, (i) {
              final section = _sections[i];
              final isOpen = _expanded[section.title] ?? true;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  GestureDetector(
                    onTap: () => setState(() => _expanded[section.title] = !isOpen),
                    child: Row(
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.darkgrey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          size: 16,
                          color: ColorManager.blueprime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),

                  // Document rows
                  if (isOpen)
                    ...section.items.map((doc) => _DocRow(doc: doc)),

                  const SizedBox(height: AppSize.s16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────

class _SectionData {
  final String title;
  final List<_DocItem> items;
  const _SectionData({required this.title, required this.items});
}

class _DocItem {
  final String name;
  final String person;
  final String date;
  const _DocItem({required this.name, required this.person, required this.date});
}

// ── Doc Row Widget ────────────────────────────────────────────

class _DocRow extends StatelessWidget {
  final _DocItem doc;
  const _DocRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListViewContainerConstantEMR(
      paddingLeft: AppPadding.p60,
      paddingRight: AppPadding.p60,
      paddingTop: AppPadding.p10,
      paddingBottom: AppPadding.p10,
      marginRight: AppPadding.p20,
      child: Row(
        children: [
          // Document name
          Expanded(
            child: Text(
              doc.name,
              style:  TextStyle(
                fontSize: FontSize.s12,
                color: ColorManager.pieChartBBlue,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),

          // Avatar + person name
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    doc.person[0],
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    doc.person,
                    style: EMRListViewHead.customTextStyle(context),
                  ),
                ),
              ],
            ),
          ),

          // Date
          Expanded(
            child: Text(
              doc.date,
              style: EMRListViewData.customTextStyle(context),
            ),
          ),

          // AI Summary link
          Expanded(
            child: GestureDetector(
              onTap: () {
                showDialog(context: context, builder: (_) =>  const PatientsDataSummaryPopup());
              },
              child: Text(
                'AI Summary',
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.blueprime,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}