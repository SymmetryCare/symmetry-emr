// caledner_details_data.dart

class PatientVisitCalenderDetailsData {
  final PatientCalenderDetailsData patient;
  final VisitCalenderDetailsData visit;
  final EpisodeCalenderDetailsData episode;
  final List<ClinicianCalenderDetailsData> clinicians;
  final AlertsCalenderDetailsData alerts;

  PatientVisitCalenderDetailsData({
    required this.patient,
    required this.visit,
    required this.episode,
    required this.clinicians,
    required this.alerts,
  });
}

class PatientCalenderDetailsData {
  final int ptId;
  final String name;
  final String imageUrl;
  final int MRN;
  final String dateOfBirth;
  final int age;
  final String phone;
  final String address;
  final int? zoneId;
  final String? zoneName;
  final int diagnosisId;
  final String diagnosisName;
  final int genderId;
  final String genderName;

  PatientCalenderDetailsData({
    required this.ptId,
    required this.name,
    required this.imageUrl,
    required this.MRN,
    required this.dateOfBirth,
    required this.age,
    required this.phone,
    required this.address,
    this.zoneId,
    this.zoneName,
    required this.diagnosisId,
    required this.diagnosisName,
    required this.genderId,
    required this.genderName,
  });
}

class VisitCalenderDetailsData {
  final int visitId;
  final int visitTypeId;
  final String visitTypeName;
  final String visitDateFrom;
  final String visitDateTo;
  final bool isCompleted;
  final bool isMissed;
  final bool onWay;
  final bool inZone;
  final bool isRescheduled;
  final int? recordTypeId;
  final String? requestType;
  final double visitCharge;

  VisitCalenderDetailsData({
    required this.visitId,
    required this.visitTypeId,
    required this.visitTypeName,
    required this.visitDateFrom,
    required this.visitDateTo,
    required this.isCompleted,
    required this.isMissed,
    required this.onWay,
    required this.inZone,
    required this.isRescheduled,
    this.recordTypeId,
    this.requestType,
    required this.visitCharge,
  });
}

class EpisodeCalenderDetailsData {
  final int episodeId;
  final int chartNumber;
  final int episodeNumber;
  final String episodeFrom;
  final String episodeTo;

  EpisodeCalenderDetailsData({
    required this.episodeId,
    required this.chartNumber,
    required this.episodeNumber,
    required this.episodeFrom,
    required this.episodeTo,
  });
}

class ClinicianCalenderDetailsData {
  final int employeeId;
  final String name;
  final String imageUrl;
  final String phone;
  final int employeeTypeId;
  final String employeeTypeAbbreviation;
  final String employeeTypeColor;

  ClinicianCalenderDetailsData({
    required this.employeeId,
    required this.name,
    required this.imageUrl,
    required this.phone,
    required this.employeeTypeId,
    required this.employeeTypeAbbreviation,
    required this.employeeTypeColor,
  });
}

class AlertsCalenderDetailsData {
  final List<dynamic> visitAlerts;
  final List<dynamic> patientAlerts;

  AlertsCalenderDetailsData({
    required this.visitAlerts,
    required this.patientAlerts,
  });
}