class CallHistoryResponseLog {
 final List<CallHistory> data;
 final int pageNbr;
 final int pageSize;
 final int totalRecords;
 final int totalPages;
 final bool hasNextPage;
 final bool hasPreviousPage;

 CallHistoryResponseLog({
    required this.data,
    required this.pageNbr,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
class CallHistory {
  final int callId;
  final String callType;
  final String callDirection;
  final String status;
  final String participantStatus;
  final String startTime;
  final String? endTime;
  final int duration;
  final String contactName;
  final String contactEmail;
  final String contactImage;
  final List<int> contactUserId;
  final int participantCount;
  final String timeAgo;
  final String phoneNo;
  final bool isVideo;


  CallHistory({
    required this.phoneNo,
    required this.isVideo,
    required this.callId,
    required this.callType,
    required this.callDirection,
    required this.status,
    required this.participantStatus,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.contactName,
    required this.contactEmail,
    required this.contactImage,
    required this.contactUserId,
    required this.participantCount,
    required this.timeAgo,
  });
}
