class DemographicPatientDataModel {
  final int demoId;
  final int fkPtId;
  final FirstName firstName;
  final MiddleInitial middleInitial;
  final LastName lastName;
  final Suffix suffix;
  final Street street;
  final Suite suite;
  final City city;
  final StateClass state;
  final Zipcode zipcode;
  final FacilityName facilityName;
  final LocationNotes locationNotes;
  final PrimaryContact primaryContact;
  final PrimaryContactName primaryContactName;
  final PrimaryPhone primaryPhone;
  final PrimaryEmail primaryEmail;
  final CahpsContact cahpsContact;
  final SecondaryContact secondaryContact;
  final SecondaryContactName secondaryContactName;
  final SecondaryPhone secondaryPhone;
  final SecondaryEmail secondaryEmail;
  final SocialSecurity socialSecurity;
  final String demoDob;
  final int fkGender;
  final int fkSpokenLanguage;
  final int fkCountryId;
  final int fkResidenceTypeId;
  final int fkZoneId;
  final int fkRaceEthnicity;
  final int fkMaritalStatus;
  final String demoCreatedAt;
  final Country country;
  final ResidenceType residenceType;
  final Zone zone;
  final Gender gender;
  final SpokenLanguage spokenLanguage;
  final Race race;
  final MaritalStatus maritalStatus;

  DemographicPatientDataModel({
    required this.demoId,
    required this.fkPtId,
    required this.firstName,
    required this.middleInitial,
    required this.lastName,
    required this.suffix,
    required this.street,
    required this.suite,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.facilityName,
    required this.locationNotes,
    required this.primaryContact,
    required this.primaryContactName,
    required this.primaryPhone,
    required this.primaryEmail,
    required this.cahpsContact,
    required this.secondaryContact,
    required this.secondaryContactName,
    required this.secondaryPhone,
    required this.secondaryEmail,
    required this.socialSecurity,
    required this.demoDob,
    required this.fkGender,
    required this.fkSpokenLanguage,
    required this.fkCountryId,
    required this.fkResidenceTypeId,
    required this.fkZoneId,
    required this.fkRaceEthnicity,
    required this.fkMaritalStatus,
    required this.demoCreatedAt,
    required this.country,
    required this.residenceType,
    required this.zone,
    required this.gender,
    required this.spokenLanguage,
    required this.race,
    required this.maritalStatus,
  });
}

class FirstName {
  final String demoFirstName;
  final String firstNameLink;
  final int firstNamePgNo;

  FirstName({
    required this.demoFirstName,
    required this.firstNameLink,
    required this.firstNamePgNo,
  });
}

class MiddleInitial {
  final String demoMiddleInitial;
  final String middleInitialLink;
  final int middleInitialPgNo;

  MiddleInitial({
    required this.demoMiddleInitial,
    required this.middleInitialLink,
    required this.middleInitialPgNo,
  });
}

class LastName {
  final String demoLastName;
  final String lastNameLink;
  final int lastNamePgNo;

  LastName({
    required this.demoLastName,
    required this.lastNameLink,
    required this.lastNamePgNo,
  });
}

class Suffix {
  final String demoSuffix;
  final String suffixLink;
  final int suffixPgNo;

  Suffix({
    required this.demoSuffix,
    required this.suffixLink,
    required this.suffixPgNo,
  });
}

class Street {
  final String demoStreet;
  final String streetLink;
  final int streetPgNo;

  Street({
    required this.demoStreet,
    required this.streetLink,
    required this.streetPgNo,
  });
}

class Suite {
  final String demoSuite;
  final String suiteLink;
  final int suitePgNo;

  Suite({
    required this.demoSuite,
    required this.suiteLink,
    required this.suitePgNo,
  });
}

class City {
  final String demoCity;
  final String cityLink;
  final int cityPgNo;

  City({
    required this.demoCity,
    required this.cityLink,
    required this.cityPgNo,
  });
}

class StateClass {
  final String demoState;
  final String stateLink;
  final int statePgNo;

  StateClass({
    required this.demoState,
    required this.stateLink,
    required this.statePgNo,
  });
}

class Zipcode {
  final String demoZipcode;
  final String zipcodeLink;
  final int zipcodePgNo;

  Zipcode({
    required this.demoZipcode,
    required this.zipcodeLink,
    required this.zipcodePgNo,
  });
}

class FacilityName {
  final String demoFacilityName;
  final String facilityNameLink;
  final int facilityNamePgNo;

