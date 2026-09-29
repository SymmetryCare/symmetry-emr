class PatientProtocolModule {
  final int protocolTypeId;
  final String typeName;
  final String createdAt;
  final String updatedAt;

  PatientProtocolModule({
    required this.protocolTypeId,
    required this.typeName,
    required this.createdAt,
    required this.updatedAt,
  });
}


/// Get by patient
class PatientProtocolListModule{
  final int protocolId;
  final int patientId;
  final int protocolTypeId;
  final String pdfUrl;
  final String fileName;
  final String uploadedAt;
  final String createdAt;
  final String updatedAt;
  final ProtocolData protocolType;

  PatientProtocolListModule({
    required this.protocolId,
    required this.patientId,
    required this.protocolTypeId,
    required this.pdfUrl,
    required this.fileName,
    required this.uploadedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.protocolType,
  });
}

class ProtocolData {
  final int protocolTypeId;
  final String typeName;
  final String createdAt;
  final String updatedAt;

  ProtocolData({
    required this.protocolTypeId,
    required this.typeName,
    required this.createdAt,
    required this.updatedAt,
  });
}

