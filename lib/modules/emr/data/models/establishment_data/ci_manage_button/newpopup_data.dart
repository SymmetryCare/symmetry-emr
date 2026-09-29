class TypeofDocpopup {
  final int orgDocumentSetupid;
  final int documenttypeid;
  final int documentsubtypeid;
  final String docname;
  final String expirytype;
  final int threshold;
  final String expirydate;
  final String expiryreminder;
  final int companyid;
  final String idOfDocument;
  final bool? hasIssuerExpiry;

  TypeofDocpopup({
    required this.orgDocumentSetupid,
    required this.documenttypeid,
    required this.documentsubtypeid,
    required this.docname,
    required this.expirytype,
    required this.threshold,
    required this.expirydate,
    required this.expiryreminder,
    required this.companyid,
    required this.idOfDocument,
    this.hasIssuerExpiry,
  });
}

///get
// class MCorporateComplianceModal {
//   final int orgOfficeDocumentId;
//   final int orgDocumentSetupid;
//   final String idOfDocument;
//   final String doc_created_at;
//   final String expiry_date;
//   final String docurl;
//   final int companyId;
//   final String officeId;
//
//   MCorporateComplianceModal(
//       {
//         required this.orgOfficeDocumentId,
//         required this.orgDocumentSetupid,
//         required this.idOfDocument,
//         required this.doc_created_at,
//         required this.expiry_date,
//         required this.docurl,
//         required this.companyId,
//         required this.officeId
//       });
// }
class MCorporateComplianceModal {
  final int orgOfficeDocumentId;
  final int orgDocumentSetupid;
  final String idOfDocument;
  final String doc_created_at;
  final String expiry_date;
  final String docurl;
  final int companyId;
  final String officeId;
  final String? docName;
  final String fileName;
  final bool isOthersDocs;
  final List<dynamic> docHistory; // Add this field

  MCorporateComplianceModal({
    required this.fileName,
    required this.orgOfficeDocumentId,
    required this.orgDocumentSetupid,
    required this.idOfDocument,
    required this.doc_created_at,
    required this.expiry_date,
    required this.docurl,
    required this.companyId,
    required this.officeId,
    required this.isOthersDocs,
    this.docName,
    required this.docHistory, // Initialize it here
  });
}

///prefill
class MCorporateCompliancePreFillModal {
  final int documentSetupId;
  final String idOfDocument;
  final String doc_created_at;
  final String expiry_date;
  final String url;
  final int companyId;
  final String officeId;
  final int threshould;
  final String expType;
  final String docName;
  final int docSubTypeId;
  final String fileName;
  final int docTypeId;
  final int orgOfficeDocumentId;
  final bool isOthersDocs;

  MCorporateCompliancePreFillModal(
      {required this.orgOfficeDocumentId,
      required this.documentSetupId,
        required this.fileName,
      required this.threshould,
      required this.expType,
      required this.docName,
      required this.docSubTypeId,
      required this.docTypeId,
      required this.idOfDocument,
      required this.doc_created_at,
      required this.expiry_date,
      required this.url,
      required this.companyId,
      required this.isOthersDocs,
      required this.officeId});
}
