import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/pending_assistant_form.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';

Future<PatientvisitListEmrModel> getEmrPatientVisitList({
  required BuildContext context,
  required String searchFilter,
}) async {
  PatientvisitListEmrModel? itemsData;
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.patientVisitWithFilter(filter: searchFilter));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<EmrPatientVisitModel> listData = [];

      final List<dynamic> dataList = response.data['visits'] ?? [];

      for (var item in dataList) {
        listData.add(EmrPatientVisitModel(
          visitId: item['visitId'] ?? 0,
          patientId: item['patientId'] ?? 0,
          patientName: item['patientName'] ?? '',
          patientImgUrl: item['patientImgUrl'] ?? '',
          primaryDiagnosis: item['primaryDiagnosis'] ?? '',
          visitTypeName: item['visitTypeName'] ?? '',
          isAuthorized: item['isAuthorized'] ?? false,
          visiteDateTimeFrom: item['visiteDateTimeFrom'] ?? '',
          visitDateTimeTo: item['visitDateTimeTo'] ?? '',
          isVisitCompleted: item['isVisitCompleted'] ?? false,
          isVisitMissed: item['isVisitMissed'] ?? false,
          onWay: item['onWay'] ?? false,
          isRescheduled: item['isRescheduled'] ?? false,
          rescheduledAt: item['rescheduledAt'],
          visitCharge: (item['visit_charge'] ?? 0.0).toDouble(),
          treatmentPause: item['visitStatus'] ?? '',
          alerts: VisitAlerts(
            patientAlert: item['alerts']['patientAlert'] ?? false,
            visitAlert: item['alerts']['visitAlert'] ?? false,
            disciplineAlert: item['alerts']['disciplineAlert'] ?? false,
          ),
        ));
      }

      itemsData = PatientvisitListEmrModel(visits: listData);
    } else {
      debugPrint("patient visit list error: ${response.statusCode}");
    }

    return itemsData ?? PatientvisitListEmrModel(visits: []);
  } catch (e) {
    debugPrint("get patient visit error: $e");
    return PatientvisitListEmrModel(visits: []);
  }
}


/// Approve and Reject API

