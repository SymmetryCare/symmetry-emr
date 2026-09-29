class CompletedVisitsStatsData {
  final int? total;
  final int? thisWeek;
  final int? thisMonth;
  final int? today;

  CompletedVisitsStatsData({
    this.total,
    this.thisWeek,
    this.thisMonth,
    this.today,
  });
}




class ClinicianEarningData {
  final int clinicianId;
  final int total;
  final int thisMonth;
  final int thisWeek;
  final int today;

  ClinicianEarningData({
    required this.clinicianId,
    required this.total,
    required this.thisMonth,
    required this.thisWeek,
    required this.today,
  });
}




class TodayCompletedVisitData {
  final int    visitId;
  final int    patientId;
  final String patientName;
  final String patientAvatarUrl;
  final String startTime;
  final String endTime;
  final String dayLabel;
  final int    visitCharge;

  TodayCompletedVisitData({
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientAvatarUrl,
    required this.startTime,
    required this.endTime,
    required this.dayLabel,
    required this.visitCharge,
  });
}