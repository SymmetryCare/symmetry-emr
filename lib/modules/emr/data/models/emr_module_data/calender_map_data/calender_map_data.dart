class ClinicianCalendarVisitData {
  final int? visitId;
  final int? patientId;
  final String? patientName;
  final String? patientImgUrl;
  final String? primaryDiagnosis;
  final String? visitTypeName;
  final bool? isAuthorized;
  final String? location;
  final String? distance;
  final bool? inZone;
  final String? visiteDateTimeFrom;
  final String? visitDateTimeTo;
  final bool? isVisitCompleted;
  final bool? isVisitMissed;
  final bool? isRescheduled;
  final bool? onWay;
  final List<HolidayData>? holidayList;

  ClinicianCalendarVisitData({
    this.visitId,
    this.patientId,
    this.patientName,
    this.patientImgUrl,
    this.primaryDiagnosis,
    this.visitTypeName,
    this.isAuthorized,
    this.location,
    this.distance,
    this.inZone,
    this.visiteDateTimeFrom,
    this.visitDateTimeTo,
    this.isVisitCompleted,
    this.isVisitMissed,
    this.isRescheduled,
    this.onWay,
    this.holidayList
  });
}

class HolidayData {
  final String date;
  final String holidayName;

  HolidayData({required this.date, required this.holidayName});

  factory HolidayData.fromJson(Map<String, dynamic> json) => HolidayData(
    date: json['date'] ?? '',
    holidayName: json['holidayName'] ?? '',
  );
}