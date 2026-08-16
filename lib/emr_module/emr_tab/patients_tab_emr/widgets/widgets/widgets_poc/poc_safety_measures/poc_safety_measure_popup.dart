import 'package:flutter/material.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../../../popup_const_emr.dart';

class PocSafetyMeasurePopup extends StatefulWidget {
  const PocSafetyMeasurePopup({super.key});

  @override
  State<PocSafetyMeasurePopup> createState() => _PocSafetyMeasurePopupState();
}

class _PocSafetyMeasurePopupState extends State<PocSafetyMeasurePopup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customTextController = TextEditingController();

  final List<String> _safetyItems = const [
    '24 hr. supervision',
    '911 Protocol',
    'Anticoagulant Precautions',
    'Aspiration Precautions',
    'Clear Pathways',
    'Diabetic precautions',
    'Elevate Head of Bed',
    'Emergency Plan Developed',
    'Equipment Safety',
    'Fall Precautions',
    'Hazardous Waste Disposal',
    'Keep Pathways Clear',
    'Keep Siderails Up',
    'Medication Safety/Storage',
    'O2 Precautions',
    'Safety in ADLs',
    'Seizure Precautions',
    'Slow Position Change',
    'Standard Precautions/Infection Control',
  ];

  final Map<String, bool> _selected = {
    'Anticoagulant Precautions': true,
    'Aspiration Precautions': true,
    'Diabetic precautions': true,
    'Fall Precautions': true,
    'Keep Siderails Up': true,
  };

  @override
  void dispose() {
    _searchController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p150, vertical: AppPadding.p60),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Manage Safety Measures",
        body: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height - (AppPadding.p80 * 2) - 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT: Categories sidebar ──────────────────────
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.blueprime,
                        ),
                      ),
                      const SizedBox(height: AppSize.s16),

                      // Safety Measures radio with count
                      Row(
                        children: [
                          Container(
                            width: AppSize.s16,
                            height: AppSize.s16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorManager.darkgrey,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: AppSize.s8,
                                height: AppSize.s8,
                                decoration: BoxDecoration(
                                  color: ColorManager.darkgrey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          Expanded(
                            child: Text(
                              'Safety Measures',
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.darkgrey,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p6,
                                vertical: AppPadding.p2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(AppSize.s10),
                            ),
                            child: Text(
                              '05',
                              style: TextStyle(
                                fontSize: FontSize.s10,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.blueprime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Vertical divider
                Container(
                  width: 1,
                  margin:
                  const EdgeInsets.symmetric(horizontal: AppPadding.p16),
                  color: Colors.grey.shade300,
                ),

                // ── RIGHT: Search + checkboxes + custom text ──────
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field
                        CustomSearchFieldSM(
                          searchController: _searchController,
                          width: 320,
                          onPressed: () {},
                        ),

                        const SizedBox(height: AppSize.s20),

                        // 3-column checkbox grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth =
                                (constraints.maxWidth - (AppSize.s16 * 2)) / 3;
                            return Wrap(
                              spacing: AppSize.s16,
                              runSpacing: AppSize.s14,
                              children: _safetyItems
                                  .map((item) => SizedBox(
                                width: itemWidth,
                                child: _CheckboxRow(
                                  label: item,
                                  value: _selected[item] ?? false,
                                  onChanged: (val) => setState(() =>
                                  _selected[item] = val ?? false),
                                ),
                              ))
                                  .toList(),
                            );
                          },
                        ),

                        const SizedBox(height: AppSize.s20),

                        // Custom text input
                        TextField(
                          controller: _customTextController,
                          style: TextStyle(
                            fontSize: FontSize.s12,
                            color: ColorManager.darkgrey,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter here to add new customize text',
                            hintStyle: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.mediumgrey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p10,
                                vertical: AppPadding.p8),
                            border: UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorManager.blueprime, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Checkbox Row ─────────────────────────────────────────────────────────────
class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p20,vertical: AppPadding.p8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.s8),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSize.s16,
              height: AppSize.s16,
              decoration: BoxDecoration(
                color: value ? ColorManager.blueprime : Colors.white,
                borderRadius: BorderRadius.circular(AppSize.s3),
                border: Border.all(
                  color: value ? ColorManager.blueprime : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSize.s10),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontSize.s11,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  color: ColorManager.darkgrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}