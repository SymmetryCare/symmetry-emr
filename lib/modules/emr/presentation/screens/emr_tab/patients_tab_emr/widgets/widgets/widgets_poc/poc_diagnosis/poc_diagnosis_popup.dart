import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

class _DiagnosisItem {
  final String description;
  final String icdCode;
  final String controlRating;
  final String tag;
  final Color tagColor;

  const _DiagnosisItem({
    required this.description,
    required this.icdCode,
    required this.controlRating,
    required this.tag,
    required this.tagColor,
  });
}

class PocDiagnosisPopup extends StatefulWidget {
  const PocDiagnosisPopup({super.key});

  @override
  State<PocDiagnosisPopup> createState() => _PocDiagnosisPopupState();
}

class _PocDiagnosisPopupState extends State<PocDiagnosisPopup> {
  final TextEditingController _searchController =
  TextEditingController(text: 'G20');

  static const List<Map<String, String>> _searchResults = [
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
    {'name': 'Parkinson\'s disease with dyskinesia, w/o mention of fluctuations', 'code': 'G20.A1'},
    {'name': 'Parkinson\'s Unspecified', 'code': 'G20.C'},
    {'name': 'Parkinson\'s disease without dyskinesia, with fluctuations', 'code': 'G20.A2'},
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
    {'name': 'Parkinson\'s disease with dyskinesia, with fluctuations', 'code': 'G20.B2'},
  ];

  final _DiagnosisItem _primary = const _DiagnosisItem(
    description: 'Essential (primary) hypertension',
    icdCode: 'I10',
    controlRating: '1',
    tag: 'SP',
    tagColor: Color(0xFF4CAF50),
  );

