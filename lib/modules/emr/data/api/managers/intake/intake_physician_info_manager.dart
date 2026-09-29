import 'package:flutter/material.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';

import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/sm_physician_info/physician_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/sm_physician_info/physician_info.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/intake/intake_physician_info.dart';

Future<ApiData> addPhysicianInfo({
  required BuildContext context,
  required String phyFirstName,
  required String phyLastName,
  required String phyPicoNo,
  required bool phyPicoStatus,
  required String phyEmail,
  required String phyContact,
  required String phySuffix,
  required String phyStreet,
  required String phySuite,
  required String phyCity,
  required String phyState,
  required String phyZipCode,
  required String phyFax,
  required int phyNPI,
  required String phyUPI,
  required String phyProtocols,
  required String phyNotes,
  required bool phyVerified,
  required String phyVerificationDetails,
  required String phyTrackingNotes,
}) async {
  try{
    final companyId = await TokenManager.getCompanyId();
    var data = {
      "phy_first_name": phyFirstName,
      "phy_last_name": phyLastName,
      "phy_pico_no": phyPicoNo,
      "phy_pico_status": phyPicoStatus,
      "phy_email": phyEmail,
      "phy_contact": phyContact,
      "phy_suffix": phySuffix,
      "phy_street": phyStreet,
      "phy_suite": phySuite,
      "phy_city": phyCity,
      "phy_state": phyState,
      "phy_zipCode": phyZipCode,
      "phy_fax": phyFax,
      "phy_NPI": phyNPI,
      "phy_UPI": phyUPI,
      "phy_protocols": phyProtocols,
      "phy_notes": phyNotes,
      "phy_verified": phyVerified,
      "phy_verificationDetails": phyVerificationDetails,
      "phy_trackingNotes": phyTrackingNotes,
    };

    print('New Org Corporate Doc $data');
    var response = await Api(context).post(
        path: IntakePhysicianInfo.addPhysicianMaster(),
        data: data);

    print('New ORG Doc Post::::$response ');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("New Org Corporate Doc added ");
      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!);
    }
    else {
      print("Error 1");
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message'][0]);
    }
  }
      catch(e){
        print("Error $e");
        print("Error 2");
        return ApiData(
            statusCode: 404, success: false, message: AppString.somethingWentWrong);
      }
}

