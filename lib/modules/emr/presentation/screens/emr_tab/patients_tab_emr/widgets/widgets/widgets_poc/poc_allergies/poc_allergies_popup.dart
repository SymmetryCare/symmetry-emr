import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class _AllergyEntry {
  final String name;
  final List<String> reactions;
  final bool needsOrder;

  const _AllergyEntry({
    required this.name,
    required this.reactions,
    this.needsOrder = false,
  });
}

class PocAllergiesPopup extends StatefulWidget {
  const PocAllergiesPopup({super.key});

  @override
  State<PocAllergiesPopup> createState() => _PocAllergiesPopupState();
}

class _PocAllergiesPopupState extends State<PocAllergiesPopup> {
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _dateController =
  TextEditingController(text: 'mm/dd/yyyy');
  final TextEditingController _reactionController = TextEditingController();

  // Sidebar allergies state
  final List<_AllergyEntry> _allergies = const [
    _AllergyEntry(
      name: 'Penicillin',
      reactions: ['rash'],
    ),
    _AllergyEntry(
      name: 'Latex',
      reactions: ['rash'],
      needsOrder: true,
    ),
  ];

  final Map<String, bool> _selectedAllergies = {
    'Penicillin': false,
    'Latex': true,
  };

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _dateController.dispose();
    _reactionController.dispose();
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
        title: "Edit Allergies",
        body: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height - (AppPadding.p80 * 2) - 160,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── LEFT: Current Allergies sidebar ─────────
                      SizedBox(
                        width: 200,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Allergies:',
                                style: TextStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.darkgrey,
                                ),
                              ),
                              const SizedBox(height: AppSize.s12),

                              // Allergy items
                              ..._allergies.map((allergy) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppPadding.p10),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _CheckboxRow(
                                      label: allergy.name,
                                      value: _selectedAllergies[
                                      allergy.name] ??
                                          false,
                                      onChanged: (val) => setState(() =>
                                      _selectedAllergies[
                                      allergy.name] =
                                          val ?? false),
                                    ),
                                    // Reactions sub-list
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: AppPadding.p24,
                                          top: AppPadding.p4),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          ...allergy.reactions.map((r) =>
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    bottom:
                                                    AppPadding.p2),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      r,
                                                      style: TextStyle(
                                                        fontSize:
                                                        FontSize.s11,
                                                        color:
                                                        ColorManager
                                                            .darkgrey,
                                                      ),
                                                    ),
                                                    if (_selectedAllergies[
                                                    allergy.name] ==
                                                        true) ...[
                                                      const SizedBox(
                                                          width:
                                                          AppSize.s8),
                                                      Icon(
                                                        Icons
                                                            .delete_outline,
                                                        size: AppSize.s14,
                                                        color: ColorManager
                                                            .grey,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              )),
                                          if (allergy.needsOrder)
                                            Padding(
                                              padding: const EdgeInsets
                                                  .only(top: AppPadding.p4),
                                              child: Text(
                                                '*needs order',
                                                style: TextStyle(
                                                  fontSize: FontSize.s10,
                                                  fontStyle:
                                                  FontStyle.italic,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  color: ColorManager.red,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                              const SizedBox(height: AppSize.s8),

                              // Run Interactions button
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.blueprime,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p16,
                                      vertical: AppPadding.p10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(AppSize.s20)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Run Interactions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vertical divider
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p16),
                        color: Colors.grey.shade300,
                      ),

                      // ── RIGHT: Form fields ──────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: AppPadding.p10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Allergy field
                              _FormField(
                                label: 'Allergy*',
                                child: TextField(
                                  controller: _allergyController,
                                  style: TextStyle(
                                    fontSize: FontSize.s12,
                                    color: ColorManager.darkgrey,
                                  ),
                                  decoration: _inputDecoration(
                                      'type allergy and select from list'),
                                ),
                              ),

                              const SizedBox(height: AppSize.s16),

                              // Start Date field
                              _FormField(
                                label: 'Start Date*',
                                child: TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  onTap: _pickDate,
                                  style: TextStyle(
                                    fontSize: FontSize.s12,
                                    color: ColorManager.mediumgrey,
                                  ),
                                  decoration: _inputDecoration('mm/dd/yyyy')
                                      .copyWith(
                                    suffixIcon: Icon(Icons.calendar_today_outlined,
                                        size: AppSize.s16,
                                        color: ColorManager.blueprime),
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSize.s16),

                              // Reaction field
                              _FormField(
                                label: 'Reaction*',
                                child: TextField(
                                  controller: _reactionController,
                                  style: TextStyle(
                                    fontSize: FontSize.s12,
                                    color: ColorManager.darkgrey,
                                  ),
                                  decoration: _inputDecoration('enter text'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom action buttons ─────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: AppPadding.p12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _OutlinedPillButton(
                        label: 'Cancel',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: AppSize.s10),
                      _FilledPillButton(
                        label: 'Save',
                        onTap: () {},
                      ),
                      const SizedBox(width: AppSize.s10),
                      _FilledPillButton(
                        label: 'Save & Add Additional',
                        onTap: () {},
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(fontSize: FontSize.s11, color: ColorManager.mediumgrey),
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
        borderSide: BorderSide(color: ColorManager.blueprime, width: 1.5),
      ),
    );
  }
}

// ── Form Field (label + input row) ───────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w600,
              color: ColorManager.darkgrey,
            ),
          ),
        ),
        Expanded(child: child),
      ],
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
                fontSize: FontSize.s12,
                fontWeight: FontWeight.w600,
                color: ColorManager.darkgrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pill Buttons ─────────────────────────────────────────────────────────────
class _OutlinedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedPillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: ColorManager.blueprime),
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p20, vertical: AppPadding.p8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.s20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ColorManager.blueprime,
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilledPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilledPillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.blueprime,
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p20, vertical: AppPadding.p10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.s20)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}