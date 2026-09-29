///main patient refferal

class PatientModel {
  final int ptId;
  final String? ptFirstName;
  final String ptLastName;
  final String ptContactNo;
  final String ptZipCode;
  final int ptChartNo;
  final String ptSummary;
  final String ptRefferalDate;///
  final int fkSrvId;
  final int fkPtPrimaryDiagnosis;
  final List<int> fkPtSecondaryDiagnosis;
  final int fkPtRefferalSource;
  final int fkPtPcp;
  final int fkPtMarketer;
  final List<int> fkPtDiscplines;
  final int ptCoverageArea;
  final bool isIntake;
  final String? intakeTime;///
  final bool isArchieved;
  final String? archievedTime;//final DateTime? archievedTime;
 // final int insuranceId;
  final String createdAt;///
  final String ptDateOfBirth;///
  final String? ptImgUrl;
  final int? fkempIdArchieved;
  final int? fkRptiId;
  final bool isSelfPay;
  final String? documentName;
  final bool moveToScheduler;
  final String moveToSchedulerDatetime;///
  final String admitDateTime;///
  final bool isNonAdmit;
  final int ptMRN; ///
  final String ptSOCDate;
  final bool ptSOCStatus;
  final String potentialDischargeDate;///
  final String ptAddress;
  final String ptMedicalNote;
  final bool isDemographicFilled;
  final bool isDocumentationUpload;
  final bool isPrimaryInsuranceFilled;
  final bool isPhysicianFilled;
  final bool isOrdersFilled;
  final bool isInitialContactFilled;
  // final bool isScheduler;
  // final String schedulerTime;
  final ServiceModel service;
  final ReferralSourceModel referralSource;
  final PCPModel pcp;
  final MarketerModel marketer;
  final List<DisciplineModel> disciplines;
  final List<PatientDiagnosesModel> patientDiagnoses;
  final List<InsuranceModel> insurance;
  final bool potentialDuplicate;
  final bool allCliniciansAssigned;
  final int thresould;
  final List<DetailedDiscipline> detailedDisciplines;
  PatientModel({
    required this.ptId,
    this.ptFirstName,
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
    this.intakeTime,
    required this.isArchieved,
    this.archievedTime,
    //required this.insuranceId,
    required this.createdAt,
    required this.ptDateOfBirth,
    required this.ptImgUrl,
    this.fkempIdArchieved,
    this.fkRptiId,
    required this.isSelfPay,
    this.documentName,
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
    required this.isPrimaryInsuranceFilled,
    required this.isPhysicianFilled,
    required this.isOrdersFilled,
    required this.isInitialContactFilled,
    required this.service,
    required this.referralSource,
    required this.pcp,
    required this.marketer,
    required this.disciplines,
    required this.patientDiagnoses,
    required this.insurance,
    required this.potentialDuplicate,
    required this.thresould,
    required this.allCliniciansAssigned,
    required this.detailedDisciplines,
  });
}

class DetailedDiscipline {
  final int disciplineId;
  final int fkPtId;
  final int fkEmployeeTypeId;
  final int fkEmployeeId;
  final String notesToClinician;
  final bool sentAsRequest;
  final int employeeTypeId;
  final String employeeType;
  final String color;
  final String abbreviation;
  final int departmentId;
  final int DepartmentId;
  final int employeeId;
  final String firstName;
  final String lastName;
  final String expertise;
  final String imgUrl;
  final int userId;
  final int empEmployeeTypeId;
  final int companyId;

  DetailedDiscipline({
    required this.disciplineId,
    required this.fkPtId,
    required this.fkEmployeeTypeId,
    required this.fkEmployeeId,
    required this.notesToClinician,
    required this.sentAsRequest,
    required this.employeeTypeId,
    required this.employeeType,
    required this.color,
    required this.abbreviation,
    required this.departmentId,
    required this.DepartmentId,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.expertise,
    required this.imgUrl,
    required this.userId,
    required this.empEmployeeTypeId,
    required this.companyId,
  });
}


class ServiceModel {
  final int srvId;
  final String srvName;
  final String srvCode;

  ServiceModel({required this.srvId, required this.srvName, required this.srvCode});
}

class ReferralSourceModel {
  final int refSourceId;
  final String sourceName;
  final String description;
  final String referralSourceImgUrl;
  final String? documentName;

