import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/my_task/patient_form_myTask_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/qa_coordinator/dashboard_repo.dart';

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  return int.tryParse(val.toString()) ?? 0;
}

Future<PatientFormMyTaskResponse> getPatientFormMyTaskList({
  required BuildContext context,
  required String searchByText,
  required String tab,
  required int page,
  required int limit,
  int? patientId,
  int? chartId,
  int? episodeId,
  String? formId,
  int? visitTypeId,
  int? schedulerId,
  String? formDateFrom,
  String? formDateTo,
  int? clinicianId,
  String? primaryInsurance,
  int? codingStaffId,
  int? qaStaffId,
}) async {
  PatientFormMyTaskResponse? itemsData;

  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  try {
    final Map<String, dynamic> queryParameters = {
      'search': searchByText,
      'tab':    tab,
      'page':   page,
      'limit':  limit,
    };

    if (patientId != null)                                       queryParameters['patientId']        = patientId;
    if (chartId != null)                                         queryParameters['chartId']          = chartId;
    if (episodeId != null)                                       queryParameters['episodeId']        = episodeId;
    if (formId != null)                                          queryParameters['formId']           = formId;
    if (visitTypeId != null)                                     queryParameters['visitTypeId']      = visitTypeId;
    if (schedulerId != null)                                     queryParameters['schedulerId']      = schedulerId;
    if (formDateFrom != null && formDateFrom.isNotEmpty)         queryParameters['formDateFrom']     = formDateFrom;
    if (formDateTo != null && formDateTo.isNotEmpty)             queryParameters['formDateTo']       = formDateTo;
    if (clinicianId != null)                                     queryParameters['clinicianId']      = clinicianId;
    // ✅ this is the FILTER param sent to the API (primaryInsurance), separate from the
    // patient's own insurance value (rpti_insurance_provider) returned in each row below
    if (primaryInsurance != null && primaryInsurance.isNotEmpty) queryParameters['primaryInsurance'] = primaryInsurance;
    if (codingStaffId != null)                                   queryParameters['codingStaffId']    = codingStaffId;
    if (qaStaffId != null)                                       queryParameters['qaStaffId']        = qaStaffId;

    final response = await Api(context).getWithQueryParam(
      path:            QaDashboardRepo.patientFormMytask,
      queryParameters: queryParameters,
    );

    print("Response:::::: $response");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<PatientFormTask> listData = [];
      final List<dynamic> dataList = response.data['data'] ?? [];

      for (var item in dataList) {
        final patientMap        = item['patient']       as Map<String, dynamic>?;
        final clinicianMap      = item['clinician']     as Map<String, dynamic>?;
        final qaMap             = item['qa']            as Map<String, dynamic>?;
        final codingStaffMap    = item['coding_staff']  as Map<String, dynamic>?;
        final statusHistoryList = (item['status_history'] as List<dynamic>?) ?? [];

        // ── Primary Diagnosis ──────────────────────────────────────────────
        final diagnosisMap = patientMap?['primary_diagnosis'] as Map<String, dynamic>?;
        final PrimaryDiagnosis? primaryDiagnosis = diagnosisMap == null
            ? null
            : PrimaryDiagnosis(
          dgnId:   _parseInt(diagnosisMap['dgn_id']),
          dgnName: diagnosisMap['dgn_name'] ?? '',
          dgnCode: diagnosisMap['dgn_code'] ?? '',
        );

        listData.add(PatientFormTask(
          // ✅ patient_form_id absent on supply-order rows — defaults to 0 safely
          patientFormId: _parseInt(item['patient_form_id']),
          supplyOrderId: item['supplyOrderId'] != null ? _parseInt(item['supplyOrderId']) : null,
          orderId:       item['orderId'] as String?,
          taskType:      item['taskType'] as String?,

          // ── Patient ───────────────────────────────────────────────────────
          // ✅ defensive lookup: manager/assignments uses pt_id/mrn/chart_no,
          // my-tasks (supply-order) uses patientId with no mrn/chartNo/diagnosis object
          patient: patientMap == null
              ? Patient(ptId: 0, name: '', mrn: 0, chartNo: 0, ptImgUrl: '')
              : Patient(
            ptId:    _parseInt(patientMap['pt_id'] ?? patientMap['patientId']),
            name:    patientMap['name'] ?? '',
            mrn:     _parseInt(patientMap['mrn']),
            chartNo: _parseInt(patientMap['chart_no']),
            primaryInsurance:           patientMap['rpti_insurance_provider'] ?? '--',
            insuranceCategory:          patientMap['insurance_category'] ?? '--',
            insuranceEligibilityStatus: patientMap['insurance_eligibility_status'] as bool?,
            fkPtPrimaryDiagnosis:       _parseInt(patientMap['fk_pt_primary_diagnosis']),
            primaryDiagnosis:           primaryDiagnosis,
            ptImgUrl: (patientMap['pt_img_url'] ?? patientMap['photo'] ?? '').toString(),
            diagnosis: patientMap['diagnosis'] as String?,
          ),

          formType: item['form_type'] ?? '',
          formDate: (item['form_date'] ?? item['formDate']) != null
              ? convertIsoToDayMonthYear(item['form_date'] ?? item['formDate'])
              : '',
          status:               item['status'] ?? '',
          faceToFace:           item['face_to_face'] ?? false,
          timelyFilingDeadline: item['timely_filing_deadline'] != null
              ? convertIsoToDayMonthYear(item['timely_filing_deadline'])
              : null,
          dateSentForCorrection: item['date_sent_for_correction'] != null
              ? convertIsoToDayMonthYear(item['date_sent_for_correction'])
              : null,

          // ── Clinician ─────────────────────────────────────────────────────
          // ✅ THE FIX: check both key styles.
          // manager/assignments → staff_id / imgurl / color
          // my-tasks (supply-order) → employeeId / photo / colorCode
          // '#' stripped either way so Color(int.parse('0xFF$colorCode')) always works
          clinician: clinicianMap == null
              ? Clinician(staffId: 0, name: '', imgUrl: '', abbreviation: '', colorCode: '')
              : Clinician(
            staffId: _parseInt(clinicianMap['staff_id'] ?? clinicianMap['employeeId']),
            name:    clinicianMap['name'] ?? '',
            imgUrl:  (clinicianMap['imgurl'] ?? clinicianMap['photo'] ?? '').toString(),
            colorCode: (clinicianMap['color'] ?? clinicianMap['colorCode'] ?? '')
                .toString()
                .replaceAll('#', ''),
            abbreviation: clinicianMap['abbreviation'] ?? '',
            employeeType: clinicianMap['employeeType'] as String?,
            timelyFilingDeadline: clinicianMap['timely_filing_deadline'] != null
                ? convertIsoToDayMonthYear(clinicianMap['timely_filing_deadline'])
                : null,
          ),

          // ── QA ────────────────────────────────────────────────────────────
          qa: qaMap == null
              ? QA(staffId: 0, name: '')
              : QA(
            staffId:      _parseInt(qaMap['staff_id']),
            name:         qaMap['name'] ?? '',
            color:        (qaMap['color'] ?? '').toString().replaceAll('#', ''),
            abbreviation: qaMap['abbreviation'] ?? '',
            timelyFilingDeadline: qaMap['timely_filing_deadline'] != null
                ? convertIsoToDayMonthYear(qaMap['timely_filing_deadline'])
                : null,
          ),

          // ── Coding Staff (nullable — only present once assigned) ──────────
          codingStaff: codingStaffMap == null
              ? null
              : CodingStaff(
            staffId:      _parseInt(codingStaffMap['staff_id']),
            name:         codingStaffMap['name'] ?? '',
            color:        (codingStaffMap['color'] ?? '').toString().replaceAll('#', ''),
            abbreviation: codingStaffMap['abbreviation'] ?? '',
            timelyFilingDeadline: codingStaffMap['timely_filing_deadline'] != null
                ? convertIsoToDayMonthYear(codingStaffMap['timely_filing_deadline'])
                : null,
          ),

          // ── Status History ────────────────────────────────────────────────
          statusHistory: statusHistoryList.map((e) {
            final historyMap   = e as Map<String, dynamic>?;
            final changedByMap = historyMap?['changed_by'] as Map<String, dynamic>?;
            return StatusHistory(
              fromStatus: historyMap?['from_status'] ?? '',
              toStatus:   historyMap?['to_status']   ?? '',
              note:       historyMap?['note'] as String?,
              changedAt:  historyMap?['changed_at']  ?? '',
              changedBy: changedByMap == null
                  ? ChangedBy(employeeId: 0, name: '')
                  : ChangedBy(
                employeeId: _parseInt(changedByMap['employee_id']),
                name:       changedByMap['name'] ?? '',
              ),
            );
          }).toList(),
        ));
      }

      itemsData = PatientFormMyTaskResponse(
        data:  listData,
        total: _parseInt(response.data['total']),
        page:  _parseInt(response.data['page']),
        limit: _parseInt(response.data['limit']),
      );
    } else {
      print("patient form my task error: ${response.statusCode}");
    }

    return itemsData ?? PatientFormMyTaskResponse(data: [], total: 0, page: 0, limit: 0);
  } catch (e) {
    print("Error $e");
    return PatientFormMyTaskResponse(data: [], total: 0, page: 0, limit: 0);
  }
}