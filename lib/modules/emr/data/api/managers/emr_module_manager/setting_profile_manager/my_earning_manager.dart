import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/my_earning_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/setting_profile_emr_repo/profile_secton_repo.dart';

Future<CompletedVisitsStatsData?> getCompletedVisitsStats({
  required BuildContext context,
}) async {
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getCompletedVisitsStats(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CompletedVisitsStatsData(
        total: response.data['total'] ?? 0,
        thisWeek: response.data['thisWeek'] ?? 0,
        thisMonth: response.data['thisMonth'] ?? 0,
        today: response.data['today'] ?? 0,
      );
    } else {
      debugPrint("Completed visits stats error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("getCompletedVisitsStats error: $e");
    return null;
  }
}






///
///
Future<ClinicianEarningData?> getClinicianEarning({
  required BuildContext context,
  required int clinicianId,
}) async {
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getClinicianEarning( clinicianId: clinicianId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClinicianEarningData(
        clinicianId: response.data['clinicianId'] ?? 0,
        total:       response.data['total']       ?? 0,
        thisMonth:   response.data['thismonth']   ?? 0,
        thisWeek:    response.data['thisweek']    ?? 0,
        today:       response.data['today']       ?? 0,
      );
    } else {
      debugPrint("getClinicianEarning error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("getClinicianEarning error: $e");
    return null;
  }
}





///today visit  list
Future<List<TodayCompletedVisitData>?> getTodayCompletedVisits({
  required BuildContext context,
}) async {
  try {
    final response = await Api(context).get(
      path: ProfileSectonRepo.getTodayCompletedVisits(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List data = response.data as List;
      return data.map((item) => TodayCompletedVisitData(
        visitId:          item['visitId']          ?? 0,
        patientId:        item['patientId']        ?? 0,
        patientName:      item['patientName']      ?? '',
        patientAvatarUrl: item['patientAvatarUrl'] ?? '',
        startTime:        item['startTime']        ?? '',
        endTime:          item['endTime']          ?? '',
        dayLabel:         item['dayLabel']         ?? '',
        visitCharge:      item['visit_charge']     ?? 0,
      )).toList();
    } else {
      debugPrint("getTodayCompletedVisits error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("getTodayCompletedVisits error: $e");
    return null;
  }
}