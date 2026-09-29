import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/Schedular_main_screens_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/refferals/patient_refferal_repo.dart';

Future<List<SchedularFlowPatientModel>> getSchedulerFlowPatientData({
  required BuildContext context,
  required String screen,
  required int pgNbr,
  required int nbrOfRows,
  required String sort,
  required String isScheduler,
  required String isNonAdmit,
  required String searchName,
  required String marketerId,
  required String referralSourceId,
  required String pcpId,
}) async {
  List<SchedularFlowPatientModel> itemsData = [];

  String convertIsoToDayMonthYear(dynamic isoDate) {
    try {
      if (isoDate == null || isoDate == "" || isoDate is! String) return '';
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (e) {
      return '';
    }
  }


  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getSchedulerFlowPatientData(screen: screen, pgNbr: pgNbr, nbrOfRows: nbrOfRows, sort: sort, isScheduler: isScheduler, isNonAdmit: isNonAdmit, searchName: searchName, marketerId: marketerId, referralSourceId: referralSourceId, pcpId: pcpId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        final patientData = item['patient'];

        Patient patient = Patient(
          ptId: patientData['pt_id'] ?? 0,
          ptFirstName: patientData['pt_first_name'] ?? '',
          ptLastName: patientData['pt_last_name'] ?? '',
          ptContactNo: patientData['pt_contact_no'] ?? '',
          ptZipCode: patientData['pt_zip_code'] ?? '',
          ptChartNo: patientData['pt_chart_no'] ?? 0,
          ptSummary: patientData['pt_summary'] ?? '',
          ptReferralDate: convertIsoToDayMonthYear(patientData['pt_refferal_date']),// != null ? convertIsoToDayMonthYear(patientData['pt_refferal_date']) : "",
          fkSrvId: patientData['fk_srv_id'] ?? 0,
          primaryDiagnosis: patientData['fk_pt_primary_diagnosis'] != null
              ? Diagnosis(
            dgnId: patientData['fk_pt_primary_diagnosis']?['dgn_id']?? 0,
            dgnName: patientData['fk_pt_primary_diagnosis']?['dgn_name']?? "",
            dgnCode: patientData['fk_pt_primary_diagnosis']?['dgn_code']?? "",
          )
              : Diagnosis(dgnId: 0, dgnName: '', dgnCode: ''),
          secondaryDiagnoses: [],
          referralSource: patientData['fk_pt_refferal_source'] != null
              ? ReferralSource(
            refSourceId: patientData['fk_pt_refferal_source']?['ref_source_id']?? 0,
            sourceName: patientData['fk_pt_refferal_source']?['source_name']?? "",
            description: patientData['fk_pt_refferal_source']?['description']?? "",
            referralSourceImgUrl: patientData['fk_pt_refferal_source']?['referral_source_img_url']?? "",
            documentName: patientData['fk_pt_refferal_source']?['documentName']?? "",
          )
              : ReferralSource(
            refSourceId: 0,
            sourceName: '',
            description: '',
            referralSourceImgUrl: '',
            documentName: '', ),
          fkPtPcp: patientData['fk_pt_pcp'] ?? 0,
          marketer: patientData['fk_pt_marketer'] != null
              ? EmployeeId(
            employeeId: patientData['fk_pt_marketer']?['employeeId']?? 0,
            code: patientData['fk_pt_marketer']?['code']?? "",
            firstName: patientData['fk_pt_marketer']?['firstName']?? "",
            lastName: patientData['fk_pt_marketer']?['lastName']?? "",
            expertise: patientData['fk_pt_marketer']?['expertise']?? "",
            gender: patientData['fk_pt_marketer']?['gender']?? "",
            imgUrl: patientData['fk_pt_marketer']?['imgurl']?? "",
            regOfficId: patientData['fk_pt_marketer']?['regOfficId']?? "",
            onboardingStatus: patientData['fk_pt_marketer']?['onboardingStatus']?? "",
            userId: patientData['fk_pt_marketer']?['userId']?? 0,
            ssnNbr: patientData['fk_pt_marketer']?['SSNNbr']?? "",
            address: patientData['fk_pt_marketer']?['address']?? "",
            cityId: patientData['fk_pt_marketer']?['cityId']?? 0,
            dateOfBirth: convertIsoToDayMonthYear(patientData['fk_pt_marketer']?['dateOfBirth']),// != null ? convertIsoToDayMonthYear(patientData['pt_SOC_date']) : "",
            departmentId: patientData['fk_pt_marketer']?['departmentId']?? 0,
            emergencyContact: patientData['fk_pt_marketer']?['emergencyContact']?? "",
            employeeTypeId: patientData['fk_pt_marketer']?['employeeTypeId']?? 0,
            employment: patientData['fk_pt_marketer']?['employment']?? "",
            personalEmail: patientData['fk_pt_marketer']?['personalEmail']?? "",
            primaryPhoneNbr: patientData['fk_pt_marketer']?['primaryPhoneNbr']?? "",
            secondryPhoneNbr: patientData['fk_pt_marketer']?['secondryPhoneNbr']?? "",
            service: patientData['fk_pt_marketer']?['service']?? "",
            status: patientData['fk_pt_marketer']?['status']?? "",
            workEmail: patientData['fk_pt_marketer']?['workEmail']?? "",
            workPhoneNbr: patientData['fk_pt_marketer']?['workPhoneNbr']?? "",
            companyId: patientData['fk_pt_marketer']?['companyId']?? 0,
            createdAt: convertIsoToDayMonthYear(patientData['fk_pt_marketer']?['createdAt']),// != null ? convertIsoToDayMonthYear(patientData['pt_SOC_date']) : "",
            resumeUrl: patientData['fk_pt_marketer']?['resumeurl']?? "",
            coverage: patientData['fk_pt_marketer']?['covreage']?? "",
            approved: patientData['fk_pt_marketer']?['approved']?? false,
            terminationFlag: patientData['fk_pt_marketer']?['terminationFlag']?? false,
            zoneId: patientData['fk_pt_marketer']?['zoneId']?? 0,
            countryId: patientData['fk_pt_marketer']?['countryId']?? 0,
            checkDate: convertIsoToDayMonthYear(patientData['fk_pt_marketer']?['checkDate']),// != null ? convertIsoToDayMonthYear(patientData['fk_pt_marketer']['checkDate']) : "",
            dateOfResignation: convertIsoToDayMonthYear(patientData['fk_pt_marketer']?['dateofResignation']),//!= null ? convertIsoToDayMonthYear(patientData['fk_pt_marketer']['dateofResignation']) : "" ,
            dateOfTermination: convertIsoToDayMonthYear(patientData['fk_pt_marketer']?['dateofTermination']),// != null ? convertIsoToDayMonthYear(patientData['fk_pt_marketer']['dateofTermination']) : "",
            finalAddress: patientData['fk_pt_marketer']?['finalAddress']?? "",
            finalPayCheck: double.tryParse('${patientData['fk_pt_marketer']?['finalPayCheck']}') ?? 0,
            grossPay: double.tryParse('${patientData['fk_pt_marketer']?['grossPay']}') ?? 0,
            materials: patientData['fk_pt_marketer']?['materials']?? "",
            methods: patientData['fk_pt_marketer']?['methods']?? "",
            netPay: double.tryParse('${patientData['fk_pt_marketer']?['netPay']}') ?? 0,
            reason: patientData['fk_pt_marketer']?['reason']?? "",
            rehirable: patientData['fk_pt_marketer']?['rehirable']?? "",
            type: patientData['fk_pt_marketer']?['type']?? "",
            dateOfHire: convertIsoToDayMonthYear(patientData['fk_pt_marketer']?['dateofHire']),// != null ? convertIsoToDayMonthYear(patientData['fk_pt_marketer']['dateofHire']) : "",
            position: patientData['fk_pt_marketer']?['position']?? "",
            driverLicenceNbr: patientData['fk_pt_marketer']?['driverLicenceNbr']?? "",
            race: patientData['fk_pt_marketer']?['race']?? "",
            rating: patientData['fk_pt_marketer']?['rating']?? "",
            signatureURL: patientData['fk_pt_marketer']?['signatureURL']?? "",
            countyId: patientData['fk_pt_marketer']?['countyId']?? 0,
            active: patientData['fk_pt_marketer']?['active']?? false,
            summary: patientData['fk_pt_marketer']?['summary']?? "",
          )
              : EmployeeId(
            employeeId: 0,
            code: '',
            firstName: '',
            lastName: '',
            expertise: '',
            gender: '',
            imgUrl: '',
            regOfficId: '',
            onboardingStatus: '',
            userId: 0,
            ssnNbr: '',
            address: '',
            cityId: 0,
            dateOfBirth: '',
            departmentId: 0,
            emergencyContact: '',
            employeeTypeId: 0,
            employment: '',
            personalEmail: '',
            primaryPhoneNbr: '',
            secondryPhoneNbr: '',
            service: '',
            status: '',
            workEmail: '',
            workPhoneNbr: '',
            companyId: 0,
            createdAt: '',
            resumeUrl: '',
            coverage: '',
            approved: false,
            terminationFlag: false,
            zoneId: 0,
            countryId: 0,
            checkDate: '',
            dateOfResignation: '',
            dateOfTermination: '',
            finalAddress: '',
            finalPayCheck: 0,
            grossPay: 0,
            materials: '',
            methods: '',
            netPay: 0,
            reason: '',
            rehirable: '',
            type: '',
            dateOfHire: '',
            position: '',
            driverLicenceNbr: '',
            race: '',
            rating: '',
            signatureURL: '',
            countyId: 0,
            active: false,
            summary: '',
          ),
          disciplines: (patientData['fk_pt_discplines'] as List).map((e) {
            return DisciplineType(
              employeeTypeId: e['employeeTypeId']?? 0,
              employeeType: e['employeeType']?? "",
              color: e['color']?? "",
              abbreviation: e['abbreviation']?? "",
              departmentId: e['DepartmentId']?? 0,
            );
          }).toList(),
          ptCoverageArea: patientData['pt_coverage_area'] ?? 0,
          isIntake: patientData['is_intake'] ?? false,
          intakeTime: convertIsoToDayMonthYear(patientData['intake_time']),//patientData['intake_time'] != null ? convertIsoToDayMonthYear(patientData['intake_time']) : "",
          isArchived: patientData['is_archieved'] ?? false,
          archivedTime: convertIsoToDayMonthYear(patientData['archieved_time']),//patientData['archieved_time'] != null ? convertIsoToDayMonthYear(patientData['archieved_time']) : "",
          createdAt: convertIsoToDayMonthYear(patientData['createdAt']),// patientData['createdAt'] != null ? convertIsoToDayMonthYear(patientData['createdAt']) : "",
          ptDateOfBirth: convertIsoToDayMonthYear(patientData['ptDateOfBirth']),//patientData['ptDateOfBirth'] != null ? convertIsoToDayMonthYear(patientData['ptDateOfBirth']) : "",
          ptImgUrl: patientData['pt_img_url'] ?? '',
          fkRptiId: patientData['fk_rpti_id'] ?? 0,
          fkEmpIdArchived: patientData['fk_emp_id_archived']?? 0,
          isSelfPay: patientData['is_selfPay'] ?? false,
          documentName: patientData['document_name']?? "",
          moveToScheduler: patientData['moveToScheduler'] ?? false,
          moveToSchedulerDatetime: convertIsoToDayMonthYear(patientData['moveToSchedulerDatetime']),//patientData['moveToSchedulerDatetime'] != null ? convertIsoToDayMonthYear(patientData['moveToSchedulerDatetime']) : "",
          isNonAdmit: patientData['is_non_admit'] ?? false,
          admitDateTime: convertIsoToDayMonthYear(patientData['admitDateTime']),// patientData['admitDateTime'] != null ? convertIsoToDayMonthYear(patientData['admitDateTime']) : "",
          ptMRN: patientData['pt_MRN'] ?? 0,
          ptSocDate: convertIsoToDayMonthYear(patientData['pt_SOC_date']),//patientData['pt_SOC_date'] != null ? convertIsoToDayMonthYear(patientData['pt_SOC_date']) : "",
          potentialDischargeDate: convertIsoToDayMonthYear(patientData['potential_discharge_date']),//patientData['potential_discharge_date'] != null ? convertIsoToDayMonthYear(patientData['potential_discharge_date']) : "",
          ptAddress: patientData['pt_address'] ?? '',
          ptMedicalNote: patientData['pt_medical_note'] ?? '',
        );

        List<DisciplineData> disciplineList = (item['data'] as List).map((e) {
          return DisciplineData(
            disciplineId: e['disciplineId'],
            employeetypeId: DisciplineType(
              employeeTypeId: e['employeetypeId']?['employeeTypeId']?? 0,
              employeeType: e['employeetypeId']?['employeeType']?? "",
              color: e['employeetypeId']?['color']?? "",
              abbreviation: e['employeetypeId']?['abbreviation']?? "",
              departmentId: e['employeetypeId']?['DepartmentId']?? 0,
            ),
            employeedId: EmployeeId(
              employeeId: e['employeedId']?['employeeId']?? 0,
              code: e['employeedId']?['code']?? "",
              firstName: e['employeedId']?['firstName']?? "",
              lastName: e['employeedId']?['lastName']?? "",
              expertise: e['employeedId']?['expertise']?? "",
              gender: e['employeedId']?['gender']?? "",
              imgUrl: e['employeedId']?['imgurl']?? "",
              regOfficId: e['employeedId']?['regOfficId']?? "",
              onboardingStatus: e['employeedId']?['onboardingStatus']?? "",
              userId: e['employeedId']?['userId']?? 0,
              ssnNbr: e['employeedId']?['SSNNbr']?? "",
              address: e['employeedId']?['address']?? "",
              cityId: e['employeedId']?['cityId']?? 0,
              dateOfBirth: convertIsoToDayMonthYear(e['employeedId']?['dateOfBirth']),// != null ? convertIsoToDayMonthYear(e['employeedId']['dateOfBirth']) : "",
              departmentId: e['employeedId']?['departmentId']?? 0,
              emergencyContact: e['employeedId']?['emergencyContact']?? "",
              employeeTypeId: e['employeedId']?['employeeTypeId']?? 0,
              employment: e['employeedId']?['employment']?? "",
              personalEmail: e['employeedId']?['personalEmail']?? "",
              primaryPhoneNbr: e['employeedId']?['primaryPhoneNbr']?? "",
              secondryPhoneNbr: e['employeedId']?['secondryPhoneNbr']?? "",
              service: e['employeedId']?['service']?? "",
              status: e['employeedId']?['status']?? "",
              workEmail: e['employeedId']?['workEmail']?? "",
              workPhoneNbr: e['employeedId']?['workPhoneNbr']?? "",
              companyId: e['employeedId']?['companyId']?? 0,
              createdAt: convertIsoToDayMonthYear(e['employeedId']?['createdAt']),// != null ? convertIsoToDayMonthYear(e['employeedId']['createdAt']) : "",
              resumeUrl: e['employeedId']?['resumeurl']?? "",
              coverage: e['employeedId']?['covreage']?? "",
              approved: e['employeedId']?['approved']?? false,
              terminationFlag: e['employeedId']?['terminationFlag']?? false,
              zoneId: e['employeedId']?['zoneId']?? 0,
              countryId: e['employeedId']?['countryId']?? 0,
              checkDate: convertIsoToDayMonthYear(e['employeedId']?['checkDate']),// != null ? convertIsoToDayMonthYear(e['employeedId']['checkDate']) : "",
              dateOfResignation: convertIsoToDayMonthYear(e['employeedId']?['dateOfResignation']),// != null ? convertIsoToDayMonthYear(e['employeedId']['dateOfResignation']) : "",
              dateOfTermination:convertIsoToDayMonthYear(e['employeedId']?['dateOfTermination']),// != null ? convertIsoToDayMonthYear(e['employeedId']['dateOfTermination']) : "",
              finalAddress: e['employeedId']?['finalAddress']?? "",
              finalPayCheck: double.tryParse('${e['employeedId']?['finalPayCheck']}') ?? 0,
              grossPay: double.tryParse('${e['employeedId']?['grossPay']}') ?? 0,
              materials: e['employeedId']?['materials']?? "",
              methods: e['employeedId']?['methods']?? "",
              netPay: double.tryParse('${e['employeedId']?['netPay']}') ?? 0,
              reason: e['employeedId']?['reason']?? "",
              rehirable: e['employeedId']?['rehirable']?? "",
              type: e['employeedId']?['type']?? "",
              dateOfHire: convertIsoToDayMonthYear(e['employeedId']?['dateOfHire']),// != null ? convertIsoToDayMonthYear(e['employeedId']['dateOfHire']) : "",
              position: e['employeedId']?['position']?? "",
              driverLicenceNbr: e['employeedId']?['driverLicenceNbr']?? "",
              race: e['employeedId']?['race']?? "",
              rating: e['employeedId']?['rating']?? "",
              signatureURL: e['employeedId']?['signatureURL']?? "",
              countyId: e['employeedId']?['countyId']?? 0,
              active: e['employeedId']?['active']?? false,
              summary: e['employeedId']?['summary']?? "",
            ),
            notesToClinician: e['notesToClinician']?? "",
            createdAt:convertIsoToDayMonthYear(e['employeedId']?['createdAt']),// != null ? convertIsoToDayMonthYear(e['employeedId']['createdAt']) : "",
            updatedAt:convertIsoToDayMonthYear(e['employeedId']?['updatedAt']),// != null ? convertIsoToDayMonthYear(e['employeedId']['updatedAt']) : "",
          );
        }).toList();

        itemsData.add(SchedularFlowPatientModel(
          patient: patient,
          data: disciplineList,
          allCliniciansAssigned: item['all_clinicians_assigned'] ?? false,
          moveToSchedulerDatetime: item['moveToSchedulerDatetime'] ?? "",//convertIsoToDayMonthYear(item['moveToSchedulerDatetime']),
          // item['moveToSchedulerDatetime'] != null ? convertIsoToDayMonthYear(item['moveToSchedulerDatetime']) : "",
        ));
      }

      print("✔ Total records fetched from API: ${itemsData.length}");
    } else {
      print("❌ Error while fetching patient referrals data.");
    }

    return itemsData;
  } catch (e) {
    print("❌ Exception in Scheduler scheduled: $e");
    return itemsData;
  }
}


///patch /patient-referral/{id}
Future<ApiData> updateScedularNonAdmitPatch({
  required BuildContext context,
  required int id,

}) async {
  try {
    final companyId = await TokenManager.getCompanyId();

    var response = await Api(context).patch(
      path: PatientRefferalsRepo.updateSchedularWithId(id: id),
      data: {
        "is_non_admit": true,
      },
    );

    print('Schedular Patch Response: $response');
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
