class AssignedPatientPhysicianData {
  final String? name;
  final String? contact;

  AssignedPatientPhysicianData({
    this.name,
    this.contact,
  });
}

class AssignedPatientEpisodeData {
  final int? chartId;
  final int? episodeId;
  final String? episodeFrom;
  final String? episodeTo;

  AssignedPatientEpisodeData({
    this.chartId,
    this.episodeId,
    this.episodeFrom,
    this.episodeTo,
  });
}

class AssignedPatientAuthStatusData {
  final bool? isAuthorized;
  final String? lastChecked;
  final String? authRemaining;

  AssignedPatientAuthStatusData({
    this.isAuthorized,
    this.lastChecked,
    this.authRemaining,
  });
}

class AssignedPatientData {
  final int? patientId;
  final String? patientName;
  final String? dob;
  final String? imgUrl;
  final int? mrn;
  final String? patientStatus;
  final String? primaryDiagnosis;
  final String? insurance;
  final String? kaiserNo;
  // final bool? treatmentPause;
  final AssignedPatientEpisodeData? currentEpisode;
  final AssignedPatientPhysicianData? physician;
  final AssignedPatientAuthStatusData? authStatus;

  AssignedPatientData({
    this.patientId,
    this.patientName,
    this.dob,
    this.imgUrl,
    this.mrn,
    this.patientStatus,
    this.primaryDiagnosis,
    this.insurance,
    this.kaiserNo,
    this.currentEpisode,
    this.physician,
    this.authStatus,
    // this.treatmentPause
  });
}