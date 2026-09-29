class PatientvisitListEmrModel {
  final List<EmrPatientVisitModel> visits;

  PatientvisitListEmrModel({required this.visits});
}

class EmrPatientVisitModel {
  final int visitId;
  final int patientId;
  final String patientName;
  final String patientImgUrl;
  final String primaryDiagnosis;
  final String visitTypeName;
  final bool isAuthorized;
  final String visiteDateTimeFrom;
  final String visitDateTimeTo;
  final bool isVisitCompleted;
  final bool isVisitMissed;
  final bool onWay;
  final bool isRescheduled;
  final String? rescheduledAt;
  final double visitCharge;
  final String treatmentPause;
  final VisitAlerts alerts;

  EmrPatientVisitModel({
    required this.treatmentPause,
    required this.visitId,
    required this.patientId,
    required this.patientName,
    required this.patientImgUrl,
    required this.primaryDiagnosis,
    required this.visitTypeName,
    required this.isAuthorized,
    required this.visiteDateTimeFrom,
    required this.visitDateTimeTo,
    required this.isVisitCompleted,
    required this.isVisitMissed,
    required this.onWay,
    required this.isRescheduled,
    required this.rescheduledAt,
    required this.visitCharge,
    required this.alerts,
  });
}

class VisitAlerts {
  final bool patientAlert;
  final bool visitAlert;
  final bool disciplineAlert;

  VisitAlerts({
    required this.patientAlert,
    required this.visitAlert,
    required this.disciplineAlert,
  });
}


/// patient visit by id model

class VisitPrefillByIdModel {
  final int visitId;
  final int ptId;
  final int employeeTypeId;
  final int? employeeId;
  final int visitType;
  final String visiteDateTimeFrom;
  final String visitDateTimeTo;
  final bool isVisitCompleted;
  final bool isVisitMissed;
  final bool onWay;
  final int? recordTypeId;
  final bool inZone;
  final bool isRescheduled;
  final String? rescheduledAt;
  final int? rescheduleReasonId;
  final String? visitPhotoUrl;
  final PatientPrefillModel patient;
  final EmployeeModel? employee;  // nullable since API can return null
  final EmployeePatientTypeModel employeeType;
  final int typeOfVisitId;
  final String typeOfVisitName;
  final bool isSecoundLastEpisodeVisit;
  final bool isAttemptedVisit;
  final String lastVisitPerformedBy;
  final String episodeTriggerType;
  final int daysToEpisodeEnd;
  final int remainingVisitsCount;
  final List<int> pendingAssistantFormIds;
  final List<int> lastVisitIds;

