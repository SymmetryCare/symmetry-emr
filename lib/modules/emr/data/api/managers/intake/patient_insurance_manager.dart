import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/base64/encode_decode_base64.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/intake/patient_insurance_repo.dart';

Future<List<PatientInsuranceDocumentData>> getPatientEmergencyContact({
  required BuildContext context,
  required int ptId,
  required bool isPrimary
}) async {
  List<PatientInsuranceDocumentData> itemsList = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try {
    final response = await Api(context).get(path: PatientInsuranceRepo.getPatientInsuranceDocumentsWithPtId(ptId: ptId, isPrimary: isPrimary));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PatientInsuranceDocumentData(
            insuranceDocumentId: item['insuranceDocumentId']??0,
            ptId: item['fk_pt_id']??0,
            docUrl: item['insuranceUrl']??'',
            isPrimary: item['is_primary']??false,
            docName: item['document_name']??'',
            createdAt: DateTime.parse(item['insuranceCreatedAt']),
            createdBy: item['insuranceCreatedBy']??'--',
            updatedAt: item['insuranceUpdatedAt'] != null ? convertIsoToDayMonthYear(item['insuranceUpdatedAt']) :'0000-00-00T00:00:00.000Z',
            updatedBy: item['insuranceUpdatedBy']??'--',

        ));
      }
    } else {
      print('Api Error');
    }
   // print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<PatientSecondInsuranceDocumentData>> getPatientInsuranceDoc({
  required BuildContext context,
  required int ptId,
}) async {
  List<PatientSecondInsuranceDocumentData> itemsList = [];
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }
  try {
    final response = await Api(context).get(path: PatientInsuranceRepo.getPatientInsuranceSeconfDocumentsWithPtId(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PatientSecondInsuranceDocumentData(
          insuranceDocumentId: item['insuranceDocumentId']??0,
          ptId: item['fk_pt_id']??0,
          docUrl: item['insuranceUrl']??'',
          isPrimary: item['is_primary']??false,
          docName: item['document_name']??'',
          createdAt: DateTime.parse(item['insuranceCreatedAt']),
          createdBy: item['insuranceCreatedBy']??'--',
          updatedAt: item['insuranceUpdatedAt'] != null ? convertIsoToDayMonthYear(item['insuranceUpdatedAt']) :'0000-00-00T00:00:00.000Z',
          updatedBy: item['insuranceUpdatedBy']??'--',

        ));
      }
    } else {
      print('Api Error');
    }
    // print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


