import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/services/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import '../../../../../../../../../app/services/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import '../../../../../../../../../data/api_data/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import '../../../../../../../../../presentation/screens/em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../../../popup_const_emr.dart';

class DischargeMissedVisitTypePopup extends StatefulWidget {
  final int visitId;
  final VoidCallback onNevigate;
  final patientFormId;
  const DischargeMissedVisitTypePopup(
      {super.key,
        required this.visitId,
        required this.onNevigate,
        this.patientFormId});

  @override
  State<DischargeMissedVisitTypePopup> createState() =>
      _DischargeMissedVisitTypePopupState();
}

class _DischargeMissedVisitTypePopupState
    extends State<DischargeMissedVisitTypePopup> {
  bool _isLoadingResumption = false;
  bool _isLoadingDischarge = false;

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

    // Call the patchEpisodeEnd API
    final result = await patchEpisodeEnd(
      context: context,
      visitId: widget.visitId,       // pass visit ID from prefill model
      episodeEndType: visitTypeString,     // 'RESUMPTION_OF_CARE' or 'DISCHARGE'
    );

    // Always clear loading flags before any navigation
    if (mounted) {
      setState(() {
        _isLoadingResumption = false;
        _isLoadingDischarge = false;
      });
    }

    if (result.success) {
      // Close this popup, then trigger navigation callback
      if (mounted) Navigator.pop(context, true);
      widget.onNevigate();

      showDialog(
        context: context,
        builder: (_) => const AddSuccessPopup(
          message: 'Visit type updated successfully',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AddErrorPopup(
          message: result.message.isNotEmpty
              ? result.message
              : 'Something went wrong!',
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
      title: 'RECERT or Discharge',
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Since this is last visit, how would you like to proceed?\nwith the treatment plan?',
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
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
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
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                            color: Colors.white, fontSize: 13),
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