  ReferralSourceModel({
    required this.refSourceId,
    required this.sourceName,
    required this.description,
    required this.referralSourceImgUrl,
    this.documentName,
  });
}

class PCPModel {
  final int phyId;
  final String phyFirstName;
  final String? phyFirstNameLink;
  final int? phyFirstNamePgNo;

  final String phyLastName;
  final String? phyLastNameLink;
  final int? phyLastNamePgNo;

  final String phyPicoNo;
  final String? phyPicoNoLink;
  final int? phyPicoNoPgNo;

  final bool phyPicoStatus;

  final String phyEmail;
  final String? phyEmailLink;
  final int? phyEmailPgNo;

  final String phyContact;
  final String? phyContactLink;
  final int? phyContactPgNo;

  final int phyNPI;

  final String phyUPI;
  final String? phyUPILink;
  final int? phyUPIPgNo;

  final String phyCity;
  final String? phyCityLink;
  final int? phyCityPgNo;

  final String phyFax;
  final String? phyFaxLink;
  final int? phyFaxPgNo;

  final String phyNotes;
  final String? phyNotesLink;
  final int? phyNotesPgNo;

  final String phyProtocols;
  final String? phyProtocolsLink;
  final int? phyProtocolsPgNo;

  final String phyState;
  final String? phyStateLink;
  final int? phyStatePgNo;

  final String phyStreet;
  final String? phyStreetLink;
  final int? phyStreetPgNo;

  final String phySuffix;
  final String? phySuffixLink;
  final int? phySuffixPgNo;

  final String phySuite;
  final String? phySuiteLink;
  final int? phySuitePgNo;

  final String phyTrackingNotes;
  final String? phyTrackingNotesLink;
  final int? phyTrackingNotesPgNo;

  final String phyVerificationDetails;
  final String? phyVerificationDetailsLink;
  final int? phyVerificationDetailsPgNo;

  final bool phyVerified;

  final String phyZipCode;
  final String? phyZipCodeLink;
  final int? phyZipCodePgNo;

  PCPModel({
    required this.phyId,
    required this.phyFirstName,
    this.phyFirstNameLink,
    this.phyFirstNamePgNo,
    required this.phyLastName,
    this.phyLastNameLink,
    this.phyLastNamePgNo,
    required this.phyPicoNo,
    this.phyPicoNoLink,
    this.phyPicoNoPgNo,
    required this.phyPicoStatus,
    required this.phyEmail,
    this.phyEmailLink,
    this.phyEmailPgNo,
    required this.phyContact,
    this.phyContactLink,
    this.phyContactPgNo,
    required this.phyNPI,
    required this.phyUPI,
    this.phyUPILink,
    this.phyUPIPgNo,
    required this.phyCity,
    this.phyCityLink,
    this.phyCityPgNo,
    required this.phyFax,
    this.phyFaxLink,
    this.phyFaxPgNo,
    required this.phyNotes,
    this.phyNotesLink,
    this.phyNotesPgNo,
    required this.phyProtocols,
    this.phyProtocolsLink,
    this.phyProtocolsPgNo,
    required this.phyState,
    this.phyStateLink,
    this.phyStatePgNo,
    required this.phyStreet,
    this.phyStreetLink,
    this.phyStreetPgNo,
    required this.phySuffix,
    this.phySuffixLink,
    this.phySuffixPgNo,
    required this.phySuite,
    this.phySuiteLink,
    this.phySuitePgNo,
    required this.phyTrackingNotes,
    this.phyTrackingNotesLink,
    this.phyTrackingNotesPgNo,
    required this.phyVerificationDetails,
    this.phyVerificationDetailsLink,
    this.phyVerificationDetailsPgNo,
    required this.phyVerified,
    required this.phyZipCode,
    this.phyZipCodeLink,
    this.phyZipCodePgNo,
  });
}

class MarketerModel {
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
  final bool approved;///
  final bool terminationFlag;///
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

  MarketerModel({
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
  });
}

class DisciplineModel {
  final int employeeTypeId;
  final String employeeType;
  final String color;
  final String abbreviation;
  final int departmentId;

  DisciplineModel({
    required this.employeeTypeId,
    required this.employeeType,
    required this.color,
    required this.abbreviation,
    required this.departmentId,
  });
}

class PatientDiagnosesModel {

