import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/refferals/patient_refferal_repo.dart';
///get
///get
///get
Future<List<PatientModel>> getPatientReffrealsData({
  required BuildContext context,
  required int pageNo,
  required int nbrOfRows,
  required String isIntake,
  required String intakeSort,
  required String isArchived,
  required String archivedSort,
  required String isScheduled,
  required String scheduledSort,
  required String isNotAdmit,
  required String nonAdmitSort,
  required String searchName,
  required String marketerId,
  required String referralSourceId,
  required String pcpId,
}) async {
  List<PatientModel> itemsData = [];
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  // NEW: unique id per call so concurrent/overlapping calls to this
  // function can be told apart in the console output.
  final int callId = DateTime.now().millisecondsSinceEpoch % 100000;

  try {
    final companyId = TokenManager.getCompanyId();

    print("🌐 [Manager#$callId] getPatientReffrealsData CALLED at ${DateTime.now().toIso8601String()}");
    print("🌐 [Manager#$callId] params: isIntake=$isIntake, isArchived=$isArchived, isScheduled=$isScheduled, isNotAdmit=$isNotAdmit, marketer=$marketerId, source=$referralSourceId, pcp=$pcpId, search=$searchName");

    final path = PatientRefferalsRepo.getPatientRefferals(pageNo: pageNo, nbrOfRows: nbrOfRows, isIntake: isIntake, intakeSort: intakeSort, isArchived: isArchived, archivedSort: archivedSort, isScheduled: isScheduled, scheduledSort: scheduledSort, isNonAdmit: isNotAdmit, nonAdmitSort: nonAdmitSort, searchName: searchName, marketerId: marketerId, referralSourceId: referralSourceId, pcpId: pcpId);
    print("🌐 [Manager#$callId] request path: $path");

    final response = await Api(context).get(path: path);

    print("🌐 [Manager#$callId] response received at ${DateTime.now().toIso8601String()} - status=${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        try {
          itemsData.add(PatientModel(
            ptId: item['pt_id'],
            ptFirstName: item['pt_first_name'] ?? '',
            ptLastName: item['pt_last_name'] ?? '',
            ptContactNo: item['pt_contact_no'] ?? '',
            ptZipCode: item['pt_zip_code'] ?? '',
            ptChartNo: item['pt_chart_no'] ?? 0,
            ptSummary: item['pt_summary'] ?? '',
            ptRefferalDate: convertIsoToDayMonthYear(item['pt_refferal_date']),
            fkSrvId: item['fk_srv_id'] ?? 0,
            fkPtPrimaryDiagnosis: item['fk_pt_primary_diagnosis'] ?? 0,
            fkPtSecondaryDiagnosis: List<int>.from(item['fk_pt_secondary_diagnosis'] ?? []),
            fkPtRefferalSource: item['fk_pt_refferal_source'] ?? 0,
            fkPtPcp: item['fk_pt_pcp'] ?? 0,
            fkPtMarketer: item['fk_pt_marketer'] ?? 0,
            fkPtDiscplines: List<int>.from(item['fk_pt_discplines'] ?? []),
            ptCoverageArea: item['pt_coverage_area'] ?? 0,
            isIntake: item['is_intake'] ?? false,
            intakeTime: item['intake_time']?.toString(),
            isArchieved: item['is_archieved'] ?? false,
            archievedTime: item['archieved_time'] ?? "",
            createdAt: item['created_at'] ?? "",
            ptDateOfBirth: item['pt_date_of_birth'] ?? "",
            ptImgUrl: item['pt_img_url'] ?? '',
            fkempIdArchieved: item['fk_emp_id_archived'] ?? 0,
            fkRptiId: item['fk_rpti_id'] ?? 0,
            isSelfPay: item['is_selfPay'] ?? false,
            documentName: item['document_name'] ?? "",
            moveToScheduler: item['moveToScheduler'] ?? false,
            moveToSchedulerDatetime: item['moveToSchedulerDatetime'] ?? "",
            admitDateTime: item['admitDateTime'] ?? "",
            isNonAdmit: item['is_non_admit'] ?? false,
            ptMRN: item['pt_MRN'] ?? 0,
            ptSOCDate: item['pt_SOC_date'] ?? "",
            ptSOCStatus: item['pt_SOC_status'] ?? false,
            potentialDischargeDate: convertIsoToDayMonthYear(item['potential_discharge_date'] ?? " "),
            ptAddress: item['pt_address'] ?? "",
            ptMedicalNote: item['pt_medical_note'] ?? "",
            isDemographicFilled: item['is_demographic_filled'],
            isDocumentationUpload: item['is_documentation_upload'],
            isPrimaryInsuranceFilled: item['is_primaryInsurance_filled'],
            isPhysicianFilled: item['is_physician_filled'],
            isOrdersFilled: item['is_orders_filled'],
            isInitialContactFilled: item['is_initialContact_filled'],

            service: item['service'] != null
                ? ServiceModel(
              srvId: item['service']['srv_id'] ?? 0,
              srvName: item['service']['srv_name'] ?? "",
              srvCode: item['service']['srv_code'] ?? "",
            )
                : ServiceModel(srvId: 0, srvName: "", srvCode: ""),

            referralSource: item['referralSource'] != null
                ? ReferralSourceModel(
              refSourceId: item['referralSource']['ref_source_id'] ?? 0,
              sourceName: item['referralSource']['source_name'] ?? "",
              description: item['referralSource']['description'] ?? "",
              referralSourceImgUrl: item['referralSource']['referral_source_img_url'] ?? "",
              documentName: item['referralSource']['documentName'] ?? "",
            )
                : ReferralSourceModel(
              refSourceId: 0, sourceName: "", description: "",
              referralSourceImgUrl: "", documentName: "",
            ),

            pcp: item['pcp'] != null
                ? PCPModel(
              phyId: item['pcp']['phy_id'] ?? 0,
              phyFirstName: item['pcp']['phy_first_name'] ?? "",
              phyFirstNameLink: item['pcp']['phy_first_name_link'] ?? "",
              phyFirstNamePgNo: item['pcp']['phy_first_name_pg_no'] ?? 0,
              phyLastName: item['pcp']['phy_last_name'] ?? "",
              phyLastNameLink: item['pcp']['phy_last_name_link'] ?? "",
              phyLastNamePgNo: item['pcp']['phy_last_name_pg_no'] ?? 0,
              phyPicoNo: item['pcp']['phy_pico_no'] ?? "",
              phyPicoNoLink: item['pcp']['phy_pico_no_link'] ?? "",
              phyPicoNoPgNo: item['pcp']['phy_pico_no_pg_no'] ?? 0,
              phyPicoStatus: item['pcp']['phy_pico_status'] ?? false,
              phyEmail: item['pcp']['phy_email'] ?? "",
              phyEmailLink: item['pcp']['phy_email_link'] ?? "",
              phyEmailPgNo: item['pcp']['phy_email_pg_no'] ?? 0,
              phyContact: item['pcp']['phy_contact'] ?? "",
              phyContactLink: item['pcp']['phy_contact_link'] ?? "",
              phyContactPgNo: item['pcp']['phy_contact_pg_no'] ?? 0,
              phyNPI: item['pcp']['phy_NPI'] ?? 0,
              phyUPI: item['pcp']['phy_UPI'] ?? "",
              phyUPILink: item['pcp']['phy_UPI_link'] ?? "",
              phyUPIPgNo: item['pcp']['phy_UPI_pg_no'] ?? 0,
              phyCity: item['pcp']['phy_city'] ?? "",
              phyCityLink: item['pcp']['phy_city_link'] ?? "",
              phyCityPgNo: item['pcp']['phy_city_pg_no'] ?? 0,
              phyFax: item['pcp']['phy_fax'] ?? "",
              phyFaxLink: item['pcp']['phy_fax_link'] ?? "",
              phyFaxPgNo: item['pcp']['phy_fax_pg_no'] ?? 0,
              phyNotes: item['pcp']['phy_notes'] ?? "",
              phyNotesLink: item['pcp']['phy_notes_link'] ?? "",
              phyNotesPgNo: item['pcp']['phy_notes_pg_no'] ?? 0,
              phyProtocols: item['pcp']['phy_protocols'] ?? "",
              phyProtocolsLink: item['pcp']['phy_protocols_link'] ?? "",
              phyProtocolsPgNo: item['pcp']['phy_protocols_pg_no'] ?? 0,
              phyState: item['pcp']['phy_state'] ?? "",
              phyStateLink: item['pcp']['phy_state_link'] ?? "",
              phyStatePgNo: item['pcp']['phy_state_pg_no'] ?? 0,
              phyStreet: item['pcp']['phy_street'] ?? "",
              phyStreetLink: item['pcp']['phy_street_link'] ?? "",
              phyStreetPgNo: item['pcp']['phy_street_pg_no'] ?? 0,
              phySuffix: item['pcp']['phy_suffix'] ?? "",
              phySuffixLink: item['pcp']['phy_suffix_link'] ?? "",
              phySuffixPgNo: item['pcp']['phy_suffix_pg_no'] ?? 0,
              phySuite: item['pcp']['phy_suite'] ?? "",
              phySuiteLink: item['pcp']['phy_suite_link'] ?? "",
              phySuitePgNo: item['pcp']['phy_suite_pg_no'] ?? 0,
              phyTrackingNotes: item['pcp']['phy_trackingNotes'] ?? "",
              phyTrackingNotesLink: item['pcp']['phy_trackingNotes_link'] ?? "",
              phyTrackingNotesPgNo: item['pcp']['phy_trackingNotes_pg_no'] ?? 0,
              phyVerificationDetails: item['pcp']['phy_verificationDetails'] ?? "",
              phyVerificationDetailsLink: item['pcp']['phy_verificationDetails_link'] ?? "",
              phyVerificationDetailsPgNo: item['pcp']['phy_verificationDetails_pg_no'] ?? 0,
              phyVerified: item['pcp']['phy_verified'] ?? false,
              phyZipCode: item['pcp']['phy_zipCode'] ?? "",
              phyZipCodeLink: item['pcp']['phy_zipCode_link'] ?? "",
              phyZipCodePgNo: item['pcp']['phy_zipCode_pg_no'] ?? 0,
            )
                : PCPModel(
              phyId: 0, phyFirstName: "", phyFirstNameLink: "", phyFirstNamePgNo: 0,
              phyLastName: "", phyLastNameLink: "", phyLastNamePgNo: 0,
              phyPicoNo: "", phyPicoNoLink: "", phyPicoNoPgNo: 0, phyPicoStatus: false,
              phyEmail: "", phyEmailLink: "", phyEmailPgNo: 0,
              phyContact: "", phyContactLink: "", phyContactPgNo: 0,
              phyNPI: 0, phyUPI: "", phyUPILink: "", phyUPIPgNo: 0,
              phyCity: "", phyCityLink: "", phyCityPgNo: 0,
              phyFax: "", phyFaxLink: "", phyFaxPgNo: 0,
              phyNotes: "", phyNotesLink: "", phyNotesPgNo: 0,
              phyProtocols: "", phyProtocolsLink: "", phyProtocolsPgNo: 0,
              phyState: "", phyStateLink: "", phyStatePgNo: 0,
              phyStreet: "", phyStreetLink: "", phyStreetPgNo: 0,
              phySuffix: "", phySuffixLink: "", phySuffixPgNo: 0,
              phySuite: "", phySuiteLink: "", phySuitePgNo: 0,
              phyTrackingNotes: "", phyTrackingNotesLink: "", phyTrackingNotesPgNo: 0,
              phyVerificationDetails: "", phyVerificationDetailsLink: "", phyVerificationDetailsPgNo: 0,
              phyVerified: false,
              phyZipCode: "", phyZipCodeLink: "", phyZipCodePgNo: 0,
            ),

            marketer: item['marketer'] != null
                ? MarketerModel(
              employeeId: item['marketer']['employeeId'] ?? 0,
              code: item['marketer']['code'] ?? '',
              firstName: item['marketer']['firstName'] ?? '',
              lastName: item['marketer']['lastName'] ?? '',
              expertise: item['marketer']['expertise'] ?? '',
              gender: item['marketer']['gender'] ?? '',
              imgurl: item['marketer']['imgurl'] ?? '',
              regOfficId: item['marketer']['regOfficId'] ?? '',
              onboardingStatus: item['marketer']['onboardingStatus'] ?? '',
              userId: item['marketer']['userId'] ?? 0,
              ssnNbr: item['marketer']['SSNNbr'] ?? '',
              address: item['marketer']['address'] ?? '',
              cityId: item['marketer']['cityId'] ?? 0,
              dateOfBirth: item['marketer']['dateOfBirth'] != null ? convertIsoToDayMonthYear(item['marketer']['dateOfBirth']) : '',
              departmentId: item['marketer']['departmentId'] ?? 0,
              emergencyContact: item['marketer']['emergencyContact'] ?? '',
              employeeTypeId: item['marketer']['employeeTypeId'] ?? 0,
              employment: item['marketer']['employment'] ?? '',
              personalEmail: item['marketer']['personalEmail'] ?? '',
              primaryPhoneNbr: item['marketer']['primaryPhoneNbr'] ?? '',
              secondryPhoneNbr: item['marketer']['secondryPhoneNbr'] ?? '',
              service: item['marketer']['service'] ?? '',
              status: item['marketer']['status'] ?? '',
              workEmail: item['marketer']['workEmail'] ?? '',
              workPhoneNbr: item['marketer']['workPhoneNbr'] ?? '',
              companyId: item['marketer']['companyId'] ?? 0,
              createdAt: item['marketer']['createdAt'] != null ? convertIsoToDayMonthYear(item['marketer']['createdAt']) : '',
              resumeurl: item['marketer']['resumeurl'] ?? '',
              covreage: item['marketer']['covreage'] ?? '',
              approved: item['marketer']['approved'] ?? false,
              terminationFlag: item['marketer']['terminationFlag'] ?? false,
              zoneId: item['marketer']['zoneId'] ?? 0,
              countryId: item['marketer']['countryId'] ?? 0,
              checkDate: item['marketer']['checkDate'] != null ? convertIsoToDayMonthYear(item['marketer']['checkDate']) : '',
              dateofResignation: item['marketer']['dateofResignation'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofResignation']) : '',
              dateofTermination: item['marketer']['dateofTermination'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofTermination']) : '',
              finalAddress: item['marketer']['finalAddress'] ?? '',
              finalPayCheck: (item['marketer']['finalPayCheck'] ?? 0).toDouble(),
              grossPay: (item['marketer']['grossPay'] ?? 0).toDouble(),
              materials: item['marketer']['materials'] ?? '',
              methods: item['marketer']['methods'] ?? '',
              netPay: (item['marketer']['netPay'] ?? 0).toDouble(),
              reason: item['marketer']['reason'] ?? '',
              rehirable: item['marketer']['rehirable'] ?? '',
              type: item['marketer']['type'] ?? '',
              dateofHire: item['marketer']['dateofHire'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofHire']) : '',
              position: item['marketer']['position'] ?? '',
              driverLicenceNbr: item['marketer']['driverLicenceNbr'] ?? '',
              race: item['marketer']['race'] ?? '',
              rating: item['marketer']['rating'] ?? '',
              signatureURL: item['marketer']['signatureURL'] ?? '',
              countyId: item['marketer']['countyId'] ?? 0,
              active: item['marketer']['active'] ?? false,
              summary: item['marketer']['summary'] ?? '',
            )
                : MarketerModel(
              employeeId: 0, code: '', firstName: '', lastName: '', expertise: '', gender: '',
              imgurl: '', regOfficId: '', onboardingStatus: '', userId: 0, ssnNbr: '',
              address: '', cityId: 0, dateOfBirth: '', departmentId: 0, emergencyContact: '',
              employeeTypeId: 0, employment: '', personalEmail: '', primaryPhoneNbr: '',
              secondryPhoneNbr: '', service: '', status: '', workEmail: '', workPhoneNbr: '',
              companyId: 0, createdAt: '', resumeurl: '', covreage: '', approved: false,
              terminationFlag: false, zoneId: 0, countryId: 0, checkDate: '',
              dateofResignation: '', dateofTermination: '', finalAddress: '',
              finalPayCheck: 0.0, grossPay: 0.0, materials: '', methods: '', netPay: 0.0,
              reason: '', rehirable: '', type: '', dateofHire: '', position: '',
              driverLicenceNbr: '', race: '', rating: '', signatureURL: '', countyId: 0,
              active: false, summary: '',
            ),

            disciplines: item['disciplines'] is List
                ? (item['disciplines'] as List).map((d) {
              return DisciplineModel(
                employeeTypeId: d['employeeTypeId'],
                employeeType: d['employeeType'],
                color: d['color'],
                abbreviation: d['abbreviation'],
                departmentId: d['DepartmentId'],
              );
            }).toList()
                : <DisciplineModel>[],

            patientDiagnoses: item['patientDiagnoses'] is List
                ? (item['patientDiagnoses'] as List).map((d) {
              return PatientDiagnosesModel(
                rpt_dgn_id: d['dgn_id'] ?? 0,
                dgnName: d['dgn_name'] ?? '',
                dgnCode: d['dgn_code'] ?? '',
                fk_pt_id: d['fk_pt_id'] ?? 0,
                fk_dgn_id: d['fk_dgn_id'] ?? 0,
                rpt_pdgm: d['rpt_pdgm'] ?? false,
                rpt_isPrimary: d['rpt_isPrimary'] ?? false,
                color: d['color'] ?? 0,
              );
            }).toList()
                : <PatientDiagnosesModel>[],

            insurance: item['patientInsurance'] is List
                ? (item['patientInsurance'] as List).map((d) {
              return InsuranceModel(
                rptiId: d['rpti_id'] ?? 0,
                fkptId: d['fk_pt_id'] ?? 0,
                policy: d['rpti_policy'] ?? '',
                policyLink: d['rpti_policy_link'] ?? '',
                policyPgNo: d['rpti_policy_pg_no'] ?? 0,
                insuranceProvider: d['rpti_insurance_provider'] ?? '',
                insuranceProviderLink: d['rpti_insurance_provider_link'] ?? '',
                insuranceProviderPgNo: d['rpti_insurance_provider_pg_no'] ?? 0,
                insurancePlan: d['rpti_insurance_plan'] ?? '',
                insurancePlanLink: d['rpti_insurance_plan_link'] ?? '',
                insurancePlanPgNo: d['rpti_insurance_plan_pg_no'] ?? 0,
                eligibility: d['rpti_eligibility'] ?? false,
                authorization: d['rpti_authorization'] ?? false,
                lastCheckedTime: d['rpti_last_checked_time'] ?? '',
                category: d['rpti_category'] ?? '',
                categoryLink: d['rpti_category_link'] ?? '',
                categoryPgNo: d['rpti_category_pg_no'] ?? 0,
                city: d['rpti_city'] ?? '',
                cityLink: d['rpti_city_link'] ?? '',
                cityPgNo: d['rpti_city_pg_no'] ?? 0,
                comments: d['rpti_comments'] ?? '',
                commentsLink: d['rpti_comments_link'] ?? '',
                commentsPgNo: d['rpti_comments_pg_no'] ?? 0,
                contact: d['rpti_contact'] ?? '',
                contactLink: d['rpti_contact_link'] ?? '',
                contactPgNo: d['rpti_contact_pg_no'] ?? 0,
                effectiveFrom: d['rpti_effectiveFrom'] ?? '',
                effectiveTo: d['rpti_effectiveTo'] ?? '',
                email: d['rpti_email'] ?? '',
                emailLink: d['rpti_email_link'] ?? '',
                emailPgNo: d['rpti_email_pg_no'] ?? 0,
                groupName: d['rpti_groupName'] ?? '',
                groupNameLink: d['rpti_groupName_link'] ?? '',
                groupNamePgNo: d['rpti_groupName_pg_no'] ?? 0,
                groupNumber: d['rpti_groupNumber'] ?? 0,
                name: d['rpti_name'] ?? '',
                nameLink: d['rpti_name_link'] ?? '',
                namePgNo: d['rpti_name_pg_no'] ?? 0,
                state: d['rpti_state'] ?? '',
                stateLink: d['rpti_state_link'] ?? '',
                statePgNo: d['rpti_state_pg_no'] ?? 0,
                street: d['rpti_street'] ?? '',
                streetLink: d['rpti_street_link'] ?? '',
                streetPgNo: d['rpti_street_pg_no'] ?? 0,
                suite: d['rpti_suite'] ?? '',
                suiteLink: d['rpti_suite_link'] ?? '',
                suitePgNo: d['rpti_suite_pg_no'] ?? 0,
                type: d['rpti_type'] ?? '',
                typeLink: d['rpti_type_link'] ?? '',
                typePgNo: d['rpti_type_pg_no'] ?? 0,
                verified: d['rpti_verified'] ?? false,
                zipcode: d['rpti_zipcode'] ?? '',
                zipcodeLink: d['rpti_zipcode_link'] ?? '',
                zipcodePgNo: d['rpti_zipcode_pg_no'] ?? 0,
              );
            }).toList()
                : <InsuranceModel>[],

            potentialDuplicate: item['potential_duplicate'] ?? false,
            thresould: item['threshold'] ?? 0,
            allCliniciansAssigned: item['all_clinicians_assigned'] ?? false,

            detailedDisciplines: item['detailedDisciplines'] is List
                ? (item['detailedDisciplines'] as List).map((disc) {
              return DetailedDiscipline(
                disciplineId: disc['disciplineId'] ?? 0,
                fkPtId: disc['fk_pt_id'] ?? 0,
                fkEmployeeTypeId: disc['fk_employeetypeId'] ?? 0,
                fkEmployeeId: disc['fk_employeeId'] ?? 0,
                notesToClinician: disc['notesToClinician'] ?? '',
                sentAsRequest: disc['sentAsRequest'] ?? false,
                employeeTypeId: disc['employeeTypeId'] ?? 0,
                employeeType: disc['employeeType'] ?? '',
                color: disc['color'] ?? '#FFFFFF',
                abbreviation: disc['abbreviation'] ?? '--',
                departmentId: disc['departmentId'] ?? 0,
                DepartmentId: disc['DepartmentId'] ?? 0,
                employeeId: disc['employeeId'] ?? 0,
                firstName: disc['firstName'] ?? '',
                lastName: disc['lastName'] ?? '',
                expertise: disc['expertise'] ?? '',
                imgUrl: disc['imgurl'] ?? '',
                userId: disc['userId'] ?? 0,
                empEmployeeTypeId: disc['emp_employeeTypeId'] ?? 0,
                companyId: disc['companyId'] ?? 0,
              );
            }).toList()
                : <DetailedDiscipline>[],
          ));
        } catch (e) {
          print("⚠️ [Manager#$callId] Skipped malformed referral record (pt_id: ${item['pt_id']}): $e");
        }
      }
      print("/////////Total records fetched from API *******: ${itemsData.length} [Manager#$callId]");
    } else {
      print("❌ [Manager#$callId] patient referrals error - non-200 status: ${response.statusCode}, body: ${response.data}");
    }
    return itemsData;
  } on DioException catch (e) {
    // NEW: full diagnostic dump on DioException so we can see exactly what
    // was sent (headers/contentType/path) and precisely which DioExceptionType
    // this is (connectionError vs badResponse vs cancel, etc).
    print("❌ [Manager#$callId] DioException at ${DateTime.now().toIso8601String()}");
    print("❌ [Manager#$callId] DioExceptionType: ${e.type}");
    print("❌ [Manager#$callId] message: ${e.message}");
    print("❌ [Manager#$callId] request path: ${e.requestOptions.path}");
    print("❌ [Manager#$callId] request method: ${e.requestOptions.method}");
    print("❌ [Manager#$callId] request headers: ${e.requestOptions.headers}");
    print("❌ [Manager#$callId] request contentType: ${e.requestOptions.contentType}");
    print("❌ [Manager#$callId] response statusCode (if any): ${e.response?.statusCode}");
    print("❌ [Manager#$callId] response data (if any): ${e.response?.data}");
    return itemsData;
  } catch (e) {
    print("❌ [Manager#$callId] error referral (generic): $e");
    return itemsData;
  }
}


///get non admit
Future<List<NonAdmitData>> getInfoUpdateNonAdmit({
  required BuildContext context,
  required int pageNo,
  required int nbrOfRows,
  required String sort ,
  required String searchName,
  required String marketerId,
  required String referralSourceId,
  required String pcpId,
}) async {
  List<NonAdmitData> itemsData = [];
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  try {
    final companyId = TokenManager.getCompanyId();
    final response = await Api(context).get(
        path: PatientRefferalsRepo.getReferralNonAdmitData(pgNbr: pageNo, nbrOfRows: nbrOfRows, sort: sort, searchName: searchName, marketerId: marketerId, referralSourceId: referralSourceId, pcpId: pcpId)
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(NonAdmitData(
          ptId: item['pt_id'],
          ptFirstName: item['pt_first_name'] ?? '',
          ptLastName: item['pt_last_name'] ?? '',
          ptContactNo: item['pt_contact_no'] ?? '',
          ptZipCode: item['pt_zip_code'] ?? '',
          ptChartNo: item['pt_chart_no'] ?? 0,
          ptSummary: item['pt_summary'] ?? '',
          ptRefferalDate: convertIsoToDayMonthYear(item['pt_refferal_date']),
          fkSrvId: item['fk_srv_id'] ?? 0,
          fkPtPrimaryDiagnosis: item['fk_pt_primary_diagnosis'] ?? 0,
          fkPtSecondaryDiagnosis: List<int>.from(item['fk_pt_secondary_diagnosis'] ?? []),
          fkPtRefferalSource: item['fk_pt_refferal_source'] ?? 0,
          fkPtPcp: item['fk_pt_pcp'] ?? 0,
          fkPtMarketer: item['fk_pt_marketer'] ?? 0,
          fkPtDiscplines: List<int>.from(item['fk_pt_discplines'] ?? []),
          ptCoverageArea: item['pt_coverage_area'] ?? 0,
          isIntake: item['is_intake'] ?? false,
          intakeTime:  item['intake_time']?.toString(), // != null ? DateTime.tryParse(item['intake_time']) : null,
          isArchieved: item['is_archieved'] ?? false,
          archievedTime: item['archieved_time'] ?? "",// item['archieved_time'] != null ? DateTime.tryParse(item['archieved_time']) : null,
          // insuranceId: item['insurance_id'] ?? 0,
          createdAt: item['created_at'] ?? "",// item['created_at'] != null ? convertIsoToDayMonthYear(item['created_at']) : '',
          ptDateOfBirth: item['pt_date_of_birth'] ?? "",// DateTime.parse(item['pt_date_of_birth']),
          // ptImgUrl: item['pt_img_url'] ?? '',
          ptImgUrl: item['pt_img_url'] ?? '',
          fkempIdArchieved: item['fk_emp_id_archived'] ?? 0,
          fkRptiId: item['fk_rpti_id'] ?? 0,
          isSelfPay: item['is_selfPay'] ?? false,
          documentName: item['document_name'] ?? "",
          moveToScheduler: item['moveToScheduler'] ?? false,
          moveToSchedulerDatetime: item['moveToSchedulerDatetime'] ?? "" ,
          admitDateTime: item['admitDateTime'] ?? "",
          isNonAdmit:item['is_non_admit'] ?? false ,
          ptMRN: item['pt_MRN'] ?? 0,
          ptSOCDate: item['pt_SOC_date'] ?? "",
          ptSOCStatus: item['pt_SOC_status'] ?? false,
          potentialDischargeDate:convertIsoToDayMonthYear(item['potential_discharge_date']?? " "),
          ptAddress: item['pt_address'] ?? "",
          ptMedicalNote: item['pt_medical_note'] ?? "",
          isDemographicFilled: item['is_demographic_filled'],
          isDocumentationUpload: item['is_documentation_upload'],
          isPrimaryInsuranceFilled: item['is_primaryInsurance_filled'],
          isPhysicianFilled: item['is_physician_filled'],
          isOrdersFilled: item['is_orders_filled'],
          isInitialContactFilled: item['is_initialContact_filled'],
          service: ServiceModel(
            srvId: item['service']['srv_id'] ?? 0,
            srvName: item['service']['srv_name'] ?? "",
            srvCode: item['service']['srv_code'] ?? "",
          ),
          referralSource: item['referralSource'] != null
              ? ReferralSourceModel(
            refSourceId: item['referralSource']['ref_source_id'] ?? 0,
            sourceName: item['referralSource']['source_name'] ?? "",
            description: item['referralSource']['description'] ?? "",
            referralSourceImgUrl: item['referralSource']['referral_source_img_url'] ?? "",
            documentName: item['referralSource']['documentName'] ?? "",
          )
              : ReferralSourceModel(
            refSourceId: 0,
            sourceName: "",
            description: "",
            referralSourceImgUrl: "",
            documentName: "",
          ),

          pcp: item['pcp'] != null
              ? PCPModel(
            phyId: item['pcp']['phy_id'] ?? 0,
            phyFirstName: item['pcp']['phy_first_name'] ?? "",
            phyFirstNameLink: item['pcp']['phy_first_name_link'] ?? "",
            phyFirstNamePgNo: item['pcp']['phy_first_name_pg_no'] ?? 0,
            phyLastName: item['pcp']['phy_last_name'] ?? "",
            phyLastNameLink: item['pcp']['phy_last_name_link'] ?? "",
            phyLastNamePgNo: item['pcp']['phy_last_name_pg_no'] ?? 0,
            phyPicoNo: item['pcp']['phy_pico_no'] ?? "",
            phyPicoNoLink: item['pcp']['phy_pico_no_link'] ?? "",
            phyPicoNoPgNo: item['pcp']['phy_pico_no_pg_no'] ?? 0,
            phyPicoStatus: item['pcp']['phy_pico_status'] ?? false,
            phyEmail: item['pcp']['phy_email'] ?? "",
            phyEmailLink: item['pcp']['phy_email_link'] ?? "",
            phyEmailPgNo: item['pcp']['phy_email_pg_no'] ?? 0,
            phyContact: item['pcp']['phy_contact'] ?? "",
            phyContactLink: item['pcp']['phy_contact_link'] ?? "",
            phyContactPgNo: item['pcp']['phy_contact_pg_no'] ?? 0,
            phyNPI: item['pcp']['phy_NPI'] ?? 0,
            phyUPI: item['pcp']['phy_UPI'] ?? "",
            phyUPILink: item['pcp']['phy_UPI_link'] ?? "",
            phyUPIPgNo: item['pcp']['phy_UPI_pg_no'] ?? 0,
            phyCity: item['pcp']['phy_city'] ?? "",
            phyCityLink: item['pcp']['phy_city_link'] ?? "",
            phyCityPgNo: item['pcp']['phy_city_pg_no'] ?? 0,
            phyFax: item['pcp']['phy_fax'] ?? "",
            phyFaxLink: item['pcp']['phy_fax_link'] ?? "",
            phyFaxPgNo: item['pcp']['phy_fax_pg_no'] ?? 0,
            phyNotes: item['pcp']['phy_notes'] ?? "",
            phyNotesLink: item['pcp']['phy_notes_link'] ?? "",
            phyNotesPgNo: item['pcp']['phy_notes_pg_no'] ?? 0,
            phyProtocols: item['pcp']['phy_protocols'] ?? "",
            phyProtocolsLink: item['pcp']['phy_protocols_link'] ?? "",
            phyProtocolsPgNo: item['pcp']['phy_protocols_pg_no'] ?? 0,
            phyState: item['pcp']['phy_state'] ?? "",
            phyStateLink: item['pcp']['phy_state_link'] ?? "",
            phyStatePgNo: item['pcp']['phy_state_pg_no'] ?? 0,
            phyStreet: item['pcp']['phy_street'] ?? "",
            phyStreetLink: item['pcp']['phy_street_link'] ?? "",
            phyStreetPgNo: item['pcp']['phy_street_pg_no'] ?? 0,
            phySuffix: item['pcp']['phy_suffix'] ?? "",
            phySuffixLink: item['pcp']['phy_suffix_link'] ?? "",
            phySuffixPgNo: item['pcp']['phy_suffix_pg_no'] ?? 0,
            phySuite: item['pcp']['phy_suite'] ?? "",
            phySuiteLink: item['pcp']['phy_suite_link'] ?? "",
            phySuitePgNo: item['pcp']['phy_suite_pg_no'] ?? 0,
            phyTrackingNotes: item['pcp']['phy_trackingNotes'] ?? "",
            phyTrackingNotesLink: item['pcp']['phy_trackingNotes_link'] ?? "",
            phyTrackingNotesPgNo: item['pcp']['phy_trackingNotes_pg_no'] ?? 0,
            phyVerificationDetails: item['pcp']['phy_verificationDetails'] ?? "",
            phyVerificationDetailsLink: item['pcp']['phy_verificationDetails_link'] ?? "",
            phyVerificationDetailsPgNo: item['pcp']['phy_verificationDetails_pg_no'] ?? 0,
            phyVerified: item['pcp']['phy_verified'] ?? false,
            phyZipCode: item['pcp']['phy_zipCode'] ?? "",
            phyZipCodeLink: item['pcp']['phy_zipCode_link'] ?? "",
            phyZipCodePgNo: item['pcp']['phy_zipCode_pg_no'] ?? 0,
          )
              : PCPModel(
            phyId: 0,
            phyFirstName: "",
            phyFirstNameLink: "",
            phyFirstNamePgNo: 0,
            phyLastName: "",
            phyLastNameLink: "",
            phyLastNamePgNo: 0,
            phyPicoNo: "",
            phyPicoNoLink: "",
            phyPicoNoPgNo: 0,
            phyPicoStatus: false,
            phyEmail: "",
            phyEmailLink: "",
            phyEmailPgNo: 0,
            phyContact: "",
            phyContactLink: "",
            phyContactPgNo: 0,
            phyNPI: 0,
            phyUPI: "",
            phyUPILink: "",
            phyUPIPgNo: 0,
            phyCity: "",
            phyCityLink: "",
            phyCityPgNo: 0,
            phyFax: "",
            phyFaxLink: "",
            phyFaxPgNo: 0,
            phyNotes: "",
            phyNotesLink: "",
            phyNotesPgNo: 0,
            phyProtocols: "",
            phyProtocolsLink: "",
            phyProtocolsPgNo: 0,
            phyState: "",
            phyStateLink: "",
            phyStatePgNo: 0,
            phyStreet: "",
            phyStreetLink: "",
            phyStreetPgNo: 0,
            phySuffix: "",
            phySuffixLink: "",
            phySuffixPgNo: 0,
            phySuite: "",
            phySuiteLink: "",
            phySuitePgNo: 0,
            phyTrackingNotes: "",
            phyTrackingNotesLink: "",
            phyTrackingNotesPgNo: 0,
            phyVerificationDetails: "",
            phyVerificationDetailsLink: "",
            phyVerificationDetailsPgNo: 0,
            phyVerified: false,
            phyZipCode: "",
            phyZipCodeLink: "",
            phyZipCodePgNo: 0,
          ),

          marketer: item['marketer'] != null
              ? MarketerModel(
            employeeId: item['marketer']['employeeId'] ?? 0,
            code: item['marketer']['code'] ?? '',
            firstName: item['marketer']['firstName'] ?? '',
            lastName: item['marketer']['lastName'] ?? '',
            expertise: item['marketer']['expertise'] ?? '',
            gender: item['marketer']['gender'] ?? '',
            imgurl: item['marketer']['imgurl'] ?? '',
            regOfficId: item['marketer']['regOfficId'] ?? '',
            onboardingStatus: item['marketer']['onboardingStatus'] ?? '',
            userId: item['marketer']['userId'] ?? 0,
            ssnNbr: item['marketer']['SSNNbr'] ?? '',
            address: item['marketer']['address'] ?? '',
            cityId: item['marketer']['cityId'] ?? 0,
            dateOfBirth: item['marketer']['dateOfBirth'] != null ? convertIsoToDayMonthYear(item['marketer']['dateOfBirth']) : '',
            departmentId: item['marketer']['departmentId'] ?? 0,
            emergencyContact: item['marketer']['emergencyContact'] ?? '',
            employeeTypeId: item['marketer']['employeeTypeId'] ?? 0,
            employment: item['marketer']['employment'] ?? '',
            personalEmail: item['marketer']['personalEmail'] ?? '',
            primaryPhoneNbr: item['marketer']['primaryPhoneNbr'] ?? '',
            secondryPhoneNbr: item['marketer']['secondryPhoneNbr'] ?? '',
            service: item['marketer']['service'] ?? '',
            status: item['marketer']['status'] ?? '',
            workEmail: item['marketer']['workEmail'] ?? '',
            workPhoneNbr: item['marketer']['workPhoneNbr'] ?? '',
            companyId: item['marketer']['companyId'] ?? 0,
            createdAt: item['marketer']['createdAt'] != null ? convertIsoToDayMonthYear(item['marketer']['createdAt']) : '',
            resumeurl: item['marketer']['resumeurl'] ?? '',
            covreage: item['marketer']['covreage'] ?? '',
            approved: item['marketer']['approved'] ?? false,
            terminationFlag: item['marketer']['terminationFlag'] ?? false,
            zoneId: item['marketer']['zoneId'] ?? 0,
            countryId: item['marketer']['countryId'] ?? 0,
            checkDate: item['marketer']['checkDate'] != null ? convertIsoToDayMonthYear(item['marketer']['checkDate']) : '',
            dateofResignation: item['marketer']['dateofResignation'] != null ?convertIsoToDayMonthYear(item['marketer']['dateofResignation']) : '',
            dateofTermination: item['marketer']['dateofTermination'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofTermination']) : '',
            finalAddress: item['marketer']['finalAddress'] ?? '',
            finalPayCheck: (item['marketer']['finalPayCheck'] ?? 0).toDouble(),
            grossPay: (item['marketer']['grossPay'] ?? 0).toDouble(),
            materials: item['marketer']['materials'] ?? '',
            methods: item['marketer']['methods'] ?? '',
            netPay: (item['marketer']['netPay'] ?? 0).toDouble(),
            reason: item['marketer']['reason'] ?? '',
            rehirable: item['marketer']['rehirable'] ?? '',
            type: item['marketer']['type'] ?? '',
            dateofHire: item['marketer']['dateofHire'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofHire']) : '',
            position: item['marketer']['position'] ?? '',
            driverLicenceNbr: item['marketer']['driverLicenceNbr'] ?? '',
            race: item['marketer']['race'] ?? '',
            rating: item['marketer']['rating'] ?? '',
            signatureURL: item['marketer']['signatureURL'] ?? '',
            countyId: item['marketer']['countyId'] ?? 0,
            active: item['marketer']['active'] ?? false,
            summary: item['marketer']['summary'] ?? '',
          )
              : MarketerModel(
            employeeId: 0,
            code: '',
            firstName: '',
            lastName: '',
            expertise: '',
            gender: '',
            imgurl: '',
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
            resumeurl: '',
            covreage: '',
            approved: false,
            terminationFlag: false,
            zoneId: 0,
            countryId: 0,
            checkDate: '',
            dateofResignation: '',
            dateofTermination: '',
            finalAddress: '',
            finalPayCheck: 0.0,
            grossPay: 0.0,
            materials: '',
            methods: '',
            netPay: 0.0,
            reason: '',
            rehirable: '',
            type: '',
            dateofHire: '',
            position: '',
            driverLicenceNbr: '',
            race: '',
            rating: '',
            signatureURL: '',
            countyId: 0,
            active: false,
            summary: '',
          ),

          disciplines: (item['disciplines'] as List).map((d) {
            return DisciplineModel(
              employeeTypeId: d['employeeTypeId'],
              employeeType: d['employeeType'],
              color: d['color'],
              abbreviation: d['abbreviation'],
              departmentId: d['DepartmentId'],
            );
          }).toList(),
          patientDiagnoses: (item['patientDiagnoses'] as List).map((d) {
            return PatientDiagnosesModel(
              rpt_dgn_id: d['dgn_id']??0,
              dgnName: d['dgn_name']??'',
              dgnCode: d['dgn_code']??'',
              fk_pt_id: d['fk_pt_id']??0,
              fk_dgn_id: d['fk_dgn_id']??0,
              rpt_pdgm: d['rpt_pdgm']??false,
              rpt_isPrimary: d['rpt_isPrimary']??false,
              color: d['color']??0,
            );
          }).toList(),
          insurance: (item['patientInsurance'] as List).map((d){
            return InsuranceModel(
              rptiId: d['rpti_id']??0,
              fkptId: d['fk_pt_id']??0,

              policy: d['rpti_policy']??'',
              policyLink: d['rpti_policy_link']??'',
              policyPgNo: d['rpti_policy_pg_no']??0,

              insuranceProvider: d['rpti_insurance_provider']??'',
              insuranceProviderLink: d['rpti_insurance_provider_link']??'',
              insuranceProviderPgNo: d['rpti_insurance_provider_pg_no']??0,

              insurancePlan: d['rpti_insurance_plan']??'',
              insurancePlanLink: d['rpti_insurance_plan_link']??'',
              insurancePlanPgNo: d['rpti_insurance_plan_pg_no']??0,

              eligibility: d['rpti_eligibility']??false,
              authorization: d['rpti_authorization']??false,

              lastCheckedTime: d['rpti_last_checked_time']??'',

              category: d['rpti_category']??'',
              categoryLink: d['rpti_category_link']??'',
              categoryPgNo: d['rpti_category_pg_no']??0,

              city: d['rpti_city']??'',
              cityLink: d['rpti_city_link']??'',
              cityPgNo: d['rpti_city_pg_no']??0,

              comments: d['rpti_comments']??'',
              commentsLink: d['rpti_comments_link']??'',
              commentsPgNo: d['rpti_comments_pg_no']??0,

              contact: d['rpti_contact']??'',
              contactLink: d['rpti_contact_link']??'',
              contactPgNo: d['rpti_contact_pg_no']??0,

              effectiveFrom: d['rpti_effectiveFrom']??'',
              effectiveTo: d['rpti_effectiveTo']??'',

              email: d['rpti_email']??'',
              emailLink: d['rpti_email_link']??'',
              emailPgNo: d['rpti_email_pg_no']??0,

              groupName: d['rpti_groupName']??'',
              groupNameLink: d['rpti_groupName_link']??'',
              groupNamePgNo: d['rpti_groupName_pg_no']??0,

              groupNumber: d['rpti_groupNumber']??0,

              name: d['rpti_name']??'',
              nameLink: d['rpti_name_link']??'',
              namePgNo: d['rpti_name_pg_no']??0,

              state: d['rpti_state']??'',
              stateLink: d['rpti_state_link']??'',
              statePgNo: d['rpti_state_pg_no']??0,

              street: d['rpti_street']??'',
              streetLink: d['rpti_street_link']??'',
              streetPgNo: d['rpti_street_pg_no']??0,

              suite: d['rpti_suite']??'',
              suiteLink: d['rpti_suite_link']??'',
              suitePgNo: d['rpti_suite_pg_no']??0,

              type: d['rpti_type']??'',
              typeLink: d['rpti_type_link']??'',
              typePgNo: d['rpti_type_pg_no']??0,

              verified: d['rpti_verified']??false,

              zipcode: d['rpti_zipcode']??'',
              zipcodeLink: d['rpti_zipcode_link']??'',
              zipcodePgNo: d['rpti_zipcode_pg_no']??0,
            );
          }).toList(),
          potentialDuplicate: item['potential_duplicate'] ?? false,
          thresould: item['threshold'] ?? 0,
          allCliniciansAssigned: item['all_clinicians_assigned'] ?? false,
          detailedDisciplines: (item['detailedDisciplines'] as List).map((disc){
            // item['detailedDisciplines'] != null && item['detailedDisciplines'] is List
            return DetailedDiscipline(
              disciplineId: disc['disciplineId'] ?? 0,
              fkPtId: disc['fk_pt_id'] ?? 0,
              fkEmployeeTypeId: disc['fk_employeetypeId'] ?? 0,
              fkEmployeeId: disc['fk_employeeId'] ?? 0,
              notesToClinician: disc['notesToClinician'] ?? '',
              sentAsRequest: disc['sentAsRequest'] ?? false,
              employeeTypeId: disc['employeeTypeId'] ?? 0,
              employeeType: disc['employeeType'] ?? '',
              color: disc['color'] ?? '#FFFFFF',
              abbreviation: disc['abbreviation'] ?? '--',
              departmentId: disc['departmentId'] ?? 0,
              DepartmentId: disc['DepartmentId'] ?? 0,
              employeeId: disc['employeeId'] ?? 0,
              firstName: disc['firstName'] ?? '',
              lastName: disc['lastName'] ?? '',
              expertise: disc['expertise'] ?? '',
              imgUrl: disc['imgurl'] ?? '',
              userId: disc['userId'] ?? 0,
              empEmployeeTypeId: disc['emp_employeeTypeId'] ?? 0,
              companyId: disc['companyId'] ?? 0,
            );}).toList(),
        ));
        //  print("RPTI ID ::::::::::::::::::: ${item['patientInsurance']['rpti_id'].runtimeType}");
      }
      print("/////////Total records fetched from API non admit*******: ${itemsData.length}");
    }
    else {
      print("patient non admit error");
    }
    return itemsData;
  } catch (e) {
    print("error referral: $e");
    return itemsData;
  }
}








/// Eye button manager passing pt_id
Future<PatientModel> getPatientReffrealsDataUsingId({
  required BuildContext context,
  required int patientId
}) async {
  var itemsData;
  // String convertIsoToDayMonthYear(String isoDate) {
  //   // Parse ISO date string to DateTime object
  //   DateTime dateTime = DateTime.parse(isoDate);
  //
  //   // Create a DateFormat object to format the date
  //   DateFormat dateFormat = DateFormat('yyyy/MM/dd');
  //
  //   // Format the date into "dd mm yy" format
  //   String formattedDate = dateFormat.format(dateTime);
  //
  //   return formattedDate;
  // }

  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientRefferalsWithId(id: patientId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var item = response.data;
        String formatedTime =  DateFormat.jm().format( DateTime.parse(item['pt_refferal_date']));
        itemsData = PatientModel(
            ptId: item['pt_id'],
            ptFirstName: item['pt_first_name'] ?? '',
            ptLastName: item['pt_last_name'] ?? '',
            ptContactNo: item['pt_contact_no'] ?? '',
            ptZipCode: item['pt_zip_code'] ?? '',
            ptChartNo: item['pt_chart_no'] ?? 0,
            ptSummary: item['pt_summary'] ?? '',
            ptRefferalDate: convertIsoToDayMonthYear(item['pt_refferal_date']),
            fkSrvId: item['fk_srv_id'] ?? 0,
            fkPtPrimaryDiagnosis: item['fk_pt_primary_diagnosis'] ?? 0,
            fkPtSecondaryDiagnosis: List<int>.from(item['fk_pt_secondary_diagnosis'] ?? []),
            fkPtRefferalSource: item['fk_pt_refferal_source'] ?? 0,
            fkPtPcp: item['fk_pt_pcp'] ?? 0,
            fkPtMarketer: item['fk_pt_marketer'] ?? 0,
            fkPtDiscplines: List<int>.from(item['fk_pt_discplines'] ?? []),
            ptCoverageArea: item['pt_coverage_area'] ?? 0,
            isIntake: item['is_intake'] ?? false,
            intakeTime:  item['intake_time']?.toString(), // != null ? DateTime.tryParse(item['intake_time']) : null,
            isArchieved: item['is_archieved'] ?? false,
            archievedTime: item['archieved_time'] ?? "",// item['archieved_time'] != null ? DateTime.tryParse(item['archieved_time']) : null,
            // insuranceId: item['insurance_id'] ?? 0,
            createdAt: item['created_at'] ?? "",//DateTime.parse(item['created_at']),
            ptDateOfBirth: item['pt_date_of_birth'] ?? "",// DateTime.parse(item['pt_date_of_birth']),
            // ptImgUrl: item['pt_img_url'] ?? '',
            ptImgUrl: item['pt_img_url']?.toString() ?? '',
            fkempIdArchieved: item['fk_emp_id_archived'] ?? 0,
            fkRptiId: item['fk_rpti_id'] ?? 0,
            isSelfPay: item['is_selfPay'] ?? false,
            documentName: item['document_name'] ?? "",
            moveToScheduler: item['moveToScheduler'] ?? false,
            moveToSchedulerDatetime: item['moveToSchedulerDatetime'] ?? "" ,
            admitDateTime: item['admitDateTime'] ?? "",
            isNonAdmit:item['is_non_admit'] ?? false ,
            ptMRN: item['pt_MRN'] ?? 0,
            ptSOCDate: item['pt_SOC_date'] ?? "",
            ptSOCStatus: item['pt_SOC_status'] ?? false,
            potentialDischargeDate: item['potential_discharge_date'] ?? "",
            ptAddress: item['pt_address'] ?? "",
            ptMedicalNote: item['pt_medical_note'] ?? "",
            isDemographicFilled: item['is_demographic_filled'],
            isDocumentationUpload: item['is_documentation_upload'],
            isPrimaryInsuranceFilled: item['is_primaryInsurance_filled'],
            isPhysicianFilled: item['is_physician_filled'],
            isOrdersFilled: item['is_orders_filled'],
            isInitialContactFilled: item['is_initialContact_filled'],
            service: ServiceModel(
              srvId: item['service']['srv_id'] ?? 0,
              srvName: item['service']['srv_name'] ?? "",
              srvCode: item['service']['srv_code'] ?? "",
            ),
            referralSource: item['referralSource'] != null
                ? ReferralSourceModel(
              refSourceId: item['referralSource']['ref_source_id'] ?? 0,
              sourceName: item['referralSource']['source_name'] ?? "",
              description: item['referralSource']['description'] ?? "",
              referralSourceImgUrl: item['referralSource']['referral_source_img_url'] ?? "",
              documentName: item['referralSource']['documentName'] ?? "",
            )
                : ReferralSourceModel(
              refSourceId: 0,
              sourceName: "",
              description: "",
              referralSourceImgUrl: "",
              documentName: "",
            ),

            pcp: item['pcp'] != null
                ? PCPModel(
              phyId: item['pcp']['phy_id'] ?? 0,
              phyFirstName: item['pcp']['phy_first_name'] ?? "",
              phyFirstNameLink: item['pcp']['phy_first_name_link'] ?? "",
              phyFirstNamePgNo: item['pcp']['phy_first_name_pg_no'] ?? 0,
              phyLastName: item['pcp']['phy_last_name'] ?? "",
              phyLastNameLink: item['pcp']['phy_last_name_link'] ?? "",
              phyLastNamePgNo: item['pcp']['phy_last_name_pg_no'] ?? 0,
              phyPicoNo: item['pcp']['phy_pico_no'] ?? "",
              phyPicoNoLink: item['pcp']['phy_pico_no_link'] ?? "",
              phyPicoNoPgNo: item['pcp']['phy_pico_no_pg_no'] ?? 0,
              phyPicoStatus: item['pcp']['phy_pico_status'] ?? false,
              phyEmail: item['pcp']['phy_email'] ?? "",
              phyEmailLink: item['pcp']['phy_email_link'] ?? "",
              phyEmailPgNo: item['pcp']['phy_email_pg_no'] ?? 0,
              phyContact: item['pcp']['phy_contact'] ?? "",
              phyContactLink: item['pcp']['phy_contact_link'] ?? "",
              phyContactPgNo: item['pcp']['phy_contact_pg_no'] ?? 0,
              phyNPI: item['pcp']['phy_NPI'] ?? 0,
              phyUPI: item['pcp']['phy_UPI'] ?? "",
              phyUPILink: item['pcp']['phy_UPI_link'] ?? "",
              phyUPIPgNo: item['pcp']['phy_UPI_pg_no'] ?? 0,
              phyCity: item['pcp']['phy_city'] ?? "",
              phyCityLink: item['pcp']['phy_city_link'] ?? "",
              phyCityPgNo: item['pcp']['phy_city_pg_no'] ?? 0,
              phyFax: item['pcp']['phy_fax'] ?? "",
              phyFaxLink: item['pcp']['phy_fax_link'] ?? "",
              phyFaxPgNo: item['pcp']['phy_fax_pg_no'] ?? 0,
              phyNotes: item['pcp']['phy_notes'] ?? "",
              phyNotesLink: item['pcp']['phy_notes_link'] ?? "",
              phyNotesPgNo: item['pcp']['phy_notes_pg_no'] ?? 0,
              phyProtocols: item['pcp']['phy_protocols'] ?? "",
              phyProtocolsLink: item['pcp']['phy_protocols_link'] ?? "",
              phyProtocolsPgNo: item['pcp']['phy_protocols_pg_no'] ?? 0,
              phyState: item['pcp']['phy_state'] ?? "",
              phyStateLink: item['pcp']['phy_state_link'] ?? "",
              phyStatePgNo: item['pcp']['phy_state_pg_no'] ?? 0,
              phyStreet: item['pcp']['phy_street'] ?? "",
              phyStreetLink: item['pcp']['phy_street_link'] ?? "",
              phyStreetPgNo: item['pcp']['phy_street_pg_no'] ?? 0,
              phySuffix: item['pcp']['phy_suffix'] ?? "",
              phySuffixLink: item['pcp']['phy_suffix_link'] ?? "",
              phySuffixPgNo: item['pcp']['phy_suffix_pg_no'] ?? 0,
              phySuite: item['pcp']['phy_suite'] ?? "",
              phySuiteLink: item['pcp']['phy_suite_link'] ?? "",
              phySuitePgNo: item['pcp']['phy_suite_pg_no'] ?? 0,
              phyTrackingNotes: item['pcp']['phy_trackingNotes'] ?? "",
              phyTrackingNotesLink: item['pcp']['phy_trackingNotes_link'] ?? "",
              phyTrackingNotesPgNo: item['pcp']['phy_trackingNotes_pg_no'] ?? 0,
              phyVerificationDetails: item['pcp']['phy_verificationDetails'] ?? "",
              phyVerificationDetailsLink: item['pcp']['phy_verificationDetails_link'] ?? "",
              phyVerificationDetailsPgNo: item['pcp']['phy_verificationDetails_pg_no'] ?? 0,
              phyVerified: item['pcp']['phy_verified'] ?? false,
              phyZipCode: item['pcp']['phy_zipCode'] ?? "",
              phyZipCodeLink: item['pcp']['phy_zipCode_link'] ?? "",
              phyZipCodePgNo: item['pcp']['phy_zipCode_pg_no'] ?? 0,
            )
                : PCPModel(
              phyId: 0,
              phyFirstName: "",
              phyFirstNameLink: "",
              phyFirstNamePgNo: 0,
              phyLastName: "",
              phyLastNameLink: "",
              phyLastNamePgNo: 0,
              phyPicoNo: "",
              phyPicoNoLink: "",
              phyPicoNoPgNo: 0,
              phyPicoStatus: false,
              phyEmail: "",
              phyEmailLink: "",
              phyEmailPgNo: 0,
              phyContact: "",
              phyContactLink: "",
              phyContactPgNo: 0,
              phyNPI: 0,
              phyUPI: "",
              phyUPILink: "",
              phyUPIPgNo: 0,
              phyCity: "",
              phyCityLink: "",
              phyCityPgNo: 0,
              phyFax: "",
              phyFaxLink: "",
              phyFaxPgNo: 0,
              phyNotes: "",
              phyNotesLink: "",
              phyNotesPgNo: 0,
              phyProtocols: "",
              phyProtocolsLink: "",
              phyProtocolsPgNo: 0,
              phyState: "",
              phyStateLink: "",
              phyStatePgNo: 0,
              phyStreet: "",
              phyStreetLink: "",
              phyStreetPgNo: 0,
              phySuffix: "",
              phySuffixLink: "",
              phySuffixPgNo: 0,
              phySuite: "",
              phySuiteLink: "",
              phySuitePgNo: 0,
              phyTrackingNotes: "",
              phyTrackingNotesLink: "",
              phyTrackingNotesPgNo: 0,
              phyVerificationDetails: "",
              phyVerificationDetailsLink: "",
              phyVerificationDetailsPgNo: 0,
              phyVerified: false,
              phyZipCode: "",
              phyZipCodeLink: "",
              phyZipCodePgNo: 0,
            ),

            marketer: item['marketer'] != null
                ? MarketerModel(
              employeeId: item['marketer']['employeeId'] ?? 0,
              code: item['marketer']['code'] ?? '',
              firstName: item['marketer']['firstName'] ?? '',
              lastName: item['marketer']['lastName'] ?? '',
              expertise: item['marketer']['expertise'] ?? '',
              gender: item['marketer']['gender'] ?? '',
              imgurl: item['marketer']['imgurl'] ?? '',
              regOfficId: item['marketer']['regOfficId'] ?? '',
              onboardingStatus: item['marketer']['onboardingStatus'] ?? '',
              userId: item['marketer']['userId'] ?? 0,
              ssnNbr: item['marketer']['SSNNbr'] ?? '',
              address: item['marketer']['address'] ?? '',
              cityId: item['marketer']['cityId'] ?? 0,
              dateOfBirth: item['marketer']['dateOfBirth'] != null ? convertIsoToDayMonthYear(item['marketer']['dateOfBirth']) : '',
              departmentId: item['marketer']['departmentId'] ?? 0,
              emergencyContact: item['marketer']['emergencyContact'] ?? '',
              employeeTypeId: item['marketer']['employeeTypeId'] ?? 0,
              employment: item['marketer']['employment'] ?? '',
              personalEmail: item['marketer']['personalEmail'] ?? '',
              primaryPhoneNbr: item['marketer']['primaryPhoneNbr'] ?? '',
              secondryPhoneNbr: item['marketer']['secondryPhoneNbr'] ?? '',
              service: item['marketer']['service'] ?? '',
              status: item['marketer']['status'] ?? '',
              workEmail: item['marketer']['workEmail'] ?? '',
              workPhoneNbr: item['marketer']['workPhoneNbr'] ?? '',
              companyId: item['marketer']['companyId'] ?? 0,
              createdAt: item['marketer']['createdAt'] != null ? convertIsoToDayMonthYear(item['marketer']['createdAt']) : '',
              resumeurl: item['marketer']['resumeurl'] ?? '',
              covreage: item['marketer']['covreage'] ?? '',
              approved: item['marketer']['approved'] ?? false,
              terminationFlag: item['marketer']['terminationFlag'] ?? false,
              zoneId: item['marketer']['zoneId'] ?? 0,
              countryId: item['marketer']['countryId'] ?? 0,
              checkDate: item['marketer']['checkDate'] != null ? convertIsoToDayMonthYear(item['marketer']['checkDate']) : '',
              dateofResignation: item['marketer']['dateofResignation'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofResignation']) : '',
              dateofTermination: item['marketer']['dateofTermination'] != null ? convertIsoToDayMonthYear(item['marketer']['dateofTermination']) : '',
              finalAddress: item['marketer']['finalAddress'] ?? '',
              finalPayCheck: (item['marketer']['finalPayCheck'] ?? 0).toDouble(),
              grossPay: (item['marketer']['grossPay'] ?? 0).toDouble(),
              materials: item['marketer']['materials'] ?? '',
              methods: item['marketer']['methods'] ?? '',
              netPay: (item['marketer']['netPay'] ?? 0).toDouble(),
              reason: item['marketer']['reason'] ?? '',
              rehirable: item['marketer']['rehirable'] ?? '',
              type: item['marketer']['type'] ?? '',
              dateofHire: item['marketer']['dateofHire']!=null?convertIsoToDayMonthYear(item['marketer']['dateofHire']):'',
              position: item['marketer']['position'] ?? '',
              driverLicenceNbr: item['marketer']['driverLicenceNbr'] ?? '',
              race: item['marketer']['race'] ?? '',
              rating: item['marketer']['rating'] ?? '',
              signatureURL: item['marketer']['signatureURL'] ?? '',
              countyId: item['marketer']['countyId'] ?? 0,
              active: item['marketer']['active'] ?? false,
              summary: item['marketer']['summary'] ?? '',
            )
                : MarketerModel(
              employeeId: 0,
              code: '',
              firstName: '',
              lastName: '',
              expertise: '',
              gender: '',
              imgurl: '',
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
              resumeurl: '',
              covreage: '',
              approved: false,
              terminationFlag: false,
              zoneId: 0,
              countryId: 0,
              checkDate: '',
              dateofResignation: '',
              dateofTermination: '',
              finalAddress: '',
              finalPayCheck: 0.0,
              grossPay: 0.0,
              materials: '',
              methods: '',
              netPay: 0.0,
              reason: '',
              rehirable: '',
              type: '',
              dateofHire: '',
              position: '',
              driverLicenceNbr: '',
              race: '',
              rating: '',
              signatureURL: '',
              countyId: 0,
              active: false,
              summary: '',
            ),

            disciplines: (item['disciplines'] as List).map((d) {
              return DisciplineModel(
                employeeTypeId: d['employeeTypeId'],
                employeeType: d['employeeType'],
                color: d['color'],
                abbreviation: d['abbreviation'],
                departmentId: d['DepartmentId'],
              );
            }).toList(),
            patientDiagnoses: (item['patientDiagnoses'] as List).map((d) {
              return PatientDiagnosesModel(
                rpt_dgn_id: d['dgn_id']??0,
                dgnName: d['dgn_name']??'',
                dgnCode: d['dgn_code']??'',
                fk_pt_id: d['fk_pt_id']??0,
                fk_dgn_id: d['fk_dgn_id']??0,
                rpt_pdgm: d['rpt_pdgm']??false,
                rpt_isPrimary: d['rpt_isPrimary']??false,
                color: d['color']??0,
              );
            }).toList(),
            insurance: (item['patientInsurance'] as List).map((d){
              return InsuranceModel(
                rptiId: d['rpti_id'],
                fkptId: d['fk_pt_id'],

                policy: d['rpti_policy'],
                policyLink: d['rpti_policy_link'],
                policyPgNo: d['rpti_policy_pg_no'],

                insuranceProvider: d['rpti_insurance_provider'],
                insuranceProviderLink: d['rpti_insurance_provider_link'],
                insuranceProviderPgNo: d['rpti_insurance_provider_pg_no'],

                insurancePlan: d['rpti_insurance_plan'],
                insurancePlanLink: d['rpti_insurance_plan_link'],
                insurancePlanPgNo: d['rpti_insurance_plan_pg_no'],

                eligibility: d['rpti_eligibility'],
                authorization: d['rpti_authorization'],

                lastCheckedTime: d['rpti_last_checked_time'],

                category: d['rpti_category'],
                categoryLink: d['rpti_category_link'],
                categoryPgNo: d['rpti_category_pg_no'],

                city: d['rpti_city'],
                cityLink: d['rpti_city_link'],
                cityPgNo: d['rpti_city_pg_no'],

                comments: d['rpti_comments'],
                commentsLink: d['rpti_comments_link'],
                commentsPgNo: d['rpti_comments_pg_no'],

                contact: d['rpti_contact'],
                contactLink: d['rpti_contact_link'],
                contactPgNo: d['rpti_contact_pg_no'],

                effectiveFrom: d['rpti_effectiveFrom'],
                effectiveTo: d['rpti_effectiveTo'],

                email: d['rpti_email'],
                emailLink: d['rpti_email_link'],
                emailPgNo: d['rpti_email_pg_no'],

                groupName: d['rpti_groupName'],
                groupNameLink: d['rpti_groupName_link'],
                groupNamePgNo: d['rpti_groupName_pg_no'],

                groupNumber: d['rpti_groupNumber'],

                name: d['rpti_name'],
                nameLink: d['rpti_name_link'],
                namePgNo: d['rpti_name_pg_no'],

                state: d['rpti_state'],
                stateLink: d['rpti_state_link'],
                statePgNo: d['rpti_state_pg_no'],

                street: d['rpti_street'],
                streetLink: d['rpti_street_link'],
                streetPgNo: d['rpti_street_pg_no'],

                suite: d['rpti_suite'],
                suiteLink: d['rpti_suite_link'],
                suitePgNo: d['rpti_suite_pg_no'],

                type: d['rpti_type'],
                typeLink: d['rpti_type_link'],
                typePgNo: d['rpti_type_pg_no'],

                verified: d['rpti_verified'],

                zipcode: d['rpti_zipcode'],
                zipcodeLink: d['rpti_zipcode_link'],
                zipcodePgNo: d['rpti_zipcode_pg_no'],
              );
            }).toList(),
            potentialDuplicate: item['potential_duplicate'] ?? false,
            thresould: item['threshold'] ?? 0,
            allCliniciansAssigned: item['all_clinicians_assigned'] ?? false,
          detailedDisciplines: (item['detailedDisciplines'] is List)
              ? (item['detailedDisciplines'] as List).map((disc) {
            return DetailedDiscipline(
              disciplineId: disc['disciplineId'] ?? 0,
              fkPtId: disc['fk_pt_id'] ?? 0,
              fkEmployeeTypeId: disc['fk_employeetypeId'] ?? 0,
              fkEmployeeId: disc['fk_employeeId'] ?? 0,
              notesToClinician: disc['notesToClinician'] ?? '',
              sentAsRequest: disc['sentAsRequest'] ?? false,
              employeeTypeId: disc['employeeTypeId'] ?? 0,
              employeeType: disc['employeeType'] ?? '',
              color: disc['color'] ?? '#FFFFFF',
              abbreviation: disc['abbreviation'] ?? '',
              departmentId: disc['departmentId'] ?? 0,
              DepartmentId: disc['DepartmentId'] ?? 0,
              employeeId: disc['employeeId'] ?? 0,
              firstName: disc['firstName'] ?? '',
              lastName: disc['lastName'] ?? '',
              expertise: disc['expertise'] ?? '',
              imgUrl: disc['imgurl'] ?? '',
              userId: disc['userId'] ?? 0,
              empEmployeeTypeId: disc['emp_employeeTypeId'] ?? 0,
              companyId: disc['companyId'] ?? 0,
            );
          }).toList()
              : [],
        );
    
    } else {
      print("patient referrals prefill error");
    }
    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

/// referal patient patch
Future<ApiData> updateReferralPatient({
    required BuildContext context,
    required int patientId,
     bool? isIntake,
     bool? isArchived,
    required bool isUpdatePatiendData,
     String? firstName,
     String? lastName,
     String? contactNo,
     String? zipCode,
     String? summary,
     int? serviceId,
     int? insuranceId,
     bool? moveToSchedular,
     bool? isselfpay = false,
    List<int>? disciplineIds,
}) async {
  try {
    print('fk rpti ID ${insuranceId}');
    print('first name ${firstName}');
    print('Last name ${lastName}');
    print('pt_contact_no ${contactNo}');
    print('pt_zip_code ${zipCode}');
    print('summary ${summary}');
    print('fk_srv_id ${serviceId}');
    print('disciplineIds ${disciplineIds}');
    print('isselfpay ${isselfpay}');

    var response = await Api(context).patch(
      path: PatientRefferalsRepo.getPatientRefferalsWithId(id: patientId),
      data: isUpdatePatiendData == false? {
        "is_intake": isIntake,
        "is_archieved": isArchived,
        "moveToScheduler": moveToSchedular ?? false,
      } : insuranceId == 0 ?{
        "pt_first_name": firstName,
        "pt_last_name": lastName,
        "pt_contact_no": contactNo,
        "pt_zip_code": zipCode,
        "pt_summary": summary,
        "fk_srv_id":serviceId,
        "fk_pt_discplines":disciplineIds,
       // "fk_rpti_id":insuranceId,
        "is_selfPay":isselfpay
      } :{
        "pt_first_name": firstName,
        "pt_last_name": lastName,
        "pt_contact_no": contactNo,
        "pt_zip_code": zipCode,
        "pt_summary": summary,
        "fk_srv_id":serviceId,
        "fk_pt_discplines":disciplineIds,
        "fk_rpti_id":insuranceId,
        "is_selfPay":isselfpay
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient updated ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print(";;;;❌ Error 1");
      print(";;;;;;;;;;❗ Status code: ${response.statusCode}");
      print(";;;;;;;;;;;;❗ Response body: ${response.data}");
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// Services master
Future<List<ServicePatientReffralsData>> getReferealsServiceList({
  required BuildContext context,
}) async {
  List<ServicePatientReffralsData> itemsData = [];

  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getReffrealsServiceData(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(ServicePatientReffralsData(
            serviceId: item['srv_id']??0,
            serviceName: item['srv_name']??'',
            serviceCode: item['srv_code']??''));
      }
    } else {
      print("patient referrals Services error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

/// employee clinical
Future<List<EmployeeClinicalData>> getEmployeeClinicalInReffreals({
  required BuildContext context,
}) async {
  List<EmployeeClinicalData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getReffrealsEmployeeClinicalType(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(EmployeeClinicalData(
            emptypeId: item['employeeTypeId'] ?? 0,
            empType: item['employeeType'] ?? '',
            color: item['color'] ?? '',
            abbreviation: item['abbreviation'] ?? '',
            deptId: item['DepartmentId'] ?? 0
            ));
      }
    } else {
      print("patient referrals employee type error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}


/// insurance patient
Future<List<PatientInsurancesData>> getReffrealsPatientInsurance({
  required BuildContext context,
}) async {
  List<PatientInsurancesData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getReffrealsInsurance(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientInsurancesData(
            insurance_id: item['insurance_id']??0,
            insurance_policy: item['insurance_policy']??'',
            insurance_provider: item['insurance_provider']??'',///agency
            insurance_plan: item['insurance_plan']??''

        ));
      }
    } else {
      print("patient referrals insurance error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

/// Insurance patient prefill
Future<PatientInsurancesData> getReffrealsPatientInsurancePrefill({
  required BuildContext context,
  required int insuranceId
}) async {
  var itemsData;
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getReffrealsInsuranceWithId(id: insuranceId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
        itemsData = PatientInsurancesData(
            insurance_id: response.data['insurance_id']??0,
            insurance_policy: response.data['insurance_policy']??'',
            insurance_provider: response.data['insurance_provider']??'',
            insurance_plan: response.data['insurance_plan']??''

        );

    } else {
      print("patient referrals insurance prefill error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}



Future<List<PatientDocumentsData>> getReffrealsPatientDocuments({
  required BuildContext context,
  required int patientId,
}) async {
  List<PatientDocumentsData> itemsData = [];

  // ✅ safe parse — falls back to raw string if parsing fails instead of
  // silently producing a garbage date like "0180/10/08"
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '--';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return '--';
    final DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    return dateFormat.format(parsed);
  }

  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientDocument(patientId: patientId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(
          PatientDocumentsData(
            rptd_id: item['rptd_id'] ?? 0,
            fk_pt_id: item['fk_pt_id'] ?? 0,
            rptd_url: item['rptd_url'] ?? '',
            rptd_created_at: convertIsoToDayMonthYear(item['rptd_created_at']),
            // ✅ was reading rptd_id (wrong key + wrong type) — now reads the
            // actual rptd_created_by field, kept as String since API returns
            // "undefined " rather than a numeric id
            rptd_created_by: item['rptd_created_by']?.toString() ?? '--',
            documentName: item['document_name'] ?? "--",
            rptd_document_type: item['rptd_document_type'] ?? 0,
            rptd_content: item['rptd_content'] ?? "",
          ),
        );
      }
    } else {
      print("patient Document error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}



///patient-document/patient/{patientId}/{documentType}
Future<List<PatientDocumentsData>> getReffrealsPatientDocumentsByDocType({
  required BuildContext context,
  required int patientId,
  required int documentType,
}) async {
  List<PatientDocumentsData> itemsData = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate).toLocal(); // toLocal() if you want local timezone

    // Format date and time separated by a comma
    DateFormat dateFormat = DateFormat('yyyy/MM/dd, HH:mm:ss');

    // Format the datetime
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientDocumentByDocType(patientId: patientId,documentType: documentType),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientDocumentsData(
            rptd_id: item['rptd_id']??0,
            fk_pt_id: item['fk_pt_id']??0,
            rptd_url: item['rptd_url']??'',
            rptd_created_at: convertIsoToDayMonthYear(item['rptd_created_at'])??'',
            rptd_created_by: item['rptd_id']??0, documentName: item['document_name']??"--",
            rptd_document_type: item['rptd_document_type'] ?? 0,
            rptd_content: item['rptd_content'] ?? ""
        ));
      }
    }
    else {
      print("patient Document error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

///patient document billing attachment
Future<List<PatientDocumentsBillingData>> getReffrealsPatientDocumentsBillingAttachment({
  required BuildContext context,
  required int patientId,
}) async {
  List<PatientDocumentsBillingData> itemsData = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate).toLocal(); // toLocal() if you want local timezone

    // Format date and time separated by a comma
    DateFormat dateFormat = DateFormat('yyyy/MM/dd, HH:mm:ss');

    // Format the datetime
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientDocumentByDocType(patientId: patientId,documentType: FrontendConfigStore.data!.config.billingAttachment),
      // path: PatientRefferalsRepo.getPatientDocumentByDocType(patientId: patientId,documentType: AppConfig.billingAttachment),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientDocumentsBillingData(
            rptd_id: item['rptd_id']??0,
            fk_pt_id: item['fk_pt_id']??0,
            rptd_url: item['rptd_url']??'',
            rptd_created_at: convertIsoToDayMonthYear(item['rptd_created_at'])??'',
            rptd_created_by: item['rptd_id']??0, documentName: item['document_name']??"--",
            rptd_document_type: item['rptd_document_type'] ?? 0,
            rptd_content: item['rptd_content'] ?? ""
        ));
      }
    }
    else {
      print("patient Document error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}


/// patient document F2f get
Future<List<PatientDocumentsFtwoFData>> getReffrealsPatientDocumentsFaceTwoFace({
  required BuildContext context,
  required int patientId,
}) async {
  List<PatientDocumentsFtwoFData> itemsData = [];

  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientDocumentF2FIntake(patientId: patientId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientDocumentsFtwoFData(
          f2f_id: item['f2f_id'] ?? 0,
          fk_pt_id: item['fk_pt_id'] ?? 0,
          rptd_F2FDate: item['rptd_F2FDate'] ?? "",
          fk_marketerId: item['fk_marketerId'] ?? 0,
          rptd_visitNote: item['rptd_visitNote'],
          rptd_F2Fappointment: item['rptd_F2Fappointment'],
          documents: (item['documents'] as List).map((d) {
            return FTwoFDocumentsModel(
              f2f_doc_id: d['f2f_doc_id'] ?? 0,
              fk_f2f_id: d['fk_f2f_id'] ?? 0,
              f2f_doc_url: d['f2f_doc_url'] ?? "",
              f2f_doc_name: d['f2f_doc_name'] ?? "",
              f2f_doc_content: d['f2f_doc_content'] ?? "",
              // ✅ kept as RAW ISO string here — PatientDataScreen already
              // runs this through its own _formatDate(). Pre-formatting it
              // here caused a double-format bug where the screen's
              // _formatDate couldn't re-parse the already-formatted
              // "yyyy/MM/dd, HH:mm:ss" string and fell back to "--".
              f2f_doc_created_at: d['f2f_doc_created_at'] ?? "",
              f2f_doc_created_by: d['f2f_doc_created_by']?.toString() ?? "--",
            );
          }).toList(),
        ));
      }

      print("/////////Total records fetched from API: ${itemsData.length}");
    } else {
      print("patient referrals error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

///patient document Consent
Future<List<PatientDocumentsConsentData>> getReffrealsPatientDocumentsConsent({
  required BuildContext context,
  required int patientId,
  required int doctypeId,
}) async {
  List<PatientDocumentsConsentData> itemsData = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate).toLocal(); // toLocal() if you want local timezone

    // Format date and time separated by a comma
    DateFormat dateFormat = DateFormat('yyyy/MM/dd, HH:mm:ss');

    // Format the datetime
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientDocumentByDocType(patientId: patientId,documentType: doctypeId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientDocumentsConsentData(
            rptd_id: item['rptd_id']??0,
            fk_pt_id: item['fk_pt_id']??0,
            rptd_url: item['rptd_url']??'',
            rptd_created_at: convertIsoToDayMonthYear(item['rptd_created_at'])??'',
            rptd_created_by: item['rptd_id']??0, documentName: item['document_name']??"--",
            rptd_document_type: item['rptd_document_type'] ?? 0,
            rptd_content: item['rptd_content'] ?? ""

        ));
      }
    }
    else {
      print("patient Document error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

/// Add Patient documents
Future<ApiData> postReferralPatientDocuments(
    {
      required BuildContext context,
      required int fk_pt_id,
     // required String document_name,
      //required int rptd_created_by,
      int? rptd_document_type,
      required String rptd_content,

    }) async {
  try {
    var response = await Api(context).post(
      path: PatientRefferalsRepo.addPatientDocument(),
      data: {
        "fk_pt_id": fk_pt_id,
       // "document_name": document_name,
        "rptd_document_type": rptd_document_type,
        "rptd_content": rptd_content,
      }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Document added ");
      // orgDocumentGet(context);
      var uploadResponse = response.data;
      int rptd_id = uploadResponse['rptd_id'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          rptd_id: rptd_id);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


/// delete document
Future<ApiData> deletePatientDocument(
    {
      required BuildContext context,
      required int docId,
    }) async {
  try {
    var response = await Api(context).delete(
        path: PatientRefferalsRepo.deletePatientDocument(id: docId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Document deleted ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

/// delete document
Future<ApiData> deleteFTwoFDocument(
    {
      required BuildContext context,
      required int id,
    }) async {
  try {
    var response = await Api(context).delete(
      path: PatientRefferalsRepo.deleteF2FDocument(id: id),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("F2F Document deleted ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
/// patient document upload base64
Future<ApiData> uploadPatientReffrelsDocuments({
  required BuildContext context,
  required int rptd_id,
  required dynamic documentFile,
  required String documentName,
  String? expiryDate
}) async {
  try {
    String documents = await
    AppFilePickerBase64.getEncodeBase64(
        bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path: PatientRefferalsRepo.attachPatientDocument(rptd_id: rptd_id),
      data: {
        'base64':documents,
        "documentName":documentName
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Documents uploded intake");
      // orgDocumentGet(context);
      //var uploadResponse = response.data;
     // int documentId = uploadResponse['employeeDocumentId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage! );
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


/// Marketer data
Future<List<PatientMarketerData>> getMarketerWithDeptId({
  required BuildContext context,
  required int deptId
}) async {
  List<PatientMarketerData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getMarketerIdWithData(deptId: deptId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientMarketerData(
            employeeId: item['employeeId']??0,
            firstName: item['firstName']??'--',
            lastName: item['lastName']??'--',
            departmentId: item['departmentId']??0, employeeTypeId: item['employeeTypeId']??0
        ));
      }
    }
    else {
      print("Marketer data error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

/// Patient diagnosis

Future<List<PatientDiagnosisWithIdData>> getPatientDiagnosisData({
  required BuildContext context,
  required int ptId
}) async {
  List<PatientDiagnosisWithIdData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientDiagnosisWithPtId(ptId: ptId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientDiagnosisWithIdData(
            dgnId: item['rpt_dgn_id']??0,
            ptId: item['fk_pt_id']??0,
            fkDgnId: item['fk_dgn_id']??0,
            pdgm: item['rpt_pdgm']??false,
            isPrimary: item['rpt_isPrimary']??false,
            dgnName: item['dgn_name']??'',
            dgnCode: item['dgn_code']??'',
            colorId: item['color']??0
        ));
      }
    }
    else {
      print("Diagnosis data error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

Future<ApiData> addPatientDiagnosis(
    {
      required BuildContext context,
      required int dgnId,
      required int fk_pt_id,

    }) async {
  try {
    var response = await Api(context).post(
        path: PatientRefferalsRepo.addPatientDiagnosis(),
        data: {
          "fk_pt_id": fk_pt_id,
          "fk_dgn_id": dgnId,
          "rpt_pdgm": false,
          "rpt_isPrimary": false
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Diagnosis added ");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } on DioException catch (e) {
    print("DioException $e");
    final serverMessage = e.response?.data is Map ? e.response?.data['message'] : null;
    return ApiData(
      statusCode: e.response?.statusCode ?? 404,
      success: false,
      message: serverMessage ?? AppString.somethingWentWrong,
    );
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
Future<ApiData> patchDiagnosisData(
    {
      required BuildContext context,
      required int recordId,
      required int dgnId,
      required int fk_pt_id,

    }) async {
  try {
    var response = await Api(context).patch(
        path: PatientRefferalsRepo.patchPatientDiagnosis(id: recordId),
        data: {
          "fk_pt_id": fk_pt_id,
          "fk_dgn_id": dgnId,
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Diagnosis Updated ");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}



///referal dd
Future<List<ReferralSourcesData>> getReferalSourceDD({
  required BuildContext context,

}) async {
  List<ReferralSourcesData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getReferalpath(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(ReferralSourcesData(
          refsouid: item['ref_source_id']??0,
          sourcename: item['source_name']??'--',
          description: item['description']??'--',
          imgurl: item['referral_source_img_url']??'--',
          docname: item['documentName']??'--',

        ));
      }
    }
    else {
      print("Marketer data error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}


///f2f/add
Future<ApiData> F2FAddDocuments({
  required BuildContext context,
  required int fk_pt_id,
  required String rptd_F2FDate,
  required int fk_marketerId,
  required String rptd_visitNote,
  required String rptd_F2Fappointment,
  String? expiryDate
}) async {
  try {
    // String documents = await
    // AppFilePickerBase64.getEncodeBase64(
    //     bytes: documentFile);
    // print("File :::${documents}" );
    var response = await Api(context).post(
      path: PatientRefferalsRepo.addF2F(),
      data: {
        'fk_pt_id':fk_pt_id,
        'rptd_F2FDate':rptd_F2FDate,
        'fk_marketerId':fk_marketerId,
        'rptd_visitNote':rptd_visitNote,
        "rptd_F2Fappointment":rptd_F2Fappointment
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("f2f add");
      // orgDocumentGet(context);
      var uploadResponse = response.data;
      int documentId = uploadResponse['f2f_id'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          f2f_id: documentId);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///f2f/document/add
Future<ApiData> uploadF2FDocumentsAdd({
  required BuildContext context,
  required int fk_f2f_id,
  required String f2f_doc_url,
  required String f2f_doc_name,
  required String f2f_doc_content,
}) async {
  try {
    // String documents = await
    // AppFilePickerBase64.getEncodeBase64(
    //     bytes: documentFile);
   // print("File :::${documents}" );
    var response = await Api(context).post(
      path: PatientRefferalsRepo.addDocumentF2FAdd(),
      data: {
        'fk_f2f_id':fk_f2f_id,
        "f2f_doc_url":f2f_doc_url,
        "f2f_doc_name":f2f_doc_name,
        "f2f_doc_content": f2f_doc_content,
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("F2f Documents 2nd post uploded intake");
      // orgDocumentGet(context);
      var uploadResponse = response.data;
      int documentId = uploadResponse['f2f_doc_id'];
      print("Upload Document f2f Response Data: ${response.data}");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          f2f_doc_id: documentId,);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}




/// f2f document upload base64
Future<ApiData> uploadF2FDocumentsBase64({
  required BuildContext context,
  required int f2f_doc_id,
  required dynamic documentFile,
  required String documentName,
}) async {
  try {
    String documents = await
    AppFilePickerBase64.getEncodeBase64(
        bytes: documentFile);
    print("File :::${documents}" );
    var response = await Api(context).post(
      path: PatientRefferalsRepo.addDocumentF2FAttach(f2f_doc_id: f2f_doc_id),
      data: {
        'base64':documents,
        "documentName":documentName
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("F2F Documents uploded base 64");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage! );
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}






/// special order
Future<List<SpacialOrderData>> getSpecialOrder({
  required BuildContext context,
}) async {
  List<SpacialOrderData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getspecialorderpath(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(SpacialOrderData(
            spcialorderid: item['specialOrderId'] ?? 0,
            spcialordername: item['specialorderName'] ?? '',
            description: item['description'] ?? '',
            createdat: item['createdAt'] ?? '',
            updatedat: item['updatedAt'] ?? ''
        ));
      }
    } else {
      print("special order type error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}




///post
Future<ApiData> postOrderPatient({
  required BuildContext context,
  required int patientid,
  required List<int> specialOrderId,
  required String dateReceived,
  required String orderdate,
  required List<int> ptDisciplines,
  required int merkatereid,
  required int refersourceid,
  required String casemanger,
  required String trackingnote,
  required bool ordersignature,
} ) async {
  try {
    var response = await Api(context).post(
      path: PatientRefferalsRepo.addPatientorder(), // Replace with your actual endpoint
      data: {
        "pt_id": patientid,
        "specialOrderId": specialOrderId,
        "dateReceived": dateReceived,      //"${effectiveDate}T00:00:00Z"
        "orderDate": orderdate ,
        "pt_disciplines": ptDisciplines,
        "fk_marketerId": merkatereid,
        "fk_ref_source_id": refersourceid,
        "caseManager": casemanger,
        "trackingNotes": trackingnote,
        "ordersSignedDate": ordersignature,
      },
    );
    print("📥 Received response:");
    print("Status Code: ${response.statusCode}");
    print("Response Data: ${response.data}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Order posted successfully");

      var responseData = response.data;

      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
        banckingId: responseData['orderId'], // Adjust key if needed
      );
    } else {
      print("Order post failed: ${response.statusCode}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? "Something went wrong",
      );
    }
  } catch (e) {
    print("Error posting order: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}

///order patch
Future<ApiData> patchOrderbyOrderID({
  required BuildContext context,
  required int orderId, // Pass the order ID here
  required int patientid,
  required List<int> specialOrderId,
  required String dateReceived,
  required String orderdate,
  required List<int> ptDisciplines,
  required int merkatereid,
  required int refersourceid,
  required String casemanger,
  required String trackingnote,
  required bool ordersignature,
}) async {
  try {
    var response = await Api(context).patch( // Use PATCH method
      path: PatientRefferalsRepo.updateorderId(id: orderId), // Pass orderId into the endpoint
      data: {
        "pt_id": patientid,
        "specialOrderId": specialOrderId,
        "dateReceived": dateReceived,
        "orderDate": orderdate,
        "pt_disciplines": ptDisciplines,
        "fk_marketerId": merkatereid,
        "fk_ref_source_id": refersourceid,
        "caseManager": casemanger,
        "trackingNotes": trackingnote,
        "ordersSignedDate": ordersignature,
      },
    );

    print("📥 Received response:");
    print("Status Code: ${response.statusCode}");
    print("Response Data: ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Order updated successfully");

      var responseData = response.data;

      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage ?? "Success",
        banckingId: responseData['orderId'], // adjust if needed
      );
    } else {
      print("Order update failed: ${response.statusCode}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'] ?? "Something went wrong",
      );
    }
  } catch (e) {
    print("Error updating order: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}





///order prefill
Future<List<PatientOrderData>> getPatientOrderprifill({
  required BuildContext context,
  required int patientId,
}) async {
  // Format ISO date string to yyyy/MM/dd
  String convertIsoToDayMonthYear(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy/MM/dd').format(dateTime);
    } catch (_) {
      return '';
    }
  }

  List<PatientOrderData> itemsData = [];

  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getPatientorderbyid(pt_id: patientId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        // ✅ Use correct snake_case keys from the API
        String formattedReceivedDate = convertIsoToDayMonthYear(item['date_received']);
        String formattedOrderDate = convertIsoToDayMonthYear(item['order_date']);

        // 🔎 Debug (optional)
        print("📅 Received Date: $formattedReceivedDate");
        print("📅 Order Date: $formattedOrderDate");

        itemsData.add(PatientOrderData(
          orderId: item['order_id'] ?? 0,
          patientId: item['pt_id'] ?? 0,
          specialOrderIds: List<int>.from(item['special_order_ids'] ?? []),
          dateReceived: formattedReceivedDate,
          orderDate: formattedOrderDate,
          ptDisciplines: List<int>.from(item['pt_disciplines'] ?? []),
          marketerId: item['fk_marketer_id'] ?? 0,
          referralSourceId: item['fk_ref_source_id'] ?? 0,
          caseManager: CaseManager(
            caseManager: item['case_manager']['caseManager'] ?? "",
            caseManagerLink: item['case_manager']['caseManager_link'] ?? "",
            caseManagerPgNo: item['case_manager']['caseManager_pg_no'] ?? 0,
          ),
          trackingNotes: TrackingNotes(
            trackingNotes: item['tracking_notes']['trackingNotes'] ?? "",
            trackingNotesLink: item['tracking_notes']['trackingNotes_link'] ?? "",
            trackingNotesPgNo: item['tracking_notes']['trackingNotes_pg_no'] ?? 0,
          ),
          createdAt: item['created_at'],
          updatedAt: item['updated_at'],
          ordersSignedDate: item['orders_signed_date'] ?? false,
        ));
      }
    } else {
      print("⚠️ Failed to fetch patient orders: ${response.statusCode}");
    }

    return itemsData;
  } catch (e) {
    print("❌ Error fetching patient order form: $e");
    return itemsData;
  }
}




/// intake nonAdmit patch
Future<ApiData> updateNonAdmitPatient({
  required BuildContext context,
  required int patientId,
  bool? isIntake,

  bool? isNotAdmit,

}) async {
  try {
    var response = await Api(context).patch(
      path: PatientRefferalsRepo.getPatientRefferalsWithId(id: patientId),
      data: {
        "is_intake": isIntake,
        "is_non_admit": isNotAdmit,
      }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient updated ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}



/// referal patient patch disciplain
Future<ApiData> updateReferralPatientdisciplain({
  required BuildContext context,
  required int patientId,
  List<int>? disciplineIds,
}) async {
  try {
    var response = await Api(context).patch(
      path: PatientRefferalsRepo.getPatientRefferalsWithId(id: patientId),
      data: {
        "fk_pt_discplines":disciplineIds,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient updated ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print(";;;;❌ Error 1");
      print(";;;;;;;;;;❗ Status code: ${response.statusCode}");
      print(";;;;;;;;;;;;❗ Response body: ${response.data}");
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}


///self pay
Future<ApiData> updateReferralPatientselfpay({
  required BuildContext context,
  required int patientId,
  bool? isselfpay,
}) async {
  try {
    var response = await Api(context).patch(
      path: PatientRefferalsRepo.getPatientRefferalsWithId(id: patientId),
      data: {
        "is_selfPay":isselfpay
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" self pay Patient updated ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print(";;;;❌ Error 1");
      print(";;;;;;;;;;❗ Status code: ${response.statusCode}");
      print(";;;;;;;;;;;;❗ Response body: ${response.data}");
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}

///insurance
Future<ApiData> updateReferralPatientInsuranceRpti({
  required BuildContext context,
  required int patientId,
  required int fkrptiID,
}) async {
  try {
    var response = await Api(context).patch(
      path: PatientRefferalsRepo.getPatientRefferalsWithId(id: patientId),
      data: {
        "fk_rpti_id": fkrptiID
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(" Insurance Patient updated ");
      // orgDocumentGet(context);
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    } else {
      print(";;;;❌ Error 1");
      print(";;;;;;;;;;❗ Status code: ${response.statusCode}");
      print(";;;;;;;;;;;;❗ Response body: ${response.data}");
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}