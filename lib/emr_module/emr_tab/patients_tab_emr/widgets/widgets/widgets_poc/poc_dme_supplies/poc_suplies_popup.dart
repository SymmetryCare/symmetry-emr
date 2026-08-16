import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

class PocDmeSupliesPopup extends StatefulWidget {
  const PocDmeSupliesPopup({super.key});

  @override
  State<PocDmeSupliesPopup> createState() => _PocDmeSupliesPopupState();
}

class _PocDmeSupliesPopupState extends State<PocDmeSupliesPopup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customTextController = TextEditingController();

  // Categories list (left sidebar items)
  final List<String> _categoryItems = const [
    'Gauze',
    'Wound Cleanser',
    'Non-sterile Gloves',
  ];

  bool _showCategoryItems = false;

  // Selected items (right side checkboxes)
  final Map<String, bool> _selected = {
    'Gauze_1': true,
    'Wound Cleanser': true,
    'Gauze_2': true,
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
        title: "Manage Supplies",
        body: [
          SizedBox(
            height: MediaQuery.of(context).size.height - (AppPadding.p80 * 2) - 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // ── LEFT: Categories sidebar ──────────────────────
              SizedBox(
                width: 200,
                child: SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSize.s30),
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.blueprime,
                      ),
                    ),
                    const SizedBox(height: AppSize.s30),

                    // Supplies radio with count
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
                            'Supplies',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.darkgrey,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                              () => _showCategoryItems = !_showCategoryItems),
                          child: Container(
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
                        ),
                      ],
                    ),

                    if (_showCategoryItems) ...[
                      const SizedBox(height: AppSize.s12),
                      ..._categoryItems.map((item) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: AppPadding.p8),
                        child: Row(
                          children: [
                            Container(
                              width: AppSize.s16,
                              height: AppSize.s16,
                              decoration: BoxDecoration(
                                color: ColorManager.blueprime,
                                borderRadius:
                                BorderRadius.circular(AppSize.s3),
                              ),
                              child: const Icon(Icons.check,
                                  size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: AppSize.s10),
                            Text(
                              item,
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.darkgrey,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                  ),
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

                      const SizedBox(height: AppSize.s40),

                      // Two-column checkbox grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CheckboxRow(
                                  label: 'Gauze',
                                  value: _selected['Gauze_1'] ?? false,
                                  onChanged: (val) => setState(() =>
                                  _selected['Gauze_1'] = val ?? false),
                                ),
                                const SizedBox(height: AppSize.s30),
                                _CheckboxRow(
                                  label: 'Wound Cleanser',
                                  value:
                                  _selected['Wound Cleanser'] ?? false,
                                  onChanged: (val) => setState(() =>
                                  _selected['Wound Cleanser'] =
                                      val ?? false),
                                ),
                              ],
                            ),
                          ),

                          // Right column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CheckboxRow(
                                  label: 'Gauze',
                                  value: _selected['Gauze_2'] ?? false,
                                  onChanged: (val) => setState(() =>
                                  _selected['Gauze_2'] = val ?? false),
                                ),
                              ],
                            ),
                          ),
                        ],
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w600,
              color: ColorManager.darkgrey,
            ),
          ),
        ],
      ),
    );
  }
}