Future<ApiData> addPatientInsuranceDocuments(
    {
      required BuildContext context,
      required int ptId,
      required String documentUrl,
      required String documentName,
      required bool isPrimary,
    }) async {
  try {
    var response = await Api(context).post(
      path: PatientInsuranceRepo.addPatientInsuranceDocuments(),
      data: {
        "fk_pt_id": ptId,
        "insuranceUrl": documentUrl,
        "document_name": documentName,
        "is_primary": isPrimary
      },
    );
    print('Response add::::${response}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient insurance document created ");
      // orgDocumentGet(context);
      var doumentId = response.data;
      int insuranceDocumentId = doumentId['insuranceDocumentId'];
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          patientInsuranceDocId:insuranceDocumentId);
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

Future<ApiData> uploadPatientInsuranceDocuments({
  required BuildContext context,
  required int documentId,
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
      path: PatientInsuranceRepo.attachPatientInsuranceDocuments(documentid: documentId),
      data: {
        'base64':documents,
        "documentName":documentName
      },
    );
    print("Response ${response.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient insurance document uploaded");
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


Future<ApiData> deletePatientInsuranceDocument(
    {
      required BuildContext context,
      required int documentId,
    }) async {
  try {
    var response = await Api(context).delete(
      path: PatientInsuranceRepo.deletePatientInsuranceDocuments(documentid: documentId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient insurance document deleted");
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

/// insurance info
Future<List<PatientInsuranceInfoData>> getPatientInsuranceinfo({
  required BuildContext context,
  required int ptId
}) async {
  List<PatientInsuranceInfoData> itemsList = [];
  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }
  try {
    final response = await Api(context).get(path: PatientInsuranceRepo.getPatientInsuranceInfo(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data){
        print('rpti id type ${item['rpti_id'].runtimeType}');
        print('rpti id type ${item['rpti_id']}');
        itemsList.add(PatientInsuranceInfoData(
            rptiId: item['rpti_id']??0,
            fkPtId: item['fk_pt_id']??0,
            policy: Policy(
                rptiPolicy: item['policy']['rpti_policy'] ?? "",
                rptiPolicyLink: item['policy']['rpti_policy_link'] ?? "",
                rptiPolicyPgNo: item['policy']['rpti_policy_pg_no'] ?? 0),

            insuranceProvider: InsuranceProvider(rptiInsuranceProvider: item['insurance_provider']['rpti_insurance_provider'] ?? "",
                rptiInsuranceProviderLink: item['insurance_provider']['rpti_insurance_provider_link'] ?? "",
                rptiInsuranceProviderPgNo: item['insurance_provider']['rpti_insurance_provider_pg_no'] ?? 0),

            insurancePlan: InsurancePlan(rptiInsurancePlan: item['insurance_plan']['rpti_insurance_plan'] ?? "",
                rptiInsurancePlanLink: item['insurance_plan']['rpti_insurance_plan_link'] ?? "",
                rptiInsurancePlanPgNo: item['insurance_plan']['rpti_insurance_plan_pg_no'] ?? 0),

            rptiEligibility: item['rpti_eligibility']??false,
            rptiAuthorization: item['rpti_authorization']??false,
            rptiLastCheckedTime: item['rpti_last_checked_time'] == null ? '' : convertIsoToDayMonthYear(item['rpti_last_checked_time']),

            category: Category(rptiCategory: item['category']['rpti_category'] ?? "",
                rptiCategoryLink: item['category']['rpti_category_link'] ?? "",
                rptiCategoryPgNo: item['category']['rpti_category_pg_no'] ?? 0),

            city: City(rptiCity: item['city']['rpti_city'] ?? "",
                rptiCityLink: item['city']['rpti_city_link'] ?? "",
                rptiCityPgNo: item['city']['rpti_city_pg_no'] ?? 0),

            comments: Comments(rptiComments: item['comments']['rpti_comments'] ?? "",
                rptiCommentsLink: item['comments']['rpti_comments_link'] ?? "",
                rptiCommentsPgNo: item['comments']['rpti_comments_pg_no'] ?? 0,),

          contact: Contact(rptiContact: item['contact']['rpti_contact'] ?? "",
              rptiContactLink: item['contact']['rpti_contact_link'] ?? "",
              rptiContactPgNo: item['contact']['rpti_contact_pg_no'] ?? 0),

          rptiEffectiveFrom: item['rpti_effectiveFrom'] == null ? '' : convertIsoToDayMonthYear(item['rpti_effectiveFrom']),
          rptiEffectiveTo: item['rpti_effectiveTo'] == null ? '' : convertIsoToDayMonthYear(item['rpti_effectiveTo']),

          groupName: GroupName(rptiGroupName: item['group_name']['rpti_groupName'] ?? "",
              rptiGroupNameLink: item['group_name']['rpti_groupName_link'] ?? "",
              rptiGroupNamePgNo: item['group_name']['rpti_groupName_pg_no'] ?? 0),

          groupNumber: GroupNumber(rptiGroupNumber: item['group_number']['rpti_groupNumber'] ?? 0,
              rptiGroupNumberLink: item['group_number']['rpti_groupNumber_link'] ?? "",
              rptiGroupNumberPgNo: item['group_number']['rpti_groupNumber_pg_no'] ?? 0),

          email: Email(rptiEmail: item['email']['rpti_email'] ?? "",
              rptiEmailLink: item['email']['rpti_email_link'] ?? "",
              rptiEmailPgNo: item['email']['rpti_email_pg_no'] ?? 0),

          name: Name(rptiName: item['name']['rpti_name'] ?? "",
                rptiNameLink: item['name']['rpti_name_link'] ?? "",
                rptiNamePgNo: item['name']['rpti_name_pg_no'] ?? 0),

            type: Type(rptiType: item['type']['rpti_type'] ?? "",
                rptiTypeLink: item['type']['rpti_type_link'] ?? "",
                rptiTypePgNo: item['type']['rpti_type_pg_no'] ?? 0),

            street: Street(rptiStreet: item['street']['rpti_street'] ?? "",
                rptiStreetLink: item['street']['rpti_street_link'] ?? "",
                rptiStreetPgNo: item['street']['rpti_street_pg_no'] ?? 0),

            suite: Suite(rptiSuite: item['suite']['rpti_suite'] ?? "",
                rptiSuiteLink: item['suite']['rpti_suite_link'] ?? "",
                rptiSuitePgNo: item['suite']['rpti_suite_pg_no'] ?? 0),

            state: StateInsurance(rptiState: item['state']['rpti_state'] ?? "",
                rptiStateLink: item['state']['rpti_state_link'] ?? "",
                rptiStatePgNo: item['state']['rpti_state_pg_no'] ?? 0),

            zipcode: Zipcode(rptiZipcode: item['zipcode']['rpti_zipcode'] ?? "",
                rptiZipcodeLink: item['zipcode']['rpti_zipcode_link'] ?? "",
                rptiZipcodePgNo: item['zipcode']['rpti_zipcode_pg_no'] ?? 0),


            rptiVerified: item['rpti_verified'] ?? false,
          // ✅ Add this line for is_selfPay
          isSelfPay: item['is_selfPay'] ?? false,
        ));
      }
    } else {
      print('Api Error');
    }
    // print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<ApiData> updatePatientInsuranceInfo(
    {
      required BuildContext context,
      required int id,
      required String rptiPolicy,
      required String rptiInsuranceProvider,
      required String rptiInsurancePlan,
      required bool rptiEligibility,
      required bool rptiAuthorization,
      required String rptiName,
      required String rptiType,
      required String rptiCategory,
      required String rptiStreet,
      required String rptiSuite,
      required String rptiCity,
      required String rptiState,
      required String rptiZipcode,
      required String rptiContact,
      required String rptiEffectiveFrom,
      required String rptiEffectiveTo,
      required int rptiGroupNumber,
      required String rptiGroupName,
      required String rptiEmail,
      required bool rptiVerified,
      required String rptiComments,
      required bool isSelfPay, // <-- New parameter
    }) async {
  try {
    var response = await Api(context).patch(
      path: PatientInsuranceRepo.updatePatientInsurance(id: id),
      data: {
        "rpti_policy": rptiPolicy,
        "rpti_insurance_provider": rptiInsuranceProvider,
        "rpti_insurance_plan": rptiInsurancePlan,
        "rpti_eligibility": rptiEligibility,
        "rpti_authorization": rptiAuthorization,
        "rpti_name": rptiName,
        "rpti_type": rptiType,
        "rpti_category": rptiCategory,
        "rpti_street": rptiStreet,
        "rpti_suite": rptiSuite,
        "rpti_city": rptiCity,
        "rpti_state": rptiState,
        "rpti_zipcode": rptiZipcode,
        "rpti_contact": rptiContact,
        "rpti_effectiveFrom": rptiEffectiveFrom,
        "rpti_effectiveTo": rptiEffectiveTo,
        "rpti_groupNumber": rptiGroupNumber,
        "rpti_groupName": rptiGroupName,
        "rpti_email": rptiEmail,
        "rpti_verified": rptiVerified,
        "rpti_comments": rptiComments,
        "is_selfPay": isSelfPay, // <-- New field added to payload
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient insurance info updated");
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



///ai-emergency-contact/patient/{patientId}
// Future<List<IntakeEmergencyContact>> getIntakeEmergencyContact({
//   required BuildContext context,
//   required int ptId
// }) async {
//   List<IntakeEmergencyContact> itemsList = [];
//   try {
//     final response = await Api(context).get(path: PatientInsuranceRepo.getIntakeEmergencyContact(ptId: ptId));
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       for (var item in response.data) {
//         itemsList.add(IntakeEmergencyContact(
//             contactId_I: item['contactId_I']??0,
//             fk_pt_id: item['fk_pt_id']??0,
//             firstName_I: item['firstName_I']??'',
//             lastName_I: item['lastName_I']??'',
//             street_I: item['street_I']??'',
//             suite_I: item['suite_I']??'',
//             city_I: item['city_I']??'',
//             state_I: item['state_I']??'',
//             zipCode_I: item['zipCode_I']??'',
//             phoneNumber_I: item['phoneNumber_I']??'',
//             email_I: item['email_I']??''
//         ));
//       }
//     } else {
//       print('Api Error');
//     }
//     print("Response:::::${response}");
//     return itemsList;
//   } catch (e) {
//     print("Error $e");
//     return itemsList;
//   }
// }

Future<AIRefPatientInsurance?> getSingleAIRefPatientInsurance({
  required BuildContext context,
  required int ptId,
}) async {
  try {
    final response = await Api(context).get(
      path: PatientInsuranceRepo.getIntakeRefPatientInsurance(ptId: ptId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item = response.data;
      return AIRefPatientInsurance(
        rpti_id_I: item['rpti_id_I'] ?? 0,
        fk_pt_id: item['fk_pt_id'] ?? 0,
        rpti_policy_I: item['rpti_policy_I'] ?? '',
        rpti_insurance_provider_I: item['rpti_insurance_provider_I'] ?? '',
        rpti_insurance_plan_I: item['rpti_insurance_plan_I'] ?? '',
        rpti_name_I: item['rpti_name_I'] ?? '',
        rpti_type_I: item['rpti_type_I'] ?? '',
        rpti_category_I: item['rpti_category_I'] ?? '',
        rpti_street_I: item['rpti_street_I'] ?? '',
        rpti_suite_I: item['rpti_suite_I'] ?? '',
        rpti_city_I: item['rpti_city_I'] ?? '',
        rpti_state_I: item['rpti_state_I'] ?? '',
        rpti_zipcode_I: item['rpti_zipcode_I'] ?? '',
        rpti_contact_I: item['rpti_contact_I'] ?? '',
        rpti_groupName_I: item['rpti_groupName_I'] ?? '',
        rpti_email_I: item['rpti_email_I'] ?? '',
        rpti_comments_I: item['rpti_comments_I'] ?? '',
      )
      ;
    } else {
      print('API Error with status: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching single intake emergency contact: $e");
  }
  return null;
}

///patient-insurance
/// insurance info
Future<List<PatientInsuranceInfoData>> getPatientInsuranceAll({
  required BuildContext context
}) async {
  List<PatientInsuranceInfoData> itemsList = [];
  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }
  try {
    final response = await Api(context).get(path: PatientInsuranceRepo.getPatientInsuranceAll());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for(var item in response.data){
        print('rpti id type ${item['rpti_id'].runtimeType}');
        print('rpti id type ${item['rpti_id']}');
        itemsList.add(PatientInsuranceInfoData(
          rptiId: item['rpti_id']??0,
          fkPtId: item['fk_pt_id']??0,
          policy: Policy(
              rptiPolicy: item['policy']['rpti_policy'] ?? "",
              rptiPolicyLink: item['policy']['rpti_policy_link'] ?? "",
              rptiPolicyPgNo: item['policy']['rpti_policy_pg_no'] ?? 0),

          insuranceProvider: InsuranceProvider(rptiInsuranceProvider: item['insurance_provider']['rpti_insurance_provider'] ?? "",
              rptiInsuranceProviderLink: item['insurance_provider']['rpti_insurance_provider_link'] ?? "",
              rptiInsuranceProviderPgNo: item['insurance_provider']['rpti_insurance_provider_pg_no'] ?? 0),

          insurancePlan: InsurancePlan(rptiInsurancePlan: item['insurance_plan']['rpti_insurance_plan'] ?? "",
              rptiInsurancePlanLink: item['insurance_plan']['rpti_insurance_plan_link'] ?? "",
              rptiInsurancePlanPgNo: item['insurance_plan']['rpti_insurance_plan_pg_no'] ?? 0),

          rptiEligibility: item['rpti_eligibility']??false,
          rptiAuthorization: item['rpti_authorization']??false,
          rptiLastCheckedTime: item['rpti_last_checked_time'] == null ? '' : convertIsoToDayMonthYear(item['rpti_last_checked_time']),

          category: Category(rptiCategory: item['category']['rpti_category'] ?? "",
              rptiCategoryLink: item['category']['rpti_category_link'] ?? "",
              rptiCategoryPgNo: item['category']['rpti_category_pg_no'] ?? 0),

          city: City(rptiCity: item['city']['rpti_city'] ?? "",
              rptiCityLink: item['city']['rpti_city_link'] ?? "",
              rptiCityPgNo: item['city']['rpti_city_pg_no'] ?? 0),

          comments: Comments(rptiComments: item['comments']['rpti_comments'] ?? "",
            rptiCommentsLink: item['comments']['rpti_comments_link'] ?? "",
            rptiCommentsPgNo: item['comments']['rpti_comments_pg_no'] ?? 0,),

          contact: Contact(rptiContact: item['contact']['rpti_contact'] ?? "",
              rptiContactLink: item['contact']['rpti_contact_link'] ?? "",
              rptiContactPgNo: item['contact']['rpti_contact_pg_no'] ?? 0),

          rptiEffectiveFrom: item['rpti_effectiveFrom'] == null ? '' : convertIsoToDayMonthYear(item['rpti_effectiveFrom']),
          rptiEffectiveTo: item['rpti_effectiveTo'] == null ? '' : convertIsoToDayMonthYear(item['rpti_effectiveTo']),

          groupName: GroupName(rptiGroupName: item['group_name']['rpti_groupName'] ?? "",
              rptiGroupNameLink: item['group_name']['rpti_groupName_link'] ?? "",
              rptiGroupNamePgNo: item['group_name']['rpti_groupName_pg_no'] ?? 0),

          groupNumber: GroupNumber(rptiGroupNumber: item['group_number']['rpti_groupNumber'] ?? 0,
              rptiGroupNumberLink: item['group_number']['rpti_groupNumber_link'] ?? "",
              rptiGroupNumberPgNo: item['group_number']['rpti_groupNumber_pg_no'] ?? 0),

          email: Email(rptiEmail: item['email']['rpti_email'] ?? "",
              rptiEmailLink: item['email']['rpti_email_link'] ?? "",
              rptiEmailPgNo: item['email']['rpti_email_pg_no'] ?? 0),

          name: Name(rptiName: item['name']['rpti_name'] ?? "",
              rptiNameLink: item['name']['rpti_name_link'] ?? "",
              rptiNamePgNo: item['name']['rpti_name_pg_no'] ?? 0),

          type: Type(rptiType: item['type']['rpti_type'] ?? "",
              rptiTypeLink: item['type']['rpti_type_link'] ?? "",
              rptiTypePgNo: item['type']['rpti_type_pg_no'] ?? 0),

          street: Street(rptiStreet: item['street']['rpti_street'] ?? "",
              rptiStreetLink: item['street']['rpti_street_link'] ?? "",
              rptiStreetPgNo: item['street']['rpti_street_pg_no'] ?? 0),

          suite: Suite(rptiSuite: item['suite']['rpti_suite'] ?? "",
              rptiSuiteLink: item['suite']['rpti_suite_link'] ?? "",
              rptiSuitePgNo: item['suite']['rpti_suite_pg_no'] ?? 0),

          state: StateInsurance(rptiState: item['state']['rpti_state'] ?? "",
              rptiStateLink: item['state']['rpti_state_link'] ?? "",
              rptiStatePgNo: item['state']['rpti_state_pg_no'] ?? 0),

          zipcode: Zipcode(rptiZipcode: item['zipcode']['rpti_zipcode'] ?? "",
              rptiZipcodeLink: item['zipcode']['rpti_zipcode_link'] ?? "",
              rptiZipcodePgNo: item['zipcode']['rpti_zipcode_pg_no'] ?? 0),


          rptiVerified: item['rpti_verified'] ?? false,
          // ✅ Add this line for is_selfPay
          isSelfPay: item['is_selfPay'] ?? false,
        ));
      }
    } else {
      print('Api Error');
    }
    // print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}






//emr profile


// GET /patient-insurance-documents/{patientId}/{isPrimary}
Future<List<PatientInsuranceDocumentData>> getPatientInsuranceDocuments({
  required BuildContext context,
  required int patientId,
  required bool isPrimary,
}) async {
  List<PatientInsuranceDocumentData> itemsList = [];

  String convertIsoToDayMonthYear(String isoDate) {
    DateTime dateTime = DateTime.parse(isoDate);
    DateFormat dateFormat = DateFormat('yyyy/MM/dd');
    return dateFormat.format(dateTime);
  }

  try {
    final response = await Api(context).get(
      path: PatientInsuranceDocumentRepository.getByPatientIdAndIsPrimary(
        patientId: patientId,
        isPrimary: isPrimary,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PatientInsuranceDocumentData(
          insuranceDocumentId: item['insuranceDocumentId'] ?? 0,
          ptId: item['fk_pt_id'] ?? 0,
          docUrl: item['insuranceUrl'] ?? '',
          isPrimary: item['is_primary'] ?? false,
          docName: item['document_name'] ?? '',
          createdAt: item['insuranceCreatedAt'] != null
              ? DateTime.parse(item['insuranceCreatedAt'])
              : DateTime.now(),
          createdBy: item['insuranceCreatedBy'] ?? '--',
          updatedAt: item['insuranceUpdatedAt'] != null
              ? convertIsoToDayMonthYear(item['insuranceUpdatedAt'])
              : '0000-00-00T00:00:00.000Z',
          updatedBy: item['insuranceUpdatedBy'] ?? '--',
        ));
      }
    } else {
      print('Api Error');
    }
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}



class PatientInsuranceDocumentRepository {
  static String _base = '/patient-insurance-documents';

  // GET /patient-insurance-documents/{patientId}/{isPrimary}
  static String getByPatientIdAndIsPrimary({
    required int patientId,
    required bool isPrimary,
  }) {
    return '$_base/$patientId/$isPrimary';
  }
}