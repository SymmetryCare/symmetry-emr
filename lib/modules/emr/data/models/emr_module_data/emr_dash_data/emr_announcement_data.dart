// ── Alert models ──────────────────────────────────────────────────────────────

class ClinicianAlertDataDashboard {
  final int alertId;
  final String alertHeading;
  final String alertBody;
  final String alertType;
  final bool alertResolve;
  final int fkPtId;
  final String createdAt;
  final List<AlertClinicianData> clinicians;

  ClinicianAlertDataDashboard({
    required this.alertId,
    required this.alertHeading,
    required this.alertBody,
    required this.alertType,
    required this.alertResolve,
    required this.fkPtId,
    required this.createdAt,
    required this.clinicians,
  });
}

class AlertClinicianData {
  final int employeeId;
  final String fullName;
  final String imgurl;
  final String abbreviation;
  final String color;

  AlertClinicianData({
    required this.employeeId,
    required this.fullName,
    required this.imgurl,
    required this.abbreviation,
    required this.color,
  });
}

// ── Map models ────────────────────────────────────────────────────────────────

class ClinicianVisitsMapData {
  final ClinicianLocationData clinician;
  final List<VisitMapData> visits;

  ClinicianVisitsMapData({
    required this.clinician,
    required this.visits,
  });
}

class ClinicianLocationData {
  final int employeeId;
  final String name;
  final String? imageUrl;
  final double latitude;
  final double longitude;

  ClinicianLocationData({
    required this.employeeId,
    required this.name,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}

class VisitMapData {
  final int visitId;
  final int visitNumber;
  final int patientId;
  final String patientName;
  final String? patientImageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final String visitStatus; // NOT_STARTED | IN_PROGRESS | VISITED
  final String visitDateTimeFrom;
  final String visitDateTimeTo;

  VisitMapData({
    required this.visitId,
    required this.visitNumber,
    required this.patientId,
    required this.patientName,
    this.patientImageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.visitStatus,
    required this.visitDateTimeFrom,
    required this.visitDateTimeTo,
  });
}