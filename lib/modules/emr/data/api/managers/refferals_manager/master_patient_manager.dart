import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/refferals/patient_refferal_repo.dart';

///  patient physician master
Future<List<PatientPhysicianMasterData>> getPatientPhysicianMaster({
  required BuildContext context,
}) async {
  List<PatientPhysicianMasterData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.patientPhysicianmaster(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(
          PatientPhysicianMasterData(
            phyId: item['phy_id'] ?? 0,
            firstName: NameField(
              value: item['first_name']?['phy_first_name'] ?? '--',
              link: item['first_name']?['phy_first_name_link'] ?? '',
              pgNo: item['first_name']?['phy_first_name_pg_no'] ?? 0,
            ),
            lastName: NameField(
              value: item['last_name']?['phy_last_name'] ?? '--',
              link: item['last_name']?['phy_last_name_link'] ?? '',
              pgNo: item['last_name']?['phy_last_name_pg_no'] ?? 0,
            ),
            picoNo: PicoNoField(
              value: item['pico_no']?['phy_pico_no'] ?? '',
              link: item['pico_no']?['phy_pico_no_link'] ?? '',
              pgNo: item['pico_no']?['phy_pico_no_pg_no'] ?? 0,
            ),
            phyPicoStatus: item['phy_pico_status'] ?? false,
            email: EmailField(
              value: item['email']?['phy_email'] ?? '--',
              link: item['email']?['phy_email_link'] ?? '',
              pgNo: item['email']?['phy_email_pg_no'] ?? 0,
            ),
            contact: ContactField(
              value: item['contact']?['phy_contact'] ?? '',
              link: item['contact']?['phy_contact_link'] ?? '',
              pgNo: item['contact']?['phy_contact_pg_no'] ?? 0,
            ),
            phyNPI: NpiField(
              value: item['npi']?['phy_NPI'] ?? 0,
              link: item['npi']?['phy_NPI_link'] ?? '',
              pgNo: item['npi']?['phy_NPI_pg_no'] ?? 0,
            ),
            upi: UpiField(
              value: item['upi']?['phy_UPI'] ?? '',
              link: item['upi']?['phy_UPI_link'] ?? '',
              pgNo: item['upi']?['phy_UPI_pg_no'] ?? 0,
            ),
            city: CityField(
              value: item['city']?['phy_city'] ?? '',
              link: item['city']?['phy_city_link'] ?? '',
              pgNo: item['city']?['phy_city_pg_no'] ?? 0,
            ),
            fax: FaxField(
              value: item['fax']?['phy_fax'] ?? '',
              link: item['fax']?['phy_fax_link'] ?? '',
              pgNo: item['fax']?['phy_fax_pg_no'] ?? 0,
            ),
            notes: NotesField(
              value: item['notes']?['phy_notes'] ?? '',
              link: item['notes']?['phy_notes_link'] ?? '',
              pgNo: item['notes']?['phy_notes_pg_no'] ?? 0,
            ),
            protocols: ProtocolsField(
              value: item['protocols']?['phy_protocols'] ?? '',
              link: item['protocols']?['phy_protocols_link'] ?? '',
              pgNo: item['protocols']?['phy_protocols_pg_no'] ?? 0,
            ),
            state: StateField(
              value: item['state']?['phy_state'] ?? '',
              link: item['state']?['phy_state_link'] ?? '',
              pgNo: item['state']?['phy_state_pg_no'] ?? 0,
            ),
            street: StreetField(
              value: item['street']?['phy_street'] ?? '',
              link: item['street']?['phy_street_link'] ?? '',
              pgNo: item['street']?['phy_street_pg_no'] ?? 0,
            ),
            suffix: SuffixField(
              value: item['suffix']?['phy_suffix'] ?? '',
              link: item['suffix']?['phy_suffix_link'] ?? '',
              pgNo: item['suffix']?['phy_suffix_pg_no'] ?? 0,
            ),
            suite: SuiteField(
              value: item['suite']?['phy_suite'] ?? '',
              link: item['suite']?['phy_suite_link'] ?? '',
              pgNo: item['suite']?['phy_suite_pg_no'] ?? 0,
            ),
            trackingNotes: TrackingNotesField(
              value: item['tracking_notes']?['phy_trackingNotes'] ?? '',
              link: item['tracking_notes']?['phy_trackingNotes_link'] ?? '',
              pgNo: item['tracking_notes']?['phy_trackingNotes_pg_no'] ?? 0,
            ),
            verificationDetails: VerificationDetailsField(
              value: item['verification_details']?['phy_verificationDetails'] ?? '',
              link: item['verification_details']?['phy_verificationDetails_link'] ?? '',
              pgNo: item['verification_details']?['phy_verificationDetails_pg_no'] ?? 0,
            ),
            phyVerified: item['phy_verified'] ?? false,
            zipcode: ZipCodeField(
              value: item['zipcode']?['phy_zipCode'] ?? '',
              link: item['zipcode']?['phy_zipCode_link'] ?? '',
              pgNo: item['zipcode']?['phy_zipCode_pg_no'] ?? 0,
            ),
          ),
        );
      }

    }
    else {
      print("patient physician master");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}


///  patient referral master
Future<List<PatientRefferalSourcesData>> getPatientreferralsMaster({
  required BuildContext context,
}) async {
  List<PatientRefferalSourcesData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.patientReffrealsSources(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientRefferalSourcesData(
            ref_source_id: item['ref_source_id']??0,
            source_name: item['source_name']??'',
            description: item['description']??'',
            referral_source_img_url: item['referral_source_img_url']??'',
            documentName:item['documentName']??''
        ));
      }
    }
    else {
      print("patient referrals master");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

///  patient Diagnosis master
Future<List<PatientDiagnosisMasterData>> getPatientDiagnosisMaster({
  required BuildContext context,
}) async {
  List<PatientDiagnosisMasterData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.getDiagnosisMaster(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientDiagnosisMasterData(
            dgnId: item['dgn_id']??0,
            dgnName: item['dgn_name']??'',
            dgnCode: item['dgn_code']??''

        ));
      }
    }
    else {
      print("patient Diagnosis master");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}

///  patient referral master
Future<List<PatientRefferalSourcesData>> getPatientreferralsSearchMaster({
  required BuildContext context,
  required String nameSearch
}) async {
  List<PatientRefferalSourcesData> itemsData = [];
  try {
    final response = await Api(context).get(
      path: PatientRefferalsRepo.patientReffrealsSearchSources(searchPatient: nameSearch),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsData.add(PatientRefferalSourcesData(
            ref_source_id: item['ref_source_id']??0,
            source_name: item['source_name']??'',
            description: item['description']??'',
            referral_source_img_url: item['referral_source_img_url']??'',
            documentName:item['documentName']??''
        ));
      }
    }
    else {
      print("patient referrals master");
    }

    return itemsData;
  } catch (e) {
    print("error: $e");
    return itemsData;
  }
}