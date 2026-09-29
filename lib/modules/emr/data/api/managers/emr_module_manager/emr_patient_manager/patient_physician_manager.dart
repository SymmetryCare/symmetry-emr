
import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_physician_model.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/emr_patient_repo/patient_physician_repo.dart';

Future<List<PatientPhysicianModel>> getEmrPatientPhysicians({
  required BuildContext context,
  required int patientId,
}) async {
  List<PatientPhysicianModel> itemsList = [];
  try {
    final response = await Api(context).get(path: PatientPhysicianRepo.getPatientPhysicianEndpoint(patientId: patientId));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PatientPhysicianModel(
          phyId: item['phy_id'] ?? 0,
          firstName: PatientPhyFirstName(
            phyFirstName: item['first_name']['phy_first_name'] ?? "",
            phyFirstNameLink: item['first_name']['phy_first_name_link'] ?? "",
            phyFirstNamePgNo: item['first_name']['phy_first_name_pg_no'] ?? 0,
          ),
          lastName: PatientPhyLastName(
            phyLastName: item['last_name']['phy_last_name'] ?? "",
            phyLastNameLink: item['last_name']['phy_last_name_link'] ?? "",
            phyLastNamePgNo: item['last_name']['phy_last_name_pg_no'] ?? 0,
          ),
          picoNo: PatientPhyPicoNo(
            phyPicoNo: item['pico_no']['phy_pico_no'] ?? "",
            phyPicoNoLink: item['pico_no']['phy_pico_no_link'] ?? "",
            phyPicoNoPgNo: item['pico_no']['phy_pico_no_pg_no'] ?? 0,
          ),
          phyPicoStatus: item['phy_pico_status'] ?? false,
          email: PatientPhyEmail(
            phyEmail: item['email']['phy_email'] ?? "",
            phyEmailLink: item['email']['phy_email_link'] ?? "",
            phyEmailPgNo: item['email']['phy_email_pg_no'] ?? 0,
          ),
          contact: PatientPhyContact(
            phyContact: item['contact']['phy_contact'] ?? "",
            phyContactLink: item['contact']['phy_contact_link'] ?? "",
            phyContactPgNo: item['contact']['phy_contact_pg_no'] ?? 0,
          ),
          phyNPI: PatientPhyNPI(phyNPI: item['npi']['phy_NPI'] ?? 0,
              phyNPILink: item['npi']['phy_NPI_link'] ?? "",
              phyFirstNamePgNo: item['npi']['phy_NPI_pg_no'] ?? 0),

          upi: PatientPhyUPI(
            phyUPI: item['upi']['phy_UPI'] ?? "",
            phyUPILink: item['upi']['phy_UPI_link'] ?? "",
            phyUPIPgNo: item['upi']['phy_UPI_pg_no'] ?? 0,
          ),
          city: PatientPhyCity(
            phyCity: item['city']['phy_city'] ?? "",
            phyCityLink: item['city']['phy_city_link'] ?? "",
            phyCityPgNo: item['city']['phy_city_pg_no'] ?? 0,
          ),
          fax: PatientPhyFax(
            phyFax: item['fax']['phy_fax'] ?? "",
            phyFaxLink: item['fax']['phy_fax_link'] ?? "",
            phyFaxPgNo: item['fax']['phy_fax_pg_no'] ?? 0,
          ),
          notes: PatientPhyNotes(
            phyNotes: item['notes']['phy_notes'] ?? "",
            phyNotesLink: item['notes']['phy_notes_link'] ?? "",
            phyNotesPgNo: item['notes']['phy_notes_pg_no'] ?? 0,
          ),
          protocols: PatientPhyProtocols(
            phyProtocols: item['protocols']['phy_protocols'] ?? "",
            phyProtocolsLink: item['protocols']['phy_protocols_link'] ?? "",
            phyProtocolsPgNo: item['protocols']['phy_protocols_pg_no'] ?? 0,
          ),
          state: PatientPhyState(
            phyState: item['state']['phy_state'] ?? "",
            phyStateLink: item['state']['phy_state_link'] ?? "",
            phyStatePgNo: item['state']['phy_state_pg_no'] ?? 0,
          ),
          street: PatientPhyStreet(
            phyStreet: item['street']['phy_street'] ?? "",
            phyStreetLink: item['street']['phy_street_link'] ?? "",
            phyStreetPgNo: item['street']['phy_street_pg_no'] ?? 0,
          ),
          suffix: PatientPhySuffix(
            phySuffix: item['suffix']['phy_suffix'] ?? "",
            phySuffixLink: item['suffix']['phy_suffix_link'] ?? "",
            phySuffixPgNo: item['suffix']['phy_suffix_pg_no'] ?? 0,
          ),
          suite: PatientPhySuite(
            phySuite: item['suite']['phy_suite'] ?? "",
            phySuiteLink: item['suite']['phy_suite_link'] ?? "",
            phySuitePgNo: item['suite']['phy_suite_pg_no'] ?? 0,
          ),
          trackingNotes: PatientPhyTrackingNotes(
            phyTrackingNotes: item['tracking_notes']['phy_trackingNotes'] ?? "",
            phyTrackingNotesLink: item['tracking_notes']['phy_trackingNotes_link'] ?? "",
            phyTrackingNotesPgNo: item['tracking_notes']['phy_trackingNotes_pg_no'] ?? 0,
          ),
          verificationDetails: PatientPhyVerificationDetails(
            phyVerificationDetails: item['verification_details']['phy_verificationDetails'] ?? "",
            phyVerificationDetailsLink: item['verification_details']['phy_verificationDetails_link'] ?? "",
            phyVerificationDetailsPgNo: item['verification_details']['phy_verificationDetails_pg_no'] ?? 0,
          ),
          phyVerified: item['phy_verified'] ?? false,
          zipcode: PatientPhyZipCode(
            phyZipCode: item['zipcode']['phy_zipCode'] ?? "",
            phyZipCodeLink: item['zipcode']['phy_zipCode_link'] ?? "",
            phyZipCodePgNo: item['zipcode']['phy_zipCode_pg_no'] ?? 0,
          ),
          profileUrl: PatientPhyUrl(
            phyUrl: item['profile_url']['phy_url'] ?? "",
            phyUrlLink: item['profile_url']['phy_url_link'] ?? "",
            phyUrlPgNo: item['profile_url']['phy_url_pg_no'] ?? 0,
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