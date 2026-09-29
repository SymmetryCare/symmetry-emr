
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/create_new_order_clinician_dialog.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/create_new_order_patient_dialog.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class OrderSuppliesDialog extends StatelessWidget {
  const OrderSuppliesDialog({super.key});

  void _handleSelection(BuildContext context, String selected) {
    final navigator = Navigator.of(context);
    navigator.pop();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selected == 'Patient') {
        showCreateNewOrderDialog(navigator.context);
      } else if (selected == 'Clinician') {
        showClinicianOrderDialog(navigator.context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: AppSize.s330,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: ColorManager.blueprime,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppPadding.p10, horizontal: AppPadding.p20),

              child: Row(
                children: [
                  Text(
                    'Order Supplies',
                    style: PopupBlueBarText.customTextStyle(context),
                  ),
                  const Spacer(),
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close,
                        color: ColorManager.white, size: 18),
                  ),
                ],
              ),
            ),

            // ── Options ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p25,
                horizontal: AppPadding.p45,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectOption(context, 'Patient'),
                  _selectOption(context, 'Clinician'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectOption(BuildContext context, String label) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _handleSelection(context, label),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            color: ColorManager.mediumgrey,
            size: IconSize.I22,
          ),
          const SizedBox(width: AppSize.s8),
          Text(
            label,
            style:  TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorManager.mediumgrey,
            ),
          ),
        ],
      ),
    );
  }
}