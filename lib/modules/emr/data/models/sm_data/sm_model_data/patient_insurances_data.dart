class PatientInsurancesData{
  final int insurance_id;
  final String insurance_policy;
  final String insurance_provider;
  final String insurance_plan;

  PatientInsurancesData({
    required this.insurance_id,
    required this.insurance_policy,
    required this.insurance_provider,
    required this.insurance_plan});
}

/// patient documents
class PatientDocumentsData {
  final int rptd_id;
  final int fk_pt_id;
  final String rptd_url;
  final String documentName;
  final String rptd_created_at;
  final String rptd_created_by;
  final int rptd_document_type;
  final String rptd_content;

  PatientDocumentsData({
    required this.rptd_id,
    required this.documentName,
    required this.fk_pt_id,
    required this.rptd_url,
    required this.rptd_created_at,
    required this.rptd_created_by,
    required this.rptd_document_type,
    required this.rptd_content,
  });
}

///patient document billing attachment
class PatientDocumentsBillingData{
  final int rptd_id;
  final int fk_pt_id;
  final String rptd_url;
  final String documentName;
  final String rptd_created_at;
  final int rptd_created_by;
  final int rptd_document_type;
  final String rptd_content;
  PatientDocumentsBillingData({required this.rptd_id,
    required this.documentName,
    required this.fk_pt_id,
    required this.rptd_url, required this.rptd_created_at, required this.rptd_created_by, required this.rptd_document_type,
    required this.rptd_content});
}

///patient document Consent
class PatientDocumentsConsentData{
  final int rptd_id;
  final int fk_pt_id;
  final String rptd_url;
  final String documentName;
  final String rptd_created_at;
  final int rptd_created_by;
  final int rptd_document_type;
  final String rptd_content;

  PatientDocumentsConsentData({required this.rptd_id,
    required this.documentName,
    required this.fk_pt_id,
    required this.rptd_url, required this.rptd_created_at, required this.rptd_created_by, required this.rptd_document_type,
    required this.rptd_content});
}

/// patient document F2f — nested document inside a F2F record
class FTwoFDocumentsModel {
  final int f2f_doc_id;
  final int fk_f2f_id;
  final String f2f_doc_url;
  final String f2f_doc_name;
  final String f2f_doc_content;
  final String f2f_doc_created_at;
  final String f2f_doc_created_by;

  FTwoFDocumentsModel({
    required this.f2f_doc_id,
    required this.fk_f2f_id,
    required this.f2f_doc_url,
    required this.f2f_doc_name,
    required this.f2f_doc_content,
    required this.f2f_doc_created_at,
    required this.f2f_doc_created_by,
  });
}

/// patient document F2f
// ✅ removed documentName, rptd_created_at, rptd_content, rptd_created_by —
// these are NOT present anywhere in the actual /f2f/patient/{id} response
// at the top level (confirmed against real API response). Only the fields
// below exist on the top-level record; per-document info (name, date,
// created by) lives on FTwoFDocumentsModel inside `documents`.
class PatientDocumentsFtwoFData {
  final int f2f_id;
  final int fk_pt_id;
  final String rptd_F2FDate;
  final int fk_marketerId;
  final String? rptd_visitNote;
  final String? rptd_F2Fappointment;
  final List<FTwoFDocumentsModel>? documents;

  PatientDocumentsFtwoFData({
    required this.f2f_id,
    required this.fk_pt_id,
    required this.fk_marketerId,
    this.documents,
    this.rptd_visitNote,
    this.rptd_F2Fappointment,
    required this.rptd_F2FDate,
  });
}

class AIRefPatientInsurance {
  final int rpti_id_I;
  final int fk_pt_id;
  final String rpti_policy_I;
  final String rpti_insurance_provider_I;
  final String rpti_insurance_plan_I;
  final String rpti_name_I;
  final String rpti_type_I;
  final String rpti_category_I;
  final String rpti_street_I;
  final String rpti_suite_I;
  final String rpti_city_I;
  final String rpti_state_I;
  final String rpti_zipcode_I;
  final String rpti_contact_I;
  final String rpti_groupName_I;
  final String rpti_email_I;
  final String rpti_comments_I;

  AIRefPatientInsurance({
    required this.rpti_id_I,
    required this.fk_pt_id,
    required this.rpti_policy_I,
    required this.rpti_insurance_provider_I,
    required this.rpti_insurance_plan_I,
    required this.rpti_name_I,
    required this.rpti_type_I,
    required this.rpti_category_I,
    required this.rpti_street_I,
    required this.rpti_suite_I,
    required this.rpti_city_I,
    required this.rpti_state_I,
    required this.rpti_zipcode_I,
    required this.rpti_contact_I,
    required this.rpti_groupName_I,
    required this.rpti_email_I,
    required this.rpti_comments_I,
});
}
