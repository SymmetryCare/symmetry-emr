class SignatureFormDocumentRepository {
  static String _signatureFormDocuments = '/signature-form-documents';
  static String _attach = '/attach';
  static String _add = '/add';
  static String _patient = '/patient';

  static String add = '$_signatureFormDocuments$_add';

  static String attachDocument({required int sigDocId}) {
    return '$_signatureFormDocuments$_attach/$sigDocId';
  }

  static String getByPatientId({required int patientId}) {
    return '$_signatureFormDocuments$_patient/$patientId';
  }
  static String delete({required int sigDocId}) {
    return '$_signatureFormDocuments/$sigDocId';
  }
}