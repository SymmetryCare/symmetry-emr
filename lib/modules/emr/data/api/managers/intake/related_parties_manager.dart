import 'package:flutter/cupertino.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';
// removed in extraction: import '../../../../../../presentation/screens/scheduler_model/sm_Intake/widgets/intake_demographics/widgets/patients_related_party/post_model.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/intake/relatedParties_repo.dart';

Future<List<EmergencyContactData>> getPatientEmergencyContact({
  required BuildContext context,
  required int ptId
}) async {
  List<EmergencyContactData> itemsList = [];
  try {
    final response = await Api(context).get(path: RelatedPartiesRepo.getEmergencyContact(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(EmergencyContactData(
          no_emergency_contact: item['no_emergency_contact']??false,
          contactId: item['contact_id'] ?? 0,
          fkPtId: item['fk_pt_id'] ?? 0,
          firstName: FirstName(
            value: item['first_name']?['firstName'] ?? '',
            link: item['first_name']?['firstNameLink'] ?? '',
            pageNo: item['first_name']?['firstNamePgNo'] ?? 0,
          ),
          lastName: LastName(
            value: item['last_name']?['lastName'] ?? '',
            link: item['last_name']?['lastNameLink'] ?? '',
            pageNo: item['last_name']?['lastNamePgNo'] ?? 0,
          ),
          relationship: Relationship(
            relationshipId: item['relationship']?['relationship_id'] ?? 0,
            relationshipName: item['relationship']?['relationship_name'] ?? '',
            relationshipDescription: item['relationship']?['relationship_description'] ?? '',
          ),
          street: Street(
            street: item['street']?['street'] ?? '',
            streetLink: item['street']?['streetLink'] ?? '',
            streetPgNo: item['street']?['streetPgNo'] ?? 0,
          ),
          suite: Suite(
            suite: item['suite']?['suite'] ?? '',
            suiteLink: item['suite']?['suiteLink'] ?? '',
            suitePgNo: item['suite']?['suitePgNo'] ?? 0,
          ),
          city: City(
            city: item['city']?['city'] ?? '',
            cityLink: item['city']?['cityLink'] ?? '',
            cityPgNo: item['city']?['cityPgNo'] ?? 0,
          ),
          state: StateField(
            state: item['state']?['state'] ?? '',
            stateLink: item['state']?['stateLink'] ?? '',
            statePgNo: item['state']?['statePgNo'] ?? 0,
          ),
          zipcode: Zipcode(
            zipcode: item['zipcode']?['zipcode'] ?? '',
            zipcodeLink: item['zipcode']?['zipcodeLink'] ?? '',
            zipcodePgNo: item['zipcode']?['zipcodePgNo'] ?? 0,
          ),
          phoneNumber: ContactField(
            value: item['phone_number']?['phoneNumber'] ?? '',
            link: item['phone_number']?['phoneNumberLink'] ?? '',
            pageNo: item['phone_number']?['phoneNumberPgNo'] ?? 0,
          ),
          email: EmailField(
            value: item['email']?['email'] ?? '',
            link: item['email']?['emailLink'] ?? '',
            pageNo: item['email']?['emailPgNo'] ?? 0,
          ),
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<ApiData> addPatientEmergencyContact(
    {
      required BuildContext context,
      required int ec_fk_pt_id,
      required String ec_firstName,
      required String ec_lastname,
      required int ec_relationshipId,
      required String ec_street,
      required String ec_suite,
      required String ec_city,
      required String ec_state,
      required String ec_zipCode,
      required String ec_phoneNumber,
      required String ec_email,
      required bool no_emergency_contact

    }) async {
  try {
    var response = await Api(context).post(
        path: RelatedPartiesRepo.addEmergencyContact(),
        data: {
          "emergencyContact": no_emergency_contact == true ? {
            "no_emergency_contact": no_emergency_contact
          }:{
              "fk_pt_id": ec_fk_pt_id,
              "firstName": ec_firstName,
              "lastName": ec_lastname,
              "fk_Relationship": ec_relationshipId,
              "street":ec_street,
              "suite": ec_suite,
              "city": ec_city,
              "state": ec_state,
              "zipCode": ec_zipCode,
              "phoneNumber": ec_phoneNumber,
              "email": ec_email,
              "no_emergency_contact": no_emergency_contact
            }
          },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient emergency conatact added ");
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

Future<ApiData> deletePatientEmergencyContact(
    {
      required BuildContext context,
      required int recordId,
    }) async {
  try {
    var response = await Api(context).delete(
        path: RelatedPartiesRepo.deleteEmergencyContact(id: recordId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient emergency conatact deleted ");
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

Future<ApiData> addPatientRepresent(
    {
      required BuildContext context,
      required int re_fk_pt_id,
      required String re_firstName,
      required String re_lastname,
      required int re_relationshipId,
      required String re_street,
      required String re_suite,
      required String re_city,
      required String re_state,
      required String re_zipCode,
      required String re_phoneNumber,
      required String re_email,
      required int re_role,
      required int re_type,
      required bool no_patient_representative,

    }) async {
  try {
    var response = await Api(context).post(
        path: RelatedPartiesRepo.addEmergencyContact(),
        data: {
          "patientRepresentative": no_patient_representative == true ? {
            "no_patient_representative":no_patient_representative
          }:{
            "fk_pt_id": re_fk_pt_id,
            "firstName":re_firstName,
            "lastName": re_lastname,
            "fk_Relationship": re_relationshipId,
            "street": re_street,
            "suite": re_suite,
            "city": re_city,
            "state":re_state,
            "zipCode": re_zipCode,
            "phoneNumber": re_phoneNumber,
            "email": re_email,
            "fk_role": re_role,
            "fk_type": re_type,
            "no_patient_representative":no_patient_representative
          }
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient represendt added ");
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
Future<ApiData> deletePatientRepresent(
    {
      required BuildContext context,
      required int recordId,

    }) async {
  try {
    var response = await Api(context).delete(
        path: RelatedPartiesRepo.deleteRelatedRepresentive(id: recordId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient represendt deleted ");
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
/// Role dropdown
Future<List<RelatedPartiesRoleData>> getRelataedRoleDropDown({
  required BuildContext context,
}) async {
  List<RelatedPartiesRoleData> itemsList = [];
  try {
    final response = await Api(context).get(path: RelatedPartiesRepo.getRelatedPartiesRole());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(RelatedPartiesRoleData(
            roleId: item['roleId']??0,
            roleName: item['roleName']??'',
            roleDiscription: item['roleDescription']??''
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// Type dropdown
Future<List<RelatedPatiesTypeData>> getRelataedTypeDropDown({
  required BuildContext context,
}) async {
  List<RelatedPatiesTypeData> itemsList = [];
  try {
    final response = await Api(context).get(path: RelatedPartiesRepo.getRelatedPartiesType());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(RelatedPatiesTypeData(
            typeId: item['typeId']??0,
            typeName: item['typeName']??'',
            typeDiscription: item['typeDescription']??''
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

Future<List<PatientRepresentativeData>> getPatientRepresentative({
  required BuildContext context,
  required int ptId
}) async {
  List<PatientRepresentativeData> itemsList = [];
  try {
    final response = await Api(context).get(path: RelatedPartiesRepo.getRelatedRepresentive(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          PatientRepresentativeData(
            no_patient_representative: item['no_patient_representative']??false,
            representative_id: item['representative_id'] ?? 0,
            fkPtId: item['fk_pt_id'] ?? 0,
            firstName: FirstName(
              value: item['first_name']?['firstName'] ?? '',
              link: item['first_name']?['firstNameLink'] ?? '',
              pageNo: item['first_name']?['firstNamePgNo'] ?? 0,
            ),
            lastName: LastName(
              value: item['last_name']?['lastName'] ?? '',
              link: item['last_name']?['lastNameLink'] ?? '',
              pageNo: item['last_name']?['lastNamePgNo'] ?? 0,
            ),
            relationship: Relationship(
              relationshipId: item['relationship']?['relationship_id'] ?? 0,
              relationshipName: item['relationship']?['relationship_name'] ?? '',
              relationshipDescription: item['relationship']?['relationship_description'] ?? '',
            ),
            street: Street(
              street: item['street']?['street'] ?? '',
              streetLink: item['street']?['streetLink'] ?? '',
              streetPgNo: item['street']?['streetPgNo'] ?? 0,
            ),
            suite: Suite(
              suite: item['suite']?['suite'] ?? '',
              suiteLink: item['suite']?['suiteLink'] ?? '',
              suitePgNo: item['suite']?['suitePgNo'] ?? 0,
            ),
            city: City(
              city: item['city']?['city'] ?? '',
              cityLink: item['city']?['cityLink'] ?? '',
              cityPgNo: item['city']?['cityPgNo'] ?? 0,
            ),
            state: StateField(
              state: item['state']?['state'] ?? '',
              stateLink: item['state']?['stateLink'] ?? '',
              statePgNo: item['state']?['statePgNo'] ?? 0,
            ),
            zipcode: Zipcode(
              zipcode: item['zipcode']?['zipcode'] ?? '',
              zipcodeLink: item['zipcode']?['zipcodeLink'] ?? '',
              zipcodePgNo: item['zipcode']?['zipcodePgNo'] ?? 0,
            ),
            phoneNumber: ContactField(
              value: item['phone_number']?['phoneNumber'] ?? '',
              link: item['phone_number']?['phoneNumberLink'] ?? '',
              pageNo: item['phone_number']?['phoneNumberPgNo'] ?? 0,
            ),
            email: EmailField(
              value: item['email']?['email'] ?? '',
              link: item['email']?['emailLink'] ?? '',
              pageNo: item['email']?['emailPgNo'] ?? 0,
            ),
            type: Type(
                typeId: item['type']['type_id']??0,
                typeName: item['type']['type_name']??'',
                typeDes: item['type']['type_description']??''),
            role: Role(
                roleId: item['role']['role_id']??0,
                roleName: item['role']['role_name']??'',
                roleDes: item['role']['role_description']??''),
          ),
        );
      }

    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


Future<ApiData> addPatientRepresentative(
    {
      required BuildContext context,
      required int fk_pt_id,
      required String firstName,
      required String lastname,
      required int relationshipId,
      required String street,
      required String suite,
      required String city,
      required String state,
      required String zipCode,
      required String phoneNumber,
      required String email,
      required int fk_role,
      required int fk_type
    }) async {
  try {
    var response = await Api(context).post(
        path: RelatedPartiesRepo.addRelatedRepresentive(),
        data: {
          "fk_pt_id": fk_pt_id,
          "firstName": firstName,
          "lastName": lastname,
          "fk_Relationship": relationshipId,
          "street": street,
          "suite": suite,
          "city": city,
          "state": state,
          "zipCode": zipCode,
          "phoneNumber": phoneNumber,
          "email": email,
          "fk_role": fk_role,
          "fk_type": fk_type
        }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Representative  added ");
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