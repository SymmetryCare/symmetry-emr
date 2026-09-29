import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

enum _EligibilityCategory { homeboundStatus, faceToFace }

class PocEligibilityPopup extends StatefulWidget {
  const PocEligibilityPopup({super.key});

  @override
  State<PocEligibilityPopup> createState() => _PocEligibilityPopupState();
}

class _PocEligibilityPopupState extends State<PocEligibilityPopup> {
  _EligibilityCategory _selected = _EligibilityCategory.homeboundStatus;

  // Homebound Status state
  bool _expandedLevel1 = false;
  bool _expandedLevel2 = true;
  String? _normalAbility;
  final TextEditingController _conditionController = TextEditingController();
  final Map<String, bool> _level1Items = {};
  // Face to Face state
  bool _isNewRequest = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _conditionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p150, vertical: AppPadding.p30),
      child: DialogueTemplate(
        width: double.infinity,
        height: double.infinity,
        title: 'Eligibility',
        body: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT: Categories ──────────────────────────────
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
                      const SizedBox(height: AppSize.s12),
                      _CategoryRow(
                        label: 'Homebound Status',
                        count: '05',
                        selected: _selected == _EligibilityCategory.homeboundStatus,
                        onTap: () => setState(() =>
                        _selected = _EligibilityCategory.homeboundStatus),
                      ),
                      const SizedBox(height: AppSize.s8),
                      _CategoryRow(
                        label: 'Face-to-Face Encounter',
                        count: '01',
                        selected: _selected == _EligibilityCategory.faceToFace,
                        onTap: () => setState(
                                () => _selected = _EligibilityCategory.faceToFace),
                      ),
                    ],
                  ),
                ),

                // ── Divider ───────────────────────────────────────
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
                  color: Colors.grey.shade300,
                ),

                // ── RIGHT: Content ────────────────────────────────
                Expanded(
                  child: _selected == _EligibilityCategory.homeboundStatus
                      ? _buildHomeboundContent()
                      : _buildFaceToFaceContent(),
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

  // ── Homebound Status Content ───────────────────────────────────
  Widget _buildHomeboundContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          CustomSearchFieldSM(
            searchController: _searchController,
            width: 320,
            onPressed: () {},
          ),
          const SizedBox(height: AppSize.s16),

          // Homebound Status header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p12, vertical: AppPadding.p10),
            color: const Color(0xFFEFF6FB),
            child: Text(
              'Homebound Status',
              style: TextStyle(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w700,
                color: ColorManager.darkgrey,
              ),
            ),
          ),

          const SizedBox(height: AppSize.s4),

          // Level 1 Criteria header
          _CollapsibleHeader(
            title: 'Level 1 Criteria',
            expanded: _expandedLevel1,
            onTap: () => setState(() => _expandedLevel1 = !_expandedLevel1),
          ),

          // Level 1 expanded content (NO inner scroll view)
          if (_expandedLevel1) ...[
            const SizedBox(height: AppSize.s16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The patient is considered homebound/confirmed to home because (select all apply)',
                    style: TextStyle(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                  const SizedBox(height: AppSize.s12),

                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Because of illness or injury, the patient needs aid of supportive devices.',
                      value: _level1Items['illness_devices'] ?? false,
                      onChanged: (val) => setState(() =>
                      _level1Items['illness_devices'] = val ?? false),
                    ),
                  ),

                  if (_level1Items['illness_devices'] == true)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: AppPadding.p24, top: AppPadding.p4),
                      child: Wrap(
                        spacing: AppSize.s16,
                        runSpacing: AppSize.s8,
                        children: [
                          _CheckboxItem(
                            label: 'Crutches',
                            value: _level1Items['crutches'] ?? false,
                            onChanged: (val) => setState(() =>
                            _level1Items['crutches'] = val ?? false),
                          ),
                          _CheckboxItem(
                            label: 'Wheelchair',
                            value: _level1Items['wheelchair'] ?? false,
                            onChanged: (val) => setState(() =>
                            _level1Items['wheelchair'] = val ?? false),
                          ),
                          _CheckboxItem(
                            label: 'Other',
                            value: _level1Items['other_device'] ?? false,
                            onChanged: (val) => setState(() =>
                            _level1Items['other_device'] = val ?? false),
                          ),
                          _CheckboxItem(
                            label: 'Cane',
                            value: _level1Items['cane'] ?? false,
                            onChanged: (val) => setState(() =>
                            _level1Items['cane'] = val ?? false),
                          ),
                          _CheckboxItem(
                            label: 'Walker',
                            value: _level1Items['walker'] ?? false,
                            onChanged: (val) => setState(() =>
                            _level1Items['walker'] = val ?? false),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppSize.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Use of special transportation',
                      value: _level1Items['special_transport'] ?? false,
                      onChanged: (val) => setState(() =>
                      _level1Items['special_transport'] = val ?? false),
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Assistance of another person in order to leave place of residence',
                      value: _level1Items['assistance'] ?? false,
                      onChanged: (val) => setState(() =>
                      _level1Items['assistance'] = val ?? false),
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Patient has a condition such that leaving home is medically contradicted',
                      value: _level1Items['medical_contradicted'] ?? false,
                      onChanged: (val) => setState(() =>
                      _level1Items['medical_contradicted'] = val ?? false),
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Psychiatric services. Refusal or inability to safely leave home unattended',
                      value: _level1Items['psychiatric'] ?? false,
                      onChanged: (val) => setState(() =>
                      _level1Items['psychiatric'] = val ?? false),
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Patient not confined homebound',
                      value: _level1Items['not_confined'] ?? false,
                      onChanged: (val) => setState(() =>
                      _level1Items['not_confined'] = val ?? false),
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _CheckboxItem(
                      label: 'Other (Specify)',
                      value: _level1Items['other'] ?? false,
                      onChanged: (val) =>
                          setState(() => _level1Items['other'] = val ?? false),
                    ),
                  ),
                  const SizedBox(height: AppSize.s16),
                ],
              ),
            ),
          ],

          // Level 2 Criteria
          _CollapsibleHeader(
            title: 'Level 2 Criteria',
            expanded: _expandedLevel2,
            onTap: () => setState(() => _expandedLevel2 = !_expandedLevel2),
          ),

          if (_expandedLevel2) ...[
            const SizedBox(height: AppSize.s16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Does a normal inability to leave the home exist and leaving the home requires a considerable and taxing effort?',
                    style: TextStyle(
                      fontSize: FontSize.s11,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  Row(
                    children: [
                      _RadioOption(
                        label: 'Yes',
                        value: 'yes',
                        groupValue: _normalAbility,
                        onChanged: (v) => setState(() => _normalAbility = v),
                      ),
                      const SizedBox(width: AppSize.s24),
                      _RadioOption(
                        label: 'No',
                        value: 'no',
                        groupValue: _normalAbility,
                        onChanged: (v) => setState(() => _normalAbility = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.s20),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Document patient\'s condition and limitations as it relates to their homebound status.',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.s6),
                      Icon(Icons.edit_outlined,
                          size: AppSize.s14, color: ColorManager.blueprime),
                    ],
                  ),
                  const SizedBox(height: AppSize.s8),
                  TextField(
                    controller: _conditionController,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.darkgrey,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Text',
                      hintStyle: TextStyle(
                        fontSize: FontSize.s12,
                        color: ColorManager.mediumgrey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.p10, vertical: AppPadding.p10),
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
                        borderSide:
                        BorderSide(color: ColorManager.blueprime, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Face to Face Content ───────────────────────────────────────
  Widget _buildFaceToFaceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        CustomSearchFieldSM(
          searchController: _searchController,
          width: 320,
          onPressed: (){},
        ),

        const SizedBox(height: AppSize.s16),

        // Section header with "Edit New Request" checkbox
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12, vertical: AppPadding.p10),
          color: const Color(0xFFEFF6FB),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Face to Face Encounter',
                style: TextStyle(
                  fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkgrey,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: AppSize.s16,
                    height: AppSize.s16,
                    child: Checkbox(
                      value: _isNewRequest,
                      onChanged: (val) =>
                          setState(() => _isNewRequest = val ?? false),
                      activeColor: ColorManager.blueprime,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      side:
                      BorderSide(color: Colors.grey.shade400, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSize.s2)),
                    ),
                  ),
                  const SizedBox(width: AppSize.s6),
                  Text(
                    'Edit New Request',
                    style: TextStyle(
                      fontSize: FontSize.s11,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSize.s16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: FontSize.s11,
                color: ColorManager.darkgrey,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                  'I certify/recertify that the above-stated patient is homebound and that upon completion of the FTF encounter, has a need/continued need for intermittent skilled nursing, physical therapy, and/or speech or occupational therapy services in their home for their current diagnosis as outlined in their initial plan of care. This patient is under my care, and I will periodically review and update the plan of care as required. I further certify that this patient had a face-to-face on ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.p4, vertical: AppPadding.p2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(AppSize.s4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '04/19/2025',
                          style: TextStyle(
                            fontSize: FontSize.s11,
                            color: ColorManager.darkgrey,
                          ),
                        ),
                        const SizedBox(width: AppSize.s4),
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: ColorManager.blueprime),
                      ],
                    ),
                  ),
                ),
                const TextSpan(
                  text:
                  ' that was related to the primary reason the patient requires home health services.',
                ),
              ],
            ),
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
        child: Row(
          children: [
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppSize.s4),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collapsible Header ───────────────────────────────────────────────────────
class _CollapsibleHeader extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;

  const _CollapsibleHeader({
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p12, vertical: AppPadding.p10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w600,
                color: ColorManager.darkgrey,
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: AppSize.s18,
              color: ColorManager.blueprime,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Radio Option ─────────────────────────────────────────────────────────────
class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSize.s16,
            height: AppSize.s16,
            child: Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: ColorManager.blueprime,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: AppSize.s8),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s11,
              color: ColorManager.darkgrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxItem({
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: AppSize.s16,
            height: AppSize.s16,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: ColorManager.blueprime,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s2),
              ),
            ),
          ),
          const SizedBox(width: AppSize.s8),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s11,
              color: ColorManager.darkgrey,
            ),
          ),
        ],
      ),
    );
  }
}
