class CreateDataScheduler {
  final int? schedulerCreateId;
  final int? patientId;
  final int? clinicianId;
  final String? visitType;
  final String? assignDate;
  final String? startTime;
  final String? endTime;
  final String? details;

  CreateDataScheduler(
      {required this.schedulerCreateId,
      required this.patientId,
      required this.clinicianId,
      required this.visitType,
      required this.assignDate,
      required this.startTime,
      required this.endTime,
      required this.details});
}

/// Calender prefill data
class CreatePrefillDataScheduler {
  final int? schedulerCreateId;
  final int? patientId;
  final int? clinicianId;
  final String? visitType;
  final String? assignDate;
  final String? startTime;
  final String? endTime;
  final String? details;

  CreatePrefillDataScheduler(
      {required this.schedulerCreateId,
        required this.patientId,
        required this.clinicianId,
        required this.visitType,
        required this.assignDate,
        required this.startTime,
        required this.endTime,
        required this.details});
}
class StateData {
  final int stateId;
  final String name;
  final String short;
  final int countryId;
  final String country;

  StateData(
      {required this.stateId,
      required this.name,
      required this.short,
      required this.countryId,
      required this.country});
}
//////////
class CityData {
  final int city_id;
  final String cityName;
  final String state;
  final String Country;

  CityData(
      {required this.city_id,
      required this.cityName,
      required this.state,
      required this.Country});
}
/////

class RelationshipData{

  final int relationshipId;
  final String relationship;

  RelationshipData({required this.relationshipId, required this.relationship});

}


//////
class LanguageSpokenData{
  final int languageSpokenId;
  final String languageSpoken;

  LanguageSpokenData({required this.languageSpokenId, required this.languageSpoken});

}


/////
class MetrialStatusData{
  final int maritalStatusId;
  final String maritalStatus;

  MetrialStatusData({required this.maritalStatusId, required this.maritalStatus});
}

////


class RaceData{

  final int raceId;
  final String race;

  RaceData({required this.raceId, required this.race});
}

///////


class ReligionData{

  final int religionId;
  final String religion;

  ReligionData({required this.religionId, required this.religion});
}


/////

class PatientStatusData{

  final int patientStatusId;
  final String patientStatus;

  PatientStatusData({required this.patientStatusId, required this.patientStatus});
}


////

class PriorityDisasterData{

  final int Id;
  final String idText;

  PriorityDisasterData({required this.Id, required this.idText});
}

/////

class EligiblityStatusData{

  final int Id;
  final String idText;

  EligiblityStatusData({required this.Id, required this.idText});
}


////


class CategoryData{

  final int Id;
  final String idText;

  CategoryData({required this.Id, required this.idText});
}

/////

class SuppliesData{

  final int Id;
  final String idText;

  SuppliesData({required this.Id, required this.idText});
}


////

class PharmacyData{

  final int Id;
  final String idText;

  PharmacyData({required this.Id, required this.idText});
}

/////


class FacilityData{

  final int Id;
  final String idText;

  FacilityData({required this.Id, required this.idText});
}



/////

class CountryData{

  final int countryId;
  final String name;
  final String short;

  CountryData( {required this.countryId, required this.name , required this.short,});
}