import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class RecertFormDialog extends StatefulWidget {
  final int visitId;
  final VisitPrefillByIdModel visitData;

  const RecertFormDialog({
    super.key,
    required this.visitId,
    required this.visitData,
  });

  @override
  State<RecertFormDialog> createState() => _RecertFormDialogState();
}

class _RecertFormDialogState extends State<RecertFormDialog> {
  bool _isLoadingYes = false;
  bool _isLoadingNo  = false;

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _handleDecision({
    required String decision,
    required bool isYes,
  }) async {
    setState(() {
      if (isYes) _isLoadingYes = true;
      else       _isLoadingNo  = true;
    });

    final result = await patchRecertVisit(
      context: context,
      id: widget.visitId,
      decision: decision,
    );

    setState(() {
      _isLoadingYes = false;
      _isLoadingNo  = false;
    });

    if (result.success) {
      // ── Close current dialog then open ViewStartVisit ─────────────────
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => ViewStartVisit(
          visitData: widget.visitData,
          onRefresh: () {},
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AddErrorPopup(
          message: result.message,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: AppSize.s400,
      height: AppSize.s200,
      title: 'Recert',
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Would you like to complete the Recert Form?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.granitegray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  // ── No Button ───────────────────────────────────
                  Expanded(
                    child: _isLoadingNo
                        ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                        : OutlinedButton(
                      onPressed: _isLoadingYes
                          ? null
                          : () => _handleDecision(
                        decision: "no",
                        isYes: false,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.blueprime,
                        side: BorderSide(color: ColorManager.blueprime),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Yes Button ──────────────────────────────────
                  Expanded(
                    child: _isLoadingYes
                        ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: ColorManager.blueprime,
                        ),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: _isLoadingNo
                          ? null
                          : () => _handleDecision(
                        decision: "yes",
                        isYes: true,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.blueprime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}