///physician-master/patient/{patientId}
// Future<PhysicianInfoPrefillData> getPhysicianInfoById({
//   required BuildContext context,
//   required int patientId,
// }) async {
//   try {
//     final response = await Api(context).get(
//       path: IntakePhysicianInfo.getByIdPhysicianMaster(patientId: patientId),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final item = response.data;
//
//       return PhysicianInfoPrefillData(
//         phyId: item['phy_id'] ?? 0,
//         firstName: PhyFirstName(
//           phyFirstName: item['first_name']['phy_first_name'] ?? "",
//           phyFirstNameLink: item['first_name']['phy_first_name_link'] ?? "",
//           phyFirstNamePgNo: item['first_name']['phy_first_name_pg_no'] ?? 0,
//         ),
//         lastName: PhyLastName(
//           phyLastName: item['last_name']['phy_last_name'] ?? "",
//           phyLastNameLink: item['last_name']['phy_last_name_link'] ?? "",
//           phyLastNamePgNo: item['last_name']['phy_last_name_pg_no'] ?? 0,
//         ),
//         picoNo: PhyPicoNo(
//           phyPicoNo: item['pico_no']['phy_pico_no'] ?? "",
//           phyPicoNoLink: item['pico_no']['phy_pico_no_link'] ?? "",
//           phyPicoNoPgNo: item['pico_no']['phy_pico_no_pg_no'] ?? 0,
//         ),
//         phyPicoStatus: item['phy_pico_status'] ?? false,
//         email: PhyEmail(
//           phyEmail: item['email']['phy_email'] ?? "",
//           phyEmailLink: item['email']['phy_email_link'] ?? "",
//           phyEmailPgNo: item['email']['phy_email_pg_no'] ?? 0,
//         ),
//         contact: PhyContact(
//           phyContact: item['contact']['phy_contact'] ?? "",
//           phyContactLink: item['contact']['phy_contact_link'] ?? "",
//           phyContactPgNo: item['contact']['phy_contact_pg_no'] ?? 0,
//         ),
//         phyNPI: item['phy_NPI'] ?? 0,
//         upi: PhyUPI(
//           phyUPI: item['upi']['phy_UPI'] ?? "",
//           phyUPILink: item['upi']['phy_UPI_link'] ?? "",
//           phyUPIPgNo: item['upi']['phy_UPI_pg_no'] ?? 0,
//         ),
//         city: PhyCity(
//           phyCity: item['city']['phy_city'] ?? "",
//           phyCityLink: item['city']['phy_city_link'] ?? "",
//           phyCityPgNo: item['city']['phy_city_pg_no'] ?? 0,
//         ),
//         fax: PhyFax(
//           phyFax: item['fax']['phy_fax'] ?? "",
//           phyFaxLink: item['fax']['phy_fax_link'] ?? "",
//           phyFaxPgNo: item['fax']['phy_fax_pg_no'] ?? 0,
//         ),
//         notes: PhyNotes(
//           phyNotes: item['notes']['phy_notes'] ?? "",
//           phyNotesLink: item['notes']['phy_notes_link'] ?? "",
//           phyNotesPgNo: item['notes']['phy_notes_pg_no'] ?? 0,
//         ),
//         protocols: PhyProtocols(
//           phyProtocols: item['protocols']['phy_protocols'] ?? "",
//           phyProtocolsLink: item['protocols']['phy_protocols_link'] ?? "",
//           phyProtocolsPgNo: item['protocols']['phy_protocols_pg_no'] ?? 0,
//         ),
//         state: PhyState(
//           phyState: item['state']['phy_state'] ?? "",
//           phyStateLink: item['state']['phy_state_link'] ?? "",
//           phyStatePgNo: item['state']['phy_state_pg_no'] ?? 0,
//         ),
//         street: PhyStreet(
//           phyStreet: item['street']['phy_street'] ?? "",
//           phyStreetLink: item['street']['phy_street_link'] ?? "",
//           phyStreetPgNo: item['street']['phy_street_pg_no'] ?? 0,
//         ),
//         suffix: PhySuffix(
//           phySuffix: item['suffix']['phy_suffix'] ?? "",
//           phySuffixLink: item['suffix']['phy_suffix_link'] ?? "",
//           phySuffixPgNo: item['suffix']['phy_suffix_pg_no'] ?? 0,
//         ),
//         suite: PhySuite(
//           phySuite: item['suite']['phy_suite'] ?? "",
//           phySuiteLink: item['suite']['phy_suite_link'] ?? "",
//           phySuitePgNo: item['suite']['phy_suite_pg_no'] ?? 0,
//         ),
//         trackingNotes: PhyTrackingNotes(
//           phyTrackingNotes: item['tracking_notes']['phy_trackingNotes'] ?? "",
//           phyTrackingNotesLink: item['tracking_notes']['phy_trackingNotes_link'] ?? "",
//           phyTrackingNotesPgNo: item['tracking_notes']['phy_trackingNotes_pg_no'] ?? 0,
//         ),
//         verificationDetails: PhyVerificationDetails(
//           phyVerificationDetails: item['verification_details']['phy_verificationDetails'] ?? "",
//           phyVerificationDetailsLink: item['verification_details']['phy_verificationDetails_link'] ?? "",
//           phyVerificationDetailsPgNo: item['verification_details']['phy_verificationDetails_pg_no'] ?? 0,
//         ),
//         phyVerified: item['phy_verified'] ?? false,
//         zipcode: PhyZipCode(
//           phyZipCode: item['zipcode']['phy_zipCode'] ?? "",
//           phyZipCodeLink: item['zipcode']['phy_zipCode_link'] ?? "",
//           phyZipCodePgNo: item['zipcode']['phy_zipCode_pg_no'] ?? 0,
//         ),
//       );
//     } else {
//       throw Exception('API Error with status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print("Error $e");
//     rethrow;
//   }
// }
///
Future<List<PhysicianInfoPrefillData>> getPhysicianInfoById({
  required BuildContext context,
  required int patientId,
  required int physicianId
}) async {
  List<PhysicianInfoPrefillData> itemsList = [];
  try {
    final response = await Api(context).get(path: IntakePhysicianInfo.getByIdPhysicianMaster(patientId: patientId, physicianId: physicianId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PhysicianInfoPrefillData(
            phyId: item['phy_id'] ?? 0,
            firstName: PhyFirstName(
              phyFirstName: item['first_name']['phy_first_name'] ?? "",
              phyFirstNameLink: item['first_name']['phy_first_name_link'] ?? "",
              phyFirstNamePgNo: item['first_name']['phy_first_name_pg_no'] ?? 0,
            ),
            lastName: PhyLastName(
              phyLastName: item['last_name']['phy_last_name'] ?? "",
              phyLastNameLink: item['last_name']['phy_last_name_link'] ?? "",
              phyLastNamePgNo: item['last_name']['phy_last_name_pg_no'] ?? 0,
            ),
            picoNo: PhyPicoNo(
              phyPicoNo: item['pico_no']['phy_pico_no'] ?? "",
              phyPicoNoLink: item['pico_no']['phy_pico_no_link'] ?? "",
              phyPicoNoPgNo: item['pico_no']['phy_pico_no_pg_no'] ?? 0,
            ),
            phyPicoStatus: item['phy_pico_status'] ?? false,
            email: PhyEmail(
              phyEmail: item['email']['phy_email'] ?? "",
              phyEmailLink: item['email']['phy_email_link'] ?? "",
              phyEmailPgNo: item['email']['phy_email_pg_no'] ?? 0,
            ),
            contact: PhyContact(
              phyContact: item['contact']['phy_contact'] ?? "",
              phyContactLink: item['contact']['phy_contact_link'] ?? "",
              phyContactPgNo: item['contact']['phy_contact_pg_no'] ?? 0,
            ),
            phyNPI: PhyNPI(phyNPI: item['npi']['phy_NPI'] ?? 0,
                phyNPILink: item['npi']['phy_NPI_link'] ?? "",
                phyFirstNamePgNo: item['npi']['phy_NPI_pg_no'] ?? 0),

            upi: PhyUPI(
              phyUPI: item['upi']['phy_UPI'] ?? "",
              phyUPILink: item['upi']['phy_UPI_link'] ?? "",
              phyUPIPgNo: item['upi']['phy_UPI_pg_no'] ?? 0,
            ),
            city: PhyCity(
              phyCity: item['city']['phy_city'] ?? "",
              phyCityLink: item['city']['phy_city_link'] ?? "",
              phyCityPgNo: item['city']['phy_city_pg_no'] ?? 0,
            ),
            fax: PhyFax(
              phyFax: item['fax']['phy_fax'] ?? "",
              phyFaxLink: item['fax']['phy_fax_link'] ?? "",
              phyFaxPgNo: item['fax']['phy_fax_pg_no'] ?? 0,
            ),
            notes: PhyNotes(
              phyNotes: item['notes']['phy_notes'] ?? "",
              phyNotesLink: item['notes']['phy_notes_link'] ?? "",
              phyNotesPgNo: item['notes']['phy_notes_pg_no'] ?? 0,
            ),
            protocols: PhyProtocols(
              phyProtocols: item['protocols']['phy_protocols'] ?? "",
              phyProtocolsLink: item['protocols']['phy_protocols_link'] ?? "",
              phyProtocolsPgNo: item['protocols']['phy_protocols_pg_no'] ?? 0,
            ),
            state: PhyState(
              phyState: item['state']['phy_state'] ?? "",
              phyStateLink: item['state']['phy_state_link'] ?? "",
              phyStatePgNo: item['state']['phy_state_pg_no'] ?? 0,
            ),
            street: PhyStreet(
              phyStreet: item['street']['phy_street'] ?? "",
              phyStreetLink: item['street']['phy_street_link'] ?? "",
              phyStreetPgNo: item['street']['phy_street_pg_no'] ?? 0,
            ),
            suffix: PhySuffix(
              phySuffix: item['suffix']['phy_suffix'] ?? "",
              phySuffixLink: item['suffix']['phy_suffix_link'] ?? "",
              phySuffixPgNo: item['suffix']['phy_suffix_pg_no'] ?? 0,
            ),
            suite: PhySuite(
              phySuite: item['suite']['phy_suite'] ?? "",
              phySuiteLink: item['suite']['phy_suite_link'] ?? "",
              phySuitePgNo: item['suite']['phy_suite_pg_no'] ?? 0,
            ),
            trackingNotes: PhyTrackingNotes(
              phyTrackingNotes: item['tracking_notes']['phy_trackingNotes'] ?? "",
              phyTrackingNotesLink: item['tracking_notes']['phy_trackingNotes_link'] ?? "",
              phyTrackingNotesPgNo: item['tracking_notes']['phy_trackingNotes_pg_no'] ?? 0,
            ),
            verificationDetails: PhyVerificationDetails(
              phyVerificationDetails: item['verification_details']['phy_verificationDetails'] ?? "",
              phyVerificationDetailsLink: item['verification_details']['phy_verificationDetails_link'] ?? "",
              phyVerificationDetailsPgNo: item['verification_details']['phy_verificationDetails_pg_no'] ?? 0,
            ),
            phyVerified: item['phy_verified'] ?? false,
            zipcode: PhyZipCode(
              phyZipCode: item['zipcode']['phy_zipCode'] ?? "",
              phyZipCodeLink: item['zipcode']['phy_zipCode_link'] ?? "",
              phyZipCodePgNo: item['zipcode']['phy_zipCode_pg_no'] ?? 0,
            ),
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

Future<List<PhysicianDropDownData>> getPhysicianDropDown({
  required BuildContext context,
}) async {
  List<PhysicianDropDownData> itemsList = [];
  try {
    final response = await Api(context).get(path: IntakePhysicianInfo.getDropDownPhysician());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PhysicianDropDownData(
            id: item['id'] ?? 0,
            physicianName: item['name'] ?? 0),
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

///patch
Future<ApiData> updatePhysicianMasterPatch({
  required BuildContext context,
  required int phyId,
  required String phyFirstName,
  required String phyLastName,
  required String? phySuffix,
  required String phyPicoNo,
  required bool phyPicoStatus,
  required String phyEmail,
  required String phyContact,
  required String? phyStreet,
  required String? phySuite,
  required String? phyCity,
  required String? phyState,
  required String? phyZipCode,
  required String? phyFax,
  required int? phyNPI,
  required String? phyUPI,
  required String? phyProtocols,
  required String? phyNotes,
  required bool? phyVerified,
  required String? phyVerificationDetails,
  required String? phyTrackingNotes,
  required int fk_pt_id,
}) async {
  try {
    final companyId = await TokenManager.getCompanyId();

    var response = await Api(context).patch(
      path: IntakePhysicianInfo.patchPhysicianMaster(id: phyId),
      data: {
        "phy_id": phyId,
        "phy_first_name": phyFirstName,
        "phy_last_name": phyLastName,
        "phy_suffix": phySuffix,
        "phy_pico_no": phyPicoNo,
        "phy_pico_status": phyPicoStatus,
        "phy_email": phyEmail,
        "phy_contact": phyContact,
        "phy_street": phyStreet,
        "phy_suite": phySuite,
        "phy_city": phyCity,
        "phy_state": phyState,
        "phy_zipCode": phyZipCode,
        "phy_fax": phyFax,
        "phy_NPI": phyNPI,
        "phy_UPI": phyUPI,
        "phy_protocols": phyProtocols,
        "phy_notes": phyNotes,
        "phy_verified": phyVerified,
        "phy_verificationDetails": phyVerificationDetails,
        "phy_trackingNotes": phyTrackingNotes,
        "fk_pt_id":fk_pt_id,
      },
    );

    print('Physician Patch Response: $response');

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