  final List<_DiagnosisItem> _secondary = const [
    _DiagnosisItem(description: 'Other Chronic Pain',                                            icdCode: 'G89.29', controlRating: '1', tag: 'SP', tagColor: Color(0xFF4CAF50)),
    _DiagnosisItem(description: 'Low back pain, unspecified',                                    icdCode: 'M54.50', controlRating: '1', tag: 'SP', tagColor: Color(0xFF4CAF50)),
    _DiagnosisItem(description: 'Type 2 diabetes mellitus without complications',                icdCode: 'E11.9',  controlRating: '1', tag: 'SP', tagColor: Color(0xFF4CAF50)),
    _DiagnosisItem(description: 'Mild cognitive impairment of uncertain or unknown etiology',    icdCode: 'G31.84', controlRating: '1', tag: 'SP', tagColor: Color(0xFF4CAF50)),
    _DiagnosisItem(description: 'Long-term (current) use of injectable non-insulin antidiabetic drugs', icdCode: 'Z79.85', controlRating: '1', tag: 'IQ', tagColor: Color(0xFFB71C1C)),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p150, vertical: AppPadding.p16),
      child: DialogueTemplate(
        width: double.infinity,
        height: double.infinity,
        title: "Update Diagnosis Codes",
        body: [
          SizedBox(
            height: MediaQuery.of(context).size.height - (AppPadding.p30 * 2) - (AppPadding.p18 * 2) - 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT: Search + results ──────────────────────────
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field with dropdown chevron
                      Row(
                        children: [
                          Expanded(
                            child: CustomSearchFieldSM(
                              searchController: _searchController,
                              width: 200,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: AppSize.s4),
                          Icon(Icons.keyboard_arrow_down,
                              size: AppSize.s18,
                              color: ColorManager.blueprime),
                        ],
                      ),
                      const SizedBox(height: AppSize.s12),

                      // Search results
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppPadding.p10),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: FontSize.s10,
                                    color: ColorManager.grey,
                                    height: 1.4,
                                  ),
                                  children: [
                                    TextSpan(text: '${result['name']} ('),
                                    TextSpan(
                                      text: result['code'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: ColorManager.darkgrey,
                                      ),
                                    ),
                                    const TextSpan(text: ')'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16),
                  color: Colors.grey.shade300,
                ),

                // ── RIGHT: Column headers + Diagnosis form ──────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column headers
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Column 1',
                                  style: TextStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w700,
                                    color: ColorManager.darkgrey,
                                  ),
                                ),
                                const SizedBox(height: AppSize.s8),
                                Text(
                                  'Diagnosis (Sequencing of diagnosis should reflect the seriousness of each condition and support the disciplines and services provided.)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: ColorManager.grey,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: AppSize.s8),
                                Text(
                                  'Descriptions',
                                  style: TextStyle(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.darkgrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Column 2',
                                  style: TextStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w700,
                                    color: ColorManager.darkgrey,
                                  ),
                                ),
                                const SizedBox(height: AppSize.s8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p8),
                                  child: Text(
                                    'ICD-10-CM and symptom control rating for each condition. Note that the sequencing of these rating may not match the sequencing of the diagnoses.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: ColorManager.grey,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSize.s8),
                                Text(
                                  'ICD-10-CM/Symptom Control Rating',
                                  style: TextStyle(
                                    fontSize: FontSize.s10,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.darkgrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.attach_money,
                                size: AppSize.s20,
                                color: ColorManager.green,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSize.s16),

                      // Form area (scrollable)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Primary Diagnosis label
                              Text(
                                '(M1021) Primary Diagnosis',
                                style: TextStyle(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.darkgrey,
                                ),
                              ),
                              const SizedBox(height: AppSize.s10),
                              _DiagnosisRow(item: _primary),

                              const SizedBox(height: AppSize.s16),

                              // Secondary Diagnosis label
                              Text(
                                '(M1023) Secondary Diagnosis',
                                style: TextStyle(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.darkgrey,
                                ),
                              ),
                              const SizedBox(height: AppSize.s10),
                              ..._secondary.map((item) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppPadding.p10),
                                child: _DiagnosisRow(item: item),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        bottomButtons: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButtonTransparent(
              text: "Cancel",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: AppSize.s12),
            CustomElevatedButton(
              text: "Insert",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ── Diagnosis Row ─────────────────────────────────────────────────────────────
class _DiagnosisRow extends StatelessWidget {
  final _DiagnosisItem item;
  const _DiagnosisRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Drag handle
        Icon(Icons.drag_handle,
            size: AppSize.s18, color: ColorManager.blueprime),
        const SizedBox(width: AppSize.s8),

        // Description text field
        Expanded(
          flex: 4,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppSize.s4),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              item.description,
              style: TextStyle(
                fontSize: FontSize.s11,
                color: ColorManager.darkgrey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),

        const SizedBox(width: AppSize.s8),

        // ICD code field
        SizedBox(
          width: 75,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppSize.s4),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              item.icdCode,
              style: TextStyle(
                fontSize: FontSize.s11,
                color: ColorManager.darkgrey,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSize.s8),

        // Control rating dropdown
        Container(
          width: 60,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(AppSize.s4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.controlRating,
                style: TextStyle(
                    fontSize: FontSize.s11, color: ColorManager.darkgrey),
              ),
              Icon(Icons.keyboard_arrow_down,
                  size: AppSize.s14, color: ColorManager.grey),
            ],
          ),
        ),

        const SizedBox(width: AppSize.s8),

        // Tag badge (SP / IQ / etc.)
        Container(
          width: 28,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: item.tagColor,
            borderRadius: BorderRadius.circular(AppSize.s4),
          ),
          child: Text(
            item.tag,
            style: const TextStyle(
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: AppSize.s6),

        // Info icon
        Icon(Icons.info_outline,
            size: AppSize.s16, color: ColorManager.blueprime),

        const SizedBox(width: AppSize.s6),

        // Close icon
        Icon(Icons.close, size: AppSize.s16, color: ColorManager.red),
      ],
    );
  }
}