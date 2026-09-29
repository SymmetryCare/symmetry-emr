import 'package:flutter/material.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/schedule_visit_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';


class VisitDetailsRepository {
  static String _visitDetails = '/patient-visits/visit-details';

  static String getVisitDetails({required int visitId}) {
    return '$_visitDetails/$visitId';
  }
}


List<dynamic> _parseAlertList(dynamic value) {
  if (value == null) return [];
  if (value is List) return List<dynamic>.from(value);
  return [];
}


Future<VisitDetailsData?> getVisitDetails(
    BuildContext context,
    int visitId,
    ) async {
  try {
    final response = await Api(context).get(
      path: VisitDetailsRepository.getVisitDetails(visitId: visitId),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 304) {
      final d = response.data;

      final patient  = d['patient'];
      final visit    = d['visit'];
      final episode  = d['episode'];
      final alerts   = d['alerts'];

      List<VisitClinicianData> cliniciansList = [];
      for (var item in d['clinicians']) {
        cliniciansList.add(
          VisitClinicianData(
            employeeId:               item['employeeId'] ?? 0,
            name:                     item['name'] ?? '',
            imageUrl:                 item['imageUrl'] ?? '',
            phone:                    item['phone'] ?? '',
            employeeTypeId:           item['employeeTypeId'] ?? 0,
            employeeTypeAbbreviation: item['employeeTypeAbbreviation'] ?? '',
            employeeTypeColor:        item['employeeTypeColor'] ?? '',
          ),
        );
      }

      print("Response:::::: $response");

      return VisitDetailsData(
        patient: VisitPatientData(
          ptId:          patient['ptId'] ?? 0,
          name:          patient['name'] ?? '',
          imageUrl:      patient['imageUrl'] ?? '',
          mrn:           patient['MRN'] ?? 0,
          dateOfBirth:   patient['dateOfBirth'] ?? '',
          age:           patient['age'] ?? 0,
          phone:         patient['phone'] ?? '',
          address:       patient['address'] ?? '',
          zoneId:        patient['zoneId'],
          zoneName:      patient['zoneName'],
          diagnosisId:   patient['diagnosisId'] ?? 0,
          diagnosisName: patient['diagnosisName'] ?? '',
          genderId:      patient['genderId'] ?? 0,
          genderName:    patient['genderName'] ?? '',
        ),
        visit: VisitInfoData(
          visitId:       visit['visitId'] ?? 0,
          visitTypeId:   visit['visitTypeId'] ?? 0,
          visitTypeName: visit['visitTypeName'] ?? '',
          visitDateFrom: visit['visitDateFrom'] ?? '',
          visitDateTo:   visit['visitDateTo'] ?? '',
          isCompleted:   visit['isCompleted'] ?? false,
          isMissed:      visit['isMissed'] ?? false,
          onWay:         visit['onWay'] ?? false,
          inZone:        visit['inZone'] ?? false,
          isRescheduled: visit['isRescheduled'] ?? false,
          recordTypeId:  visit['recordTypeId'],
          requestType:   visit['requestType'],
          visitCharge:   (visit['visit_charge'] ?? 0.0).toDouble(),
        ),
        episode: VisitEpisodeData(
          episodeId:     episode['episodeId'] ?? 0,
          chartNumber:   episode['chartNumber'] ?? 0,
          episodeNumber: episode['episodeNumber'] ?? 0,
          episodeFrom:   episode['episodeFrom'],
          episodeTo:     episode['episodeTo'],
        ),
        clinicians: cliniciansList,
        alerts: VisitAlertsData(
          visitAlerts:   _parseAlertList(alerts['visitAlerts']),
          patientAlerts: _parseAlertList(alerts['patientAlerts']),
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