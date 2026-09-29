// lib/data/api_data/my_task_order/my_task_order_manager.dart

import 'package:flutter/material.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';

import 'package:symmetry_emr/modules/emr/data/models/clinical_manager_data/my_tasks_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/clinical_manager_repo/my_tasks_repo.dart';


// Future<MyTaskOrderResponseData> getMyTaskOrder(
//     BuildContext context, {
//       int? patientId,
//       int? chartId,
//       int? episodeId,
//       int? formId,
//       int? visitTypeId,
//       int? schedulerId,
//       String? tab,
//       String? search,
//       int page = 1,
//       int limit = 20,
//     }) async {
//   List<MyTaskOrderData> itemsList = [];
//   try {
//     final response = await Api(context).get(
//       path: MyTaskOrderRepository.getMyTasks(
//         patientId: patientId,
//         chartId: chartId,
//         episodeId: episodeId,
//         formId: formId,
//         visitTypeId: visitTypeId,
//         schedulerId: schedulerId,
//         tab: tab,
//         search: search,
//         page: page,
//         limit: limit,
//       ),
//     );
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       for (var item in response.data['data']) {
//         final p = item['patient'];
//         final c = item['clinician'];
//         final pd = p['primary_diagnosis'];
//
//         itemsList.add(
//           MyTaskOrderData(
//             id:                   item['id'],
//             patientFormId:        item['patient_form_id'],
//             subFormId:            item['subFormId'],
//             subFormName:          item['subFormName'],
//             physicianOrderStatus: item['physician_order_status'],
//             isFilled:             item['is_filled'],
//             data:                 item['data'],
//             createdAt:            item['created_at'],
//             updatedAt:            item['updated_at'],
//             formId:               item['form_id'],
//             formName:             item['formName'],
//             chartId:              item['chart_id'],
//             episodeId:            item['episode_id'],
//             status:               item['status'],
//             statusHistory:        List<dynamic>.from(item['status_history'] ?? []),
//             patient: MyTaskOrderPatientData(
//               ptId:                      p['pt_id'],
//               name:                      p['name'],
//               mrn:                       p['mrn'],
//               chartNo:                   p['chart_no'],
//               primaryInsurance:          p['primary_insurance'],
//               insuranceCategory:         p['insurance_category'],
//               insuranceEligibilityStatus: p['insurance_eligibility_status'],
//               fkPtPrimaryDiagnosis:      p['fk_pt_primary_diagnosis'] ?? 0,
//               primaryDiagnosis: pd == null
//                   ? null
//                   : MyTaskOrderDiagnosisData(
//                 dgnId:   pd['dgn_id'],
//                 dgnName: pd['dgn_name'],
//                 dgnCode: pd['dgn_code'],
//               ),
//             ),
//             clinician: c == null
//                 ? null
//                 : MyTaskOrderClinicianData(
//               staffId:      c['staff_id'],
//               name:         c['name'],
//               imgurl:       c['imgurl'],
//               color:        c['color'],
//               abbreviation: c['abbreviation'],
//             ),
//           ),
//         );
//       }
//     } else {
//       print('Api Error');
//     }
//     print("Response:::::${response}");
//     return MyTaskOrderResponseData(
//       data:  itemsList,
//       total: response.data['total'],
//       page:  response.data['page'],
//       limit: response.data['limit'],
//     );
//   } catch (e) {
//     print("Error $e");
//     return MyTaskOrderResponseData(data: itemsList);
//   }
// }


///manager patient
///

Future<PatientReferralData?> getPatientReferralById(
    BuildContext context,
    int id,
    ) async {
  try {
    final response = await Api(context).get(
      path: PatientReferralRepository.getById(id: id),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;
      final g = d['gender'] ?? {};
      return PatientReferralData(
        ptId:                    d['pt_id'] ?? 0,
        ptFirstName:             d['pt_first_name'] ?? '',
        ptLastName:              d['pt_last_name'] ?? '',
        ptContactNo:             d['pt_contact_no'] ?? '',
        ptZipCode:               d['pt_zip_code'] ?? '',
        ptChartNo:               d['pt_chart_no'] ?? 0,
        ptSummary:               d['pt_summary'] ?? '',
        ptRefferalDate:          d['pt_refferal_date'] ?? '',
        ptDateOfBirth:           d['pt_date_of_birth'] ?? '',
        ptImgUrl:                d['pt_img_url'] ?? '',
        fkSrvId:                 d['fk_srv_id'] ?? 0,
        genderId:                d['genderId'] ?? 0,
        gender: PatientReferralGenderData(
          genderId:   g['gender_id'] ?? 0,
          genderName: g['gender_name'] ?? '',
        ),
        fkPtPrimaryDiagnosis:   d['fk_pt_primary_diagnosis'] ?? 0,
        fkPtSecondaryDiagnosis: List<int>.from(d['fk_pt_secondary_diagnosis'] ?? []),
        fkPtRefferalSource:     d['fk_pt_refferal_source'] ?? 0,
        fkPtPcp:                d['fk_pt_pcp'] ?? 0,
        fkPtMarketer:           d['fk_pt_marketer'] ?? 0,
        fkPtDiscplines:         List<int>.from(d['fk_pt_discplines'] ?? []),
        ptCoverageArea:         d['pt_coverage_area'] ?? 0,
        fkRptiId:               d['fk_rpti_id'] ?? 0,
        fkEmpIdArchived:        d['fk_emp_id_archived'] ?? 0,
        isSelfPay:              d['is_selfPay'] ?? false,
        documentName:           d['document_name'] ?? '',
        isIntake:               d['is_intake'] ?? false,
        intakeTime:             d['intake_time'],
        isArchieved:            d['is_archieved'] ?? false,
        archievedTime:          d['archieved_time'],
        moveToScheduler:        d['moveToScheduler'] ?? false,
        moveToSchedulerDatetime: d['moveToSchedulerDatetime'],
        isNonAdmit:             d['is_non_admit'] ?? false,
        admitDateTime:          d['admitDateTime'],
        createdAt:              d['created_at'] ?? '',
        isPotentialDuplicate:   d['is_potential_duplicate'] ?? false,
        threshold:              d['threshold'] ?? 0,
        ptMRN:                  d['pt_MRN'] ?? 0,
        ptSocDate:              d['pt_SOC_date'],
        ptAddress:              d['pt_address'] ?? '',
        ptMedicalNote:          d['pt_medical_note'] ?? '',
        potentialDischargeDate: d['potential_discharge_date'],
        ptSocStatus:            d['pt_soc_status'] ?? false,
      );
    } else {
      print('Api Error');
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}

///clanical manager
// lib/data/api_data/employee/employee_by_id_manager.dart


Future<EmployeeByIdData?> getEmployeeById(
    BuildContext context,
    int employeeId,
    ) async {
  try {
    final response = await Api(context).get(
      path: EmployeeByIdRepository.getById(employeeId: employeeId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;
      return EmployeeByIdData(
        summary:           d['summary'] ?? '',
        employeeId:        d['employeeId'] ?? 0,
        code:              d['code'] ?? '',
        userId:            d['userId'] ?? 0,
        firstName:         d['firstName'] ?? '',
        lastName:          d['lastName'] ?? '',
        departmentId:      d['departmentId'] ?? 0,
        employeeTypeId:    d['employeeTypeId'] ?? 0,
        expertise:         d['expertise'] ?? '',
        cityId:            d['cityId'] ?? 0,
        countryId:         d['countryId'] ?? 0,
        countyId:          d['countyId'] ?? 0,
        zoneId:            d['zoneId'] ?? 0,
        ssnNbr:            d['SSNNbr'] ?? '',
        primaryPhoneNbr:   d['primaryPhoneNbr'] ?? '',
        secondryPhoneNbr:  d['secondryPhoneNbr'] ?? '',
        workPhoneNbr:      d['workPhoneNbr'] ?? '',
        regOfficId:        d['regOfficId'] ?? '',
        personalEmail:     d['personalEmail'] ?? '',
        workEmail:         d['workEmail'] ?? '',
        address:           d['address'] ?? '',
        dateOfBirth:       d['dateOfBirth'] ?? '',
        emergencyContact:  d['emergencyContact'] ?? '',
        covreage:          d['covreage'] ?? '',
        employment:        d['employment'] ?? '',
        gender:            d['gender'] ?? '',
        status:            d['status'] ?? '',
        service:           d['service'] ?? '',
        imgurl:            d['imgurl'] ?? '',
        resumeurl:         d['resumeurl'] ?? '',
        onboardingStatus:  d['onboardingStatus'] ?? '',
        companyId:         d['companyId'] ?? 0,
        terminationFlag:   d['terminationFlag'] ?? false,
        driverLicenceNbr:  d['driverLicenceNbr'] ?? '',
        approved:          d['approved'] ?? false,
        dateofTermination: d['dateofTermination'],
        dateofResignation: d['dateofResignation'],
        dateofHire:        d['dateofHire'],
        rehirable:         d['rehirable'] ?? '',
        position:          d['position'] ?? '',
        finalAddress:      d['finalAddress'] ?? '',
        type:              d['type'] ?? '',
        reason:            d['reason'] ?? '',
        finalPayCheck:     d['finalPayCheck'] ?? 0,
        checkDate:         d['checkDate'],
        grossPay:          d['grossPay'] ?? 0,
        netPay:            d['netPay'] ?? 0,
        methods:           d['methods'] ?? '',
        materials:         d['materials'] ?? '',
        race:              d['race'] ?? '',
        rating:            d['rating'] ?? '',
        signatureURL:      d['signatureURL'] ?? '',
        active:            d['active'] ?? false,
        roleId:            d['roleId'] ?? 0,
        documentName:      d['documentName'] ?? '',
        documentUrl:       d['documentUrl'] ?? '',
        color:             d['color'] ?? '#C5E1A5',
      );
    } else {
      print('Api Error');
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}