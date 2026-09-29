class PatientInsuranceDocumentData {
  final int insuranceDocumentId;
  final int ptId;
  final String docUrl;
  final String docName;
  final bool isPrimary;
  final DateTime createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;

  PatientInsuranceDocumentData(
      {required this.insuranceDocumentId,
      required this.ptId,
      required this.docUrl,
      required this.docName,
      required this.isPrimary,
      required this.createdAt,
      required this.createdBy,
      required this.updatedAt,
      required this.updatedBy});
}

class PatientSecondInsuranceDocumentData {
  final int insuranceDocumentId;
  final int ptId;
  final String docUrl;
  final String docName;
  final bool isPrimary;
  final DateTime createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;

  PatientSecondInsuranceDocumentData(
      {required this.insuranceDocumentId,
        required this.ptId,
        required this.docUrl,
        required this.docName,
        required this.isPrimary,
        required this.createdAt,
        required this.createdBy,
        required this.updatedAt,
        required this.updatedBy});
}

class PatientInsuranceInfoData {
  final int rptiId;
  final int fkPtId;
  final Policy policy;
  final InsuranceProvider insuranceProvider;
  final InsurancePlan insurancePlan;
  final bool rptiEligibility;
  final bool rptiAuthorization;
  final String rptiLastCheckedTime;
  final Name name;
  final Type type;
  final Category category;
  final Street street;
  final Suite suite;
  final City city;
  final StateInsurance state;
  final Zipcode zipcode;
  final Contact contact;
  final String rptiEffectiveFrom;
  final String rptiEffectiveTo;
  final GroupName groupName;
  final GroupNumber groupNumber;
  final Email email;
  final bool rptiVerified;
  final Comments comments;
  final bool isSelfPay;    // ✅ New field added

  PatientInsuranceInfoData({
    required this.rptiId,
    required this.fkPtId,
    required this.policy,
    required this.insuranceProvider,
    required this.insurancePlan,
    required this.rptiEligibility,
    required this.rptiAuthorization,
    required this.rptiLastCheckedTime,
    required this.name,
    required this.type,
    required this.category,
    required this.street,
    required this.suite,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.contact,
    required this.rptiEffectiveFrom,
    required this.rptiEffectiveTo,
    required this.groupNumber,
    required this.groupName,
    required this.email,
    required this.rptiVerified,
    required this.comments,
    required this.isSelfPay,
  });
}

class Policy {
  final String rptiPolicy;
  final String rptiPolicyLink;
  final int rptiPolicyPgNo;

  Policy({
    required this.rptiPolicy,
    required this.rptiPolicyLink,
    required this.rptiPolicyPgNo,
  });
}

class InsuranceProvider {
  final String rptiInsuranceProvider;
  final String rptiInsuranceProviderLink;
  final int rptiInsuranceProviderPgNo;

  InsuranceProvider({
    required this.rptiInsuranceProvider,
    required this.rptiInsuranceProviderLink,
    required this.rptiInsuranceProviderPgNo,
  });
}

class InsurancePlan {
  final String rptiInsurancePlan;
  final String rptiInsurancePlanLink;
  final int rptiInsurancePlanPgNo;

  InsurancePlan({
    required this.rptiInsurancePlan,
    required this.rptiInsurancePlanLink,
    required this.rptiInsurancePlanPgNo,
  });
}

class Name {
  final String rptiName;
  final String rptiNameLink;
  final int rptiNamePgNo;

  Name({
    required this.rptiName,
    required this.rptiNameLink,
    required this.rptiNamePgNo,
  });
}

class Type {
  final String rptiType;
  final String rptiTypeLink;
  final int rptiTypePgNo;

  Type({
    required this.rptiType,
    required this.rptiTypeLink,
    required this.rptiTypePgNo,
  });
}

class Category {
  final String rptiCategory;
  final String rptiCategoryLink;
  final int rptiCategoryPgNo;

  Category({
    required this.rptiCategory,
    required this.rptiCategoryLink,
    required this.rptiCategoryPgNo,
  });
}

class Street {
  final String rptiStreet;
  final String rptiStreetLink;
  final int rptiStreetPgNo;

  Street({
    required this.rptiStreet,
    required this.rptiStreetLink,
    required this.rptiStreetPgNo,
  });
}

class Suite {
  final String rptiSuite;
  final String rptiSuiteLink;
  final int rptiSuitePgNo;

  Suite({
    required this.rptiSuite,
    required this.rptiSuiteLink,
    required this.rptiSuitePgNo,
  });
}

class City {
  final String rptiCity;
  final String rptiCityLink;
  final int rptiCityPgNo;

  City({
    required this.rptiCity,
    required this.rptiCityLink,
    required this.rptiCityPgNo,
  });
}

class StateInsurance {
  final String rptiState;
  final String rptiStateLink;
  final int rptiStatePgNo;

  StateInsurance({
    required this.rptiState,
    required this.rptiStateLink,
    required this.rptiStatePgNo,
  });
}

class Zipcode {
  final String rptiZipcode;
  final String rptiZipcodeLink;
  final int rptiZipcodePgNo;

  Zipcode({
    required this.rptiZipcode,
    required this.rptiZipcodeLink,
    required this.rptiZipcodePgNo,
  });
}

class Contact {
  final String rptiContact;
  final String rptiContactLink;
  final int rptiContactPgNo;

  Contact({
    required this.rptiContact,
    required this.rptiContactLink,
    required this.rptiContactPgNo,
  });
}

class GroupName {
  final String rptiGroupName;
  final String rptiGroupNameLink;
  final int rptiGroupNamePgNo;

  GroupName({
    required this.rptiGroupName,
    required this.rptiGroupNameLink,
    required this.rptiGroupNamePgNo,
  });
}

class GroupNumber {
  final int rptiGroupNumber;
  final String rptiGroupNumberLink;
  final int rptiGroupNumberPgNo;

  GroupNumber({
    required this.rptiGroupNumber,
    required this.rptiGroupNumberLink,
    required this.rptiGroupNumberPgNo,
  });
}

class Email {
  final String rptiEmail;
  final String rptiEmailLink;
  final int rptiEmailPgNo;

  Email({
    required this.rptiEmail,
    required this.rptiEmailLink,
    required this.rptiEmailPgNo,
  });
}

class Comments {
  final String rptiComments;
  final String rptiCommentsLink;
  final int rptiCommentsPgNo;

  Comments({
    required this.rptiComments,
    required this.rptiCommentsLink,
    required this.rptiCommentsPgNo,
  });
}