Future<ApiData> approveRejectVisit({
  required BuildContext context,
  required int visitId,
  required String rejectedReason,
  required bool isVisitAccepted,
}) async {
  try {
    var response = await Api(context).post(
      path: EMRDashboardRepo.rejectApproveVisit,
      data:{
        "visitId": visitId,
        "rejectedReason": rejectedReason,
        "isVisitAccepted": isVisitAccepted
      }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error Reject approve visit");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);}
}

/// Bulk Approve visits

Future<ApiData> bulkApproveVisits({
  required BuildContext context,
  required List<int> visitIds,
}) async {
  try {
    var response = await Api(context).post(
        path: EMRDashboardRepo.bulkApproveVisit,
        data:{
          "visitIds": visitIds
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error bulk approve visit");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);}
}

/// Start visit

Future<ApiData> patchStartVisit({
  required BuildContext context,
  required int visitId,
  required bool onWay,
  String? visitTypeData,
  bool? isLastVisit,
}) async {
  try {
    var response = await Api(context).patch(
        path: EMRDashboardRepo.patientVisitById(visitId: visitId,),
        data: isLastVisit == true ? {
          "onWay": onWay,
          "episodeEndType": visitTypeData
        }:{
          "onWay": onWay,
        }
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("patch start visit response: ${response.data}");
      var data = response.data;
      int ptId = data['pt_id'] ?? 0;
      int ptFormId = data['patient_form_id'] ?? 0;
      bool isVisitTypeSection = data['episodeStatus']['requiresVisitTypeSelection'] ?? false;
      bool isEpisodeEndDecision = data['isSecondLastEpisodeVisit'] ??false;
      String lastVisitAssistant = data['lastVisitPerformedBy'] ?? '';
      List<int> pendingFormsIds = List<int>.from(data['pendingAssistantFormIds'] ?? []);
      print("isSecondLastEpisodeVisit: $isEpisodeEndDecision");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
        ptFormId: ptFormId,
        ptId: ptId,
        visitTypeSelection: isVisitTypeSection,
        episodeEndDecision: isEpisodeEndDecision,
        pendingFormsIds: pendingFormsIds,
        lastVisitPerformedBy: lastVisitAssistant,
      );
    } else {
      print("Error Start visit");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);}
}


Future<VisitPrefillByIdModel> getVisitDataUsingVisitId({
  required BuildContext context,
  required int visitId,
}) async {
  VisitPrefillByIdModel? itemsData;
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.patientVisitById(visitId: visitId));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = response.data;

      final patientData = data['patient'];
      final employeeTypeData = data['employeeType'];
      final employeeData = data['employee'];

      itemsData = VisitPrefillByIdModel(
        remainingVisitsCount: data['remainingVisitsCount'] ?? 0,
        episodeTriggerType: data['episodeTriggerType'] ?? '',
        daysToEpisodeEnd: data['daysToEpisodeEnd'] ?? 0,
        lastVisitPerformedBy: data['lastVisitPerformedBy'] ?? '',
        pendingAssistantFormIds: List<int>.from(data['pendingAssistantFormIds'] ?? []),
        lastVisitIds: List<int>.from(data['lastVisitIds'] ?? []),
        isAttemptedVisit: data['isAttemptedVisit'] ?? false,
        isSecoundLastEpisodeVisit: data['isSecondLastEpisodeVisit'] ?? false,
        visitId: data['visitId'] ?? 0,
        ptId: data['pt_id'] ?? 0,
        employeeTypeId: data['employeeTypeId'] ?? 0,
        employeeId: data['employeeId'] ?? 0,
        visitType: data['visitType'] ?? 0,
        visiteDateTimeFrom: data['visiteDateTimeFrom'] ?? '',
        visitDateTimeTo: data['visitDateTimeTo'] ?? '',
        isVisitCompleted: data['isVisitCompleted'] ?? false,
        isVisitMissed: data['isVisitMissed'] ?? false,
        onWay: data['onWay'] ?? false,
        recordTypeId: data['recordTypeId'] ?? 0,
        inZone: data['inZone'] ?? false,
        isRescheduled: data['isRescheduled'] ?? false,
        rescheduledAt: data['rescheduledAt'] ?? '',
        rescheduleReasonId: data['rescheduleReasonId'] ?? 0,
        visitPhotoUrl: data['visitPhotoUrl'] ?? '',
        employee: employeeData != null
            ? EmployeeModel(
          employeeId: employeeData['employeeId'] ?? 0,
          code: employeeData['code'] ?? '',
          firstName: employeeData['firstName'] ?? '',
          lastName: employeeData['lastName'] ?? '',
          expertise: employeeData['expertise'] ?? '',
          gender: employeeData['gender'] ?? '',
          imgurl: employeeData['imgurl'] ?? '',
          regOfficId: employeeData['regOfficId'] ?? '',
          onboardingStatus: employeeData['onboardingStatus'] ?? '',
          userId: employeeData['userId'] ?? 0,
          ssnNbr: employeeData['SSNNbr'] ?? '',
          address: employeeData['address'] ?? '',
          cityId: employeeData['cityId'] ?? 0,
          dateOfBirth: employeeData['dateOfBirth'] ?? '',
          departmentId: employeeData['departmentId'] ?? 0,
          emergencyContact: employeeData['emergencyContact'] ?? '',
          employeeTypeId: employeeData['employeeTypeId'] ?? 0,
          employment: employeeData['employment'] ?? '',
          personalEmail: employeeData['personalEmail'] ?? '',
          primaryPhoneNbr: employeeData['primaryPhoneNbr'] ?? '',
          secondryPhoneNbr: employeeData['secondryPhoneNbr'] ?? '',
          service: employeeData['service'] ?? '',
          status: employeeData['status'] ?? '',
          workEmail: employeeData['workEmail'] ?? '',
          workPhoneNbr: employeeData['workPhoneNbr'] ?? '',
          companyId: employeeData['companyId'] ?? 0,
          createdAt: employeeData['createdAt'] ?? '',
          resumeurl: employeeData['resumeurl'] ?? '',
          covreage: employeeData['covreage'] ?? '',
          approved: employeeData['approved'],
          terminationFlag: employeeData['terminationFlag'],
          zoneId: employeeData['zoneId'] ?? 0,
          countryId: employeeData['countryId'] ?? 0,
          checkDate: employeeData['checkDate'] ?? '',
          dateofResignation: employeeData['dateofResignation'] ?? '',
          dateofTermination: employeeData['dateofTermination'] ?? '',
          finalAddress: employeeData['finalAddress'] ?? '',
          finalPayCheck: (employeeData['finalPayCheck'] ?? 0).toDouble(),
          grossPay: (employeeData['grossPay'] ?? 0).toDouble(),
          materials: employeeData['materials'] ?? '',
          methods: employeeData['methods'] ?? '',
          netPay: (employeeData['netPay'] ?? 0).toDouble(),
          reason: employeeData['reason'] ?? '',
          rehirable: employeeData['rehirable'] ?? '',
          type: employeeData['type'] ?? '',
          dateofHire: employeeData['dateofHire'] ?? '',
          position: employeeData['position'] ?? '',
          driverLicenceNbr: employeeData['driverLicenceNbr'] ?? '',
          race: employeeData['race'] ?? '',
          rating: employeeData['rating'] ?? '',
          signatureURL: employeeData['signatureURL'] ?? '',
          countyId: employeeData['countyId'] ?? 0,
          active: employeeData['active'] ?? false,
          summary: employeeData['summary'] ?? '',
          documentName: employeeData['documentName'],
          documentUrl: employeeData['documentUrl'],
        )
            : null,
        typeOfVisitId: data['typeOfVisitId'] ?? 0,
        typeOfVisitName: data['typeOfVisitName'] ?? '',
        employeeType:employeeTypeData != null ? EmployeePatientTypeModel(
          employeeTypeId: employeeTypeData['employeeTypeId'] ?? 0,
          employeeType: employeeTypeData['employeeType'] ?? '',
          color: employeeTypeData['color'] ?? '',
          abbreviation: employeeTypeData['abbreviation'] ?? '',
          departmentId: employeeTypeData['DepartmentId'] ?? 0,
          roleId: employeeTypeData['roleId'] ?? 0,
          masterEmpTypeId: employeeTypeData['masterEmpTypeId'] ?? 0,
          childEmpTypeId: List<int>.from(employeeTypeData['childEmpTypeId'] ?? []),
          templateIdSalaried: employeeTypeData['templateId_salaried'] ?? 0,
          templateIdParttime: employeeTypeData['templateId_parttime'] ?? 0,
          templateIdPerdiem: employeeTypeData['templateId_perdiem'] ?? 0,
        ) : EmployeePatientTypeModel(
          employeeTypeId: 0,
          employeeType: '',
          color: '',
          abbreviation: '',
          departmentId: 0,
          roleId: 0,
          masterEmpTypeId: 0,
          childEmpTypeId: [],
          templateIdSalaried: 0,
          templateIdParttime: 0,
          templateIdPerdiem: 0,
        ),
        patient: PatientPrefillModel(
          ptId: patientData['pt_id'] ?? 0,
          ptFirstName: patientData['pt_first_name'] ?? '',
          ptLastName: patientData['pt_last_name'] ?? '',
          ptContactNo: patientData['pt_contact_no'] ?? '',
          ptZipCode: patientData['pt_zip_code'] ?? '',
          ptChartNo: patientData['pt_chart_no'] ?? 0,
          ptSummary: patientData['pt_summary'] ?? '',
          ptRefferalDate: patientData['pt_refferal_date'] ?? '',
          fkSrvId: patientData['fk_srv_id'] ?? 0,
          fkPtPrimaryDiagnosis: patientData['fk_pt_primary_diagnosis'] ?? 0,
          fkPtSecondaryDiagnosis: List<dynamic>.from(patientData['fk_pt_secondary_diagnosis'] ?? []),
          fkPtRefferalSource: patientData['fk_pt_refferal_source'] ?? 0,
          fkPtPcp: patientData['fk_pt_pcp'] ?? 0,
          fkPtMarketer: patientData['fk_pt_marketer'] ?? 0,
          fkPtDiscplines: List<int>.from(patientData['fk_pt_discplines'] ?? []),
          ptCoverageArea: patientData['pt_coverage_area'] ?? 0,
          isIntake: patientData['is_intake'] ?? false,
          intakeTime: patientData['intake_time'] ?? '',
          isArchieved: patientData['is_archieved'] ?? false,
          archievedTime: patientData['archieved_time'] ?? '',
          createdAt: patientData['created_at'] ?? '',
          ptDateOfBirth: patientData['pt_date_of_birth'] ?? '',
          ptImgUrl: patientData['pt_img_url'] ?? '',
          fkEmpIdArchived: patientData['fk_emp_id_archived'],
          fkRptiId: patientData['fk_rpti_id'] ?? 0,
          isSelfPay: patientData['is_selfPay'] ?? false,
          documentName: patientData['document_name'] ?? '',
          moveToScheduler: patientData['moveToScheduler'] ?? false,
          moveToSchedulerDatetime: patientData['moveToSchedulerDatetime'] ?? '',
          admitDateTime: patientData['admitDateTime'],
          isNonAdmit: patientData['is_non_admit'] ?? false,
          ptMRN: patientData['pt_MRN'] ?? 0,
          ptSOCDate: patientData['pt_SOC_date'] ?? '',
          ptSOCStatus: patientData['pt_SOC_status'] ?? false,
          potentialDischargeDate: patientData['potential_discharge_date'] ?? '',
          ptAddress: patientData['pt_address'] ?? '',
          ptMedicalNote: patientData['pt_medical_note'] ?? '',
          isDemographicFilled: patientData['is_demographic_filled'] ?? false,
          isDocumentationUpload: patientData['is_documentation_upload'] ?? false,
          isInitialContactFilled: patientData['is_initialContact_filled'] ?? false,
          isOrdersFilled: patientData['is_orders_filled'] ?? false,
          isPhysicianFilled: patientData['is_physician_filled'] ?? false,
          isPrimaryInsuranceFilled: patientData['is_primaryInsurance_filled'] ?? false,
          companyId: patientData['companyId'] ?? 0,
          genderId: patientData['genderId'] ?? 0,
          potentialDuplicate: patientData['potential_duplicate'] ?? false,
          fkPatientStatusId: patientData['fk_patientStatusId'] ?? 0,
          specialPrecautions: patientData['specialPrecautions'] ?? '',
          rehospitalizationRisk: patientData['rehospitalizationRisk'] ?? '',
        ),
      );
    } else {
      debugPrint("visit data error: ${response.statusCode}");
    }

    return itemsData ?? VisitPrefillByIdModel(
      remainingVisitsCount: 0,
      episodeTriggerType: '',
      daysToEpisodeEnd: 0,
      lastVisitIds: [],
      lastVisitPerformedBy: "",
      pendingAssistantFormIds: [],
      isSecoundLastEpisodeVisit: false,
      isAttemptedVisit: false,
      visitId: 0,
      ptId: 0,
      employeeTypeId: 0,
      employeeId: null,
      visitType: 0,
      visiteDateTimeFrom: '',
      visitDateTimeTo: '',
      isVisitCompleted: false,
      isVisitMissed: false,
      onWay: false,
      recordTypeId: null,
      inZone: false,
      isRescheduled: false,
      rescheduledAt: null,
      rescheduleReasonId: null,
      visitPhotoUrl: null,
      employee: null,
      typeOfVisitId: 0,
      typeOfVisitName: '',
      employeeType: EmployeePatientTypeModel(
        employeeTypeId: 0,
        employeeType: '',
        color: '',
        abbreviation: '',
        departmentId: 0,
        roleId: 0,
        masterEmpTypeId: 0,
        childEmpTypeId: [],
        templateIdSalaried: 0,
        templateIdParttime: 0,
        templateIdPerdiem: 0,
      ),
      patient: PatientPrefillModel(
        ptId: 0,
        ptFirstName: '',
        ptLastName: '',
        ptContactNo: '',
        ptZipCode: '',
        ptChartNo: 0,
        ptSummary: '',
        ptRefferalDate: '',
        fkSrvId: 0,
        fkPtPrimaryDiagnosis: 0,
        fkPtSecondaryDiagnosis: [],
        fkPtRefferalSource: 0,
        fkPtPcp: 0,
        fkPtMarketer: 0,
        fkPtDiscplines: [],
        ptCoverageArea: 0,
        isIntake: false,
        intakeTime: '',
        isArchieved: false,
        archievedTime: null,
        createdAt: '',
        ptDateOfBirth: '',
        ptImgUrl: '',
        fkEmpIdArchived: null,
        fkRptiId: 0,
        isSelfPay: false,
        documentName: '',
        moveToScheduler: false,
        moveToSchedulerDatetime: '',
        admitDateTime: null,
        isNonAdmit: false,
        ptMRN: 0,
        ptSOCDate: '',
        ptSOCStatus: false,
        potentialDischargeDate: '',
        ptAddress: '',
        ptMedicalNote: '',
        isDemographicFilled: false,
        isDocumentationUpload: false,
        isInitialContactFilled: false,
        isOrdersFilled: false,
        isPhysicianFilled: false,
        isPrimaryInsuranceFilled: false,
        companyId: 0,
        genderId: 0,
        potentialDuplicate: false,
        fkPatientStatusId: null,
        specialPrecautions: '',
        rehospitalizationRisk: '',
      ),
    );
  } catch (e) {
    debugPrint("get visit data error: $e");
    return VisitPrefillByIdModel(
      remainingVisitsCount: 0,
      episodeTriggerType: '',
      daysToEpisodeEnd: 0,
      lastVisitIds: [],
      lastVisitPerformedBy: "",
      pendingAssistantFormIds: [],
      isSecoundLastEpisodeVisit: false,
      isAttemptedVisit: false,
      visitId: 0,
      ptId: 0,
      employeeTypeId: 0,
      employeeId: null,
      visitType: 0,
      visiteDateTimeFrom: '',
      visitDateTimeTo: '',
      isVisitCompleted: false,
      isVisitMissed: false,
      onWay: false,
      recordTypeId: null,
      inZone: false,
      isRescheduled: false,
      rescheduledAt: null,
      rescheduleReasonId: null,
      visitPhotoUrl: null,
      employee: null,
      typeOfVisitId: 0,
      typeOfVisitName: '',
      employeeType: EmployeePatientTypeModel(
        employeeTypeId: 0,
        employeeType: '',
        color: '',
        abbreviation: '',
        departmentId: 0,
        roleId: 0,
        masterEmpTypeId: 0,
        childEmpTypeId: [],
        templateIdSalaried: 0,
        templateIdParttime: 0,
        templateIdPerdiem: 0,
      ),
      patient: PatientPrefillModel(
        ptId: 0,
        ptFirstName: '',
        ptLastName: '',
        ptContactNo: '',
        ptZipCode: '',
        ptChartNo: 0,
        ptSummary: '',
        ptRefferalDate: '',
        fkSrvId: 0,
        fkPtPrimaryDiagnosis: 0,
        fkPtSecondaryDiagnosis: [],
        fkPtRefferalSource: 0,
        fkPtPcp: 0,
        fkPtMarketer: 0,
        fkPtDiscplines: [],
        ptCoverageArea: 0,
        isIntake: false,
        intakeTime: '',
        isArchieved: false,
        archievedTime: null,
        createdAt: '',
        ptDateOfBirth: '',
        ptImgUrl: '',
        fkEmpIdArchived: null,
        fkRptiId: 0,
        isSelfPay: false,
        documentName: '',
        moveToScheduler: false,
        moveToSchedulerDatetime: '',
        admitDateTime: null,
        isNonAdmit: false,
        ptMRN: 0,
        ptSOCDate: '',
        ptSOCStatus: false,
        potentialDischargeDate: '',
        ptAddress: '',
        ptMedicalNote: '',
        isDemographicFilled: false,
        isDocumentationUpload: false,
        isInitialContactFilled: false,
        isOrdersFilled: false,
        isPhysicianFilled: false,
        isPrimaryInsuranceFilled: false,
        companyId: 0,
        genderId: 0,
        potentialDuplicate: false,
        fkPatientStatusId: null,
        specialPrecautions: '',
        rehospitalizationRisk: '',
      ),
    );
  }
}

/// Mark missed visit

Future<ApiData> patchMissedVisitVisit({
  required BuildContext context,
  required int visitId,
  required String reason,
  required bool isAttemptedVisit,
  required String photoUrl,
  required List<String> actionsTaken,
  required String notificationDate,
  required String notificationTime,
  required List<String> individualsNotified,
  required List<String> notificationMethods,
}) async {
  try {
    print("::::${reason}");
    print("::::${isAttemptedVisit}");
    print("::::${photoUrl}");
    print("::::${actionsTaken}");
    print("::::${notificationDate}");
    print("::::${notificationTime}");
    print("::::${individualsNotified}");
    print("::::${notificationMethods}");
    var response = await Api(context).patch(
        path: EMRDashboardRepo.patientMissedVisit(visitId: visitId),
        data:{
          "reason": reason,
          "isAttemptedVisit": isAttemptedVisit,
          "photoUrl": photoUrl.isEmpty ? "--" : photoUrl,
          "actionsTaken": actionsTaken,
          "notificationDate": notificationDate,
          "notificationTime": notificationTime,
          "individualsNotified": individualsNotified,
          "notificationMethods": notificationMethods
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error missed visit patch");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);}
}


Future<ApiData> patchTreatmentPauseVisit({
  required BuildContext context,
  required int id,
  required bool treatmentPause,

}) async {
  try {
    var response = await Api(context).patch(
      path: EMRDashboardRepo.pauseTreatmentVisit(visitId: id),
      data: {
        "treatment_pause": treatmentPause,
      },
    );

    print('treatment pause: $response');
    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.data;
      var pauseEpisodeEnd = data['requiresEpisodeEndDecision'] ?? false;
      var lastVisitId = data['lastVisitId'] ?? 0;
      var secoundLastVisitId = data['secondLastVisitId'] ?? 0;
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
        pauseEpisodeEnd: pauseEpisodeEnd,
        pauseLastVisitId: lastVisitId,
        pauseSecoundVisitId: secoundLastVisitId,
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

Future<ApiData> patchRecertVisit({
  required BuildContext context,
  required int id,
  required String decision,

}) async {
  try {
    var response = await Api(context).patch(
      path: EMRDashboardRepo.recertDecisionVisit(visitId: id),
      data: {
        "decision": decision,
      },
    );

    print('decision: $response');
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


Future<List<PendingReviewAssistanceForm>> getEmrPendingReviewForm({
  required BuildContext context,
  required int patientId,
}) async {
  List<PendingReviewAssistanceForm> itemsData = [];
  try {
    final response = await Api(context).get(
        path: EMRDashboardRepo.getPatientFormReview(patientId: patientId));

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PendingReviewAssistanceForm(
          visitId: item['visitId'] ?? 0,
          patientFormId: item['patientFormId'] ?? 0,
          patientId: item['patientId'] ?? 0,
          formId: item['formId'] ?? 0,
          formName: item['formName'] ?? '',
          assistantEmployeeId: item['assistantEmployeeId'] ?? 0,
          assistantName: item['assistantName'] ?? '',
          assistantImage: item['assistantImage'] ?? '',
          assistantEmployeeType: item['assistantEmployeeType'] ?? '',
          assistantEmployeeTypeAbbreviation: item['assistantEmployeeTypeAbbreviation'] ?? '',
        ));
      }

      return itemsData;
    } else {
      debugPrint("patient visit list error: ${response.statusCode}");
    }

    return itemsData;
  } catch (e) {
    debugPrint("get patient visit error: $e");
    return itemsData;
  }
}