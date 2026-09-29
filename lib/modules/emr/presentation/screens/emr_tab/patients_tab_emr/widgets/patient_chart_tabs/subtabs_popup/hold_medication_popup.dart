import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class HoldMedicationPopup extends StatefulWidget {
  const HoldMedicationPopup({super.key});

  @override
  State<HoldMedicationPopup> createState() => _HoldMedicationPopupState();
}

class _HoldMedicationPopupState extends State<HoldMedicationPopup> {
  String? _selectedHold;
  String? _selectedResume;

  final List<String> _holdOptions = ['Option 1', 'Option 2', 'Option 3'];
  final List<String> _resumeOptions = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s700,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Blue header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSize.s8),
                  topRight: Radius.circular(AppSize.s8),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppPadding.p5, horizontal: AppPadding.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hold',
                    style: PopupBlueBarText.customTextStyle(context),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: ColorManager.white),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p40, vertical: AppPadding.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSize.s10),
                  // Hold dropdown
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hold',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.black,
                          ),
                        ),
                        const SizedBox(height: AppSize.s8),
                        _buildDropdown(
                          value: _selectedHold,
                          items: _holdOptions,
                          onChanged: (val) =>
                              setState(() => _selectedHold = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s20),

                  // Resume dropdown
                  SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.black,
                          ),
                        ),
                        const SizedBox(height: AppSize.s8),
                        _buildDropdown(
                          value: _selectedResume,
                          items: _resumeOptions,
                          onChanged: (val) =>
                              setState(() => _selectedResume = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s40),

                  // ── Buttons ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel button
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorManager.blueprime),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p32,
                              vertical: AppPadding.p12),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: ColorManager.blueprime,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSize.s16),

                      // Save button
                      ElevatedButton(
                        onPressed: () {
                          // TODO: handle save
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.blueprime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p32,
                              vertical: AppPadding.p12),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: ColorManager.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSize.s10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: 300,
      height: 35,
      padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12, vertical: AppPadding.p4),
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.grey),
        borderRadius: BorderRadius.circular(AppSize.s8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text('Select'),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}