  final int rpt_dgn_id;
  final String dgnName;
  final String dgnCode;
  final int fk_pt_id;
  final int fk_dgn_id;
  final bool rpt_pdgm;
  final bool rpt_isPrimary;
  final int color;

  PatientDiagnosesModel({
    required this.fk_pt_id,
    required this.fk_dgn_id,
    required this.rpt_pdgm,
    required this.rpt_isPrimary,
    required this.color,
    required this.rpt_dgn_id,
    required this.dgnName,
    required this.dgnCode,
  });
}

class InsuranceModel {
  final int rptiId;
  final int fkptId;

  final String policy;
  final String? policyLink;
  final int? policyPgNo;

  final String insuranceProvider;
  final String? insuranceProviderLink;
  final int? insuranceProviderPgNo;

  final String insurancePlan;
  final String? insurancePlanLink;
  final int? insurancePlanPgNo;

  final bool eligibility;
  final bool authorization;

  final String? lastCheckedTime;

  final String? category;
  final String? categoryLink;
  final int? categoryPgNo;

  final String? city;
  final String? cityLink;
  final int? cityPgNo;

  final String? comments;
  final String? commentsLink;
  final int? commentsPgNo;

  final String? contact;
  final String? contactLink;
  final int? contactPgNo;

  final String? effectiveFrom;
  final String? effectiveTo;

  final String? email;
  final String? emailLink;
  final int? emailPgNo;

  final String? groupName;
  final String? groupNameLink;
  final int? groupNamePgNo;

  final int? groupNumber;

  final String? name;
  final String? nameLink;
  final int? namePgNo;

  final String? state;
  final String? stateLink;
  final int? statePgNo;

  final String? street;
  final String? streetLink;
  final int? streetPgNo;

  final String? suite;
  final String? suiteLink;
  final int? suitePgNo;

  final String? type;
  final String? typeLink;
  final int? typePgNo;

  final bool verified;

  final String? zipcode;
  final String? zipcodeLink;
  final int? zipcodePgNo;

  InsuranceModel({
    required this.rptiId,
    required this.fkptId,

    required this.policy,
    this.policyLink,
    this.policyPgNo,

    required this.insuranceProvider,
    this.insuranceProviderLink,
    this.insuranceProviderPgNo,

    required this.insurancePlan,
    this.insurancePlanLink,
    this.insurancePlanPgNo,

    required this.eligibility,
    required this.authorization,

    this.lastCheckedTime,

    this.category,
    this.categoryLink,
    this.categoryPgNo,

    this.city,
    this.cityLink,
    this.cityPgNo,

    this.comments,
    this.commentsLink,
    this.commentsPgNo,

    this.contact,
    this.contactLink,
    this.contactPgNo,

    this.effectiveFrom,
    this.effectiveTo,

    this.email,
    this.emailLink,
    this.emailPgNo,

    this.groupName,
    this.groupNameLink,
    this.groupNamePgNo,

    this.groupNumber,

    this.name,
    this.nameLink,
    this.namePgNo,

    this.state,
    this.stateLink,
    this.statePgNo,

    this.street,
    this.streetLink,
    this.streetPgNo,

    this.suite,
    this.suiteLink,
    this.suitePgNo,

    this.type,
    this.typeLink,
    this.typePgNo,

    required this.verified,

    this.zipcode,
    this.zipcodeLink,
    this.zipcodePgNo,
  });
}




/// employee type
class EmployeeClinicalData{
  final int emptypeId;
  final String empType;
  final String color;
  final String abbreviation;
  final int deptId;

  EmployeeClinicalData({required this.emptypeId, required this.empType,
  required this.color, required this.abbreviation, required this.deptId});
}


class SpacialOrderData{
  final int spcialorderid;
  final String spcialordername;
  final String description;
  final String createdat;
  final String updatedat;

  SpacialOrderData({required this.spcialorderid, required this.spcialordername, required this.description, required this.createdat, required this.updatedat});
}






class AddOrderData{
  final int  patientid;
  final List<int> specialOrderId;
  final String dateReceived;
  final String orderdate;
  final List<int> ptDisciplines;
  final int  merkatereid;
  final int refersourceid ;
  final String casemanger;
  final String trackingnote;
  final bool ordersignature;

  AddOrderData({
    required this.patientid,
    required this.specialOrderId,
    required this.dateReceived,
    required this.orderdate,
    required this.ptDisciplines, required this.merkatereid,
    required this.refersourceid, required this.casemanger,
    required this.trackingnote, required this.ordersignature});
}




