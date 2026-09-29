/// Simple model classes representing the visits data.
/// Plain data holders only — no fromJson/toJson or map parsing included.

class PendingVisitNotesModel {
  final int employeeId;
  final String date;
  final List<PendingVisitItem> items;

  PendingVisitNotesModel({
    required this.employeeId,
    required this.date,
    required this.items,
  });
}

class PendingVisitItem {
  final int visitId;
  final int employeeId;
  final int employeeTypeId;
  final int ptId;
  final String patientName;
  final String imageUrl;
  final Diagnosis primaryDiagnosis;
  final VisitType visitType;
  final String visiteDateTimeFrom;
  final String visitDateTimeTo;
  final bool isVisitCompleted;
  final bool isVisitMissed;
  final bool? isVisitAccepted;
  final int visitCharge;

  PendingVisitItem({
    required this.visitId,
    required this.employeeId,
    required this.employeeTypeId,
    required this.ptId,
    required this.patientName,
    required this.imageUrl,
    required this.primaryDiagnosis,
    required this.visitType,
    required this.visiteDateTimeFrom,
    required this.visitDateTimeTo,
    required this.isVisitCompleted,
    required this.isVisitMissed,
    required this.isVisitAccepted,
    required this.visitCharge,
  });
}

class Diagnosis {
  final int id;
  final String name;
  final String code;

  Diagnosis({
    required this.id,
    required this.name,
    required this.code,
  });
}

class VisitType {
  final int id;
  final String name;

  VisitType({
    required this.id,
    required this.name,
  });
}