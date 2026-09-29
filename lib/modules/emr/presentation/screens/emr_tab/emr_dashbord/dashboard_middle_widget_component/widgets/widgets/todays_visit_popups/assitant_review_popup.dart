import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/chart_patient_referral_data_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/oasis_form_mapper.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/form_builder_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/patient_form_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/discharge_visit.dart';

class AssistantReviewPopup extends StatefulWidget {
  final VisitPrefillByIdModel visitData;
  final VoidCallback onNevigate;
  const AssistantReviewPopup(
      {super.key, required this.visitData, required this.onNevigate});

  @override
  State<AssistantReviewPopup> createState() => _AssistantReviewPopupState();
}

class _AssistantReviewPopupState extends State<AssistantReviewPopup> {
  bool _isLoading = false;

  Future<void> _onReviewPressed() async {
    _onTap(
      ptId: widget.visitData.ptId,
      patientFormId: widget.visitData.pendingAssistantFormIds.first,
      visitId: widget.visitData.lastVisitIds.first,
      lastFormFillByAssist: 'assistant',
    );
  }
  Future<void> _onTap({
    required int patientFormId,
    required int ptId,
    required int visitId,
    required String lastFormFillByAssist,
  }) async {
    try {
      final result = await getPatientFormByPatientID(
        context,
        patientFormId: patientFormId,
      );
      String userRole = await TokenManager.getRole();

      if (!mounted) return;
      setState(() => _isLoading = false);

      // ✅ Guard: bail out if result or critical data is null
      if (result == null) {
        debugPrint('_onTap: result is null — aborting navigation');
        return;
      }

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OasisFormMapper(
            form: PatientForm(
              formID: result.formId,
              formName: result.formName,
              fillStatus: result.status,
              subForms: result.subForms
                  .map((e) => PatientSubForm(
                  formID: result.formId,
                  subFormID: e.id,
                  subFormName: e.subFormName,
                  patientFormID: result.patientFormId,
                  fillStatus: e.isFilled,
                  commentCount: e.comment_count
              ))
                  .toList(),
            ),
            subForm: PatientSubForm(
              formID: result.formId,
              subFormID: result.subForms.isNotEmpty ? result.subForms.first.id : 0,
              subFormName: result.subForms.isNotEmpty ? result.subForms.first.subFormName : '',
              patientFormID: result.patientFormId,
              commentCount: result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
              fillStatus: result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
            ),
            patient: ChartPatientReferral(
              patientId: ptId,
              firstName: result.referralData.patientFirstname,
              lastName: result.referralData.patientLastname,
              contactNumber: result.referralData.patientPhone,
              address: result.referralData.patientAddress,
              imageUrl: result.referralData.patientImageUrl,
              gender: Gender(genderID: 1, genderName: 'Male'),
              dateOfBirth: DateTime.tryParse(result.referralData.patientDob ?? '') ?? DateTime.now(),
              chartNo: result.referralData.patientChartNo,
              episodes: [],
            ),
            appBarString: 'EMR - Clinical',
            userRole: userRole,
            lastFormFillByAssist: lastFormFillByAssist,
            visitId: visitId,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('_onTap error: $e\n$stack');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: AppSize.s400,
      height: AppSize.s200,
      title: 'Review Form',
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please review the forms before proceeding to the next visit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: ColorManager.granitegray,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  // ── Cancel ──────────────────────────────────────
                Expanded(
                    child: OutlinedButton(
                      onPressed:
                      _isLoading ? null : () => Navigator.pop(context),
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

                  // ── Review ──────────────────────────────────────
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onReviewPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.blueprime,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: const Color(0xFFBFBFBF),
                        disabledForegroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Review',
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