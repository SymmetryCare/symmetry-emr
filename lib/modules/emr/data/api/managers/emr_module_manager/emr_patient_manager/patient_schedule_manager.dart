import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_schedule_data.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/emr_patient_repo/patient_schedule_repo.dart';

// ── Episode Chart Dropdown ────────────────────────────────────────────────────
Future<List<EpisodeChartDropdownData>> getEpisodeChartDropdown(
    BuildContext context,
    int ptId,
    ) async {
  List<EpisodeChartDropdownData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: PatientScheduleModuleRepository.chartDropdown(ptId: ptId),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(
          EpisodeChartDropdownData(
            ptEpisodeId: item['pt_episodeId'],
            episodeId:   item['episode_id'],
            chartId:     item['chart_id'],
            label:       item['label'],
            episodeFrom: item['episodeFrom'],
            episodeTo:   item['episodeTo'],
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

// ── LUPA ──────────────────────────────────────────────────────────────────────
Future<LupaData?> getLupa(
    BuildContext context,
    int ptId,
    int ptEpisodeId,
    ) async {
  try {
    final response = await Api(context).get(
      path: PatientScheduleModuleRepository.lupa(
        ptId: ptId,
        ptEpisodeId: ptEpisodeId,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final ep  = response.data['episode'];
      final f30 = response.data['first30'];
      final s30 = response.data['second30'];
      print("Response:::::${response}");
      return LupaData(
        episode: LupaEpisodeData(
          ptEpisodeId: ep['pt_episodeId'],
          episodeFrom: ep['episodeFrom'],
          episodeTo:   ep['episodeTo'],
        ),
        first30: LupaPeriodData(
          dateFrom:        f30['dateFrom'],
          dateTo:          f30['dateTo'],
          completedVisits: f30['completedVisits'],
          totalVisits:     f30['totalVisits'],
        ),
        second30: LupaPeriodData(
          dateFrom:        s30['dateFrom'],
          dateTo:          s30['dateTo'],
          completedVisits: s30['completedVisits'],
          totalVisits:     s30['totalVisits'],
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

// ── Patient Daily Visit List ──────────────────────────────────────────────────
Future<List<PatientDailyVisitData>> getPatientDailyVisitList(
    BuildContext context,
    int ptId,
    String date,
    ) async {
  List<PatientDailyVisitData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: PatientScheduleModuleRepository.dailyList(ptId: ptId, date: date),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        final d = item['discipline'];
        final c = item['clinician'];
        itemsList.add(
          PatientDailyVisitData(
            visitId:       item['visitId'],
            timeFrom:      item['timeFrom'],
            timeTo:        item['timeTo'],
            status:        item['status'],
            visitTypeName: item['visitTypeName'],
            discipline: DailyVisitDisciplineData(
              employeeTypeId: d['employeeTypeId'],
              name:           d['name'],
              abbreviation:   d['abbreviation'],
              color:          d['color'],
            ),
            clinician: DailyVisitClinicianData(
              employeeId: c['employeeId'],
              name:       c['name'],
              imgUrl:     c['imgUrl'],
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

// ── Patient Schedule ──────────────────────────────────────────────────────────
Future<PatientScheduleData?> getPatientSchedule(
    BuildContext context,
    int ptId,
    int ptEpisodeId,
    ) async {
  try {
    final response = await Api(context).get(
      path: PatientScheduleModuleRepository.patientSchedule(
        ptId: ptId,
        ptEpisodeId: ptEpisodeId,
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final ep = response.data['episode'];

      List<PatientScheduleVisitData> visitsList = [];
      for (var item in response.data['visits']) {
        final d = item['discipline'];
        final c = item['clinician'];
        visitsList.add(
          PatientScheduleVisitData(
            visitId:        item['visitId'],
            visitDate:      item['visitDate'],
            timeFrom:       item['timeFrom'],
            timeTo:         item['timeTo'],
            status:         item['status'],
            visitTypeName:  item['visitTypeName'],
            discipline: PatientScheduleDisciplineData(
              employeeTypeId: d['employeeTypeId'],
              name:           d['name'],
              abbreviation:   d['abbreviation'],
              color:          d['color'],
            ),
            clinician: PatientScheduleClinicianData(
              employeeId: c['employeeId'],
              name:       c['name'],
              imgUrl:     c['imgUrl'],
            ),
            isEpisodeStart:  item['isEpisodeStart'],
            is2nd30DayStart: item['is2nd30DayStart'],
          ),
        );
      }

      print("Response:::::${response}");
      return PatientScheduleData(
        episode: PatientScheduleEpisodeData(
          ptEpisodeId:  ep['pt_episodeId'],
          ptId:         ep['pt_id'],
          chartId:      ep['chart_id'],
          episodeId:    ep['episode_id'],
          episodeFrom:  ep['episodeFrom'],
          episodeTo:    ep['episodeTo'],
          mid30DayDate: ep['mid30DayDate'],
        ),
        visits: visitsList,
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




