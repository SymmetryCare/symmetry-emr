// ── GET: Care Team Chat ───────────────────────────────────────────────────────
class PatientCareTeamChatData {
  final int ptGroupId;
  final String groupName;
  final String groupDescription;
  final String groupProfileUrl;
  final bool isActive;
  final bool isClinicianOnly;
  final String createdAt;
  final List<CareTeamMemberData> members;

  PatientCareTeamChatData({
    required this.ptGroupId,
    required this.groupName,
    required this.groupDescription,
    required this.groupProfileUrl,
    required this.isActive,
    required this.isClinicianOnly,
    required this.createdAt,
    required this.members,
  });
}

class CareTeamMemberData {
  final int employeeId;
  final int userId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String imgurl;
  final String email;
  final String position;
  final int employeeTypeId;
  final String employeeTypeName;
  final String employeeTypeAbbreviation;
  final String employeeTypeColor;

  CareTeamMemberData({
    required this.employeeId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.imgurl,
    required this.email,
    required this.position,
    required this.employeeTypeId,
    required this.employeeTypeName,
    required this.employeeTypeAbbreviation,
    required this.employeeTypeColor,
  });
}

// ── GET: Chat Screen ──────────────────────────────────────────────────────────
class PatientGroupChatScreenData {
  final GroupInfoData groupInfo;
  final List<ChatParticipantData> participants;
  final List<ChatMessageData> messages;
  final ChatPaginationData pagination;

  PatientGroupChatScreenData({
    required this.groupInfo,
    required this.participants,
    required this.messages,
    required this.pagination,
  });
}

class GroupInfoData {
  final int ptGroupId;
  final String groupName;
  final String groupDescription;
  final String groupProfileUrl;
  final bool isActive;
  final String createdAt;

  GroupInfoData({
    required this.ptGroupId,
    required this.groupName,
    required this.groupDescription,
    required this.groupProfileUrl,
    required this.isActive,
    required this.createdAt,
  });
}

class ChatParticipantData {
  final int participantId;
  final String participantType;
  final String firstName;
  final String lastName;
  final String fullName;
  final String imgurl;
  final String email;
  final int userId;
  final bool isOnline;
  final String? lastOnline;
  final bool willReceiveSms;
  final String? employeeTypeAbbreviation;
  final String? employeeTypeColor;
  final int? employeeTypeId;
  final String? employeeTypeName;

  ChatParticipantData({
    required this.participantId,
    required this.participantType,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.imgurl,
    required this.email,
    required this.userId,
    required this.isOnline,
    this.lastOnline,
    required this.willReceiveSms,
    this.employeeTypeAbbreviation,
    this.employeeTypeColor,
    this.employeeTypeId,
    this.employeeTypeName,
  });
}

// real API fields — snake_case keys, nullable where backend sends null
class ChatMessageData {
  final int ptChatId;
  final int? ptUserId;             // null when sent by clinician
  final int? ptUserEmpId;          // null when sent by patient
  final String textContent;
  final String dateCreated;
  final String? dateModified;
  final bool unsend;
  final bool seenByPatient;
  final List<String> attachedMultimediaUrl;
  final String? voiceNoteUrl;
  final int? voiceNoteUrlDuration;
  final bool sentAsSms;
  final ChatMessageSenderData sender;

  ChatMessageData({
    required this.ptChatId,
    this.ptUserId,
    this.ptUserEmpId,
    required this.textContent,
    required this.dateCreated,
    this.dateModified,
    required this.unsend,
    required this.seenByPatient,
    required this.attachedMultimediaUrl,
    this.voiceNoteUrl,
    this.voiceNoteUrlDuration,
    required this.sentAsSms,
    required this.sender,
  });
}

class ChatMessageSenderData {
  final int senderId;
  final String senderType;
  final String firstName;
  final String lastName;
  final String imgurl;
  final int userId;

  ChatMessageSenderData({
    required this.senderId,
    required this.senderType,
    required this.firstName,
    required this.lastName,
    required this.imgurl,
    required this.userId,
  });
}

class ChatPaginationData {
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  ChatPaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

// ── POST: Send Message ────────────────────────────────────────────────────────
class CliniciansChatData {
  final int ptGroupId;
  final int? referredChatId;
  final String textContent;
  final String? attachedMultimediaUrl;
  final String? stickerMultimediaUrl;
  final bool restrictPatientFromView;
  final bool sentAsSms;
  final String? voiceNoteUrl;

  CliniciansChatData({
    required this.ptGroupId,
    this.referredChatId,
    required this.textContent,
    this.attachedMultimediaUrl,
    this.stickerMultimediaUrl,
    required this.restrictPatientFromView,
    required this.sentAsSms,
    this.voiceNoteUrl,
  });
}

// ── POST: Attachment ──────────────────────────────────────────────────────────
class ChatAttachmentData {
  final String base64;
  final String fileName;

  ChatAttachmentData({
    required this.base64,
    required this.fileName,
  });
}

// ── POST: Voice Note ──────────────────────────────────────────────────────────
class ChatVoiceNoteData {
  final String base64;
  final String fileName;
  final int duration;

  ChatVoiceNoteData({
    required this.base64,
    required this.fileName,
    required this.duration,
  });
}