class PhysicianInfoPrefillData {
  final int phyId;
  final PhyFirstName firstName;
  final PhyLastName lastName;
  final PhyPicoNo picoNo;
  final bool phyPicoStatus;
  final PhyEmail email;
  final PhyContact contact;
  final PhyNPI phyNPI;
  final PhyUPI upi;
  final PhyCity city;
  final PhyFax fax;
  final PhyNotes notes;
  final PhyProtocols protocols;
  final PhyState state;
  final PhyStreet street;
  final PhySuffix suffix;
  final PhySuite suite;
  final PhyTrackingNotes trackingNotes;
  final PhyVerificationDetails verificationDetails;
  final bool phyVerified;
  final PhyZipCode zipcode;

  PhysicianInfoPrefillData({
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

class PhyFirstName {
  final String phyFirstName;
  final String phyFirstNameLink;
  final int phyFirstNamePgNo;

  PhyFirstName({
    required this.phyFirstName,
    required this.phyFirstNameLink,
    required this.phyFirstNamePgNo,
  });
}

class PhyLastName {
  final String phyLastName;
  final String phyLastNameLink;
  final int phyLastNamePgNo;

  PhyLastName({
    required this.phyLastName,
    required this.phyLastNameLink,
    required this.phyLastNamePgNo,
  });
}

class PhyPicoNo {
  final String phyPicoNo;
  final String phyPicoNoLink;
  final int phyPicoNoPgNo;

  PhyPicoNo({
    required this.phyPicoNo,
    required this.phyPicoNoLink,
    required this.phyPicoNoPgNo,
  });
}

class PhyEmail {
  final String phyEmail;
  final String phyEmailLink;
  final int phyEmailPgNo;

  PhyEmail({
    required this.phyEmail,
    required this.phyEmailLink,
    required this.phyEmailPgNo,
  });
}

class PhyContact {
  final String phyContact;
  final String phyContactLink;
  final int phyContactPgNo;

  PhyContact({
    required this.phyContact,
    required this.phyContactLink,
    required this.phyContactPgNo,
  });
}

class PhyNPI {
  final int phyNPI;
  final String phyNPILink;
  final int phyFirstNamePgNo;

  PhyNPI({
    required this.phyNPI,
    required this.phyNPILink,
    required this.phyFirstNamePgNo,
  });
}

class PhyUPI {
  final String phyUPI;
  final String phyUPILink;
  final int phyUPIPgNo;

  PhyUPI({
    required this.phyUPI,
    required this.phyUPILink,
    required this.phyUPIPgNo,
  });
}

class PhyCity {
  final String phyCity;
  final String phyCityLink;
  final int phyCityPgNo;

  PhyCity({
    required this.phyCity,
    required this.phyCityLink,
    required this.phyCityPgNo,
  });
}

class PhyFax {
  final String phyFax;
  final String phyFaxLink;
  final int phyFaxPgNo;

  PhyFax({
    required this.phyFax,
    required this.phyFaxLink,
    required this.phyFaxPgNo,
  });
}

class PhyNotes {
  final String phyNotes;
  final String phyNotesLink;
  final int phyNotesPgNo;

  PhyNotes({
    required this.phyNotes,
    required this.phyNotesLink,
    required this.phyNotesPgNo,
  });
}

class PhyProtocols {
  final String phyProtocols;
  final String phyProtocolsLink;
  final int phyProtocolsPgNo;

  PhyProtocols({
    required this.phyProtocols,
    required this.phyProtocolsLink,
    required this.phyProtocolsPgNo,
  });
}

class PhyState {
  final String phyState;
  final String phyStateLink;
  final int phyStatePgNo;

  PhyState({
    required this.phyState,
    required this.phyStateLink,
    required this.phyStatePgNo,
  });
}

class PhyStreet {
  final String phyStreet;
  final String phyStreetLink;
  final int phyStreetPgNo;

  PhyStreet({
    required this.phyStreet,
    required this.phyStreetLink,
    required this.phyStreetPgNo,
  });
}

class PhySuffix {
  final String phySuffix;
  final String phySuffixLink;
  final int phySuffixPgNo;

  PhySuffix({
    required this.phySuffix,
    required this.phySuffixLink,
    required this.phySuffixPgNo,
  });
}

class PhySuite {
  final String phySuite;
  final String phySuiteLink;
  final int phySuitePgNo;

  PhySuite({
    required this.phySuite,
    required this.phySuiteLink,
    required this.phySuitePgNo,
  });
}

class PhyTrackingNotes {
  final String phyTrackingNotes;
  final String phyTrackingNotesLink;
  final int phyTrackingNotesPgNo;

  PhyTrackingNotes({
    required this.phyTrackingNotes,
    required this.phyTrackingNotesLink,
    required this.phyTrackingNotesPgNo,
  });
}

class PhyVerificationDetails {
  final String phyVerificationDetails;
  final String phyVerificationDetailsLink;
  final int phyVerificationDetailsPgNo;

  PhyVerificationDetails({
    required this.phyVerificationDetails,
    required this.phyVerificationDetailsLink,
    required this.phyVerificationDetailsPgNo,
  });
}

class PhyZipCode {
  final String phyZipCode;
  final String phyZipCodeLink;
  final int phyZipCodePgNo;

  PhyZipCode({
    required this.phyZipCode,
    required this.phyZipCodeLink,
    required this.phyZipCodePgNo,
  });
}