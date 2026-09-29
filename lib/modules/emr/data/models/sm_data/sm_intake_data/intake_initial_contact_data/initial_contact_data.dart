class PatientInitialContactData{
  final int initialContactId;
  final int patientId;
  final bool introCallComplete;
  final bool patientIsHome;
  final bool consentsNeeded;
  final bool demographicsConfirmed;
  final String potentialDcDate;
  final bool sendConsentsForSign;
  final bool representativePresentSoc;
  final String createdAt;
  final String updatedAt;

  PatientInitialContactData({required this.initialContactId,
    required this.patientId, required this.introCallComplete,
    required this.patientIsHome, required this.consentsNeeded,
    required this.demographicsConfirmed, required this.potentialDcDate,
    required this.sendConsentsForSign, required this.representativePresentSoc,
    required this.createdAt, required this.updatedAt});

}