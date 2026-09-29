class TimeOffTypeData {
  final int? id;
  final String? name;

  TimeOffTypeData({
    this.id,
    this.name,
  });
}




///leaves api data file
class LeaveTypeData {
  final int? id;
  final String? name;

  LeaveTypeData({
    this.id,
    this.name,
  });
}







///
class TimeOffHistoryData {
  final int? timeOffRequestId;
  final int? employeeId;
  final String? employeeName;
  final int? timeOffTypeId;
  final String? timeOffTypeName;
  final String? startDate;
  final String? endDate;
  final String? reason;
  final String? status;
  final String? createdAt;

  TimeOffHistoryData({
    this.timeOffRequestId,
    this.employeeId,
    this.employeeName,
    this.timeOffTypeId,
    this.timeOffTypeName,
    this.startDate,
    this.endDate,
    this.reason,
    this.status,
    this.createdAt,
  });
}