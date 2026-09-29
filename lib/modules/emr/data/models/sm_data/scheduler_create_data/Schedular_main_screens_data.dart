class SchedularFlowPatientModel {
  final Patient patient;
  final List<DisciplineData> data;
  final bool allCliniciansAssigned;
  final String moveToSchedulerDatetime;

  SchedularFlowPatientModel({
    required this.patient,
    required this.data,
    required this.allCliniciansAssigned,
    required this.moveToSchedulerDatetime,
  });
}

class Patient {
  final int ptId;
  final String ptFirstName;
  final String ptLastName;
  final String ptContactNo;
  final String ptZipCode;
  final int ptChartNo;
  final String ptSummary;
  final String ptReferralDate;
  final int fkSrvId;
  final Diagnosis primaryDiagnosis;
  final List<Diagnosis> secondaryDiagnoses;
  final ReferralSource referralSource;
  final int fkPtPcp;
  final EmployeeId marketer;
  final List<DisciplineType> disciplines;
  final int ptCoverageArea;
  final bool isIntake;
  final String intakeTime;
  final bool isArchived;
  final String archivedTime;
  final String createdAt;
  final String ptDateOfBirth;
  final String ptImgUrl;
  final int fkRptiId;
  final int fkEmpIdArchived;
  final bool isSelfPay;
  final String documentName;
  final bool moveToScheduler;
  final String moveToSchedulerDatetime;
  final bool isNonAdmit;
  final String admitDateTime;
  final int ptMRN;
  final String ptSocDate;
  final String potentialDischargeDate;
  final String ptAddress;
  final String ptMedicalNote;

  Patient({
    required this.ptId,
    required this.ptFirstName,
    required this.ptLastName,
    required this.ptContactNo,
    required this.ptZipCode,
    required this.ptChartNo,
    required this.ptSummary,
    required this.ptReferralDate,
    required this.fkSrvId,
    required this.primaryDiagnosis,
    required this.secondaryDiagnoses,
    required this.referralSource,
    required this.fkPtPcp,
    required this.marketer,
    required this.disciplines,
    required this.ptCoverageArea,
    required this.isIntake,
    required this.intakeTime,
    required this.isArchived,
    required this.archivedTime,
    required this.createdAt,
    required this.ptDateOfBirth,
    required this.ptImgUrl,
    required this.fkRptiId,
    required this.fkEmpIdArchived,
    required this.isSelfPay,
    required this.documentName,
    required this.moveToScheduler,
    required this.moveToSchedulerDatetime,
    required this.isNonAdmit,
    required this.admitDateTime,
    required this.ptMRN,
    required this.ptSocDate,
    required this.potentialDischargeDate,
    required this.ptAddress,
    required this.ptMedicalNote,
  });
}

class Diagnosis {
  final int dgnId;
  final String dgnName;
  final String dgnCode;

  Diagnosis({
    required this.dgnId,
    required this.dgnName,
    required this.dgnCode,
  });
}

class ReferralSource {
  final int refSourceId;
  final String sourceName;
  final String description;
  final String referralSourceImgUrl;
  final String documentName;

  ReferralSource({
    required this.refSourceId,
    required this.sourceName,
    required this.description,
    required this.referralSourceImgUrl,
    required this.documentName,
  });
}

class EmployeeId {
  final int? employeeId;
  final String code;
  final String firstName;
  final String lastName;
  final String expertise;
  final String gender;
  final String imgUrl;
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
  final String resumeUrl;
  final String coverage;
  final bool approved;
  final bool terminationFlag;
  final int zoneId;
  final int countryId;
  final String checkDate;
  final String dateOfResignation;
  final String dateOfTermination;
  final String finalAddress;
  final double finalPayCheck;
  final double grossPay;
  final String materials;
  final String methods;
  final double netPay;
  final String reason;
  final String rehirable;
  final String type;
  final String dateOfHire;
  final String position;
  final String driverLicenceNbr;
  final String race;
  final String rating;
  final String signatureURL;
  final int countyId;
  final bool active;
  final String summary;

  EmployeeId({
    required this.employeeId,
    required this.code,
    required this.firstName,
    required this.lastName,
    required this.expertise,
    required this.gender,
    required this.imgUrl,
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
    required this.resumeUrl,
    required this.coverage,
    required this.approved,
    required this.terminationFlag,
    required this.zoneId,
    required this.countryId,
    required this.checkDate,
    required this.dateOfResignation,
    required this.dateOfTermination,
    required this.finalAddress,
    required this.finalPayCheck,
    required this.grossPay,
    required this.materials,
    required this.methods,
    required this.netPay,
    required this.reason,
    required this.rehirable,
    required this.type,
    required this.dateOfHire,
    required this.position,
    required this.driverLicenceNbr,
    required this.race,
    required this.rating,
    required this.signatureURL,
    required this.countyId,
    required this.active,
    required this.summary,
  });
}

class DisciplineType {
  final int employeeTypeId;
  final String employeeType;
  final String color;
  final String abbreviation;
  final int departmentId;

  DisciplineType({
    required this.employeeTypeId,
    required this.employeeType,
    required this.color,
    required this.abbreviation,
    required this.departmentId,
  });
}

class DisciplineData {
  final int disciplineId;
  final DisciplineType employeetypeId;
  final EmployeeId employeedId;
  final String notesToClinician;
  final String createdAt;
  final String updatedAt;

  DisciplineData({
    required this.disciplineId,
    required this.employeetypeId,
    required this.employeedId,
    required this.notesToClinician,
    required this.createdAt,
    required this.updatedAt,
  });
}