class PatientOrderData {
  final int orderId;
  final int patientId;
  final List<int> specialOrderIds;
  final String dateReceived;
  final String orderDate;
  final List<int> ptDisciplines;
  final int marketerId;
  final int referralSourceId;
  final CaseManager caseManager;
  final TrackingNotes trackingNotes;
  final bool ordersSignedDate;
  final String createdAt;
  final String updatedAt;

  PatientOrderData({
    required this.orderId,
    required this.patientId,
    required this.specialOrderIds,
    required this.dateReceived,
    required this.orderDate,
    required this.ptDisciplines,
    required this.marketerId,
    required this.referralSourceId,
    required this.caseManager,
    required this.trackingNotes,
    required this.ordersSignedDate,
    required this.createdAt,
    required this.updatedAt,
  });
}

class CaseManager {
  final String caseManager;
  final String caseManagerLink;
  final int caseManagerPgNo;

  CaseManager({
    required this.caseManager,
    required this.caseManagerLink,
    required this.caseManagerPgNo,
  });
}

class TrackingNotes {
  final String trackingNotes;
  final String trackingNotesLink;
  final int trackingNotesPgNo;

  TrackingNotes({
    required this.trackingNotes,
    required this.trackingNotesLink,
    required this.trackingNotesPgNo,
  });
}

///non admit
class NonAdmitData {
  final int ptId;
  final String? ptFirstName;
  final String ptLastName;
  final String ptContactNo;
  final String ptZipCode;
  final int ptChartNo;
  final String ptSummary;
  final String ptRefferalDate;///
  final int fkSrvId;
  final int fkPtPrimaryDiagnosis;
  final List<int> fkPtSecondaryDiagnosis;
  final int fkPtRefferalSource;
  final int fkPtPcp;
  final int fkPtMarketer;
  final List<int> fkPtDiscplines;
  final int ptCoverageArea;
  final bool isIntake;
  final String? intakeTime;///
  final bool isArchieved;
  final String? archievedTime;//final DateTime? archievedTime;
  // final int insuranceId;
  final String createdAt;///
  final String ptDateOfBirth;///
  final String? ptImgUrl;
  final int? fkempIdArchieved;
  final int? fkRptiId;
  final bool isSelfPay;
  final String? documentName;
  final bool moveToScheduler;
  final String moveToSchedulerDatetime;///
  final String admitDateTime;///
  final bool isNonAdmit;
  final int ptMRN; ///
  final String ptSOCDate;
  final bool ptSOCStatus;
  final String potentialDischargeDate;///
  final String ptAddress;
  final String ptMedicalNote;
  final bool isDemographicFilled;
  final bool isDocumentationUpload;
  final bool isPrimaryInsuranceFilled;
  final bool isPhysicianFilled;
  final bool isOrdersFilled;
  final bool isInitialContactFilled;
  // final bool isScheduler;
  // final String schedulerTime;
  final ServiceModel service;
  final ReferralSourceModel referralSource;
  final PCPModel pcp;
  final MarketerModel marketer;
  final List<DisciplineModel> disciplines;
  final List<PatientDiagnosesModel> patientDiagnoses;
  final List<InsuranceModel> insurance;
  final bool potentialDuplicate;
  final bool allCliniciansAssigned;
  final int thresould;
  final List<DetailedDiscipline> detailedDisciplines;
  NonAdmitData({
    required this.ptId,
    this.ptFirstName,
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
    this.intakeTime,
    required this.isArchieved,
    this.archievedTime,
    //required this.insuranceId,
    required this.createdAt,
    required this.ptDateOfBirth,
    required this.ptImgUrl,
    this.fkempIdArchieved,
    this.fkRptiId,
    required this.isSelfPay,
    this.documentName,
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
    required this.isPrimaryInsuranceFilled,
    required this.isPhysicianFilled,
    required this.isOrdersFilled,
    required this.isInitialContactFilled,
    required this.service,
    required this.referralSource,
    required this.pcp,
    required this.marketer,
    required this.disciplines,
    required this.patientDiagnoses,
    required this.insurance,
    required this.potentialDuplicate,
    required this.thresould,
    required this.allCliniciansAssigned,
    required this.detailedDisciplines,
  });
}
