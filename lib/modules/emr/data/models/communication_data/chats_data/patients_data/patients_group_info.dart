class PatientsGroupInfoData {
  final int ptGroupId;
  final String groupName;
  final String groupDescription;
  final String groupProfileUrl;
  final bool isActive;
  final String createdAt;
  final int totalMessages;
  final int unseenMessageCount;
  final List<Participant> allParticipants;
  final List<MediaLinksData> mediaLinksAndDocs;
  final PatientInfo patientInfo;

  PatientsGroupInfoData({
    required this.ptGroupId,
    required this.groupName,
    required this.groupDescription,
    required this.groupProfileUrl,
    required this.isActive,
    required this.createdAt,
    required this.totalMessages,
    required this.unseenMessageCount,
    required this.allParticipants,
    required this.mediaLinksAndDocs,
    required this.patientInfo,
  });
}

class Participant {
  final int participantId;
  final String participantType;
  final String firstName;
  final String lastName;
  final String fullName;
  final String imgUrl;
  final String email;
  final String? address;
  final String? treatment;
  final String? lastOnline;

  Participant({
    required this.participantId,
    required this.participantType,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.imgUrl,
    required this.email,
    this.address,
    this.treatment,
    this.lastOnline,
  });
}

class PatientInfo {
  final int ptUserId;
  final String ptUserName;
  final String ptUserEmail;
  final String ptUserProfileUrl;
  final String ptUserAddress;
  final String ptUserTreatment;
  final String ptUserLastOnline;

  PatientInfo({
    required this.ptUserId,
    required this.ptUserName,
    required this.ptUserEmail,
    required this.ptUserProfileUrl,
    required this.ptUserAddress,
    required this.ptUserTreatment,
    required this.ptUserLastOnline,
  });
}

class MediaLinksData{
final String mediaID;
final String mediaType;
final String mediaUrl;
final String description;
final String datecreated;

MediaLinksData({required this.mediaID, required this.mediaType, required this.mediaUrl,
  required this.description, required this.datecreated});

}
