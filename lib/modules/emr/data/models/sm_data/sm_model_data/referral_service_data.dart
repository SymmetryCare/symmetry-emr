class ServicePatientReffralsData{
  final int serviceId;
  final String serviceName;
  final String serviceCode;
  ServicePatientReffralsData({required this.serviceId, required this.serviceName, required this.serviceCode,});
}

/// refferal sources
class PatientRefferalSourcesData{
  final int ref_source_id;
  final String source_name;
  final String description;
  final String referral_source_img_url;
  final String documentName;
  PatientRefferalSourcesData({required this.documentName,
    required this.ref_source_id,
    required this.source_name,
    required this.description,
    required this.referral_source_img_url});
}

/// patient physician master
class PatientPhysicianMasterData {
  final int phyId;
  final NameField firstName;
  final NameField lastName;
  final PicoNoField picoNo;
  final bool phyPicoStatus;
  final EmailField email;
  final ContactField contact;
  final NpiField phyNPI;
  final UpiField upi;
  final CityField city;
  final FaxField fax;
  final NotesField notes;
  final ProtocolsField protocols;
  final StateField state;
  final StreetField street;
  final SuffixField suffix;
  final SuiteField suite;
  final TrackingNotesField trackingNotes;
  final VerificationDetailsField verificationDetails;
  final bool phyVerified;
  final ZipCodeField zipcode;

  PatientPhysicianMasterData({
    required this.phyId,
    required this.firstName,
    required this.lastName,
    required this.picoNo,
    required this.phyPicoStatus,
    required this.email,
    required this.contact,
    required this.phyNPI,
    required this.upi,
    required this.city,
    required this.fax,
    required this.notes,
    required this.protocols,
    required this.state,
    required this.street,
    required this.suffix,
    required this.suite,
    required this.trackingNotes,
    required this.verificationDetails,
    required this.phyVerified,
    required this.zipcode,
  });
}

// Sub-model classes below

class NameField {
  final String value;
  final String link;
  final int pgNo;

  NameField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class PicoNoField {
  final String value;
  final String link;
  final int pgNo;

  PicoNoField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class EmailField {
  final String value;
  final String link;
  final int pgNo;

  EmailField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class ContactField {
  final String value;
  final String link;
  final int pgNo;

  ContactField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class NpiField {
  final int value;
  final String link;
  final int pgNo;

  NpiField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class UpiField {
  final String value;
  final String link;
  final int pgNo;

  UpiField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class CityField {
  final String value;
  final String link;
  final int pgNo;

  CityField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class FaxField {
  final String value;
  final String link;
  final int pgNo;

  FaxField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class NotesField {
  final String value;
  final String link;
  final int pgNo;

  NotesField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class ProtocolsField {
  final String value;
  final String link;
  final int pgNo;

  ProtocolsField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class StateField {
  final String value;
  final String link;
  final int pgNo;

  StateField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class StreetField {
  final String value;
  final String link;
  final int pgNo;

  StreetField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class SuffixField {
  final String value;
  final String link;
  final int pgNo;

  SuffixField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class SuiteField {
  final String value;
  final String link;
  final int pgNo;

  SuiteField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class TrackingNotesField {
  final String value;
  final String link;
  final int pgNo;

  TrackingNotesField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class VerificationDetailsField {
  final String value;
  final String link;
  final int pgNo;

  VerificationDetailsField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}

class ZipCodeField {
  final String value;
  final String link;
  final int pgNo;

  ZipCodeField({
    required this.value,
    required this.link,
    required this.pgNo,
  });
}



class PatientMarketerData{
  final int employeeId;
  final String firstName;
  final String lastName;
  final int departmentId;
  final int employeeTypeId;
  PatientMarketerData({
    required this.employeeTypeId,
    required this.employeeId, required this.firstName, required this.lastName, required this.departmentId});
}

class PatientDiagnosisMasterData{
  final int dgnId;
  final String dgnName;
  final String dgnCode;

  PatientDiagnosisMasterData({required this.dgnId, required this.dgnName, required this.dgnCode});

}


class PatientDiagnosisWithIdData {
  final int dgnId;
  final int ptId;
  final int fkDgnId;
  final bool pdgm;
  final bool isPrimary;
  final String dgnName;
  final String dgnCode;
  final int colorId;

  PatientDiagnosisWithIdData({required this.dgnName, required this.dgnCode, required this.colorId,
    required this.dgnId, required this.ptId, required this.fkDgnId, required this.pdgm, required this.isPrimary});

}



class ReferralSourcesData{
  final int refsouid;
  final String sourcename ;
  final String description;
  final String imgurl ;
  final String docname;

  ReferralSourcesData({required this.refsouid, required this.sourcename, required this.description, required this.imgurl, required this.docname, });
}
