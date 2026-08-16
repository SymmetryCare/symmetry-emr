import 'package:flutter/material.dart';
import 'package:prohealth/app/services/token/token_manager.dart';

import '../../../../../../../../oasis_form_builder/model/chart_patient_referral_data_model.dart';
import '../../../../../../../../oasis_form_builder/model/patient_form_model.dart';
import '../../../../../../../../oasis_form_builder/oasis_form_mapper.dart';
import '../../../../../../../../oasis_form_builder/services/api/managers/patient_form_manager.dart';

class PatienFormTapping with ChangeNotifier{
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void onTap({
    required BuildContext context,
    required int patientFormId,
    required int ptId,
    required int chartNo}) async {
    // if (widget.item == null) return;

     _isLoading = true;
     notifyListeners();

    final result = await getPatientFormByPatientID(
      context,
      patientFormId: patientFormId,
    );
    String role = await TokenManager.getRole();

    _isLoading = false;
    notifyListeners();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OasisFormMapper(
          appBarString: 'Patient-Chart',
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
            fillStatus: result.subForms.isNotEmpty ? result.subForms.first.isFilled : false,
            commentCount: result.subForms.isNotEmpty ? result.subForms.first.comment_count : 0,
          ),
          patient: ChartPatientReferral(
            patientId: ptId,
            firstName:result.referralData.patientFirstname,
            lastName: result.referralData.patientLastname,
            contactNumber: result.referralData.patientPhone,
            address: result.referralData.patientAddress,
            imageUrl: result.referralData.patientImageUrl,
            gender: Gender(genderID: 1, genderName: 'Male'),
            dateOfBirth: DateTime.tryParse(result.referralData.patientDob ?? '') ?? DateTime.now(),
            chartNo: result.referralData.patientChartNo,
            episodes: [],
          ),
          userRole: role,
        ),
      ),
    );
  }
}