class EligibleClinicianData {
  final int employeeTypeId;
  final String eligibleClinician;
  final String color;

  EligibleClinicianData({
    required this.employeeTypeId,
    required this.eligibleClinician,
    required this.color,
  });
}

class VisitListData {
  final int visitId;
  final String typeOfVisit;
  final String serviceId;
  final List<EligibleClinicianData> eligibleClinician;

  VisitListData({
    required this.visitId,
    required this.typeOfVisit,
    required this.serviceId,
    required this.eligibleClinician,
  });
}