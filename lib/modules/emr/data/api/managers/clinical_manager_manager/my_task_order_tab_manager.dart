import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/clinical_manager_data/my_task_order_tab_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/clinical_manager_repo/my_task_order_tab_repo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Safe int parser — handles String "1", int 1, null → 0 ────────────────────
int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  return int.tryParse(val.toString()) ?? 0;
}

// ✅ safe parse — DateTime.parse throws on malformed input; tryParse +
// fallback keeps a single bad record from blowing up the whole list fetch
String _convertIsoToDayMonthYear(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return '';
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  return dateFormat.format(parsed);
}

Future<PhysicianOrderListResponseData> getMyTasksList(
    BuildContext context, {
      int? patientId,
      int? chartId,
      int? episodeId,
      int? formId,
      int? visitTypeId,
      int? schedulerId,
      String? tab,
      String? formDateFrom,
      String? formDateTo,
      int? clinicianId,
      String? primaryInsurance,
      int? codingStaffId,
      int? qaStaffId,
      String? search,
      int page  = 1,
      int limit = 20,
    }) async {
  PhysicianOrderListResponseData result =
  PhysicianOrderListResponseData(data: []);

  try {
    final buffer = StringBuffer(PhysicianOrderRepository.getMyTasks);
    buffer.write('?page=$page&limit=$limit');
    if (patientId != null)        buffer.write('&patientId=$patientId');
    if (chartId != null)          buffer.write('&chartId=$chartId');
    if (episodeId != null)        buffer.write('&episodeId=$episodeId');
    if (formId != null)           buffer.write('&formId=$formId');
    if (visitTypeId != null)      buffer.write('&visitTypeId=$visitTypeId');
    if (schedulerId != null)      buffer.write('&schedulerId=$schedulerId');
    if (tab != null)              buffer.write('&tab=$tab');
    if (formDateFrom != null)     buffer.write('&formDateFrom=$formDateFrom');
    if (formDateTo != null)       buffer.write('&formDateTo=$formDateTo');
    if (clinicianId != null)      buffer.write('&clinicianId=$clinicianId');
    if (primaryInsurance != null) buffer.write('&primaryInsurance=$primaryInsurance');
    if (codingStaffId != null)    buffer.write('&codingStaffId=$codingStaffId');
    if (qaStaffId != null)        buffer.write('&qaStaffId=$qaStaffId');
    if (search != null)           buffer.write('&search=$search');

    final response = await Api(context).get(path: buffer.toString());

    if (response.statusCode == 200 || response.statusCode == 201) {
      final int total      = _parseInt(response.data['total']);
      final int totalPages = (total / limit).ceil().clamp(1, 999999);

      List<PhysicianOrderData> dataList = [];

      for (var item in (response.data['data'] ?? [])) {
        if (item['taskType'] == 'Order Supply') {
          final sp = item['patient'];
          final sc = item['clinician'];

          dataList.add(
            PhysicianOrderData(
              // ✅ was hardcoded to 0 — response actually returns a linked
              // patient_form_id on several supply orders (e.g. supplyOrderId
              // 71 → patient_form_id 423); that link was silently dropped
              patientFormId: _parseInt(item['patient_form_id']),
              supplyOrderId: _parseInt(item['supplyOrderId']),
              orderId:       item['orderId'],
              formType:      item['taskType'] ?? 'Order Supply',
              formDate:      item['formDate'] != null
                  ? _convertIsoToDayMonthYear(item['formDate'])
                  : '',
              status:               item['status'] ?? '',
              orderStatus:          item['orderStatus'],
              deliveryStatus:       item['deliveryStatus'],
              assignedCmEmployeeId:  item['assignedCmEmployeeId'] != null
                  ? _parseInt(item['assignedCmEmployeeId'])
                  : null,
              assignedDmeEmployeeId: item['assignedDmeEmployeeId'] != null
                  ? _parseInt(item['assignedDmeEmployeeId'])
                  : null,
              timelyFilingDeadline: item['formDate'],
              patient: sp != null
                  ? PhysicianOrderPatientData(
                ptId:                       _parseInt(sp['patientId']),
                name:                       sp['name'] ?? '',
                mrn:                        0,
                chartNo:                    _parseInt(item['chartId']),
                primaryInsurance:           item['primaryInsurance'],
                secondaryInsurance:         item['secondaryInsurance'],
                insuranceCategory:          null,
                insuranceEligibilityStatus: null,
                fkPtPrimaryDiagnosis:       0,
                primaryDiagnosis: sp['diagnosis'] != null
                    ? PhysicianOrderDiagnosisData(
                  dgnId:   0,
                  dgnName: sp['diagnosis'],
                  dgnCode: '',
                )
                    : null,
                // ✅ was reading 'pt_img_url' — supply-order patient object
                // actually returns the photo under 'photo'; every supply
                // order was showing a blank avatar before this fix
                ptImgUrl: sp['photo'],
              )
                  : PhysicianOrderPatientData(
                ptId: 0, name: 'Unknown', mrn: 0, chartNo: 0,
                primaryInsurance: "", secondaryInsurance: "",
                insuranceCategory: "",
                insuranceEligibilityStatus: false, fkPtPrimaryDiagnosis: 0,
                primaryDiagnosis: null,
              ),
              clinician: sc != null
                  ? PhysicianOrderStaffData(
                staffId:      _parseInt(sc['employeeId']),
                name:         sc['name'] ?? '',
                imgurl:       sc['photo'] ?? '',
                color:        sc['colorCode'] ?? '#CCCCCC',
                abbreviation: sc['abbreviation'] ?? '',
              )
                  : PhysicianOrderStaffData(
                staffId: 0, name: 'Unknown', imgurl: '',
                color: '#CCCCCC', abbreviation: 'N/A',
              ),
              statusHistory: const [],
            ),
          );
          continue;
        }

        // ── status_history ────────────────────────────────────────────────
        List<PhysicianOrderStatusHistoryData> historyList = [];
        for (var h in (item['status_history'] ?? [])) {
          final changedBy = h['changed_by'];
          historyList.add(
            PhysicianOrderStatusHistoryData(
              fromStatus: h['from_status'] ?? '',
              toStatus:   h['to_status']   ?? '',
              note:       h['note'],
              changedBy: PhysicianOrderChangedByData(
                employeeId: _parseInt(changedBy?['employee_id']),
                name:       changedBy?['name'] ?? '',
              ),
              changedAt: h['changed_at'] ?? '',
            ),
          );
        }

        // ── patient ───────────────────────────────────────────────────────
        final p = item['patient'];
        PhysicianOrderDiagnosisData? diagnosis;
        if (p != null && p['primary_diagnosis'] != null) {
          final pd = p['primary_diagnosis'];
          diagnosis = PhysicianOrderDiagnosisData(
            dgnId:   _parseInt(pd['dgn_id']),
            dgnName: pd['dgn_name'] ?? '',
            dgnCode: pd['dgn_code'] ?? '',
          );
        }

        // ── clinician (nullable guard) ─────────────────────────────────────
        final c = item['clinician'];
        final PhysicianOrderStaffData clinician = c != null
            ? PhysicianOrderStaffData(
          staffId:              _parseInt(c['staff_id']),
          name:                 c['name']                  ?? '',
          imgurl:               c['imgurl']                ?? '',
          color:                c['color']                 ?? '#CCCCCC',
          abbreviation:         c['abbreviation']          ?? '',
          timelyFilingDeadline: c['timely_filing_deadline'],
        )
            : PhysicianOrderStaffData(
          staffId:              0,
          name:                 'Unknown',
          imgurl:               '',
          color:                '#CCCCCC',
          abbreviation:         'N/A',
          timelyFilingDeadline: null,
        );

        // ── qa (nullable) ─────────────────────────────────────────────────
        PhysicianOrderQaData? qa;
        if (item['qa'] != null) {
          final q = item['qa'];
          qa = PhysicianOrderQaData(
            staffId:              _parseInt(q['staff_id']),
            name:                 q['name']                   ?? '',
            color:                q['color']                  ?? '',
            abbreviation:         q['abbreviation']           ?? '',
            timelyFilingDeadline: q['timely_filing_deadline'],
          );
        }

        // ── coding_staff (nullable) ───────────────────────────────────────
        PhysicianOrderCodingStaffData? codingStaff;
        if (item['coding_staff'] != null) {
          final cs = item['coding_staff'];
          codingStaff = PhysicianOrderCodingStaffData(
            staffId:              _parseInt(cs['staff_id']),
            name:                 cs['name']                  ?? '',
            color:                cs['color']                 ?? '',
            abbreviation:         cs['abbreviation']          ?? '',
            timelyFilingDeadline: cs['timely_filing_deadline'],
          );
        }

        dataList.add(
          PhysicianOrderData(
            patientFormId:         _parseInt(item['patient_form_id']),
            formType:              item['form_type']    ?? item['formName'] ?? '',
            formDate:              _convertIsoToDayMonthYear(item['form_date']),
            status:                item['status']       ?? '',
            faceToFace:            item['face_to_face'] ?? false,
            timelyFilingDeadline:  item['timely_filing_deadline'],
            dateSentForCorrection: item['date_sent_for_correction'],
            patient: p != null
                ? PhysicianOrderPatientData(
              ptId:                       _parseInt(p['pt_id']),
              name:                       p['name']                         ?? '',
              mrn:                        _parseInt(p['mrn']),
              chartNo:                    _parseInt(p['chart_no']),
              // ✅ was reading 'primary_insurance' — API actually returns
              // this field as 'rpti_insurance_provider'; every row was
              // silently showing null before this fix
              primaryInsurance:           p['rpti_insurance_provider'],
              insuranceCategory:          p['insurance_category'],
              insuranceEligibilityStatus: p['insurance_eligibility_status'],
              fkPtPrimaryDiagnosis:       _parseInt(p['fk_pt_primary_diagnosis']),
              primaryDiagnosis:           diagnosis,
              // ✅ was never mapped even though the API returns it
              ptImgUrl:                   p['pt_img_url'],
            )
                : PhysicianOrderPatientData(
              ptId:                       0,
              name:                       'Unknown',
              mrn:                        0,
              chartNo:                    0,
              primaryInsurance:           "",
              insuranceCategory:          "",
              insuranceEligibilityStatus: false,
              fkPtPrimaryDiagnosis:       0,
              primaryDiagnosis:           null,
              ptImgUrl:                   '',
            ),
            clinician:     clinician,
            qa:            qa,
            codingStaff:   codingStaff,
            statusHistory: historyList,
          ),
        );
      }

      result = PhysicianOrderListResponseData(
        data:       dataList,
        total:      total,
        page:       page,
        limit:      limit,
        totalPages: totalPages,
      );
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return result;
  } catch (e) {
    print("Error $e");
    return result;
  }
}

Future<ApiData> bulkApprovePhysicianOrders(
    BuildContext context,
    List<int> ids,
    ) async {
  try {
    var response = await Api(context).patch(
      path: '/patient-form/physician-order/bulk-status',
      data: {
        "ids":    ids,
        "status": "APPROVED",
      },
    );
    print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Bulk approve success");
      return ApiData(
        statusCode: response.statusCode!,
        success:    true,
        message:    response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
        statusCode: response.statusCode!,
        success:    false,
        message:    response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success:    false,
      message:    AppString.somethingWentWrong,
    );
  }
}

Future<ApiData> bulkUpdateSupplyOrderStatus(
    BuildContext context,
    List<int> supplyOrderIds,
    String status,
    ) async {
  try {
    var response = await Api(context).patch(
      path: PhysicianOrderRepository.supplyOrderBulkStatus,
      data: {
        "ids":    supplyOrderIds,
        "status": status,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success:    true,
        message:    response.statusMessage!,
      );
    } else {
      return ApiData(
        statusCode: response.statusCode!,
        success:    false,
        message:    response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success:    false,
      message:    AppString.somethingWentWrong,
    );
  }
}

Future<ApiData> updateSupplyOrderStatus(
    BuildContext context,
    int supplyOrderId,
    String status,
    ) async {
  try {
    var response = await Api(context).patch(
      path: PhysicianOrderRepository.supplyOrderStatus(supplyOrderId),
      data: {
        "status": status,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success:    true,
        message:    response.statusMessage!,
      );
    } else {
      return ApiData(
        statusCode: response.statusCode!,
        success:    false,
        message:    response.data['message'],
      );
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
      statusCode: 404,
      success:    false,
      message:    AppString.somethingWentWrong,
    );
  }
}