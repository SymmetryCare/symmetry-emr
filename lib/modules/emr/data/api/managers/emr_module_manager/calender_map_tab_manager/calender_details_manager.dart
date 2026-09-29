import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/calender_map_data/caledner_details_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
// NOTE: keep your existing Api import path here, e.g.:
// import '../../../../api.dart';

class PatientVisitCalenderRepository {
  static String _patientVisits = '/patient-visits';
  static String _visitDetails = '/visit-details';

  static String getVisitDetailsById({required int visitId}) {
    return '$_patientVisits$_visitDetails/$visitId';
  }
}

Future<PatientVisitCalenderDetailsData?> getPatientVisitCalenderDetails(
    BuildContext context,
    int visitId,
    ) async {
  try {
    final response = await Api(context).get(
      path: PatientVisitCalenderRepository.getVisitDetailsById(visitId: visitId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final item = response.data;

      final patient = item['patient'];
      final visit = item['visit'];
      final episode = item['episode'];
      final cliniciansList = (item['clinicians'] as List?) ?? [];
      final alertsMap = item['alerts'];

      print("Response:::::: ${response}");

      return PatientVisitCalenderDetailsData(
        patient: PatientCalenderDetailsData(
          ptId: patient['ptId'] ?? 0,
          name: patient['name'] ?? '',
          imageUrl: patient['imageUrl'] ?? '',
          MRN: patient['MRN'] ?? 0,
          dateOfBirth: patient['dateOfBirth'] ?? '',
          age: patient['age'] ?? 0,
          phone: patient['phone'] ?? '',
          address: patient['address'] ?? '',
          zoneId: patient['zoneId'],
          zoneName: patient['zoneName'],
          diagnosisId: patient['diagnosisId'] ?? 0,
          diagnosisName: patient['diagnosisName'] ?? '',
          genderId: patient['genderId'] ?? 0,
          genderName: patient['genderName'] ?? '',
        ),
        visit: VisitCalenderDetailsData(
          visitId: visit['visitId'] ?? 0,
          visitTypeId: visit['visitTypeId'] ?? 0,
          visitTypeName: visit['visitTypeName'] ?? '',
          visitDateFrom: visit['visitDateFrom'] ?? '',
          visitDateTo: visit['visitDateTo'] ?? '',
          isCompleted: visit['isCompleted'] ?? false,
          isMissed: visit['isMissed'] ?? false,
          onWay: visit['onWay'] ?? false,
          inZone: visit['inZone'] ?? false,
          isRescheduled: visit['isRescheduled'] ?? false,
          recordTypeId: visit['recordTypeId'],
          requestType: visit['requestType'],
          visitCharge: (visit['visit_charge'] as num?)?.toDouble() ?? 0.0,
        ),
        episode: EpisodeCalenderDetailsData(
          episodeId: episode['episodeId'] ?? 0,
          chartNumber: episode['chartNumber'] ?? 0,
          episodeNumber: episode['episodeNumber'] ?? 0,
          episodeFrom: episode['episodeFrom'] ?? '',
          episodeTo: episode['episodeTo'] ?? '',
        ),
        // FIX: every field on ClinicianCalenderDetailsData is non-nullable
        // (`required`), but previously only imageUrl had a fallback. A
        // clinician record missing any other field (name, phone,
        // employeeTypeAbbreviation, etc.) would throw:
        //   type 'Null' is not a subtype of type 'String'
        // and crash the whole Visit Details screen. All fields now have
        // safe fallbacks, matching the pattern already used for patient/visit.
        clinicians: cliniciansList.map((c) => ClinicianCalenderDetailsData(
          employeeId: c['employeeId'] ?? 0,
          name: c['name'] ?? '',
          imageUrl: c['imageUrl'] ?? '',
          phone: c['phone'] ?? '',
          employeeTypeId: c['employeeTypeId'] ?? 0,
          employeeTypeAbbreviation: c['employeeTypeAbbreviation'] ?? '',
          employeeTypeColor: c['employeeTypeColor'] ?? '',
        )).toList(),
        alerts: AlertsCalenderDetailsData(
          visitAlerts: alertsMap?['visitAlerts'] ?? [],
          patientAlerts: alertsMap?['patientAlerts'] ?? [],
        ),
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