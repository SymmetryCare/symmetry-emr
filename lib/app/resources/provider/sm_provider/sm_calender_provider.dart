import 'package:flutter/material.dart';

class SmCalenderProvider extends ChangeNotifier{
 String _dateFrom = '';
 String _dateTo = '';
 List<String> _employeeId = [];
 List<String> _employeeName = [];
 List<String> _employeeColor = [];
 String get dateFrom => _dateFrom;
 String get dateTo => _dateTo;
 List<String> get employeeId => _employeeId;
 List<String> get employeeName => _employeeName;
 List<String> get employeeColor => _employeeColor;


 void fetchCalenderData({required String dateForm,
   required String dateTo, required List<String> employeeId,
   required List<String>  employeeName,
   required List<String> employeeColor
 }){
   _dateFrom = dateForm;
   _dateTo = dateTo;
   _employeeId = employeeId;
   _employeeName = employeeName;
   _employeeColor = employeeColor;
   notifyListeners();
 }
 void clearCalenderData(){
   _dateFrom = '';
   _dateTo = '';
   _employeeId.clear();
   _employeeName.clear();
   // employeeColor.clear();
   notifyListeners();
 }
}