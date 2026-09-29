import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/hr_module_repository/manage_emp/manage_emp_repo.dart';
import 'package:symmetry_emr/modules/emr/data/models/hr_module_data/manage/licenses_data.dart';

/// Get Licenses status wise
Future<Map<String, List<LicensesData>>> getLicenseStatusWise(
    BuildContext context,
    int employeeId) async {
  String convertIsoToDayMonthYear(String isoDate) {
    // Parse ISO date string to DateTime object
    DateTime dateTime = DateTime.parse(isoDate);

    // Create a DateFormat object to format the date
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Format the date into "dd mm yy" format
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  List<LicensesData> aboutToExpiryData = [];
  List<LicensesData> expiredLicenses = [];
  List<LicensesData> upToDateLicenses = [];
  try {
    final response =
    await Api(context).get(path: ManageReposotory.getLicenseStatus(employeeId: employeeId, approvedOnly: 'no',));
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        String formatedDate = convertIsoToDayMonthYear(item['issueDate']);
        String formatedExpDate = convertIsoToDayMonthYear(item['expDate']);
        LicensesData licenseData = LicensesData(
          country: item['country'],
          documentType: item['documentType'],
          employeeID: item['employeeId'],
          expDate: formatedExpDate,
          issueDate: formatedDate,
          licenseNumber: item['licenseNumber'],
          licenseUrl: item['licenseUrl'],
          licenseure: item['licensure']??"--",
          org: item['org'],
          status: item['status'],
        );

        if (licenseData.status == 'Expired') {
          expiredLicenses.add(licenseData);
        } else if (licenseData.status == 'Upto date') {
          upToDateLicenses.add(licenseData);
        }else{
          aboutToExpiryData.add(licenseData);
        }
      }
    } else {
      print("License status");
    }
    return {
      'Expired':expiredLicenses,
      'Upto date':upToDateLicenses,
      'About to Expire':aboutToExpiryData
    };
  } catch (e) {
    print("error${e}");
    return {
      'Expired':expiredLicenses,
      'Upto date':upToDateLicenses,
      'About to Expire':aboutToExpiryData
    };
  }
}