  FacilityName({
    required this.demoFacilityName,
    required this.facilityNameLink,
    required this.facilityNamePgNo,
  });
}

class LocationNotes {
  final String demoLocationNotes;
  final String locationNotesLink;
  final int locationNotesPgNo;

  LocationNotes({
    required this.demoLocationNotes,
    required this.locationNotesLink,
    required this.locationNotesPgNo,
  });
}

class PrimaryContact {
  final String demoPrimaryContact;
  final String primaryContactLink;
  final int primaryContactPgNo;

  PrimaryContact({
    required this.demoPrimaryContact,
    required this.primaryContactLink,
    required this.primaryContactPgNo,
  });
}

class PrimaryContactName {
  final String demoPrimaryContactName;
  final String primaryContactNameLink;
  final int primaryContactNamePgNo;

  PrimaryContactName({
    required this.demoPrimaryContactName,
    required this.primaryContactNameLink,
    required this.primaryContactNamePgNo,
  });
}

class PrimaryPhone {
  final String demoPrimaryPhone;
  final String primaryPhoneLink;
  final int primaryPhonePgNo;

  PrimaryPhone({
    required this.demoPrimaryPhone,
    required this.primaryPhoneLink,
    required this.primaryPhonePgNo,
  });
}

class PrimaryEmail {
  final String demoPrimaryEmail;
  final String primaryEmailLink;
  final int primaryEmailPgNo;

  PrimaryEmail({
    required this.demoPrimaryEmail,
    required this.primaryEmailLink,
    required this.primaryEmailPgNo,
  });
}

class CahpsContact {
  final String demoCahpsContact;
  final String cahpsContactLink;
  final int cahpsContactPgNo;

  CahpsContact({
    required this.demoCahpsContact,
    required this.cahpsContactLink,
    required this.cahpsContactPgNo,
  });
}

class SecondaryContact {
  final String demoSecondaryContact;
  final String secondaryContactLink;
  final int secondaryContactPgNo;

  SecondaryContact({
    required this.demoSecondaryContact,
    required this.secondaryContactLink,
    required this.secondaryContactPgNo,
  });
}

class SecondaryContactName {
  final String demoSecondaryContactName;
  final String secondaryContactNameLink;
  final int secondaryContactNamePgNo;

  SecondaryContactName({
    required this.demoSecondaryContactName,
    required this.secondaryContactNameLink,
    required this.secondaryContactNamePgNo,
  });
}

class SecondaryPhone {
  final String demoSecondaryPhone;
  final String secondaryPhoneLink;
  final int secondaryPhonePgNo;

  SecondaryPhone({
    required this.demoSecondaryPhone,
    required this.secondaryPhoneLink,
    required this.secondaryPhonePgNo,
  });
}

class SecondaryEmail {
  final String demoSecondaryEmail;
  final String secondaryEmailLink;
  final int secondaryEmailPgNo;

  SecondaryEmail({
    required this.demoSecondaryEmail,
    required this.secondaryEmailLink,
    required this.secondaryEmailPgNo,
  });
}

class SocialSecurity {
  final String demoSocialSecurity;
  final String socialSecurityLink;
  final int socialSecurityPgNo;

  SocialSecurity({
    required this.demoSocialSecurity,
    required this.socialSecurityLink,
    required this.socialSecurityPgNo,
  });
}
class Country {
  final int countryId;
  final String name;
  final String short;

  Country({
    required this.countryId,
    required this.name,
    required this.short,
  });
}

class ResidenceType {
  final int id;
  final String detail;
  final String description;

  ResidenceType({
    required this.id,
    required this.detail,
    required this.description,
  });
}

class Zone {
  final int zoneId;
  final String zoneName;
  final int companyId;
  final String officeId;
  final int countyId;

  Zone({
    required this.zoneId,
    required this.zoneName,
    required this.companyId,
    required this.officeId,
    required this.countyId,
  });
}

class Gender {
  final int genderId;
  final String gender;

  Gender({
    required this.genderId,
    required this.gender,
  });
}

class SpokenLanguage {
  final int languageSpokenId;
  final String languageSpoken;

  SpokenLanguage({
    required this.languageSpokenId,
    required this.languageSpoken,
  });
}

class Race {
  final int raceId;
  final String race;

  Race({
    required this.raceId,
    required this.race,
  });
}

class MaritalStatus {
  final int maritalStatusId;
  final String maritalStatus;

  MaritalStatus({
    required this.maritalStatusId,
    required this.maritalStatus,
  });
}