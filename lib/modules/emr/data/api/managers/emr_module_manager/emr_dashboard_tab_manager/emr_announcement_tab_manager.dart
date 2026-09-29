import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/emr_announcement_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/dashboard_emr_repo.dart';

// ── Clinician Alerts ──────────────────────────────────────────────────────────

Future<List<ClinicianAlertDataDashboard>> getClinicianAlerts(
    BuildContext context,
    int clinicianId,
    ) async {
  List<ClinicianAlertDataDashboard> itemsList = [];
  try {
    final response = await Api(context).get(
      path: ClinicianAlertRepository.getByClinician(clinicianId: clinicianId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data['data']) {
        List<AlertClinicianData> cliniciansList = [];
        for (var c in item['clinicians']) {
          cliniciansList.add(
            AlertClinicianData(
              employeeId:   c['employeeId'],
              fullName:     c['fullName'] ?? '',
              imgurl:       c['imgurl'] ?? '',
              abbreviation: c['abbreviation'] ?? '',
              color:        c['color'] ?? '',
            ),
          );
        }
        itemsList.add(
          ClinicianAlertDataDashboard(
            alertId:      item['alert_id'],
            alertHeading: item['alert_heading'] ?? '--',
            alertBody:    item['alert_body'] ?? '--',
            alertType:    item['alert_type'] ?? '--',
            alertResolve: item['alert_resolve'] ?? false,
            fkPtId:       item['fk_pt_id'] ?? 0,
            createdAt:    item['created_at'] ?? '',
            clinicians:   cliniciansList,
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

// ── Clinician Today Visits Map ────────────────────────────────────────────────

Future<ClinicianVisitsMapData?> getClinicianTodayMapData(
    BuildContext context,
    int clinicianId,
    String selectedDate
    ) async {
  try {
    final response = await Api(context).getWithQueryParam(
      path: ClinicianVisitsMapRepository.getTodayMapData(
          clinicianId: clinicianId),
      queryParameters: {
        "date":selectedDate
      }
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final raw = response.data;

      // ── Clinician ──────────────────────────────────────────────
      final c = raw['clinician'];
      final clinician = ClinicianLocationData(
        employeeId: c['employeeId'],
        name:       c['name'] ?? '',
        imageUrl:   c['imageUrl'],
        latitude:   (c['latitude'] as num).toDouble(),
        longitude:  (c['longitude'] as num).toDouble(),
      );

      // ── Visits ─────────────────────────────────────────────────
      List<VisitMapData> visitsList = [];
      for (var v in raw['visits']) {
        // Skip visits with no geocoded coordinates (invalid address)
        if (v['latitude'] == null || v['longitude'] == null) continue;

        visitsList.add(
          VisitMapData(
            visitId:           v['visitId'],
            visitNumber:       v['visitNumber'],
            patientId:         v['patientId'],
            patientName:       v['patientName'] ?? '',
            patientImageUrl:   v['patientImageUrl'],
            address:           v['address'] ?? '',
            latitude:          (v['latitude'] as num).toDouble(),
            longitude:         (v['longitude'] as num).toDouble(),
            visitStatus:       v['visitStatus'] ?? 'NOT_STARTED',
            visitDateTimeFrom: v['visitDateTimeFrom'] ?? '',
            visitDateTimeTo:   v['visitDateTimeTo'] ?? '',
          ),
        );
      }

      print("Response:::::${response}");
      return ClinicianVisitsMapData(clinician: clinician, visits: visitsList);
    } else {
      print('Api Error');
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}