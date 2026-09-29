// ─────────────────────────────────────────────
//  Oasis Plan of Care – Model Classes
// ─────────────────────────────────────────────

class PatientFormEmrData {
  final String category;
  final List<FormEMRData> data;
  final int total;
  final int page;
  final int limit;

  PatientFormEmrData({
    required this.category,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });
}

// ─────────────────────────────────────────────

class FormEMRData {
  final int patientFormId;
  final int formId;
  final String formName;
  final int patientId;
  final int chartId;
  final int episodeId;
  final int schedulerId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? visitDetails;
  final List<AssignedTo> assignedTo;
  final List<StatusHistory> statusHistory;

  FormEMRData({
    required this.patientFormId,
    required this.formId,
    required this.formName,
    required this.patientId,
    required this.chartId,
    required this.episodeId,
    required this.schedulerId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.visitDetails,
    required this.assignedTo,
    required this.statusHistory,
  });
}

// ─────────────────────────────────────────────

class AssignedTo {
  final int assignmentId;
  final int staffId;
  final String name;
  final String imgUrl;
  final String role;
  final String color;
  final String abbreviation;
  final String assignedAt;
  final String? timelyFilingDeadline;

  AssignedTo({
    required this.assignmentId,
    required this.staffId,
    required this.name,
    required this.imgUrl,
    required this.role,
    required this.color,
    required this.abbreviation,
    required this.assignedAt,
    this.timelyFilingDeadline,
  });
}

// ─────────────────────────────────────────────

class StatusHistory {
  final String fromStatus;
  final String toStatus;
  final String? note;
  final ChangedBy changedBy;
  final String changedAt;

  StatusHistory({
    required this.fromStatus,
    required this.toStatus,
    this.note,
    required this.changedBy,
    required this.changedAt,
  });
}

// ─────────────────────────────────────────────

class ChangedBy {
  final int employeeId;
  final String name;

  ChangedBy({
    required this.employeeId,
    required this.name,
  });
}