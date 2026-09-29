/// Root model for the API response.
class EmployeeDocumentData {
  final String todayDate;
  final List<DocumentGroup> document;

  EmployeeDocumentData({
    required this.todayDate,
    required this.document,
  });
}

/// Represents a single document category, e.g. "Acknowledgement".
class DocumentGroup {
  final String docName;
  final int metaId;
  final List<DocItem> docList;

  DocumentGroup({
    required this.docName,
    required this.metaId,
    required this.docList,
  });
}

/// Represents an individual uploaded document entry.
class DocItem {
  final int employeeDocumentId;
  final int employeeId;
  final String documentUrl;
  final int employeeDocumentTypeMetaDataId;
  final int employeeDocumentTypeSetupId;
  final String uploadDate;
  final bool approved;
  final String documentName;
  final String expiryDate;
  final String docStatus;
  final String status;

  DocItem({
    required this.employeeDocumentId,
    required this.employeeId,
    required this.documentUrl,
    required this.employeeDocumentTypeMetaDataId,
    required this.employeeDocumentTypeSetupId,
    required this.uploadDate,
    required this.approved,
    required this.documentName,
    required this.expiryDate,
    required this.docStatus,
    required this.status,
  });
}






///dropdown data

class EmployeeDocumentTypeSetupData {
  final int? employeeDocumentTypeSetupId;
  final String? documentName;
  final String? expiry;
  final String? reminderThreshold;
  final int? employeeDocumentTypeMetaDataId;
  final String? idOfDocument;
  final int? companyId;
  final String? expiryType;
  final int? threshold;

  EmployeeDocumentTypeSetupData({
    this.employeeDocumentTypeSetupId,
    this.documentName,
    this.expiry,
    this.reminderThreshold,
    this.employeeDocumentTypeMetaDataId,
    this.idOfDocument,
    this.companyId,
    this.expiryType,
    this.threshold,
  });

}






class EssentialDocData {
  final String? documentName;
  final int? employeeDocumentTypeMetaDataId;

  EssentialDocData({
    this.documentName,
    this.employeeDocumentTypeMetaDataId,
  });
}