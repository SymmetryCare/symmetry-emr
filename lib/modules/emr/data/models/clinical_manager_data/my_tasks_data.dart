// lib/data/api_data/my_task_order/my_task_order_data.dart
// lib/data/api_data/my_task_order/my_task_order_data.dart
//
// class MyTaskOrderResponseData {
//   final List<MyTaskOrderData>? data;
//   final int? total;
//   final int? page;
//   final int? limit;
//
//   MyTaskOrderResponseData({
//     required this.data,
//     this.total,
//     this.page,
//     this.limit,
//   });
// }
//
// class MyTaskOrderData {
//   final int id;
//   final int patientFormId;
//   final int subFormId;
//   final String subFormName;
//   final String physicianOrderStatus;
//   final bool isFilled;
//   final dynamic data;
//   final String createdAt;
//   final String updatedAt;
//   final int formId;
//   final String formName;
//   final int chartId;
//   final int episodeId;
//   final String status;
//   final MyTaskOrderPatientData patient;
//   final MyTaskOrderClinicianData? clinician;
//   final List<dynamic> statusHistory;
//
//   MyTaskOrderData({
//     required this.id,
//     required this.patientFormId,
//     required this.subFormId,
//     required this.subFormName,
//     required this.physicianOrderStatus,
//     required this.isFilled,
//     required this.data,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.formId,
//     required this.formName,
//     required this.chartId,
//     required this.episodeId,
//     required this.status,
//     required this.patient,
//     this.clinician,
//     required this.statusHistory,
//   });
// }
//
// class MyTaskOrderPatientData {
//   final int ptId;
//   final String name;
//   final int mrn;
//   final String chartNo;
//   final String? primaryInsurance;
//   final String? insuranceCategory;
//   final String? insuranceEligibilityStatus;
//   final int fkPtPrimaryDiagnosis;
//   final MyTaskOrderDiagnosisData? primaryDiagnosis;
//
//   MyTaskOrderPatientData({
//     required this.ptId,
//     required this.name,
//     required this.mrn,
//     required this.chartNo,
//     this.primaryInsurance,
//     this.insuranceCategory,
//     this.insuranceEligibilityStatus,
//     required this.fkPtPrimaryDiagnosis,
//     this.primaryDiagnosis,
//   });
// }
//
// class MyTaskOrderDiagnosisData {
//   final int dgnId;
//   final String dgnName;
//   final String dgnCode;
//
//   MyTaskOrderDiagnosisData({
//     required this.dgnId,
//     required this.dgnName,
//     required this.dgnCode,
//   });
// }
//
// class MyTaskOrderClinicianData {
//   final int staffId;
//   final String name;
//   final String imgurl;
//   final String color;
//   final String abbreviation;
//
//   MyTaskOrderClinicianData({
//     required this.staffId,
//     required this.name,
//     required this.imgurl,
//     required this.color,
//     required this.abbreviation,
//   });
// }


///patient data
///

// lib/data/api_data/patient_referral/patient_referral_data.dart

class PatientReferralData {
  final int ptId;
  final String ptFirstName;
  final String ptLastName;
  final String ptContactNo;
  final String ptZipCode;
  final int ptChartNo;
  final String ptSummary;
  final String ptRefferalDate;
  final String ptDateOfBirth;
  final String ptImgUrl;
  final int fkSrvId;
  final int genderId;
  final PatientReferralGenderData gender;
  final int fkPtPrimaryDiagnosis;
  final List<int> fkPtSecondaryDiagnosis;
  final int fkPtRefferalSource;
  final int fkPtPcp;
  final int fkPtMarketer;
  final List<int> fkPtDiscplines;
  final int ptCoverageArea;
  final int fkRptiId;
  final int fkEmpIdArchived;
  final bool isSelfPay;
  final String documentName;
  final bool isIntake;
  final String? intakeTime;
  final bool isArchieved;
  final String? archievedTime;
  final bool moveToScheduler;
  final String? moveToSchedulerDatetime;
  final bool isNonAdmit;
  final String? admitDateTime;
  final String createdAt;
  final bool isPotentialDuplicate;
  final int threshold;
  final int ptMRN;
  final String? ptSocDate;
  final String ptAddress;
  final String ptMedicalNote;
  final String? potentialDischargeDate;
  final bool ptSocStatus;

