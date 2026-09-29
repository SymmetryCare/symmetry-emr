import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/calender_map_data/calender_map_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';

Future<List<ClinicianCalendarVisitData>?> getClinicianCalendarVisits({
  required BuildContext context,
  required String dateFrom,
  required String dateTo,
}) async {
  try {
    print("getClinicianCalendarVisits called >> dateFrom: $dateFrom | dateTo: $dateTo");

    final response = await Api(context).get(
      path: ProfileSectonRepo.getClinicianCalendar(
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );

    print("getClinicianCalendarVisits statusCode >> ${response.statusCode}");
    print("getClinicianCalendarVisits response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> visitsList = response.data['visits'] ?? [];
      final List<dynamic> holidaysRaw = response.data['holidays'] ?? [];

      final List<HolidayData> holidays = holidaysRaw
          .map((h) => HolidayData.fromJson(h as Map<String, dynamic>))
          .toList();

      print("getClinicianCalendarVisits visits count >> ${visitsList.length}");

      return visitsList.map((visit) {
        return ClinicianCalendarVisitData(
          visitId: visit['visitId'] ?? 0,
          patientId: visit['patientId'] ?? 0,
          patientName: visit['patientName'] ?? '',
          patientImgUrl: visit['patientImgUrl'] ?? '',
          primaryDiagnosis: visit['primaryDiagnosis'] ?? '',
          visitTypeName: visit['visitTypeName'] ?? '',
          isAuthorized: visit['isAuthorized'] ?? false,
          location: visit['location'] ?? '',
          distance: visit['distance'] ?? '',
          inZone: visit['inZone'] ?? false,
          visiteDateTimeFrom: visit['visiteDateTimeFrom'] ?? '',
          visitDateTimeTo: visit['visitDateTimeTo'] ?? '',
          isVisitCompleted: visit['isVisitCompleted'] ?? false,
          isVisitMissed: visit['isVisitMissed'] ?? false,
          isRescheduled: visit['isRescheduled'] ?? false,
          onWay: visit['onWay'] ?? false,
          holidayList:holidays
        );
      }).toList();
    } else {
      print("getClinicianCalendarVisits error statusCode >> ${response.statusCode}");
      debugPrint("Clinician calendar error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getClinicianCalendarVisits catch error >> $e");
    debugPrint("getClinicianCalendarVisits error: $e");
    return null;
  }
}