import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_data_model.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_header_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/emr_patient_repo/patient_physician_repo.dart';

Future<PatientReferralHeaderData?> getPatientReferralHeader(
    BuildContext context,
    int patientId,
    ) async {
  try {
    final response = await Api(context).get(
      path: PatientReferralRepository.getHeader(patientId: patientId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final item = response.data;
      print("Response:::::: $item");

      return PatientReferralHeaderData(
        patientId:             item['patientId']             as int,
        patientName:           item['patientName']           ?? '',
        imgUrl:                item['imgUrl']                ?? '',
        mrn:                   item['mrn']                   ?? 0,
        patientStatus:         item['patientStatus']         ?? '',
        careTeam:              List<String>.from(item['careTeam'] ?? []),
        primaryPhysician:      item['primaryPhysician'],
        physicianPhone:        item['physicianPhone'],
        primaryDiagnosis:      item['primaryDiagnosis']      ?? '',
        insurance:             item['insurance']             ?? '',
        specialPrecautions:    item['specialPrecautions']    ?? '',
        rehospitalizationRisk: item['rehospitalizationRisk'] ?? '',
        patientGroupId:        item['patientGroupId'],       // null-safe, no cast
        clinicianGroupId:      item['clinicianGroupId'],
      );
    } else {
      print('getPatientReferralHeader API Error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print("getPatientReferralHeader Error: $e");
    return null;
  }
}

/// Patient data manager
//
// Future<List<PatientReferralHeaderData>> getPatientFaceToFaceDoc({
//   required BuildContext context,
//   required int patientId,
// }) async {
//   try {
//     final response = await Api(context).get(
//       path: PatientPhysicianRepo.getPatientFormToFormDoc(patientId: patientId),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final item = response.data;
//       print("Response:::::: $item");
//
//       return PatientReferralHeaderData(
//         patientId:             item['patientId']             as int,
//         patientName:           item['patientName']           ?? '',
//         imgUrl:                item['imgUrl']                ?? '',
//         mrn:                   item['mrn']                   ?? 0,
//         patientStatus:         item['patientStatus']         ?? '',
//         careTeam:              List<String>.from(item['careTeam'] ?? []),
//         primaryPhysician:      item['primaryPhysician'],
//         physicianPhone:        item['physicianPhone'],
//         primaryDiagnosis:      item['primaryDiagnosis']      ?? '',
//         insurance:             item['insurance']             ?? '',
//         specialPrecautions:    item['specialPrecautions']    ?? '',
//         rehospitalizationRisk: item['rehospitalizationRisk'] ?? '',
//         patientGroupId:        item['patientGroupId'],       // null-safe, no cast
//         clinicianGroupId:      item['clinicianGroupId'],
//       );
//     } else {
//       print('getPatientReferralHeader API Error: ${response.statusCode}');
//       return null;
//     }
//   } catch (e) {
//     print("getPatientReferralHeader Error: $e");
//     return null;
//   }
// }


Future<List<PatientSigDoc>> getPatientSignatureDoc({
  required BuildContext context,
  required int patientId,
}) async {
  List<PatientSigDoc> itemData = [];
  try {
    final response = await Api(context).get(
      path: PatientPhysicianRepo.getSignatureFormDoc(patientId: patientId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data) {
        itemData.add(PatientSigDoc(
            sigDocId: item['sig_doc_id'] ?? 0,
            fkPtId: item['fk_pt_id'] ?? 0,
            sigDocUrl: item['sig_doc_url'] ?? '',
            sigDocName: item['sig_doc_name'] ?? '',
            sigDocContent: item['sig_doc_content'] ?? '',
            sigDocCreatedAt: item['sig_doc_created_at'] ?? '',
            sigDocCreatedBy: item['sig_doc_created_by'] ?? ''
        ));
      }
      return itemData;
    } else {
      return itemData;
    }
  } catch (e) {
    return itemData;
  }
}

