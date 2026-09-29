class SignatureFormDocumentData {
  final int sigDocId;
  final int fkPtId;
  final String sigDocUrl;
  final String sigDocName;
  final String? sigDocContent;
  final String sigDocCreatedAt;
  final String sigDocCreatedBy;

  SignatureFormDocumentData({
    required this.sigDocId,
    required this.fkPtId,
    required this.sigDocUrl,
    required this.sigDocName,
    this.sigDocContent,
    required this.sigDocCreatedAt,
    required this.sigDocCreatedBy,
  });
}


