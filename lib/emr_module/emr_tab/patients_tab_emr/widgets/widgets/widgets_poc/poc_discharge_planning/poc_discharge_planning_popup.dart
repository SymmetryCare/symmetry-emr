import 'package:flutter/material.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../../../popup_const_emr.dart';

enum _DischargeCategory { sn, pt, ot, st, msw }

class PocDischargePlanningPopup extends StatefulWidget {
  const PocDischargePlanningPopup({super.key});

  @override
  State<PocDischargePlanningPopup> createState() =>
      _PocDischargePlanningPopupState();
}

class _PocDischargePlanningPopupState extends State<PocDischargePlanningPopup> {
  _DischargeCategory _selected = _DischargeCategory.sn;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customTextController = TextEditingController();

  final List<String> _items = const [
    'DC PT',
    'Discharge when patient/team goals met',
    'Discharge to care of: Self/Caregiver/Physician',
    'Evaluation Only',
    'Discharge to facility (specify): ____',
    'Discharge when medical condition stable and patient no longer in need of skilled care',
  ];

  final Map<_DischargeCategory, Map<String, bool>> _selectedByCategory = {
    _DischargeCategory.sn: {
      'Discharge when patient/team goals met': true,
      'Discharge to care of: Self/Caregiver/Physician': true,
    },
    _DischargeCategory.pt: {},
    _DischargeCategory.ot: {},
    _DischargeCategory.st: {},
    _DischargeCategory.msw: {},
  };

