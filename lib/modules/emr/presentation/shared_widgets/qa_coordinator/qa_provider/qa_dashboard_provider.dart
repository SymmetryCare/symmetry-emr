import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/responsive_screen/qa_responsive.dart';

class QaDashboardProvider extends ChangeNotifier {
  final PageController tabPageController = PageController(initialPage: 0);

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void selectButton(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void selectButtonWhenReady(int index) {
    _selectedIndex = index;
    notifyListeners();
    _jumpWhenAttached(index);
  }

  void _jumpWhenAttached(int index, [int retryCount = 0]) {
    print("Attempt $retryCount — hasClients: ${tabPageController.hasClients}");
    if (tabPageController.hasClients) {
      print("✅ Jumping to $index");
      tabPageController.jumpToPage(index);
    } else if (retryCount < 10) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _jumpWhenAttached(index, retryCount + 1);
      });
    } else {
      print("❌ Failed after 10 retries");
    }
  }

  @override
  void dispose() {
    tabPageController.dispose();
    super.dispose();
  }
}

class QaCoordinatorProvider extends ChangeNotifier {
  PageController _pageController = PageController(initialPage: 0);
  final ButtonQACoordinatorController tabCtrl =
  Get.put(ButtonQACoordinatorController());

  int  _pageIdx  = 0;
  bool _showChat = false;

  int            get pageIdx        => _pageIdx;
  bool           get showChat       => _showChat;
  PageController get pageController => _pageController;

  void jumpTo(int index) {
    _pageIdx = index;
    tabCtrl.selectButton(index);

    if (index == 2) {
      _showChat = true;
    } else {
      _showChat = false;
      if (_pageController.hasClients &&
          _pageController.positions.length == 1) {
        _pageController.jumpToPage(index);
      }
    }
    notifyListeners();
  }

  void resetController() {
    _pageController.dispose();
    _pageController = PageController(initialPage: _pageIdx);
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}