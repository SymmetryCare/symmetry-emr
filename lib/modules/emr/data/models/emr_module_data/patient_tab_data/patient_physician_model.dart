class PatientPhysicianModel {
  final int phyId;
  final PatientPhyFirstName firstName;
  final PatientPhyLastName lastName;
  final PatientPhyPicoNo picoNo;
  final bool phyPicoStatus;
  final PatientPhyEmail email;
  final PatientPhyContact contact;
  final PatientPhyNPI phyNPI;
  final PatientPhyUPI upi;
  final PatientPhyCity city;
  final PatientPhyFax fax;
  final PatientPhyNotes notes;
  final PatientPhyProtocols protocols;
  final PatientPhyState state;
  final PatientPhyStreet street;
  final PatientPhySuffix suffix;
  final PatientPhySuite suite;
  final PatientPhyTrackingNotes trackingNotes;
  final PatientPhyVerificationDetails verificationDetails;
  final bool phyVerified;
  final PatientPhyZipCode zipcode;
  final PatientPhyUrl profileUrl;

  PatientPhysicianModel({
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
    required this.profileUrl,
  });
}

class PatientPhyFirstName {
  final String phyFirstName;
  final String phyFirstNameLink;
  final int phyFirstNamePgNo;

  PatientPhyFirstName({
    required this.phyFirstName,
    required this.phyFirstNameLink,
    required this.phyFirstNamePgNo,
  });
}

class PatientPhyLastName {
  final String phyLastName;
  final String phyLastNameLink;
  final int phyLastNamePgNo;

  PatientPhyLastName({
    required this.phyLastName,
    required this.phyLastNameLink,
    required this.phyLastNamePgNo,
  });
}

class PatientPhyPicoNo {
  final String phyPicoNo;
  final String phyPicoNoLink;
  final int phyPicoNoPgNo;

  PatientPhyPicoNo({
    required this.phyPicoNo,
    required this.phyPicoNoLink,
    required this.phyPicoNoPgNo,
  });
}

class PatientPhyEmail {
  final String phyEmail;
  final String phyEmailLink;
  final int phyEmailPgNo;

  PatientPhyEmail({
    required this.phyEmail,
    required this.phyEmailLink,
    required this.phyEmailPgNo,
  });
}

class PatientPhyContact {
  final String phyContact;
  final String phyContactLink;
  final int phyContactPgNo;

  PatientPhyContact({
    required this.phyContact,
    required this.phyContactLink,
    required this.phyContactPgNo,
  });
}

class PatientPhyNPI {
  final int phyNPI;
  final String phyNPILink;
  final int phyFirstNamePgNo;

  PatientPhyNPI({
    required this.phyNPI,
    required this.phyNPILink,
    required this.phyFirstNamePgNo,
  });
}

class PatientPhyUPI {
  final String phyUPI;
  final String phyUPILink;
  final int phyUPIPgNo;

  PatientPhyUPI({
    required this.phyUPI,
    required this.phyUPILink,
    required this.phyUPIPgNo,
  });
}

class PatientPhyCity {
  final String phyCity;
  final String phyCityLink;
  final int phyCityPgNo;

  PatientPhyCity({
    required this.phyCity,
    required this.phyCityLink,
    required this.phyCityPgNo,
  });
}

class PatientPhyFax {
  final String phyFax;
  final String phyFaxLink;
  final int phyFaxPgNo;

  PatientPhyFax({
    required this.phyFax,
    required this.phyFaxLink,
    required this.phyFaxPgNo,
  });
}

class PatientPhyNotes {
  final String phyNotes;
  final String phyNotesLink;
  final int phyNotesPgNo;

  PatientPhyNotes({
    required this.phyNotes,
    required this.phyNotesLink,
    required this.phyNotesPgNo,
  });
}

class PatientPhyProtocols {
  final String phyProtocols;
  final String phyProtocolsLink;
  final int phyProtocolsPgNo;

  PatientPhyProtocols({
    required this.phyProtocols,
    required this.phyProtocolsLink,
    required this.phyProtocolsPgNo,
  });
}

class PatientPhyState {
  final String phyState;
  final String phyStateLink;
  final int phyStatePgNo;

  PatientPhyState({
    required this.phyState,
    required this.phyStateLink,
    required this.phyStatePgNo,
  });
}

class PatientPhyStreet {
  final String phyStreet;
  final String phyStreetLink;
  final int phyStreetPgNo;

  PatientPhyStreet({
    required this.phyStreet,
    required this.phyStreetLink,
    required this.phyStreetPgNo,
  });
}

class PatientPhySuffix {
  final String phySuffix;
  final String phySuffixLink;
  final int phySuffixPgNo;

  PatientPhySuffix({
    required this.phySuffix,
    required this.phySuffixLink,
    required this.phySuffixPgNo,
  });
}

class PatientPhySuite {
  final String phySuite;
  final String phySuiteLink;
  final int phySuitePgNo;

  PatientPhySuite({
    required this.phySuite,
    required this.phySuiteLink,
    required this.phySuitePgNo,
  });
}

class PatientPhyTrackingNotes {
  final String phyTrackingNotes;
  final String phyTrackingNotesLink;
  final int phyTrackingNotesPgNo;

  PatientPhyTrackingNotes({
    required this.phyTrackingNotes,
    required this.phyTrackingNotesLink,
    required this.phyTrackingNotesPgNo,
  });
}

class PatientPhyVerificationDetails {
  final String phyVerificationDetails;
  final String phyVerificationDetailsLink;
  final int phyVerificationDetailsPgNo;

  PatientPhyVerificationDetails({
    required this.phyVerificationDetails,
    required this.phyVerificationDetailsLink,
    required this.phyVerificationDetailsPgNo,
  });
}

class PatientPhyZipCode {
  final String phyZipCode;
  final String phyZipCodeLink;
  final int phyZipCodePgNo;

  PatientPhyZipCode({
    required this.phyZipCode,
    required this.phyZipCodeLink,
    required this.phyZipCodePgNo,
  });
}

class PatientPhyUrl {
  final String phyUrl;
  final String phyUrlLink;
  final int phyUrlPgNo;

  PatientPhyUrl({
    required this.phyUrl,
    required this.phyUrlLink,
    required this.phyUrlPgNo,
  });
}