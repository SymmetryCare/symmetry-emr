class ChatDepartmentGroupCommunicationData {
  final EmployeeClinicalInfoData empInfoData;
  final List<ParticipantData> participants;
  final List<Message> messages;
  final Pagination pagination;

  ChatDepartmentGroupCommunicationData({
    required this.empInfoData,
    required this.participants,
    required this.messages,
    required this.pagination,
  });
}

class EmployeeClinicalInfoData {
  final int employeeId;
  final int userId;
  final String fullName;
  final String imageUrl;
  final bool isOnline;
  EmployeeClinicalInfoData(
      {required this.employeeId,
      required this.userId,
      required this.fullName,
      required this.imageUrl,
      required this.isOnline});
}

class ParticipantData {
  final int employeeId;
  final int userId;
  final String fullName;
  final String imgUrl;
  final String email;
  final String position;
  final int departmentId;
  final String departmentName;
  final String role;
  final bool isOnline;
  final bool willReceiveSms;
  ParticipantData({
    required this.departmentId,
    required this.departmentName,
    required this.role,
    required this.employeeId,
    required this.userId,
    required this.position,
    required this.fullName,
    required this.imgUrl,
    required this.email,
    required this.isOnline,
    required this.willReceiveSms,
  });
}

class Message {
  final int empChatId;
  final int senderEmpId;
  final int receiverEmpId;
  final String textContent;
  final String dateCreated;
  final String? dateModified;
  final bool unsend;
  final bool sendAsSms;
  final List<int> seenByEmployees;
  final List<String> attachedMultimediaUrl;
  final List<String> voiceNoteUrl;
  final String stickerMultimediaUrl;
  final bool isMine;
  final Sender sender;

  Message({required this.voiceNoteUrl,
    required this.sendAsSms,
    required this.seenByEmployees,
    required this.isMine,
    required this.empChatId,
    required this.senderEmpId,
    required this.receiverEmpId,
    required this.textContent,
    required this.dateCreated,
    required this.dateModified,
    required this.unsend,
    required this.attachedMultimediaUrl,
    required this.stickerMultimediaUrl,
    required this.sender,
  });
}

class Sender {
  final int senderId;
  final String senderType;
  final String firstName;
  final String lastName;
  final String imgUrl;

  Sender({
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