  PatientReferralData({
    required this.ptId,
    required this.ptFirstName,
    required this.ptLastName,
    required this.ptContactNo,
    required this.ptZipCode,
    required this.ptChartNo,
    required this.ptSummary,
    required this.ptRefferalDate,
    required this.ptDateOfBirth,
    required this.ptImgUrl,
    required this.fkSrvId,
    required this.genderId,
    required this.gender,
    required this.fkPtPrimaryDiagnosis,
    required this.fkPtSecondaryDiagnosis,
    required this.fkPtRefferalSource,
    required this.fkPtPcp,
    required this.fkPtMarketer,
    required this.fkPtDiscplines,
    required this.ptCoverageArea,
    required this.fkRptiId,
    required this.fkEmpIdArchived,
    required this.isSelfPay,
    required this.documentName,
    required this.isIntake,
    this.intakeTime,
    required this.isArchieved,
    this.archievedTime,
    required this.moveToScheduler,
    this.moveToSchedulerDatetime,
    required this.isNonAdmit,
    this.admitDateTime,
    required this.createdAt,
    required this.isPotentialDuplicate,
    required this.threshold,
    required this.ptMRN,
    this.ptSocDate,
    required this.ptAddress,
    required this.ptMedicalNote,
    this.potentialDischargeDate,
    required this.ptSocStatus,
  });
}

class PatientReferralGenderData {
  final int genderId;
  final String genderName;

  PatientReferralGenderData({
    required this.genderId,
    required this.genderName,
  });
}



///clinical data
///
// lib/data/api_data/employee/employee_by_id_data.dart

class EmployeeByIdData {
  final String summary;
  final int employeeId;
  final String code;
  final int userId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final int employeeTypeId;
  final String expertise;
  final int cityId;
  final int countryId;
  final int countyId;
  final int zoneId;
  final String ssnNbr;
  final String primaryPhoneNbr;
  final String secondryPhoneNbr;
  final String workPhoneNbr;
  final String regOfficId;
  final String personalEmail;
  final String workEmail;
  final String address;
  final String dateOfBirth;
  final String emergencyContact;
  final String covreage;
  final String employment;
  final String gender;
  final String status;
  final String service;
  final String imgurl;
  final String resumeurl;
  final String onboardingStatus;
  final int companyId;
  final bool terminationFlag;
  final String driverLicenceNbr;
  final bool approved;
  final String? dateofTermination;
  final String? dateofResignation;
  final String? dateofHire;
  final String rehirable;
  final String position;
  final String finalAddress;
  final String type;
  final String reason;
  final int finalPayCheck;
  final String? checkDate;
  final int grossPay;
  final int netPay;
  final String methods;
  final String materials;
  final String race;
  final String rating;
  final String signatureURL;
  final bool active;
  final int roleId;
  final String documentName;
  final String documentUrl;
  final String color;

  EmployeeByIdData({
    required this.summary,
    required this.employeeId,
    required this.code,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.employeeTypeId,
    required this.expertise,
    required this.cityId,
    required this.countryId,
    required this.countyId,
    required this.zoneId,
    required this.ssnNbr,
    required this.primaryPhoneNbr,
    required this.secondryPhoneNbr,
    required this.workPhoneNbr,
    required this.regOfficId,
    required this.personalEmail,
    required this.workEmail,
    required this.address,
    required this.dateOfBirth,
    required this.emergencyContact,
    required this.covreage,
    required this.employment,
    required this.gender,
    required this.status,
    required this.service,
    required this.imgurl,
    required this.resumeurl,
    required this.onboardingStatus,
    required this.companyId,
    required this.terminationFlag,
    required this.driverLicenceNbr,
    required this.approved,
    this.dateofTermination,
    this.dateofResignation,
    this.dateofHire,
    required this.rehirable,
    required this.position,
    required this.finalAddress,
    required this.type,
    required this.reason,
    required this.finalPayCheck,
    this.checkDate,
    required this.grossPay,
    required this.netPay,
    required this.methods,
    required this.materials,
    required this.race,
    required this.rating,
    required this.signatureURL,
    required this.active,
    required this.roleId,
    required this.documentName,
    required this.documentUrl,
    required this.color,
  });
}