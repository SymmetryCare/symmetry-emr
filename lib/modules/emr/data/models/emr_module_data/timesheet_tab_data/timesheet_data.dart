class ClinicianMonthlyCalendarData {
  final int year;
  final int month;
  final List<ClinicianCalendarDayData> days;

  ClinicianMonthlyCalendarData({
    required this.year,
    required this.month,
    required this.days,
  });
}

class ClinicianCalendarDayData {
  final String date;
  final String visitStatus;
  final int visitCount;
  final double earnedAmount;
  final double expectedAmount;

  ClinicianCalendarDayData({
    required this.date,
    required this.visitStatus,
    required this.visitCount,
    required this.earnedAmount,
    required this.expectedAmount,
  });
}

class PayrollPeriodResponseData {
  final int? year;
  final int? month;
  final List<PayrollPeriodData>? periods;

  PayrollPeriodResponseData({
    this.year,
    this.month,
    this.periods,
  });
}

class PayrollPeriodData {
  final int? periodNumber;
  final String? label;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;

  PayrollPeriodData({
    this.periodNumber,
    this.label,
    this.startDate,
    this.endDate,
    this.isCurrent,
  });
}



class SupervisorResponseData {
  final String? message;
  final List<SupervisorData>? data;

  SupervisorResponseData({
    this.message,
    this.data,
  });
}

class SupervisorData {
  final int? employeeId;
  final String? name;

  SupervisorData({
    this.employeeId,
    this.name,
  });
}






class ClinicianEventListResponseData {
  final String? message;
  final List<ClinicianEventItemData>? data;

  ClinicianEventListResponseData({
    this.message,
    this.data,
  });
}

class ClinicianEventItemData {
  final int? eventId;
  final int? employeeId;
  final String? eventTitle;
  final String? date;
  final int? supervisorId;
  final String? supervisorName;
  final String? startTime;
  final String? endTime;
  final String? createdAt;
  final String? modifiedAt;

  ClinicianEventItemData({
    this.eventId,
    this.employeeId,
    this.eventTitle,
    this.date,
    this.supervisorId,
    this.supervisorName,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.modifiedAt,

  });
}




class TodaysVisitData {
  final int? visitsDone;
  final int? visitsRemaining;
  final double? earned;
  final double? visitExpected;

  TodaysVisitData({
    this.visitsDone,
    this.visitsRemaining,
    this.earned,
    this.visitExpected,
  });
}





class VisitRangeResponseData {
  final List<VisitRangeItemData>? visits;

  VisitRangeResponseData({
    this.visits,
  });
}

class VisitRangeItemData {
  final int? visitId;
  final String? visitTypeName;
  final String? patientName;
  final String? address;
  final String? timeFrom;
  final String? timeTo;
  final bool? inZone;
  final bool? isVisitCompleted;
  final bool? isVisitMissed;
  final String? visitLabel;
  final double? distance;
  final double? drivingCost;
  final double? visitCharge;

  VisitRangeItemData({
    this.visitId,
    this.visitTypeName,
    this.patientName,
    this.address,
    this.timeFrom,
    this.timeTo,
    this.inZone,
    this.isVisitCompleted,
    this.isVisitMissed,
    this.visitLabel,
    this.distance,
    this.drivingCost,
    this.visitCharge,
  });
}






///deaily summary
class VisitSummaryData {
  final int qty;
  final double earnings;

  VisitSummaryData({
    required this.qty,
    required this.earnings,
  });
}

class MileageSummaryData {
  final double miles;
  final double earnings;

  MileageSummaryData({
    required this.miles,
    required this.earnings,
  });
}

class DailySummaryData {
  final String date;
  final VisitSummaryData submittedVisits;
  final VisitSummaryData pendingVisits;
  final MileageSummaryData submittedMileage;
  final MileageSummaryData pendingMileage;
  final VisitSummaryData miscellaneous;
  final double currentEarnings;
  final double potentialEarnings;

  DailySummaryData({
    required this.date,
    required this.submittedVisits,
    required this.pendingVisits,
    required this.submittedMileage,
    required this.pendingMileage,
    required this.miscellaneous,
    required this.currentEarnings,
    required this.potentialEarnings,
  });
}







///
class ScheduledVisitItemData {
  final int visitId;
  final int patientId;
  final String patientName;
  final String patientImgUrl;
  final String primaryDiagnosis;
  final String visitTypeName;
  final String? recordTypeName;
  final String visitDate;
  final String timeFrom;
  final String timeTo;
  final double? visitCharge;

  ScheduledVisitItemData({
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientImgUrl,
    required this.primaryDiagnosis,
    required this.visitTypeName,
    this.recordTypeName,
    required this.visitDate,
    required this.timeFrom,
    required this.timeTo,
    this.visitCharge,
  });
}

class ScheduledVisitsPopupData {
  final String date;
  final List<ScheduledVisitItemData> visits;

  ScheduledVisitsPopupData({
    required this.date,
    required this.visits,
  });
}



///
///
class PendingVisitItemData {
  final int visitId;
  final int patientId;
  final String patientName;
  final String patientImgUrl;
  final String primaryDiagnosis;
  final String visitTypeName;
  final String? recordTypeName;
  final String visitDate;
  final String timeFrom;
  final String timeTo;
  final double? visitCharge;
  final int completionPercentage;

  PendingVisitItemData({
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientImgUrl,
    required this.primaryDiagnosis,
    required this.visitTypeName,
    this.recordTypeName,
    required this.visitDate,
    required this.timeFrom,
    required this.timeTo,
    this.visitCharge,
    required this.completionPercentage,
  });
}

class PendingVisitsPopupData {
  final String date;
  final List<PendingVisitItemData> visits;

  PendingVisitsPopupData({
    required this.date,
    required this.visits,
  });
}




///
///
///
class PendingVisitsPopupResponseData {
  final String date;
  final List<PendingVisitData> visits;

  PendingVisitsPopupResponseData({
    required this.date,
    required this.visits,
  });
}

class PendingVisitData {
  final int visitId;
  final int patientId;
  final String patientName;
  final String patientImgUrl;
  final String primaryDiagnosis;
  final String visitTypeName;
  final String? recordTypeName;
  final String visitDate;
  final String timeFrom;
  final String timeTo;
  final double? visitCharge;
  final int completionPercentage;

  PendingVisitData({
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientImgUrl,
    required this.primaryDiagnosis,
    required this.visitTypeName,
    this.recordTypeName,
    required this.visitDate,
    required this.timeFrom,
    required this.timeTo,
    this.visitCharge,
    required this.completionPercentage,
  });
}







///completed  popup data file
///
class CompletedVisitsPopupData {
  final int visitId;
  final int patientId;
  final String patientName;
  final String patientImgUrl;
  final String primaryDiagnosis;
  final String visitTypeName;
  final String? recordTypeName;
  final String visitDate;
  final String timeFrom;
  final String timeTo;
  final double? visitCharge;
  final int completionPercentage;

  CompletedVisitsPopupData({
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientImgUrl,
    required this.primaryDiagnosis,
    required this.visitTypeName,
    this.recordTypeName,
    required this.visitDate,
    required this.timeFrom,
    required this.timeTo,
    this.visitCharge,
    required this.completionPercentage,
  });
}




