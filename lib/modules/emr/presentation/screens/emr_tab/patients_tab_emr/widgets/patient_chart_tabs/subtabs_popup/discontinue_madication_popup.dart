import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/subtabs_popup/add_medication_popup.dart';

class DiscontinueMadicationPopup extends StatefulWidget {
  const DiscontinueMadicationPopup({super.key});

  @override
  State<DiscontinueMadicationPopup> createState() =>
      _DiscontinueMadicationPopupState();
}

class _DiscontinueMadicationPopupState
    extends State<DiscontinueMadicationPopup> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await CalendarDialogHelper.show(
      context: context,
      selectedDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _dateController.text = CalendarDialogHelper.fmt(picked);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: AppSize.s350,
        height: AppSize.s350,
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
                    'Discontinue',
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSize.s8),
                    // ── Discontinue Date label ───────────────────────
                    Text(
                      'Discontinue Date',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.darkgrey,
                      ),
                    ),

                    const SizedBox(height: AppSize.s8),

                    // ── Date field ───────────────────────────────────
                    AppTextField(
                      controller: _dateController,
                      hint: 'Select date',
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icon(
                        Icons.calendar_month_outlined,
                        size: AppSize.s16,
                        color: ColorManager.blueprime,
                      ),
                    ),

                    const Spacer(),

                    // ── Buttons ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ColorManager.blueprime),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.s8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p24,
                                vertical: AppPadding.p10),
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
                        const SizedBox(width: AppSize.s12),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: handle discontinue
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.blueprime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSize.s8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p24,
                                vertical: AppPadding.p10),
                          ),
                          child: Text(
                            'Discontinue',
                            style: TextStyle(
                              color: ColorManager.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}