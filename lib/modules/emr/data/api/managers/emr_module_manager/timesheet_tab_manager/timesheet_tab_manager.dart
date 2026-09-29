import 'package:flutter/material.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/emr_repository/timesheet_repo.dart';


Future<ClinicianMonthlyCalendarData?> getClinicianMonthlyCalendar(
    BuildContext context,
    int year,
    int month,
    ) async {
  try {
    print("getClinicianMonthlyCalendar called >> year: $year | month: $month");

    final response = await Api(context).get(
      path: TimesheetRepo.getClinicianMonthlyCalendar(
        year:  year,
        month: month,
      ),
    );

    print("getClinicianMonthlyCalendar statusCode >> ${response.statusCode}");
    print("getClinicianMonthlyCalendar response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<ClinicianCalendarDayData> daysList = [];

      for (var day in response.data['days']) {
        daysList.add(
          ClinicianCalendarDayData(
            date:           day['date'] ?? '',
            visitStatus:    day['visitStatus'] ?? '',
            visitCount:     day['visitCount'] ?? 0,
            earnedAmount:   (day['earnedAmount'] ?? 0).toDouble(),
            expectedAmount: (day['expectedAmount'] ?? 0).toDouble(),
          ),
        );
      }

      print("getClinicianMonthlyCalendar days count >> ${daysList.length}");
      print("Response:::::${response}");

      return ClinicianMonthlyCalendarData(
        year:  response.data['year'] ?? year,
        month: response.data['month'] ?? month,
        days:  daysList,
      );
    } else {
      print("getClinicianMonthlyCalendar Api Error >> ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}


///payroll dropdown

Future<PayrollPeriodResponseData?> getPayrollPeriodCurrent({
  required BuildContext context,
}) async {
  try {
    print("getPayrollPeriodCurrent called");

    final response = await Api(context).get(
      path: TimesheetRepo.getPayrollPeriodCurrent,
    );

    print("getPayrollPeriodCurrent statusCode >> ${response.statusCode}");
    print("getPayrollPeriodCurrent response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> periodsList = response.data['periods'] ?? [];

      print("getPayrollPeriodCurrent periods count >> ${periodsList.length}");

      final List<PayrollPeriodData> periods = periodsList.map((period) {
        return PayrollPeriodData(
          periodNumber: period['period_number'] ?? 0,
          label: period['label'] ?? '',
          startDate: period['start_date'] ?? '',
          endDate: period['end_date'] ?? '',
          isCurrent: period['is_current'] ?? false,
        );
      }).toList();

      return PayrollPeriodResponseData(
        year: response.data['year'] ?? 0,
        month: response.data['month'] ?? 0,
        periods: periods,
      );
    } else {
      print("getPayrollPeriodCurrent error statusCode >> ${response.statusCode}");
      debugPrint("Payroll period current error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getPayrollPeriodCurrent catch error >> $e");
    debugPrint("getPayrollPeriodCurrent error: $e");
    return null;
  }
}



///post api
///

Future<ApiData> postClinicianEvent({
  required BuildContext context,
  required String eventTitle,
  required String date,
  required int supervisorId,
  required String startTime,
  required String endTime,
}) async {
  try {
    final response = await Api(context).post(
      path: TimesheetRepo.postClinicianEvent,
      data: {
        "event_title": eventTitle,
        "date": date,
        "supervisor_id": supervisorId,
        "start_time": startTime,
        "end_time": endTime,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Clinician event created successfully");
      return ApiData(
        statusCode: response.statusCode!,
        success: true,
        message: response.statusMessage!,
      );
    } else {
      debugPrint("postClinicianEvent error: ${response.statusCode}");
      return ApiData(
        statusCode: response.statusCode!,
        success: false,
        message: response.data['message'],
      );
    }
  } catch (e) {
    debugPrint("postClinicianEvent error: $e");
    return ApiData(
      statusCode: 404,
      success: false,
      message: AppString.somethingWentWrong,
    );
  }
}





////supervisor dropdown

Future<SupervisorResponseData?> getSupervisors({
  required BuildContext context,
}) async {
  try {
    print("getSupervisors called");

    final response = await Api(context).get(
      path: TimesheetRepo.getSupervisors,
    );

    print("getSupervisors statusCode >> ${response.statusCode}");
    print("getSupervisors response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data['data'] ?? [];

      print("getSupervisors count >> ${dataList.length}");

      final List<SupervisorData> supervisors = dataList.map((item) {
        return SupervisorData(
          employeeId: item['employeeId'] ?? 0,
          name: item['name'] ?? '',
        );
      }).toList();

      return SupervisorResponseData(
        message: response.data['message'] ?? '',
        data: supervisors,
      );
    } else {
      print("getSupervisors error statusCode >> ${response.statusCode}");
      debugPrint("getSupervisors error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getSupervisors catch error >> $e");
    debugPrint("getSupervisors error: $e");
    return null;
  }
}







///
/// NOTE: Kept for backward compatibility, but this endpoint 404s — the
/// backend only exposes /clinician-event/list/{clinicianId}, not
/// /clinician-event/list/{date}. Use getClinicianEventListByClinician below.
Future<ClinicianEventListResponseData?> getClinicianEventList({
  required BuildContext context,
  String? date,
}) async {
  try {
    print("getClinicianEventList called >> date: $date");

    final response = await Api(context).get(
      path: TimesheetRepo.getClinicianEventListByDate(date: date!),
    );

    print("getClinicianEventList statusCode >> ${response.statusCode}");
    print("getClinicianEventList response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data['data'] ?? [];

      print("getClinicianEventList count >> ${dataList.length}");

      final List<ClinicianEventItemData> events = dataList.map((item) {
        return ClinicianEventItemData(
          eventId: item['event_id'] ?? 0,
          employeeId: item['employee_id'] ?? 0,
          eventTitle: item['event_title'] ?? '',
          date: item['date'] ?? '',
          supervisorId: item['supervisor_id'] ?? 0,
          supervisorName: item['supervisor_name'] ?? '',
          startTime: item['start_time'] ?? '',
          endTime: item['end_time'] ?? '',
          createdAt: item['created_at'] ?? '',
          modifiedAt: item['modified_at'] ?? '',
        );
      }).toList();

      return ClinicianEventListResponseData(
        message: response.data['message'] ?? '',
        data: events,
      );
    } else {
      print("getClinicianEventList error statusCode >> ${response.statusCode}");
      debugPrint("getClinicianEventList error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getClinicianEventList catch error >> $e");
    debugPrint("getClinicianEventList error: $e");
    return null;
  }
}


///
/// NEW: Correct endpoint — GET /clinician-event/list (date query param is
/// optional and scoped to the logged-in clinician via the auth token, so no
/// clinicianId is needed). Called with no date filter to fetch every event
/// once; caller groups by day on the client (see TimesheetScreen._fetchMonthEvents).
Future<ClinicianEventListResponseData?> getClinicianEventListByClinician({
  required BuildContext context,
}) async {
  try {
    print("getClinicianEventListByClinician called");

    final response = await Api(context).get(
      path: TimesheetRepo.getClinicianEventList,
    );

    print("getClinicianEventListByClinician statusCode >> ${response.statusCode}");
    print("getClinicianEventListByClinician response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> dataList = response.data['data'] ?? [];

      print("getClinicianEventListByClinician count >> ${dataList.length}");

      final List<ClinicianEventItemData> events = dataList.map((item) {
        return ClinicianEventItemData(
          eventId: item['event_id'] ?? 0,
          employeeId: item['employee_id'] ?? 0,
          eventTitle: item['event_title'] ?? '',
          date: item['date'] ?? '',
          supervisorId: item['supervisor_id'] ?? 0,
          supervisorName: item['supervisor_name'] ?? '',
          startTime: item['start_time'] ?? '',
          endTime: item['end_time'] ?? '',
          createdAt: item['created_at'] ?? '',
          modifiedAt: item['modified_at'] ?? '',
        );
      }).toList();

      return ClinicianEventListResponseData(
        message: response.data['message'] ?? '',
        data: events,
      );
    } else {
      print("getClinicianEventListByClinician error statusCode >> ${response.statusCode}");
      debugPrint("getClinicianEventListByClinician error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getClinicianEventListByClinician catch error >> $e");
    debugPrint("getClinicianEventListByClinician error: $e");
    return null;
  }
}






///left side revenue
Future<TodaysVisitData?> getTodaysVisitData({
  required BuildContext context,
  required String clinicianId,
}) async {
  try {
    print("getTodaysVisitData called >> clinicianId: $clinicianId");

    final response = await Api(context).get(
      path: TimesheetRepo.getTodaysVisitData(clinicianId: clinicianId),
    );

    print("getTodaysVisitData statusCode >> ${response.statusCode}");
    print("getTodaysVisitData response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return TodaysVisitData(
        visitsDone: response.data['visitsDone'] ?? 0,
        visitsRemaining: response.data['visitsRemaining'] ?? 0,
        earned: (response.data['earned'] ?? 0).toDouble(),
        visitExpected: (response.data['visitExpected'] ?? 0).toDouble(),
      );
    } else {
      print("getTodaysVisitData error statusCode >> ${response.statusCode}");
      debugPrint("getTodaysVisitData error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getTodaysVisitData catch error >> $e");
    debugPrint("getTodaysVisitData error: $e");
    return null;
  }
}






///list right side

Future<VisitRangeResponseData?> getVisitRangeList({
  required BuildContext context,
  required String dateFrom,
  required String dateTo,
}) async {
  try {
    print("getVisitRangeList called >> dateFrom: $dateFrom | dateTo: $dateTo");

    final response = await Api(context).get(
      path: TimesheetRepo.getVisitRangeList(
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );

    print("getVisitRangeList statusCode >> ${response.statusCode}");
    print("getVisitRangeList response >> ${response.data}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> visitsList = response.data['visits'] ?? [];

      print("getVisitRangeList visits count >> ${visitsList.length}");

      final List<VisitRangeItemData> visits = visitsList.map((item) {
        return VisitRangeItemData(
          visitId: item['visitId'] ?? 0,
          visitTypeName: item['visitTypeName'] ?? '',
          patientName: item['patientName'] ?? '',
          address: item['address'] ?? '',
          timeFrom: item['timeFrom'] ?? '',
          timeTo: item['timeTo'] ?? '',
          inZone: item['inZone'] ?? false,
          isVisitCompleted: item['isVisitCompleted'] ?? false,
          isVisitMissed: item['isVisitMissed'] ?? false,
          visitLabel: item['visitLabel'] ?? '',
          distance: (item['distance'] ?? 0).toDouble(),
          drivingCost: (item['driving_cost'] ?? 0).toDouble(),
          visitCharge: (item['visit_charge'] ?? 0).toDouble(),
        );
      }).toList();

      return VisitRangeResponseData(visits: visits);
    } else {
      print("getVisitRangeList error statusCode >> ${response.statusCode}");
      debugPrint("getVisitRangeList error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("getVisitRangeList catch error >> $e");
    debugPrint("getVisitRangeList error: $e");
    return null;
  }
}




///dealiy summary

Future<DailySummaryData?> getDailySummary(
    BuildContext context,
    String date,
    ) async {
  try {
    final response = await Api(context).get(
      path: TimesheetRepo.getDailySummaryByDate(date: date),
    );
    print("Response:::::: $response");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;

      final submittedMap  = d['submittedVisits']  as Map<String, dynamic>? ?? {};
      final pendingMap    = d['pendingVisits']     as Map<String, dynamic>? ?? {};
      final subMileMap    = d['submittedMileage']  as Map<String, dynamic>? ?? {};
      final penMileMap    = d['pendingMileage']    as Map<String, dynamic>? ?? {};
      final miscMap       = d['miscellaneous']     as Map<String, dynamic>? ?? {};

      return DailySummaryData(
        date: d['date'] ?? '',
        submittedVisits: VisitSummaryData(
          qty:      (submittedMap['qty']      ?? 0).toInt(),
          earnings: (submittedMap['earnings'] ?? 0).toDouble(),
        ),
        pendingVisits: VisitSummaryData(
          qty:      (pendingMap['qty']      ?? 0).toInt(),
          earnings: (pendingMap['earnings'] ?? 0).toDouble(),
        ),
        submittedMileage: MileageSummaryData(
          miles:    (subMileMap['miles']    ?? 0).toDouble(),
          earnings: (subMileMap['earnings'] ?? 0).toDouble(),
        ),
        pendingMileage: MileageSummaryData(
          miles:    (penMileMap['miles']    ?? 0).toDouble(),
          earnings: (penMileMap['earnings'] ?? 0).toDouble(),
        ),
        miscellaneous: VisitSummaryData(
          qty:      (miscMap['qty']      ?? 0).toInt(),
          earnings: (miscMap['earnings'] ?? 0).toDouble(),
        ),
        currentEarnings:   (d['currentEarnings']   ?? 0).toDouble(),
        potentialEarnings: (d['potentialEarnings']  ?? 0).toDouble(),
      );
    } else {
      print("daily summary error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}






////



Future<ScheduledVisitsPopupData?> getScheduledVisitsPopup(
    BuildContext context,
    String date,
    ) async {
  try {
    final response = await Api(context).get(
      path: TimesheetRepo.getScheduledVisitsByDate(date: date),
    );
    print("Response:::::: $response");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;
      final List<dynamic> visitsList = d['visits'] ?? [];
      final List<ScheduledVisitItemData> visits = [];

      for (var item in visitsList) {
        visits.add(ScheduledVisitItemData(
          visitId:          item['visitId'] ?? 0,
          patientId:        item['patientId'] ?? 0,
          patientName:      item['patientName'] ?? '',
          patientImgUrl:    item['patientImgUrl'] ?? '',
          primaryDiagnosis: item['primaryDiagnosis'] ?? '',
          visitTypeName:    item['visitTypeName'] ?? '',
          recordTypeName:   item['recordTypeName'],
          visitDate:        item['visitDate'] ?? '',
          timeFrom:         item['timeFrom'] ?? '',
          timeTo:           item['timeTo'] ?? '',
          visitCharge:      item['visit_charge'] != null
              ? (item['visit_charge'] as num).toDouble()
              : null,
        ));
      }

      return ScheduledVisitsPopupData(
        date:   d['date'] ?? '',
        visits: visits,
      );
    } else {
      print("scheduled visits popup error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}




////


Future<PendingVisitsPopupData?> getPendingVisitsPopup(
    BuildContext context,
    String date,
    ) async {
  try {
    final response = await Api(context).get(
      path: TimesheetRepo.getPendingVisitsByDate(date: date),
    );
    print("Response:::::: $response");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final d = response.data;
      final List<dynamic> visitsList = d['visits'] ?? [];
      final List<PendingVisitItemData> visits = [];

      for (var item in visitsList) {
        visits.add(PendingVisitItemData(
          visitId:              item['visitId'] ?? 0,
          patientId:            item['patientId'] ?? 0,
          patientName:          item['patientName'] ?? '',
          patientImgUrl:        item['patientImgUrl'] ?? '',
          primaryDiagnosis:     item['primaryDiagnosis'] ?? '',
          visitTypeName:        item['visitTypeName'] ?? '',
          recordTypeName:       item['recordTypeName'],
          visitDate:            item['visitDate'] ?? '',
          timeFrom:             item['timeFrom'] ?? '',
          timeTo:               item['timeTo'] ?? '',
          visitCharge:          item['visit_charge'] != null
              ? (item['visit_charge'] as num).toDouble()
              : null,
          completionPercentage: item['completionPercentage'] ?? 0,
        ));
      }

      return PendingVisitsPopupData(
        date:   d['date'] ?? '',
        visits: visits,
      );
    } else {
      print("pending visits popup error: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error $e");
    return null;
  }
}





Future<List<CompletedVisitsPopupData>> getCompletedVisitsPopup(
    BuildContext context,
    String date,
    ) async {
  List<CompletedVisitsPopupData> itemsList = [];
  try {
    final response = await Api(context).get(
      path: CompletedVisitsPopupRepository.getCompletedVisits(date: date),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data['visits']) {
        itemsList.add(
          CompletedVisitsPopupData(
            visitId:              item['visitId'],
            patientId:            item['patientId'],
            patientName:          item['patientName'],
            patientImgUrl:        item['patientImgUrl'] ?? '',
            primaryDiagnosis:     item['primaryDiagnosis'],
            visitTypeName:        item['visitTypeName'],
            recordTypeName:       item['recordTypeName'],
            visitDate:            item['visitDate'],
            timeFrom:             item['timeFrom'],
            timeTo:               item['timeTo'],
            visitCharge:          item['visit_charge'] != null
                ? (item['visit_charge'] as num).toDouble()
                : null,
            completionPercentage: item['completionPercentage'],
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