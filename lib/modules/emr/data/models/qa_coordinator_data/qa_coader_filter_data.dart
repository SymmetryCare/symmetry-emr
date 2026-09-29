class FormData {
  final int formId;
  final String formName;
  final String? formCode;
  final int visitTypeId;
  final int? employeeTypeId;
  final String visitType;
  final String? employeeType;

  FormData({
    required this.formId,
    required this.formName,
    this.formCode,
    required this.visitTypeId,
    this.employeeTypeId,
    required this.visitType,
    this.employeeType,
  });
}



class PatientFormStaffData {
  final int employeeId;
  final String name;
  final String imgurl;
  final PatientFormStaffEmployeeTypeData employeeType;
  final int totalTaskCount;

  PatientFormStaffData({
    required this.employeeId,
    required this.name,
    required this.imgurl,
    required this.employeeType,
    required this.totalTaskCount,
  });
}

class PatientFormStaffEmployeeTypeData {
  final int employeeTypeId;
  final String employeeType;
  final String abbreviation;
  final String color;

  PatientFormStaffEmployeeTypeData({
    required this.employeeTypeId,
    required this.employeeType,
    required this.abbreviation,
    required this.color,
  });
}

class PatientFormStaffResponseData {
  final List<PatientFormStaffData>? data;
  final int? total;
  final int? page;
  final int? limit;
  final int? totalPages;

  PatientFormStaffResponseData({
    required this.data,
    this.total,
    this.page,
    this.limit,
    this.totalPages,
  });
}