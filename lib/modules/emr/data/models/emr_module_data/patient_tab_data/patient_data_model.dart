class F2FDocument {
  int f2fDocId;
  int fkF2fId;
  String f2fDocUrl;
  String f2fDocName;
  String f2fDocContent;
  String f2fDocCreatedAt;
  String f2fDocCreatedBy;

  F2FDocument({
    required this.f2fDocId,
    required this.fkF2fId,
    required this.f2fDocUrl,
    required this.f2fDocName,
    required this.f2fDocContent,
    required this.f2fDocCreatedAt,
    required this.f2fDocCreatedBy,
  });
}

class F2FRecord {
  int f2fId;
  int fkPtId;
  String rptdF2FDate;
  int fkMarketerId;
  String rptdVisitNote;
  String rptdF2Fappointment;
  List<F2FDocument> documents;

  F2FRecord({
    required this.f2fId,
    required this.fkPtId,
    required this.rptdF2FDate,
    required this.fkMarketerId,
    required this.rptdVisitNote,
    required this.rptdF2Fappointment,
    required this.documents,
  });
}

/// Signature doc

class PatientSigDoc {
  int sigDocId;
  int fkPtId;
  String sigDocUrl;
  String sigDocName;
  String sigDocContent;
  String sigDocCreatedAt;
  String sigDocCreatedBy;

  PatientSigDoc({
    required this.sigDocId,
    required this.fkPtId,
    required this.sigDocUrl,
    required this.sigDocName,
    required this.sigDocContent,
    required this.sigDocCreatedAt,
    required this.sigDocCreatedBy,
  });
}
