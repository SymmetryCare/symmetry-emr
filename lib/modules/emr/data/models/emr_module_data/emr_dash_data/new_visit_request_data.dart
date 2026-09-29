class RequestVisitData {
  final int visitId;
  final String? visitStatus;
  final String? visitDateTime;
  final String? warning;
  final int ptId;
  final int mrn;
  final String patientName;
  final String patientImage;
  final int patientGenderId;
  final String genderName;
  final int patientAge;
  final int primaryDiagnosisId;
  final String primaryDiagnosisName;
  final String visitType;
  final String visitTimeframeFrom;
  final String visitTimeframeTo;
  final String? requestType;
  final String isZone;
  final int zoneId;
  final String zoneName;
  final String patientAddress;
  final double distance;
  final String visitNote;
  final double visitCharge;
  final List<VisitListItemData> visitList;

  RequestVisitData({
    required this.visitId,
    this.visitStatus,
    this.visitDateTime,
    this.warning,
    required this.ptId,
    required this.mrn,
    required this.patientName,
    required this.patientImage,
    required this.patientGenderId,
    required this.genderName,
    required this.patientAge,
    required this.primaryDiagnosisId,
    required this.primaryDiagnosisName,
    required this.visitType,
    required this.visitTimeframeFrom,
    required this.visitTimeframeTo,
    this.requestType,
    required this.isZone,
    required this.zoneId,
    required this.zoneName,
    required this.patientAddress,
    required this.distance,
    required this.visitNote,
    required this.visitCharge,
    required this.visitList,
  });
}

class VisitListItemData {
  final int visitId;
  final String visitDateFrom;
  final String visitDateTo;
  final int employeeTypeId;
  final String employeeTypeAbbreviation;
  final String employeeTypeColor;

  VisitListItemData({
    required this.visitId,
    required this.visitDateFrom,
    required this.visitDateTo,
    required this.employeeTypeId,
    required this.employeeTypeAbbreviation,
    required this.employeeTypeColor,
  });
}

class RequestVisitResponseData {
  final String todaysDate;
  final List<RequestVisitData> visits;

  RequestVisitResponseData({
    required this.todaysDate,
    required this.visits,
  });
}