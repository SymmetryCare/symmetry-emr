class BrodcastModelData {
  String? message;
  int? prevPage;
  int? nextPage;
  int? currentPage;
  int? totalPages;
  int? totalItems;
  int? pageSize;
  final List<AlertItem>? data;

  BrodcastModelData({
    this.message,
    this.prevPage,
    this.nextPage,
    this.currentPage,
    this.totalPages,
    this.totalItems,
    this.pageSize,
    required this.data,
  });
}

class AlertItem {
  final int alertId;
  final String alertHeading;
  final String alertBody;
  final bool alertResolve;
  final String createdAt;
  final String day;
  final Sender sender;
  final Clinician clinician;
  final String time;

  AlertItem({
    required this.alertId,
    required this.alertHeading,
    required this.alertBody,
    required this.alertResolve,
    required this.createdAt,
    required this.day,
    required this.sender,
    required this.clinician,
    required this.time,
  });
}

class Sender {
  final int userId;
  final String name;
  final String role;

  Sender({
    required this.userId,
    required this.name,
    required this.role,
  });
}

class Clinician {
  final int employeeId;
  final String fullName;
  final String imgurl;
  final String abbreviation;
  final String color;

  Clinician({
    required this.employeeId,
    required this.fullName,
    required this.imgurl,
    required this.abbreviation,
    required this.color,
  });
}


/// broadcast get chips
class BroadCastChipsData{
  final String message;
  final List<ChipsData> data;
  BroadCastChipsData({
    required this.message,
    required this.data});
}

class ChipsData{
  final int employeeId;
  final String employeeName;
  final String code;
  final String imgUrl;
  ChipsData({
    required this.employeeId,
    required this.employeeName,
    required this.code,
    required this.imgUrl});
}