  @override
  void dispose() {
    _searchController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  Map<String, bool> get _currentSelected => _selectedByCategory[_selected]!;

  int _countFor(_DischargeCategory cat) =>
      _selectedByCategory[cat]!.values.where((v) => v).length;

  int get _totalSelected => _selectedByCategory.values
      .expand((m) => m.values)
      .where((v) => v)
      .length;

  String _labelFor(_DischargeCategory cat) {
    switch (cat) {
      case _DischargeCategory.sn:  return 'SN Discharge Plan';
      case _DischargeCategory.pt:  return 'PT Discharge Plan';
      case _DischargeCategory.ot:  return 'OT Discharge Plan';
      case _DischargeCategory.st:  return 'ST Discharge Plan';
      case _DischargeCategory.msw: return 'MSW Discharge Plan';
    }
  }

  void _selectAll() => setState(() {
    for (final item in _items) {
      _currentSelected[item] = true;
    }
  });

  void _clearAll() => setState(() {
    for (final item in _items) {
      _currentSelected[item] = false;
    }
  });

  List<String> get _filteredItems {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((i) => i.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p250, vertical: AppPadding.p30),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Manage Discharge Planning",
        body: [
          SizedBox(
            height: MediaQuery.of(context).size.height -
                (AppPadding.p80 * 2) - 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT: Categories sidebar ───────────────────────
                SizedBox(
                  width: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATEGORIES',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppSize.s16),

                        ..._DischargeCategory.values.map((cat) {
                          final isSelected = _selected == cat;
                          final count = _countFor(cat);
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: AppSize.s12),
                            child: _CategoryRow(
                              label: _labelFor(cat),
                              count: count,
                              selected: isSelected,
                              onTap: () =>
                                  setState(() => _selected = cat),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Vertical divider
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16),
                  color: Colors.grey.shade200,
                ),

                // ── RIGHT: Search + actions + checkboxes + input ───
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field
                      CustomSearchFieldSM(
                        searchController: _searchController,
                        width: double.infinity,
                        onPressed: () => setState(() {}),
                      ),

                      const SizedBox(height: AppSize.s12),

                      // Select All / Clear + count row
                      Row(
                        children: [
                          // Select All button
                          OutlinedButton.icon(
                            onPressed: _selectAll,
                            icon: Icon(Icons.check_circle_outline,
                                size: 14,
                                color: ColorManager.blueprime),
                            label: Text(
                              'Select All',
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                color: ColorManager.blueprime,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: ColorManager.blueprime.withOpacity(0.08),
                              side: BorderSide.none,
                              //side: BorderSide(color: ColorManager.blueprime, width: 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p10,
                                  vertical: AppPadding.p6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSize.s12),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSize.s10),

                          // Clear button
                          OutlinedButton.icon(
                            onPressed: _clearAll,
                            icon: Icon(Icons.cancel_outlined,
                                size: 14, color: Colors.red.shade400),
                            label: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                color: Colors.red.shade400,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              backgroundColor: Colors.red.shade300.withOpacity(0.08),
                             // side: BorderSide(color: Colors.red.shade300, width: 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p10,
                                  vertical: AppPadding.p6),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(AppSize.s12),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Selected count
                          Text(
                            '$_totalSelected of ${_items.length} selected',
                            style: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSize.s16),

                      // Checkbox grid
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: StatefulBuilder(
                            builder: (context, _) => LayoutBuilder(
                              builder: (context, constraints) {
                                final itemWidth =
                                    (constraints.maxWidth - AppSize.s12) /
                                        2;
                                return Wrap(
                                  spacing: AppSize.s12,
                                  runSpacing: AppSize.s12,
                                  children: _filteredItems
                                      .map((item) => SizedBox(
                                    width: itemWidth,
                                    child: _CheckboxCard(
                                      label: item,
                                      value: _currentSelected[item] ??
                                          false,
                                      onChanged: (val) =>
                                          setState(() {
                                            _currentSelected[item] =
                                                val ?? false;
                                          }),
                                    ),
                                  ))
                                      .toList(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSize.s12),

                      // Custom text input + Add button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customTextController,
                              style: TextStyle(
                                fontSize: FontSize.s12,
                                color: ColorManager.darkgrey,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                'Enter here to add new customize text',
                                hintStyle: TextStyle(
                                  fontSize: FontSize.s11,
                                  color: ColorManager.mediumgrey,
                                ),
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: AppPadding.p10,
                                    vertical: AppPadding.p8),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorManager.blueprime,
                                      width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          OutlinedButton.icon(
                            onPressed: () {
                              final text =
                              _customTextController.text.trim();
                              if (text.isEmpty) return;
                              setState(() {
                                _currentSelected[text] = true;
                              });
                              _customTextController.clear();
                            },
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Add'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: ColorManager.blueprime, width: 1),
                              foregroundColor: ColorManager.blueprime,
                              textStyle: TextStyle(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p12,
                                  vertical: AppPadding.p8),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(AppSize.s4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ── Category Row ─────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String label;
  final int count;
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
            // Radio circle
            Container(
              width: AppSize.s16,
              height: AppSize.s16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? ColorManager.blueprime
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
                    color: ColorManager.blueprime,
                    shape: BoxShape.circle,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: AppSize.s8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontSize.s11,
                  fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? ColorManager.darkgrey
                      : ColorManager.grey,
                ),
              ),
            ),
            const SizedBox(width: AppSize.s6),
            // Count badge — grey circle
            Container(
              width: AppSize.s20,
              height: AppSize.s20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Checkbox Card (highlighted when selected) ─────────────────────────────────
class _CheckboxCard extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxCard({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSize.s6),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p10, vertical: AppPadding.p10),
        decoration: BoxDecoration(
          color: value
              ? ColorManager.blueprime.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSize.s6),
          border: Border.all(
            color: value
                ? ColorManager.blueprime.withOpacity(0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom checkbox
            Container(
              width: AppSize.s16,
              height: AppSize.s16,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: value ? ColorManager.blueprime : Colors.white,
                borderRadius: BorderRadius.circular(AppSize.s3),
                border: Border.all(
                  color: value
                      ? ColorManager.blueprime
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSize.s8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: FontSize.s11,
                  fontWeight:
                  value ? FontWeight.w600 : FontWeight.w400,
                  color: value
                      ? ColorManager.blueprime
                      : ColorManager.darkgrey,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}