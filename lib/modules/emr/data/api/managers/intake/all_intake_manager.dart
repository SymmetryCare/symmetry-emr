
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographic_patient_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographich_ai_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/intake/patient_intake_repo.dart';

/// Add Demographich
Future<ApiData> addPatientIntakeDemographich(
    {
      required BuildContext context,
      required int ptId,
    }) async {
  try {
    var response = await Api(context).post(
      path: PatientIntakeRepo.addPatientDemographich(),
      data: {
        'fk_pt_id':ptId
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Intake demograpich created ");
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

/// Demographic patient data
Future<DemographicPatientDataModel> getDemographichPatientDetail({
  required BuildContext context,
  required int patientId
}) async {
  var itemsData;
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
    final response = await Api(context).get(
      path: PatientIntakeRepo.getPatientDemographichWithPtId(ptId: patientId),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      // print('county data ${response.data['country']['name']??'null'}');
      // print('residence_type data ${response.data['residence_type']['detail']??'null'}');
      // print('zone data ${response.data['zone']['zoneName']??'null'}');
      // print('maritalStatus data ${response.data['maritalStatus']['maritalStatus']??'null'}');

      print('All Response ${response.data}');
        itemsData = DemographicPatientDataModel(
          demoId: response.data['demo_id'] ?? 0,
          fkPtId: response.data['fk_pt_id'] ?? 0,
          firstName: FirstName(
            demoFirstName: response.data['first_name']['demo_first_name'] ?? "",
            firstNameLink: response.data['first_name']['first_name_link'] ?? "",
            firstNamePgNo: response.data['first_name']['first_name_pg_no'] ?? 0,
          ),
          middleInitial: MiddleInitial(
            demoMiddleInitial: response.data['middle_initial']['demo_middle_initial'] ?? "",
            middleInitialLink: response.data['middle_initial']['middle_initial_link'] ?? "",
            middleInitialPgNo: response.data['middle_initial']['middle_initial_pg_no'] ?? 0,
          ),
          lastName: LastName(
            demoLastName: response.data['last_name']['demo_last_name'] ?? "",
            lastNameLink: response.data['last_name']['last_name_link'] ?? "",
            lastNamePgNo: response.data['last_name']['last_name_pg_no'] ?? 0,
          ),
          suffix: Suffix(
            demoSuffix: response.data['suffix']['demo_suffix'] ?? "",
            suffixLink: response.data['suffix']['suffix_link'] ?? "",
            suffixPgNo: response.data['suffix']['suffix_pg_no'] ?? 0,
          ),
          street: Street(
            demoStreet: response.data['street']['demo_street'] ?? "",
            streetLink: response.data['street']['street_link'] ?? "",
            streetPgNo: response.data['street']['street_pg_no'] ?? 0,
          ),
          suite: Suite(
            demoSuite: response.data['suite']['demo_suite'] ?? "",
            suiteLink: response.data['suite']['suite_link'] ?? "",
            suitePgNo: response.data['suite']['suite_pg_no'] ?? 0,
          ),
          city: City(
            demoCity: response.data['city']['demo_city'] ?? "",
            cityLink: response.data['city']['city_link'] ?? "",
            cityPgNo: response.data['city']['city_pg_no'] ?? 0,
          ),
          state: StateClass(
            demoState: response.data['state']['demo_state'] ?? "",
            stateLink: response.data['state']['state_link'] ?? "",
            statePgNo: response.data['state']['state_pg_no'] ?? 0,
          ),
          zipcode: Zipcode(
            demoZipcode: response.data['zipcode']['demo_zipcode'] ?? "",
            zipcodeLink: response.data['zipcode']['zipcode_link'] ?? "",
            zipcodePgNo: response.data['zipcode']['zipcode_pg_no'] ?? 0,
          ),
          facilityName: FacilityName(
            demoFacilityName: response.data['facility_name']['demo_facility_name'] ?? "",
            facilityNameLink: response.data['facility_name']['facility_name_link'] ?? "",
            facilityNamePgNo: response.data['facility_name']['facility_name_pg_no'] ?? 0,
          ),
          locationNotes: LocationNotes(
            demoLocationNotes: response.data['location_notes']['demo_location_notes'] ?? "",
            locationNotesLink: response.data['location_notes']['location_notes_link'] ?? "",
            locationNotesPgNo: response.data['location_notes']['location_notes_pg_no'] ?? 0,
          ),
          primaryContact: PrimaryContact(
            demoPrimaryContact: response.data['primary_contact']['demo_primary_contact'] ?? "",
            primaryContactLink: response.data['primary_contact']['primary_contact_link'] ?? "",
            primaryContactPgNo: response.data['primary_contact']['primary_contact_pg_no'] ?? 0,
          ),
          primaryContactName: PrimaryContactName(
            demoPrimaryContactName: response.data['primary_contact_name']['demo_primary_contact_name'] ?? "",
            primaryContactNameLink: response.data['primary_contact_name']['primary_contact_name_link'] ?? "",
            primaryContactNamePgNo: response.data['primary_contact_name']['primary_contact_name_pg_no'] ?? 0,
          ),
          primaryPhone: PrimaryPhone(
            demoPrimaryPhone: response.data['primary_phone']['demo_primary_phone'] ?? "",
            primaryPhoneLink: response.data['primary_phone']['primary_phone_link'] ?? "",
            primaryPhonePgNo: response.data['primary_phone']['primary_phone_pg_no'] ?? 0,
          ),
          primaryEmail: PrimaryEmail(
            demoPrimaryEmail: response.data['primary_email']['demo_primary_email'] ?? "",
            primaryEmailLink: response.data['primary_email']['primary_email_link'] ?? "",
            primaryEmailPgNo: response.data['primary_email']['primary_email_pg_no'] ?? 0,
          ),
          cahpsContact: CahpsContact(
            demoCahpsContact: response.data['cahps_contact']['demo_cahps_contact'] ?? "",
            cahpsContactLink: response.data['cahps_contact']['cahps_contact_link'] ?? "",
            cahpsContactPgNo: response.data['cahps_contact']['cahps_contact_pg_no'] ?? 0,
          ),
          secondaryContact: SecondaryContact(
            demoSecondaryContact: response.data['secondary_contact']['demo_secondary_contact'] ?? "",
            secondaryContactLink: response.data['secondary_contact']['secondary_contact_link'] ?? "",
            secondaryContactPgNo: response.data['secondary_contact']['secondary_contact_pg_no'] ?? 0,
          ),
          secondaryContactName: SecondaryContactName(
            demoSecondaryContactName: response.data['secondary_contact_name']['demo_secondary_contact_name'] ?? "",
            secondaryContactNameLink: response.data['secondary_contact_name']['secondary_contact_name_link'] ?? "",
            secondaryContactNamePgNo: response.data['secondary_contact_name']['secondary_contact_name_pg_no'] ?? 0,
          ),
          secondaryPhone: SecondaryPhone(
            demoSecondaryPhone: response.data['secondary_phone']['demo_secondary_phone'] ?? "",
            secondaryPhoneLink: response.data['secondary_phone']['secondary_phone_link'] ?? "",
            secondaryPhonePgNo: response.data['secondary_phone']['secondary_phone_pg_no'] ?? 0,
          ),
          secondaryEmail: SecondaryEmail(
            demoSecondaryEmail: response.data['secondary_email']['demo_secondary_email'] ?? "",
            secondaryEmailLink: response.data['secondary_email']['secondary_email_link'] ?? "",
            secondaryEmailPgNo: response.data['secondary_email']['secondary_email_pg_no'] ?? 0,
          ),
          socialSecurity: SocialSecurity(
            demoSocialSecurity: response.data['social_security']['demo_social_security'] ?? "",
            socialSecurityLink: response.data['social_security']['social_security_link'] ?? "",
            socialSecurityPgNo: response.data['social_security']['social_security_pg_no'] ?? 0,
          ),
          demoDob: response.data['demo_dob'] != null ? convertIsoToDayMonthYear(response.data['demo_dob']) : "",
          fkGender: response.data['fk_gender'] ?? 0,
          fkSpokenLanguage: response.data['fk_spoken_language'] ?? 0,
          fkCountryId: response.data['fk_countryId'] ?? 0,
          fkResidenceTypeId: response.data['fk_residence_type_id'] ?? 0,
          fkZoneId: response.data['fk_zone_id'] ?? 0,
          fkRaceEthnicity: response.data['fk_raceEthnicity'] ?? 0,
          fkMaritalStatus: response.data['fk_maritalStatus'] ?? 0,
          demoCreatedAt: response.data['demo_created_at'] != null ?convertIsoToDayMonthYear(response.data['demo_created_at']):'',
          gender: Gender(
            genderId: response.data['gender']['genderId'] ?? 0,
            gender: response.data['gender']['gender'] ?? "Select",
          ),
          country: Country(
            countryId: response.data['country']['countryId'] ?? 0,
            name: response.data['country']['name'] ?? "Select",
            short: response.data['country']['short'] ?? "",
          ),
          residenceType: ResidenceType(
            id: response.data['residenceType']['id'] ?? 0,
            detail: response.data['residenceType']['detail'] ?? "Select",
            description: response.data['residenceType']['description'] ?? "",
          ),
          zone: Zone(
            zoneId: response.data['zone']['zone_id'] ?? 0,
            zoneName: response.data['zone']['zoneName'] ?? "Select",
            companyId: response.data['zone']['companyId'] ?? 0,
            officeId: response.data['zone']['officeId'] ?? "",
            countyId: response.data['zone']['county_id'] ?? 0,
          ),
          spokenLanguage: SpokenLanguage(
            languageSpokenId: response.data['spokenLanguage']['languageSpokenId'] ?? 0,
            languageSpoken: response.data['spokenLanguage']['languageSpoken'] ?? "",
          ),
          race: Race(
            raceId: response.data['race']['raceId'] ?? 0,
            race: response.data['race']['race'] ?? "Select",
          ),
          maritalStatus: MaritalStatus(
            maritalStatusId: response.data['maritalStatus']['maritalStatusId'] ?? 0,
            maritalStatus: response.data['maritalStatus']['maritalStatus'] ?? "Select",
          ),
        );

    }
    else {
      print("patient demographic error");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

/// Patch Demographich
Future<ApiData> patchPatientIntakeDemographich(
    {
      required BuildContext context,
      required int demoId,
      required int fk_pt_id,
      required String demoFirstName,
      required String demoMiddleInitial,
      required String demoLastName,
      required String demoSuffix,
      required String demoStreet,
      required String demoSuite,
      required String demoCity,
      required String demoState,
      required String demoZipcode,
      required int fkCountryId,
      required int fkResidenceTypeId,
      required String demoFacilityName,
      required int fkZoneId,
      required String demoLocationNotes,
      required String demoPrimaryContact,
      required String demoPrimaryContactName,
      required String demoPrimaryPhone,
      required String demoPrimaryEmail,
      required String demoCahpsContact,
      required String demoSecondaryContact,
      required String demoSecondaryContactName,
      required String demoSecondaryPhone,
      required String demoSecondaryEmail,
      required String demoDob, // Format: yyyy-MM-ddTHH:mm:ss.sssZ
      required int fkGender,
      required int fkSpokenLanguage,
      required String demoSocialSecurity,
      required int fkRaceEthnicity,
      required int fkMaritalStatus,
    }) async {
  debugPrint({
    "demoId": demoId,
    "fk_pt_id": fk_pt_id,
    "demoFirstName": demoFirstName,
    "demoMiddleInitial": demoMiddleInitial,
    "demoLastName": demoLastName,
    "demoSuffix": demoSuffix,
    "demoStreet": demoStreet,
    "demoSuite": demoSuite,
    "demoCity": demoCity,
    "demoState": demoState,
    "demoZipcode": demoZipcode,
    "fkCountryId": fkCountryId,
    "fkResidenceTypeId": fkResidenceTypeId,
    "demoFacilityName": demoFacilityName,
    "fkZoneId": fkZoneId,
    "demoLocationNotes": demoLocationNotes,
    "demoPrimaryContact": demoPrimaryContact,
    "demoPrimaryContactName": demoPrimaryContactName,
    "demoPrimaryPhone": demoPrimaryPhone,
    "demoPrimaryEmail": demoPrimaryEmail,
    "demoCahpsContact": demoCahpsContact,
    "demoSecondaryContact": demoSecondaryContact,
    "demoSecondaryContactName": demoSecondaryContactName,
    "demoSecondaryPhone": demoSecondaryPhone,
    "demoSecondaryEmail": demoSecondaryEmail,
    "demoDob": demoDob,
    "fkGender": fkGender,
    "fkSpokenLanguage": fkSpokenLanguage,
    "demoSocialSecurity": demoSocialSecurity,
    "fkRaceEthnicity": fkRaceEthnicity,
    "fkMaritalStatus": fkMaritalStatus,
  }.toString());
  try {
    var response = await Api(context).patch(
      path: PatientIntakeRepo.updatePatientDemographich(id: demoId),
      data: {
        "fk_pt_id": fk_pt_id,
        "demo_firstName": demoFirstName,
        "demo_middleInitial": demoMiddleInitial,
        "demo_lastName": demoLastName,
        "demo_suffix": demoSuffix,
        "demo_street": demoStreet,
        "demo_suite": demoSuite,
        "demo_city": demoCity,
        "demo_state": demoState,
        "demo_zipcode": demoZipcode,
        "fk_countryId": fkCountryId,
        "fk_residence_type_id": fkResidenceTypeId,
        "demo_facilityName": demoFacilityName,
        "fk_zone_id": fkZoneId,
        "demo_locationNotes": demoLocationNotes,
        "demo_primaryContact": demoPrimaryContact,
        "demo_primaryContactName": demoPrimaryContactName,
        "demo_primaryPhone": demoPrimaryPhone,
        "demo_primaryEmail": demoPrimaryEmail,
        "demo_CAHPS_Contact": demoCahpsContact,
        "demo_secondaryContact": demoSecondaryContact,
        "demo_secondaryContactName": demoSecondaryContactName,
        "demo_secondaryPhone": demoSecondaryPhone,
        "demo_secondaryEmail": demoSecondaryEmail,
        "demo_dob": demoDob,
        "fk_gender": fkGender,
        "fk_spoken_language": fkSpokenLanguage,
        "demo_socialSecurity": demoSocialSecurity,
        "fk_raceEthnicity": fkRaceEthnicity,
        "fk_maritalStatus": fkMaritalStatus,
      }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient Intake demograpich updated ");
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


Future<AIDemographichModelData> getAIDemographichData({
  required BuildContext context,
  required int ptId
}) async {
  var itemsList;
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
    final response = await Api(context).get(path: PatientIntakeRepo.getAIDemographich(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      var item = response.data;
       print('All Data ${response.data}');
      itemsList = AIDemographichModelData(
        demoIdI: item['demo_id_I']??0,
        fkPtId: item['fk_pt_id']??0,
        demoFirstNameI: item['demo_firstName_I']??'',
        demoMiddleInitialI: item['demo_middleInitial_I']??'',
        demoLastNameI: item['demo_lastName_I']??'',
        demoSuffixI: item['demo_suffix_I']??'',
        demoStreetI: item['demo_street_I']??'',
        demoSuiteI: item['demo_suite_I']??'',
        demoCityI: item['demo_city_I']??'',
        demoStateI: item['demo_state_I']??'',
        demoZipcodeI: item['demo_zipcode_I']??'',
        demoFacitlityNameI: item['demo_facitlityName_I']??'',
        demoLocationNotesI: item['demo_locationNotes_I']??'',
        demoPrimaryContactI: item['demo_primaryContact_I']??"",
        demoPrimaryContactNameI: item['demo_primaryContactName_I']??'',
        demoPrimaryPhoneI: item['demo_primaryPhone_I']??'',
        demoPrimaryEmailI: item['demo_primaryEmail_I']??'',
        demoCahpsContactI: item['demo_CAHPS_Contact_I']??'',
        demoSecondaryContactI: item['demo_secondaryContact_I']??'',
        demoSecondaryContactNameI: item['demo_secondaryContactName_I']??'',
        demoSecondaryPhoneI: item['demo_secondaryPhone_I']??'',
        demoSecondaryEmailI: item['demo_secondaryEmail_I']??'',
        demoSocialSecurityI: item['demo_socialSecurity_I']??'',
        demoCreatedAtI: convertIsoToDayMonthYear(item['demo_created_at_I']),
      );


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





/// Add Demographich
Future<ApiData> postDiscipline(
    {
      required BuildContext context,
      required int ptId,
    }) async {
  try {
    var response = await Api(context).post(
      path: PatientIntakeRepo.addDiscipline(),
      data: {
        'fk_pt_id':ptId
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Patient from Intake  to  scheduler ");
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

Future<AiEmergencyContactData> getAIEmergencyContact({
  required BuildContext context,
  required int ptId
}) async {
  var itemsList;
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
    final response = await Api(context).get(path: PatientIntakeRepo.getAIEmergencyContact(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      var item = response.data;
      print('All Data ${response.data}');
      itemsList = AiEmergencyContactData(
          contactId_I: item['contactId_I']??0,
          fk_pt_id: item['fk_pt_id']??0,
          firstName_I: item['firstName_I']??" ",
          lastName_I: item['lastName_I']??" ",
          street_I: item['street_I']??" ",
          suite_I: item['suite_I']??" ",
          city_I: item['city_I']??" ",
          state_I: item['state_I']??" ",
          zipCode_I: item['zipCode_I']??" ",
          phoneNumber_I: item['phoneNumber_I']??" ",
          email_I: item['email_I']??" "
      );
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


Future<AiRepresentativeData> getAIRepresentative({
  required BuildContext context,
  required int ptId
}) async {
  var itemsList;
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
    final response = await Api(context).get(path: PatientIntakeRepo.getAIPatientRepresentative(ptId: ptId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      var item = response.data;
      print('All Data ${response.data}');
      itemsList = AiRepresentativeData(
          representiveId_I: item['contactId_I']??0,
          fk_pt_id: item['fk_pt_id']??0,
          firstName_I: item['firstName_I']??" ",
          lastName_I: item['lastName_I']??" ",
          street_I: item['street_I']??" ",
          suite_I: item['suite_I']??" ",
          city_I: item['city_I']??" ",
          state_I: item['state_I']??" ",
          zipCode_I: item['zipCode_I']??" ",
          phoneNumber_I: item['phoneNumber_I']??" ",
          email_I: item['email_I']??" "
      );
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