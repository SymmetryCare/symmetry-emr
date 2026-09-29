import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/alert_data/alart_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';

Future<List<ClinicianAlertData>?> getAlertsByPatient({
  required BuildContext context,
  required int patientId,
  required String alertType, // 'patient' | 'visit' | 'discipline'
}) async {
  try {
    print("getAlertsByPatient called >> patientId: $patientId | alertType: $alertType");

    final response = await Api(context).get(
      path: ProfileSectonRepo.getAlertByPatient(
        patientId: patientId,
        alertType: alertType,
      ),
    );

    print("getAlertsByPatient statusCode >> ${response.statusCode}");
    print("getAlertsByPatient response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> alertsList = response.data['data'] ?? [];
      print("getAlertsByPatient alerts count >> ${alertsList.length}");

      return alertsList.map((alert) {
        final List<dynamic> rawClinicians = alert['clinicians'] ?? [];

        return ClinicianAlertData(
          alertId:        alert['alert_id']      ?? 0,
          alertHeading:   alert['alert_heading'] ?? '',
          alertBody:      alert['alert_body']    ?? '',
          alertType:      alert['alert_type']    ?? '',
          alertResolve:   alert['alert_resolve'] ?? false,
          createdAt:      alert['created_at']    ?? '',
          clinicians: rawClinicians.map((c) => AlertClinician(
            employeeId:   c['employeeId']   ?? 0,
            fullName:     c['fullName']     ?? '',
            imgUrl:       c['imgurl']       ?? '',
            abbreviation: c['abbreviation'] ?? '',
            color:        c['color']        ?? '',
          )).toList(),
          // visit extras
          visiteDateTimeFrom: alert['visiteDateTimeFrom'],
          visitDateTimeTo:    alert['visitDateTimeTo'],
          // discipline extras
          discipline:             alert['discipline'],
          disciplineAbbreviation: alert['disciplineAbbreviation'],
        );
      }).toList();
    } else {
      print("getAlertsByPatient error statusCode >> ${response.statusCode}");
      debugPrint("Alert by patient error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getAlertsByPatient catch error >> $e");
    debugPrint("getAlertsByPatient error: $e");
    return null;
  }
}





///patch  api
///
Future<ApiData> patchAlert({
  required BuildContext context,
  required int alertId,
  required int userId,
  required List<int> clinicianId,
  required String alertHeading,
  required String alertBody,
  required bool alertResolve,
  required String alertType,
  required int fkPtId,
}) async {
  try {
    final data = {
      'user_id':       userId,
      'clinician_id':  clinicianId,
      'alert_heading': alertHeading,
      'alert_body':    alertBody,
      'alert_resolve': alertResolve,
      'alert_type':    alertType,
      'fk_pt_id':      fkPtId,
    };

    print("Data payload being sent to API: $data");

    final response = await Api(context).patch(
      path: ProfileSectonRepo.updateAlert(alertId: alertId),
      data: data,
    );

    print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Alert updated successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success:    true,
        message:    response.statusMessage!,
      );
    } else {
      print("Failed to update Alert: ${response.statusCode}");
      print("Error details: ${response.data}");
      return ApiData(
        statusCode: response.statusCode!,
        success:    false,
        message:    response.statusMessage!,
      );
    }
  } catch (e) {
    print("Error: $e");
    return ApiData(statusCode: 500, success: false, message: "Server error");
  }
}




///delete api
///
Future<ApiData> deleteAlert({
  required BuildContext context,
  required int alertId,
}) async {
  try {
    print("deleteAlert called >> alertId: $alertId");

    final response = await Api(context).delete(
      path: ProfileSectonRepo.deleteAlert(alertId: alertId),
    );

    print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Alert deleted successfully >> ${response.data['message']}");
      return ApiData(
        statusCode: response.statusCode!,
        success:    true,
        message:    response.data['message'] ?? response.statusMessage!,
      );
    } else {
      print("Failed to delete Alert: ${response.statusCode}");
      print("Error details: ${response.data}");
      return ApiData(
        statusCode: response.statusCode!,
        success:    false,
        message:    response.statusMessage!,
      );
    }
  } catch (e) {
    print("Error: $e");
    return ApiData(statusCode: 500, success: false, message: "Server error");
  }
}