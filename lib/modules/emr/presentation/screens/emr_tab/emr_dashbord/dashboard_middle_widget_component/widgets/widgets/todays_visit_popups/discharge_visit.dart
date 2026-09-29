import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class DischargeVisitTypePopup extends StatefulWidget {
  final VisitPrefillByIdModel visitData;
  final VoidCallback onNevigate;
  const DischargeVisitTypePopup({super.key, required this.visitData, required this.onNevigate});

  @override
  State<DischargeVisitTypePopup> createState() =>
      _DischargeVisitTypePopupState();
}

class _DischargeVisitTypePopupState extends State<DischargeVisitTypePopup> {
  bool _isLoadingResumption = false;
  bool _isLoadingDischarge  = false;

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _onTap(
      {required int visitTypeId, required String visitTypeString}) async {
    final isResumption = visitTypeString == 'RECERT';

    // Set the appropriate loading state
    setState(() {
      if (isResumption)
        _isLoadingResumption = true;
      else
        _isLoadingDischarge = true;
    });

    Navigator.pop(context);
    showDialog(context: context,
        builder: (_) =>
            ViewStartVisit(
              visitData: widget.visitData,
              onRefresh: (){},
              visitType: visitTypeString,
            ));

    // Always clear loading flags before any navigation
    if (mounted) {
      setState(() {
        _isLoadingResumption = false;
        _isLoadingDischarge = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: AppSize.s400,
      height: AppSize.s200,
      title: 'NOM/NOC Form',
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you want to sign the NOM/NOC form?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.granitegray,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  // ── Resumption of Care ──────────────────────────
                  Expanded(
                    child: _isLoadingResumption
                        ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                        : OutlinedButton(
                      onPressed: _isLoadingDischarge
                          ? null
                          : () => _onTap(
                        visitTypeId: 11,
                        visitTypeString: 'RECERT',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.blueprime,
                        side: BorderSide(color: ColorManager.blueprime),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── Discharge ───────────────────────────────────
                  Expanded(
                    child: _isLoadingDischarge
                        ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: ColorManager.blueprime),
                      ),
                    )
                        : ElevatedButton(
                      onPressed: _isLoadingResumption
                          ? null
                          : () => _onTap(
                        visitTypeId: 4,
                        visitTypeString: 'DISCHARGE',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.blueprime,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Yes',
                        style:
                        TextStyle(color: Colors.white, fontSize: 13),
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