class AIDemographichModelData {
  final int demoIdI;
  final int fkPtId;
  final String demoFirstNameI;
  final String demoMiddleInitialI;
  final String demoLastNameI;
  final String demoSuffixI;
  final String demoStreetI;
  final String demoSuiteI;
  final String demoCityI;
  final String demoStateI;
  final String demoZipcodeI;
  final String demoFacitlityNameI;
  final String demoLocationNotesI;
  final String demoPrimaryContactI;
  final String demoPrimaryContactNameI;
  final String demoPrimaryPhoneI;
  final String demoPrimaryEmailI;
  final String demoCahpsContactI;
  final String demoSecondaryContactI;
  final String demoSecondaryContactNameI;
  final String demoSecondaryPhoneI;
  final String demoSecondaryEmailI;
  final String demoSocialSecurityI;
  final String demoCreatedAtI;

  AIDemographichModelData({
    required this.demoIdI,
    required this.fkPtId,
    required this.demoFirstNameI,
    required this.demoMiddleInitialI,
    required this.demoLastNameI,
    required this.demoSuffixI,
    required this.demoStreetI,
    required this.demoSuiteI,
    required this.demoCityI,
    required this.demoStateI,
    required this.demoZipcodeI,
    required this.demoFacitlityNameI,
    required this.demoLocationNotesI,
    required this.demoPrimaryContactI,
    required this.demoPrimaryContactNameI,
    required this.demoPrimaryPhoneI,
    required this.demoPrimaryEmailI,
    required this.demoCahpsContactI,
    required this.demoSecondaryContactI,
    required this.demoSecondaryContactNameI,
    required this.demoSecondaryPhoneI,
    required this.demoSecondaryEmailI,
    required this.demoSocialSecurityI,
    required this.demoCreatedAtI,
  });
}

class AiEmergencyContactData{
  final int contactId_I;
  final int fk_pt_id;
  final String firstName_I;
  final String lastName_I;
  final String street_I;
  final String suite_I;
  final String city_I;
  final String state_I;
  final String zipCode_I;
  final String phoneNumber_I;
  final String email_I;

  AiEmergencyContactData({
    required this.contactId_I,
    required this.fk_pt_id,
    required this.firstName_I,
    required this.lastName_I,
    required this.street_I,
    required this.suite_I,
    required this.city_I,
    required this.state_I,
    required this.zipCode_I,
    required this.phoneNumber_I,
    required this.email_I});

}

class AiRepresentativeData{
  final int representiveId_I;
  final int fk_pt_id;
  final String firstName_I;
  final String lastName_I;
  final String street_I;
  final String suite_I;
  final String city_I;
  final String state_I;
  final String zipCode_I;
  final String phoneNumber_I;
  final String email_I;

  AiRepresentativeData({
    required this.representiveId_I,
    required this.fk_pt_id,
    required this.firstName_I,
    required this.lastName_I,
    required this.street_I,
    required this.suite_I,
    required this.city_I,
    required this.state_I,
    required this.zipCode_I,
    required this.phoneNumber_I,
    required this.email_I});
}
