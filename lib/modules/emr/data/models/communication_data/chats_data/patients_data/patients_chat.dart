class ChatPatientsGroupCommunicationData {
  final GroupInfo groupInfo;
  final List<ParticipantData> participants;
  final List<Message> messages;
  final Pagination pagination;

  ChatPatientsGroupCommunicationData({
    required this.groupInfo,
    required this.participants,
    required this.messages,
    required this.pagination,
  });
}

class GroupInfo {
  final int ptGroupId;
  final String groupName;
  final String groupDescription;
  final String groupProfileUrl;
  final bool isActive;
  final String createdAt;

  GroupInfo({
    required this.ptGroupId,
    required this.groupName,
    required this.groupDescription,
    required this.groupProfileUrl,
    required this.isActive,
    required this.createdAt,
  });
}

class ParticipantData {
  final int participantId;
  final String participantType;
  final String firstName;
  final String lastName;
  final String fullName;
  final String imgUrl;
  final String email;
  final bool isOnline;
  final String? lastOnline;
  final bool willReceiveSms;
  final int userId;

  ParticipantData({required this.userId,
    required this.participantId,
    required this.participantType,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.imgUrl,
    required this.email,
    required this.isOnline,
    required this.lastOnline,
    required this.willReceiveSms,
  });
}

class Message {
  final int ptChatId;
  final String textContent;
  final String dateCreated;
  final String? dateModified;
  final bool unsend;
  final bool seenByPatient;
  final List<int> seenByClinicians;
  final List<String> attachedMultimediaUrls; // ✅ List of URLs now
  final String stickerMultimediaUrl;
  final List<String>? voiceNoteUrl;
  final bool sentAsSms;
  final Sender sender;
  final int ptUserId;
  final int ptEmpUserId;

  Message({
    required this.ptUserId,
    required this.ptEmpUserId,
    required this.ptChatId,
    required this.textContent,
    required this.dateCreated,
    this.dateModified,
    required this.unsend,
    required this.seenByPatient,
    required this.seenByClinicians,
    required this.attachedMultimediaUrls,
    required this.stickerMultimediaUrl,
    this.voiceNoteUrl,
    required this.sentAsSms,
    required this.sender,
  });
}


// class Message {
//   final int ptChatId;
//   final String textContent;
//   final String dateCreated;
//   final String? dateModified;
//   final bool unsend;
//   final bool seenByPatient;
//   final List<int> seenByClinicians;
//   final String attachedMultimediaUrl;
//   final String stickerMultimediaUrl;
//   final String? voiceNoteUrl;
//   final bool sentAsSms;
//   final Sender sender;
//   final int pt_userId;
//   final int pt_emp_userId;
//
//   Message({
//     required this.pt_userId,
//     required this.pt_emp_userId,
//     required this.ptChatId,
//     required this.textContent,
//     required this.dateCreated,
//     required this.dateModified,
//     required this.unsend,
//     required this.seenByPatient,
//     required this.seenByClinicians,
//     required this.attachedMultimediaUrl,
//     required this.stickerMultimediaUrl,
//     required this.voiceNoteUrl,
//     required this.sentAsSms,
//     required this.sender,
//   });
// }

class Sender {
  final int senderId;
  final String senderType;
  final String firstName;
  final String lastName;
  final String imgUrl;
  final int userId;

  Sender({
    required this.userId,
    required this.senderId,
    required this.senderType,
    required this.firstName,
    required this.lastName,
    required this.imgUrl,
  });
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
