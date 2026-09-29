class PatientProtocolRepo {
  static String getProtocol = "/protocol-type";
  static String getProtocolDetails = "/patient-protocol/ByPatientId";
  static String protocolAction = "/patient-protocol/add";
  static String uploadProtocolDoc = "/patient-protocol/upload-pdf";

  static String getProtocolList({required int patientId}) {
    return "$getProtocolDetails/$patientId";
  }

  static String postUploadDoc({required int protocolId}) {
    return "$uploadProtocolDoc/$protocolId";   // ← was patientId
  }
}