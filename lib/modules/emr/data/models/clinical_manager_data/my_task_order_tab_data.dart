class PhysicianOrderListResponseData {
  final List<PhysicianOrderData>? data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PhysicianOrderListResponseData({
    required this.data,
    this.total      = 0,
    this.page       = 1,
    this.limit      = 20,
    this.totalPages = 0,
  });
}

class PhysicianOrderData {
  final int patientFormId;
  final int supplyOrderId;
  final String? orderId;
  final String formType;
  final String formDate;
  final String status;
  final String? orderStatus;
  final String? deliveryStatus;
  final bool? faceToFace;
  final String? timelyFilingDeadline;
  final String? dateSentForCorrection;
  final int? assignedCmEmployeeId;
  final int? assignedDmeEmployeeId;
  final PhysicianOrderPatientData patient;
  final PhysicianOrderStaffData clinician;
  final PhysicianOrderQaData? qa;
  final PhysicianOrderCodingStaffData? codingStaff;
  final List<PhysicianOrderStatusHistoryData> statusHistory;

  bool get isSupplyOrder => supplyOrderId != 0;

  PhysicianOrderData({
    required this.patientFormId,
    this.supplyOrderId = 0,
    this.orderId,
    required this.formType,
    required this.formDate,
    required this.status,
    this.orderStatus,
    this.deliveryStatus,
    this.faceToFace,
    this.timelyFilingDeadline,
    this.dateSentForCorrection,
    this.assignedCmEmployeeId,
    this.assignedDmeEmployeeId,
    required this.patient,
    required this.clinician,
    this.qa,
    this.codingStaff,
    required this.statusHistory,
  });
}

class PhysicianOrderPatientData {
  final int ptId;
  final String name;
  final int mrn;
  final int chartNo;
  final String? primaryInsurance;
  final String? secondaryInsurance;
  final String? insuranceCategory;
  final bool? insuranceEligibilityStatus;
  final int fkPtPrimaryDiagnosis;
  final PhysicianOrderDiagnosisData? primaryDiagnosis;
  final String? ptImgUrl;

  PhysicianOrderPatientData({
    required this.ptId,
    required this.name,
    required this.mrn,
    required this.chartNo,
    this.primaryInsurance,
    this.secondaryInsurance,
    this.insuranceCategory,
    this.insuranceEligibilityStatus,
    required this.fkPtPrimaryDiagnosis,
    this.primaryDiagnosis,
    this.ptImgUrl,
  });
}

class PhysicianOrderDiagnosisData {
  final int dgnId;
  final String dgnName;
  final String dgnCode;

  PhysicianOrderDiagnosisData({
    required this.dgnId,
    required this.dgnName,
    required this.dgnCode,
  });
}

class PhysicianOrderStaffData {
  final int staffId;
  final String name;
  final String imgurl;
  final String color;
  final String abbreviation;
  final String? timelyFilingDeadline;

  PhysicianOrderStaffData({
    required this.staffId,
    required this.name,
    required this.imgurl,
    required this.color,
    required this.abbreviation,
    this.timelyFilingDeadline,
  });
}

class PhysicianOrderQaData {
  final int staffId;
  final String name;
  final String color;
  final String abbreviation;
  final String? timelyFilingDeadline;

  PhysicianOrderQaData({
    required this.staffId,
    required this.name,
    required this.color,
    required this.abbreviation,
    this.timelyFilingDeadline,
  });
}

class PhysicianOrderCodingStaffData {
  final int staffId;
  final String name;
  final String color;
  final String abbreviation;
  final String? timelyFilingDeadline;

  PhysicianOrderCodingStaffData({
    required this.staffId,
    required this.name,
    required this.color,
    required this.abbreviation,
    this.timelyFilingDeadline,
  });
}

class PhysicianOrderStatusHistoryData {
  final String fromStatus;
  final String toStatus;
  final String? note;
  final PhysicianOrderChangedByData changedBy;
  final String changedAt;

  PhysicianOrderStatusHistoryData({
    required this.fromStatus,
    required this.toStatus,
    this.note,
    required this.changedBy,
    required this.changedAt,
  });
}

class PhysicianOrderChangedByData {
  final int employeeId;
  final String name;

  PhysicianOrderChangedByData({
    required this.employeeId,
    required this.name,
  });
}