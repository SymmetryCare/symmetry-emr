class PatientReferralHeaderData {
  final int patientId;
  final String patientName;
  final String imgUrl;
  final int mrn;
  final String patientStatus;
  final List<String> careTeam;
  final String? primaryPhysician;
  final String? physicianPhone;
  final String primaryDiagnosis;
  final String insurance;
  final String specialPrecautions;
  final String rehospitalizationRisk;
  final int? patientGroupId;
  final int? clinicianGroupId;

  PatientReferralHeaderData({
    required this.patientId,
    required this.patientName,
    required this.imgUrl,
    required this.mrn,
    required this.patientStatus,
    required this.careTeam,
    this.primaryPhysician,
    this.physicianPhone,
    required this.primaryDiagnosis,
    required this.insurance,
    required this.specialPrecautions,
    required this.rehospitalizationRisk,
    this.patientGroupId,
    this.clinicianGroupId,
  });
}