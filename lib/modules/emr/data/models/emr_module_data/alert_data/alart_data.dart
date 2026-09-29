class ClinicianAlertData {
  final int alertId;
  final String alertHeading;
  final String alertBody;
  final String alertType;
  final bool alertResolve;
  final String createdAt;
  final List<AlertClinician> clinicians;

  // visit alert extras
  final String? visiteDateTimeFrom;
  final String? visitDateTimeTo;

  // discipline alert extras
  final String? discipline;
  final String? disciplineAbbreviation;

  ClinicianAlertData({
    required this.alertId,
    required this.alertHeading,
    required this.alertBody,
    required this.alertType,
    required this.alertResolve,
    required this.createdAt,
    required this.clinicians,
    this.visiteDateTimeFrom,
    this.visitDateTimeTo,
    this.discipline,
    this.disciplineAbbreviation,
  });
}

class AlertClinician {
  final int employeeId;
  final String fullName;
  final String imgUrl;
  final String abbreviation;
  final String color;

  AlertClinician({
    required this.employeeId,
    required this.fullName,
    required this.imgUrl,
    required this.abbreviation,
    required this.color,
  });
}