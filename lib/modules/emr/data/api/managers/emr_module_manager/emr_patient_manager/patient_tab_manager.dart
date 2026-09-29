import 'package:flutter/material.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_form_emr_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_tab_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/emr_patient_repo/patient_physician_repo.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/refferals/patient_refferal_repo.dart';

Future<List<AssignedPatientData>?> getAssignedPatients({
  required BuildContext context,
  String search = 'all',
  String statusFilter = 'all',
}) async {
  try {
    print("getAssignedPatients called >> search: $search | statusFilter: $statusFilter");

    final response = await Api(context).get(
      path: ProfileSectonRepo.getAssignedPatients(
        search: search,
        statusFilter: statusFilter,
      ),
    );

    print("getAssignedPatients statusCode >> ${response.statusCode}");
    print("getAssignedPatients response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> patientsList = response.data ?? [];

      print("getAssignedPatients patients count >> ${patientsList.length}");

      return patientsList.map((patient) {
        // ── nested: currentEpisode ──
        final episodeMap = patient['currentEpisode'];
        final episode = episodeMap != null
            ? AssignedPatientEpisodeData(
          chartId:     episodeMap['chartId'],
          episodeId:   episodeMap['episodeId'],
          episodeFrom: episodeMap['episodeFrom'] ?? '',
          episodeTo:   episodeMap['episodeTo'] ?? '',
        )
            : null;

        // ── nested: physician ──
        final physicianMap = patient['physician'];
        final physician = physicianMap != null
            ? AssignedPatientPhysicianData(
          name:    physicianMap['name'] ?? '--',
          contact: physicianMap['contact'] ?? '',
        )
            : null;

        // ── nested: authStatus ──
        final authMap = patient['authStatus'];
        final authStatus = authMap != null
            ? AssignedPatientAuthStatusData(
          isAuthorized:  authMap['isAuthorized'] ?? false,
          lastChecked:   authMap['lastChecked'] ?? '',
          authRemaining: authMap['authRemaining'] ?? '',
        )
            : null;

        return AssignedPatientData(
          patientId:        patient['patientId'] ?? 0,
          patientName:      patient['patientName'] ?? '',
          dob:              patient['dob'] ?? '',
          imgUrl:           patient['imgUrl'] ?? '',
          mrn:              patient['mrn'] ?? 0,
          patientStatus:    patient['patientStatus'] ?? '',
          primaryDiagnosis: patient['primaryDiagnosis'] ?? '',
          insurance:        patient['insurance'] ?? '',
          kaiserNo:         patient['kaiserNo'] ?? '',
          // treatmentPause:   patient["treatment_pause"] ?? false,
          currentEpisode:   episode,
          physician:        physician,
          authStatus:       authStatus,
        );
      }).toList();
    } else {
      print("getAssignedPatients error statusCode >> ${response.statusCode}");
      debugPrint("Assigned patients error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getAssignedPatients catch error >> $e");
    debugPrint("getAssignedPatients error: $e");
    return null;
  }
}

Future<PatientFormEmrData?> getPatientFormEMR({
  required BuildContext context,
  required int patientId,
  required int chartId,
  required int episodeId,
  required String formCategory,
  required int page,
  required int limit,
}) async {
  try {
    final response = await Api(context).getWithQueryParam(
      path: PatientPhysicianRepo.patientFormEMR,
      queryParameters: {
        'patientId':    patientId,
        'chartId':      chartId,
        'episodeId':    episodeId,
        'formCategory': formCategory,
        'page':         page,
        'limit':        limit,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> responseData = response.data ?? {};

      print("getOasisPlanOfCare data >> $responseData");

      final List<dynamic> dataList = responseData['data'] ?? [];

      final List<FormEMRData> parsedDataList = dataList.map((item) {

        // ── assigned_to ──
        final assignedToList = item['assigned_to'];
        final List<AssignedTo> assignedTo = assignedToList != null
            ? (assignedToList as List<dynamic>).map((a) => AssignedTo(
          assignmentId:         a['assignment_id'] ?? 0,
          staffId:              a['staff_id'] ?? 0,
          name:                 a['name'] ?? '',
          imgUrl:               a['imgurl'] ?? '',
          role:                 a['role'] ?? '',
          color:                a['color'] ?? '',
          abbreviation:         a['abbreviation'] ?? '',
          assignedAt:           a['assigned_at'] ?? '',
          timelyFilingDeadline: a['timely_filing_deadline'],
        )).toList()
            : [];

        // ── status_history ──
        final statusHistoryList = item['status_history'];
        final List<StatusHistory> statusHistory = statusHistoryList != null
            ? (statusHistoryList as List<dynamic>).map((h) {
          final changedByMap = h['changed_by'];
          final changedBy = changedByMap != null
              ? ChangedBy(
            employeeId: changedByMap['employee_id'] ?? 0,
            name:       changedByMap['name'] ?? '',
          )
              : ChangedBy(employeeId: 0, name: '');

          return StatusHistory(
            fromStatus: h['from_status'] ?? '',
            toStatus:   h['to_status'] ?? '',
            note:       h['note'],
            changedBy:  changedBy,
            changedAt:  h['changed_at'] ?? '',
          );
        }).toList()
            : [];

        return FormEMRData(
          patientFormId: item['patient_form_id'] ?? 0,
          formId:        item['form_id'] ?? 0,
          formName:      item['formName'] ?? '',
          patientId:     item['patient_id'] ?? 0,
          chartId:       item['chart_id'] ?? 0,
          episodeId:     item['episode_id'] ?? 0,
          schedulerId:   item['scheduler_id'] ?? 0,
          status:        item['status'] ?? '',
          createdAt:     item['created_at'] ?? '',
          updatedAt:     item['updated_at'] ?? '',
          visitDetails:  item['visitDetails'],
          assignedTo:    assignedTo,
          statusHistory: statusHistory,
        );
      }).toList();

      return PatientFormEmrData(
        category: responseData['category'] ?? '',
        data:     parsedDataList,
        total:    responseData['total'] ?? 0,
        page:     responseData['page'] ?? 0,
        limit:    responseData['limit'] ?? 0,
      );
    } else {
      print("getOasisPlanOfCare error statusCode >> ${response.statusCode}");
      debugPrint("getOasisPlanOfCare error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getOasisPlanOfCare catch error >> $e");
    debugPrint("getOasisPlanOfCare error: $e");
    return null;
  }
}

///patch /patient-referral/{id}
Future<ApiData> patchTreatmentPause({
  required BuildContext context,
  required int id,
  required bool treatmentPause,

}) async {
  try {
    var response = await Api(context).patch(
      path: PatientRefferalsRepo.updateSchedularWithId(id: id),
      data: {
        "treatment_pause": treatmentPause,
      },
    );

    print('treatment pause: $response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'][0],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}