  VisitPrefillByIdModel({
    required this.remainingVisitsCount,
    required this.episodeTriggerType,
    required this.daysToEpisodeEnd,
    required this.lastVisitIds,
    required this.lastVisitPerformedBy,
    required this.pendingAssistantFormIds,
    required this.isSecoundLastEpisodeVisit,
    required this.isAttemptedVisit,
    required this.visitId,
    required this.ptId,
    required this.employeeTypeId,
    required this.employeeId,
    required this.visitType,
    required this.visiteDateTimeFrom,
    required this.visitDateTimeTo,
    required this.isVisitCompleted,
    required this.isVisitMissed,
    required this.onWay,
    required this.recordTypeId,
    required this.inZone,
    required this.isRescheduled,
    required this.rescheduledAt,
    required this.rescheduleReasonId,
    required this.visitPhotoUrl,
    required this.patient,
    required this.employee,
    required this.employeeType,
    required this.typeOfVisitId,
    required this.typeOfVisitName,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class EmployeeModel {
  final int employeeId;
  final String code;
  final String firstName;
  final String lastName;
  final String expertise;
  final String gender;
  final String imgurl;
  final String regOfficId;
  final String onboardingStatus;
  final int userId;
  final String ssnNbr;
  final String address;
  final int cityId;
  final String dateOfBirth;
  final int departmentId;
  final String emergencyContact;
  final int employeeTypeId;
  final String employment;
  final String personalEmail;
  final String primaryPhoneNbr;
  final String secondryPhoneNbr;
  final String service;
  final String status;
  final String workEmail;
  final String workPhoneNbr;
  final int companyId;
  final String createdAt;
  final String resumeurl;
  final String covreage;
  final String? approved;
  final String? terminationFlag;
  final int zoneId;
  final int countryId;
  final String checkDate;
  final String dateofResignation;
  final String dateofTermination;
  final String finalAddress;
  final double finalPayCheck;
  final double grossPay;
  final String materials;
  final String methods;
  final double netPay;
  final String reason;
  final String rehirable;
  final String type;
  final String dateofHire;
  final String position;
  final String driverLicenceNbr;
  final String race;
  final String rating;
  final String signatureURL;
  final int countyId;
  final bool active;
  final String summary;
  final String? documentName;
  final String? documentUrl;

  EmployeeModel({
    required this.employeeId,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.expertise,
    required this.gender,
    required this.imgurl,
    required this.regOfficId,
    required this.onboardingStatus,
    required this.userId,
    required this.ssnNbr,
    required this.address,
    required this.cityId,
    required this.dateOfBirth,
    required this.departmentId,
    required this.emergencyContact,
    required this.employeeTypeId,
    required this.employment,
    required this.personalEmail,
    required this.primaryPhoneNbr,
    required this.secondryPhoneNbr,
    required this.service,
    required this.status,
    required this.workEmail,
    required this.workPhoneNbr,
    required this.companyId,
    required this.createdAt,
    required this.resumeurl,
    required this.covreage,
    required this.approved,
    required this.terminationFlag,
    required this.zoneId,
    required this.countryId,
    required this.checkDate,
    required this.dateofResignation,
    required this.dateofTermination,
    required this.finalAddress,
    required this.finalPayCheck,
    required this.grossPay,
    required this.materials,
    required this.methods,
    required this.netPay,
    required this.reason,
    required this.rehirable,
    required this.type,
    required this.dateofHire,
    required this.position,
    required this.driverLicenceNbr,
    required this.race,
    required this.rating,
    required this.signatureURL,
    required this.countyId,
    required this.active,
    required this.summary,
    required this.documentName,
    required this.documentUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class PatientPrefillModel {
  final int ptId;
  final String ptFirstName;
  final String ptLastName;
  final String ptContactNo;
  final String ptZipCode;
  final int ptChartNo;
  final String ptSummary;
  final String ptRefferalDate;
  final int fkSrvId;
  final int fkPtPrimaryDiagnosis;
  final List<dynamic> fkPtSecondaryDiagnosis;
  final int fkPtRefferalSource;
  final int fkPtPcp;
  final int fkPtMarketer;
  final List<int> fkPtDiscplines;
  final int ptCoverageArea;
  final bool isIntake;
  final String intakeTime;
  final bool isArchieved;
  final String? archievedTime;
  final String createdAt;
  final String ptDateOfBirth;
  final String ptImgUrl;
  final int? fkEmpIdArchived;
  final int fkRptiId;
  final bool isSelfPay;
  final String documentName;
  final bool moveToScheduler;
  final String moveToSchedulerDatetime;
  final String? admitDateTime;
  final bool isNonAdmit;
  final int ptMRN;
  final String ptSOCDate;
  final bool ptSOCStatus;
  final String potentialDischargeDate;
  final String ptAddress;
  final String ptMedicalNote;
  final bool isDemographicFilled;
  final bool isDocumentationUpload;
  final bool isInitialContactFilled;
  final bool isOrdersFilled;
  final bool isPhysicianFilled;
  final bool isPrimaryInsuranceFilled;
  final int companyId;
  final int genderId;
  final bool potentialDuplicate;
  final int? fkPatientStatusId;
  final String specialPrecautions;
  final String rehospitalizationRisk;

  PatientPrefillModel({
    required this.ptId,
    required this.ptFirstName,
    required this.ptLastName,
    required this.ptContactNo,
    required this.ptZipCode,
    required this.ptChartNo,
    required this.ptSummary,
    required this.ptRefferalDate,
    required this.fkSrvId,
    required this.fkPtPrimaryDiagnosis,
    required this.fkPtSecondaryDiagnosis,
    required this.fkPtRefferalSource,
    required this.fkPtPcp,
    required this.fkPtMarketer,
    required this.fkPtDiscplines,
    required this.ptCoverageArea,
    required this.isIntake,
    required this.intakeTime,
    required this.isArchieved,
    required this.archievedTime,
    required this.createdAt,
    required this.ptDateOfBirth,
    required this.ptImgUrl,
    required this.fkEmpIdArchived,
    required this.fkRptiId,
    required this.isSelfPay,
    required this.documentName,
    required this.moveToScheduler,
    required this.moveToSchedulerDatetime,
    required this.admitDateTime,
    required this.isNonAdmit,
    required this.ptMRN,
    required this.ptSOCDate,
    required this.ptSOCStatus,
    required this.potentialDischargeDate,
    required this.ptAddress,
    required this.ptMedicalNote,
    required this.isDemographicFilled,
    required this.isDocumentationUpload,
    required this.isInitialContactFilled,
    required this.isOrdersFilled,
    required this.isPhysicianFilled,
    required this.isPrimaryInsuranceFilled,
    required this.companyId,
    required this.genderId,
    required this.potentialDuplicate,
    required this.fkPatientStatusId,
    required this.specialPrecautions,
    required this.rehospitalizationRisk,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class EmployeePatientTypeModel {
  final int employeeTypeId;
  final String employeeType;
  final String color;
  final String abbreviation;
  final int departmentId;
  final int roleId;
  final int masterEmpTypeId;
  final List<int> childEmpTypeId;
  final int templateIdSalaried;
  final int templateIdParttime;
  final int templateIdPerdiem;

  EmployeePatientTypeModel({
    required this.employeeTypeId,
    required this.employeeType,
    required this.color,
    required this.abbreviation,
    required this.departmentId,
    required this.roleId,
    required this.masterEmpTypeId,
    required this.childEmpTypeId,
    required this.templateIdSalaried,
    required this.templateIdParttime,
    required this.templateIdPerdiem,
  });
}