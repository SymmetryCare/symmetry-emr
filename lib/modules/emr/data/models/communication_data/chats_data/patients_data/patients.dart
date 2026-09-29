class PatientGroup {
  final int ptGroupId;
  final String groupName;
  final String groupDescription;
  final String groupProfileUrl;
  final bool isActive;
  final List<GroupMember> groupMembers;
  final int unseenMessageCount;
  final String lastMessageTimestamp;
  final String lastMessageText;

  PatientGroup({
    required this.lastMessageText,
    required this.ptGroupId,
    required this.groupName,
    required this.groupDescription,
    required this.groupProfileUrl,
    required this.isActive,
    required this.groupMembers,
    required this.unseenMessageCount,
    required this.lastMessageTimestamp,
  });
}

class GroupMember {
  final int memberId;
  final String firstName;
  final String lastName;
  final String imgUrl;

  GroupMember({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.imgUrl,
  });
}

