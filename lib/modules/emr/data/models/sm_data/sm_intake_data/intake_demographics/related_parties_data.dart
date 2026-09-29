class EmergencyContactData{
  final int contactId;
  final int fkPtId;
  final FirstName firstName;
  final LastName lastName;
  final Relationship relationship;
  final Street street;
  final Suite suite;
  final City city;
  final StateField state;
  final Zipcode zipcode;
  final ContactField phoneNumber;
  final EmailField email;
  final bool no_emergency_contact;

  EmergencyContactData({
    required this.no_emergency_contact,
    required this.contactId, required this.fkPtId, required this.firstName,
    required this.lastName, required this.relationship, required this.street,
    required this.suite, required this.city, required this.state, required this.zipcode,
    required this.phoneNumber, required this.email});
}
class EcFirstName {
  final String value;
  final String link;
  final int pageNo;

  EcFirstName({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}

class EcLastName {
  final String value;
  final String link;
  final int pageNo;

  EcLastName({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}

class EcRelationship {
  final int relationshipId;
  final String relationshipName;
  final String relationshipDescription;

  EcRelationship({
    required this.relationshipId,
    required this.relationshipName,
    required this.relationshipDescription,
  });
}

class EcStreet {
  final String street;
  final String streetLink;
  final int streetPgNo;

  EcStreet({
    required this.street,
    required this.streetLink,
    required this.streetPgNo,
  });
}

class EcSuite {
  final String suite;
  final String suiteLink;
  final int suitePgNo;

  EcSuite({
    required this.suite,
    required this.suiteLink,
    required this.suitePgNo,
  });
}

class EcCity {
  final String city;
  final String cityLink;
  final int cityPgNo;

  EcCity({
    required this.city,
    required this.cityLink,
    required this.cityPgNo,
  });
}

class EcStateField {
  final String state;
  final String stateLink;
  final int statePgNo;

  EcStateField({
    required this.state,
    required this.stateLink,
    required this.statePgNo,
  });
}

class EcZipcode {
  final String zipcode;
  final String zipcodeLink;
  final int zipcodePgNo;

  EcZipcode({
    required this.zipcode,
    required this.zipcodeLink,
    required this.zipcodePgNo,
  });
}

class EcContactField {
  final String value;
  final String link;
  final int pageNo;

  EcContactField({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}
class EcEmailField {
  final String value;
  final String link;
  final int pageNo;

  EcEmailField({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}


















/// Patient Representative

class PatientRepresentativeData {
  final int representative_id;
  final int fkPtId;
  final FirstName firstName;
  final LastName lastName;
  final Relationship relationship;
  final Street street;
  final Suite suite;
  final City city;
  final StateField state;
  final Zipcode zipcode;
  final ContactField phoneNumber;
  final EmailField email;
  final Type type;
  final Role role;
  final bool no_patient_representative;

  PatientRepresentativeData({
    required this.no_patient_representative,
    required this.representative_id,
    required this.fkPtId,
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.street,
    required this.suite,
    required this.city,
    required this.state,
    required this.zipcode,
    required this.phoneNumber,
    required this.email,
    required this.type,
    required this.role,
  });
}

class FirstName {
  final String value;
  final String link;
  final int pageNo;

  FirstName({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}

class LastName {
  final String value;
  final String link;
  final int pageNo;

  LastName({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}

class Relationship {
  final int relationshipId;
  final String relationshipName;
  final String relationshipDescription;

  Relationship({
    required this.relationshipId,
    required this.relationshipName,
    required this.relationshipDescription,
  });
}

class Street {
  final String street;
  final String streetLink;
  final int streetPgNo;

  Street({
    required this.street,
    required this.streetLink,
    required this.streetPgNo,
  });
}

class Suite {
  final String suite;
  final String suiteLink;
  final int suitePgNo;

  Suite({
    required this.suite,
    required this.suiteLink,
    required this.suitePgNo,
  });
}

class City {
  final String city;
  final String cityLink;
  final int cityPgNo;

  City({
    required this.city,
    required this.cityLink,
    required this.cityPgNo,
  });
}
class Role {
  final int roleId;
  final String roleName;
  final String roleDes;

  Role({
    required this.roleId,
    required this.roleName,
    required this.roleDes,
  });
}
class Type {
  final int typeId;
  final String typeName;
  final String typeDes;

  Type({
    required this.typeId,
    required this.typeName,
    required this.typeDes,
  });
}

class StateField {
  final String state;
  final String stateLink;
  final int statePgNo;

  StateField({
    required this.state,
    required this.stateLink,
    required this.statePgNo,
  });
}

class Zipcode {
  final String zipcode;
  final String zipcodeLink;
  final int zipcodePgNo;

  Zipcode({
    required this.zipcode,
    required this.zipcodeLink,
    required this.zipcodePgNo,
  });
}

class ContactField {
  final String value;
  final String link;
  final int pageNo;

  ContactField({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}
class EmailField {
  final String value;
  final String link;
  final int pageNo;

  EmailField({
    required this.value,
    required this.link,
    required this.pageNo,
  });
}

// class PatientRepresentativeData{
//   final int representiveId;
//   final int fk_pt_id;
//   final String firstName;
//   final String lastName;
//   final int fk_Relationship;
//   final String street;
//   final String suite;
//   final String city;
//   final String state;
//   final String zipCode;
//   final String phoneNumber;
//   final String email;
//   final int RoleId;
//   final int typeId;
//   final String roleName;
//   final String typeName;
//
//   PatientRepresentativeData({
//     required this.roleName,required this.typeName,
//     required this.representiveId, required this.fk_pt_id, required this.firstName,
//     required this.lastName, required this.fk_Relationship, required this.street,
//     required this.suite, required this.city, required this.state, required this.zipCode,
//     required this.phoneNumber, required this.email,required this.RoleId,required this.typeId});
// }