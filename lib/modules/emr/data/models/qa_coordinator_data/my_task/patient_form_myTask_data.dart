// ─── Primary Diagnosis ────────────────────────────────────────────────────────

class PrimaryDiagnosis {
  final int dgnId;
  final String dgnName;
  final String dgnCode;

  PrimaryDiagnosis({
    required this.dgnId,
    required this.dgnName,
    required this.dgnCode,
  });
}

// ─── Changed By ───────────────────────────────────────────────────────────────

class ChangedBy {
  final int employeeId;
  final String name;

  ChangedBy({
    required this.employeeId,
    required this.name,
  });
}

// ─── Status History ───────────────────────────────────────────────────────────

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

// ─── Patient ──────────────────────────────────────────────────────────────────

class Patient {
  final int ptId;
  final String name;
  final int mrn;
  final int chartNo;
  final String? primaryInsurance;
  final String? insuranceCategory;
  final bool? insuranceEligibilityStatus;
  final int? fkPtPrimaryDiagnosis;
  final PrimaryDiagnosis? primaryDiagnosis;
  final String ptImgUrl;
  final String? diagnosis; // ✅ added: supply-order shape returns a flat diagnosis string, not primaryDiagnosis

  Patient({
    required this.ptId,
    required this.name,
    required this.mrn,
    required this.chartNo,
    this.primaryInsurance,
    this.insuranceCategory,
    this.insuranceEligibilityStatus,
    this.fkPtPrimaryDiagnosis,
    this.primaryDiagnosis,
    required this.ptImgUrl,
    this.diagnosis,
  });
}

// ─── Clinician ────────────────────────────────────────────────────────────────

class Clinician {
  final int staffId;
  final String name;
  final String imgUrl;
  final String abbreviation;
  final String colorCode;
  final String? timelyFilingDeadline;
  final String? employeeType; // ✅ added: supply-order shape includes this

  Clinician({
    required this.staffId,
    required this.name,
    required this.imgUrl,
    required this.abbreviation,
    required this.colorCode,
    this.timelyFilingDeadline,
    this.employeeType,
  });
}

// ─── QA ───────────────────────────────────────────────────────────────────────

class QA {
  final int staffId;
  final String name;
  final String? color;
  final String? abbreviation;
  final String? timelyFilingDeadline;

  QA({
    required this.staffId,
    required this.name,
    this.color,
    this.abbreviation,
    this.timelyFilingDeadline,
  });
}

// ─── Coding Staff (nullable — mirrors QA/Clinician shape) ─────────────────────

class CodingStaff {
  final int staffId;
  final String name;
  final String? color;
  final String? abbreviation;
  final String? timelyFilingDeadline;

  CodingStaff({
    required this.staffId,
    required this.name,
    this.color,
    this.abbreviation,
    this.timelyFilingDeadline,
  });
}

// ─── Patient Form Task ────────────────────────────────────────────────────────

class PatientFormTask {
  final int patientFormId;
  final Patient patient;
  final String formType;
  final String formDate;
  final String status;
  final bool? faceToFace;
  final String? timelyFilingDeadline;
  final String? dateSentForCorrection;
  final Clinician clinician;
  final QA qa;
  final CodingStaff? codingStaff;
  final List<StatusHistory> statusHistory;
  final int? supplyOrderId; // ✅ added
  final String? orderId;    // ✅ added
  final String? taskType;   // ✅ added

  PatientFormTask({
    required this.patientFormId,
    required this.patient,
    required this.formType,
    required this.formDate,
    required this.status,
    this.faceToFace,
    this.timelyFilingDeadline,
    this.dateSentForCorrection,
    required this.clinician,
    required this.qa,
    this.codingStaff,
    required this.statusHistory,
    this.supplyOrderId,
    this.orderId,
    this.taskType,
  });
}

// ─── Paginated Response ───────────────────────────────────────────────────────

class PatientFormMyTaskResponse {
  final List<PatientFormTask> data;
  final int total;
  final int page;
  final int limit;

  PatientFormMyTaskResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });
}