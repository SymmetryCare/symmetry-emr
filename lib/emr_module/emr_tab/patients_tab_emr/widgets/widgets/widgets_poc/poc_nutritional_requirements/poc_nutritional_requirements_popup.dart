import 'package:flutter/material.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../em_module/widgets/button_constant.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../../../popup_const_emr.dart';

enum _NutritionalCategory { dietHydration, enteralParenteral, pediatric }

class PocNutritionalRequirementsPopup extends StatefulWidget {
  const PocNutritionalRequirementsPopup({super.key});

  @override
  State<PocNutritionalRequirementsPopup> createState() =>
      _PocNutritionalRequirementsPopupState();
}

class _PocNutritionalRequirementsPopupState
    extends State<PocNutritionalRequirementsPopup> {
  _NutritionalCategory _selected = _NutritionalCategory.dietHydration;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customTextController = TextEditingController();

  final List<String> _items = const [
    '__ Calorie ADA',
    'No concentrated sweets',
    'Diabetic Diet',
    'NPO',
    'Diet as Tolerated',
    'Increase fluids to __ per day',
    'Gluten Free',
    'Low Carbohydrate',
    '____ Gram Sodium',
    'Low Fat',
    'High Carbohydrate',
    'Low Protein',
    'High Protein',
    'Nutritional Supplement',
    'High Sodium',
    'Pureed Diet',
    'Low Sodium',
    'Restrict fluids to ____ per day',
    'Mechanical Soft',
    'Sip/Ice chips only',
  ];

  // Items that need value input when checked (have blanks like __)
  static const List<String> _itemsRequiringValue = [
    '__ Calorie ADA',
    'Increase fluids to __ per day',
    '____ Gram Sodium',
    'Restrict fluids to ____ per day',
  ];

  final Map<String, bool> _selectedItems = {
    '__ Calorie ADA': true,
    'No concentrated sweets': true,
    'Diabetic Diet': true,
    'High Carbohydrate': true,
    'Low Protein': true,
    'Nutritional Supplement': true,
  };

  // Stored value-input values
  final Map<String, String> _itemValues = {};

  @override
  void dispose() {
    _searchController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  // Get all checked items in display order
  List<String> get _checkedItems => _items
      .where((item) => _selectedItems[item] == true)
      .toList();

  // Show value input popup
  Future<void> _showValueInputPopup(String item) async {
    final controller =
    TextEditingController(text: _itemValues[item] ?? '');
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DialogueTemplateNoButtons(
        width: AppSize.s450,
        height: AppSize.s200,
        title: 'Manage Nutritional Requirements',
        body: [

            // Input + label
            Padding(
              padding: const EdgeInsets.all(AppPadding.p20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        color: ColorManager.darkgrey,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p10,
                            vertical: AppPadding.p10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSize.s6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSize.s6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSize.s6),
                          borderSide: BorderSide(
                              color: ColorManager.blueprime, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s12),
                  Text(
                    "Calorie ADa",
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                  const SizedBox(width: AppSize.s30),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.only(
                  right: AppPadding.p16, bottom: AppPadding.p16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: ColorManager.darkgrey,
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s12),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, controller.text),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: ColorManager.blueprime,
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );

    if (result != null) {
      setState(() {
        _itemValues[item] = result;
        _selectedItems[item] = true;
      });
    }
  }

  void _toggleCheckbox(String item, bool? val) {
    if (val == true && _itemsRequiringValue.contains(item)) {
      _showValueInputPopup(item);
    } else {
      setState(() => _selectedItems[item] = val ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p150, vertical: AppPadding.p30),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Manage Nutritional Requirements",
        body: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height - (AppPadding.p80 * 2) - 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT: Categories sidebar ──────────────────────
                SizedBox(
                  width: 220,
                  child: SingleChildScrollView(
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

                        // Diet/Hydration radio
                        _CategoryRow(
                          label: 'Diet/Hydration',
                          count:
                          _checkedItems.length.toString().padLeft(2, '0'),
                          selected:
                          _selected == _NutritionalCategory.dietHydration,
                          onTap: () => setState(() => _selected =
                              _NutritionalCategory.dietHydration),
                        ),

                        // Show checked items under Diet/Hydration when selected
                        if (_selected ==
                            _NutritionalCategory.dietHydration &&
                            _checkedItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppPadding.p2, top: AppPadding.p6),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: _checkedItems
                                  .map(
                                    (item) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppPadding.p6),
                                  child: _CheckboxRow(
                                    label: item,
                                    value: true,
                                    onChanged: (val) =>
                                        _toggleCheckbox(item, val),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                          ),

                        const SizedBox(height: AppSize.s12),

                        _CategoryRow(
                          label: 'Enteral/Parenteral',
                          count: '01',
                          selected: _selected ==
                              _NutritionalCategory.enteralParenteral,
                          onTap: () => setState(() => _selected =
                              _NutritionalCategory.enteralParenteral),
                        ),
                        const SizedBox(height: AppSize.s10),
                        _CategoryRow(
                          label: 'Pediatric Diet/Hydration',
                          count: '01',
                          selected:
                          _selected == _NutritionalCategory.pediatric,
                          onTap: () => setState(() =>
                          _selected = _NutritionalCategory.pediatric),
                        ),
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
                        CustomSearchFieldSM(
                          searchController: _searchController,
                          width: 320,
                          onPressed: () {},
                        ),

                        const SizedBox(height: AppSize.s20),

                        // 2-column checkbox grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth =
                                (constraints.maxWidth - AppSize.s16) / 2;
                            return Wrap(
                              spacing: AppSize.s16,
                              runSpacing: AppSize.s14,
                              children: _items
                                  .map((item) => SizedBox(
                                width: itemWidth,
                                child: _CheckboxRow(
                                  label: item,
                                  value:
                                  _selectedItems[item] ?? false,
                                  onChanged: (val) =>
                                      _toggleCheckbox(item, val),
                                ),
                              ))
                                  .toList(),
                            );
                          },
                        ),

                        const SizedBox(height: AppSize.s20),

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

// ── Category Row (sidebar item) ──────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSize.s4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p4),
        child: Row(
          children: [
            Container(
              width: AppSize.s16,
              height: AppSize.s16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? ColorManager.darkgrey
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width: AppSize.s8,
                  height: AppSize.s8,
                  decoration: BoxDecoration(
                    color: ColorManager.darkgrey,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: AppSize.s10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? ColorManager.darkgrey : ColorManager.grey,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p6, vertical: AppPadding.p2),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE3F2FD)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSize.s10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? ColorManager.blueprime
                      : ColorManager.grey,
                ),
              ),
            ),
          ],
        ),
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
    );
  }
}