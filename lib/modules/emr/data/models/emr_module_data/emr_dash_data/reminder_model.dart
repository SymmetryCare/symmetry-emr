class RemiderListData{
  final int reminderId;
  final String title;
  final String clinicianName;
  final String date;
  final String startTime;
  final String endTime;
  final String priority;
  final bool isCompleted;
  final String createdAt;

  RemiderListData({
    required this.reminderId,
    required this.title,
    required this.clinicianName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });
}

class ReminderPreFillData{
  final int reminderId;
  final int employeeId;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String priority;
  final bool isCompleted;
  final String createdAt;
  final String modifiedAt;

  ReminderPreFillData({
    required this.reminderId,
    required this.employeeId,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.modifiedAt
  });
}
class ReminderDataPrefill{
  final ReminderPreFillData data;

  ReminderDataPrefill({
    required this.data,
  });
}

class ReminderData{
  final List<RemiderListData> data;

  ReminderData({
    required this.data,
  });
}


/// Supply order category

class SupplyOrderCategoryData{
  final int categoryId;
  final String categoryName;

  SupplyOrderCategoryData({
    required this.categoryId,
    required this.categoryName,
  });
}

class InventorySupplyData {
  final int inventoryId;
  final String name;
  final int qty;
  final String description;
  final int companyId;
  final String sku;
  final double price;
  final String expiryDate;
  final int fkCategoryId;

  const InventorySupplyData({
    required this.inventoryId,
    required this.name,
    required this.qty,
    required this.description,
    required this.companyId,
    required this.sku,
    required this.price,
    required this.expiryDate,
    required this.fkCategoryId,
  });
}

class PatientNameDetails {
  final int patientId;
  final String name;

  PatientNameDetails({
    required this.patientId,
    required this.name,
  });
}

class SupplyOrderPatientDetails {
  final int patientId;
  final String name;
  final int age;
  final String address;
  final String lastSupplyOrderDate;


  SupplyOrderPatientDetails({
    required this.address,
    required this.patientId,
    required this.name,
    required this.age,
    required this.lastSupplyOrderDate,
  });
}


class SupplyOrderClinicalDetails {
  final int clinicianId;
  final String name;
  final String gender;
  final String address;
  final String photo;
  final String employeeType;
  final String abbreviation;
  final String colorCode;
  final String lastSupplyOrderDate;


  SupplyOrderClinicalDetails({
    required this.clinicianId,
    required this.name,
    required this.gender,
    required this.address,
    required this.photo,
    required this.employeeType,
    required this.abbreviation,
    required this.colorCode,
    required this.lastSupplyOrderDate,
});
}