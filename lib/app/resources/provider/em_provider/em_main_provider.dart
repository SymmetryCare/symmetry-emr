import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmMainProvider extends ChangeNotifier{
  int _selectedInexValue = 0;
  String _pageNmaeValue = 'Select a Module';

  int get selectedIndexValue => _selectedInexValue;
  String get pageNmaeValue => _pageNmaeValue;

  void selectModuleScreen(int index){
    _selectedInexValue = index;
    notifyListeners();
  }
  void selectModuleNameScreen(String valueName){
    _pageNmaeValue = valueName;
    notifyListeners();
  }
  void clearValue(){
    _selectedInexValue = 0;
    _pageNmaeValue = 'Select a Module';
    notifyListeners();
  }
}