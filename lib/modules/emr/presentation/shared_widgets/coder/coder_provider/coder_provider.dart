import 'package:flutter/material.dart';

class CoderProvider extends ChangeNotifier {
  PageController _pageController = PageController(initialPage: 0);

  int _pageIdx = 0;
  bool _showChat = false;

  int get pageIdx => _pageIdx;
  bool get showChat => _showChat;
  PageController get pageController => _pageController;

  void jumpTo(int index) {
    if (index == 2) {
      _pageIdx = 2; // neither tab selected while chat is open
      _showChat = true;
      notifyListeners();
    } else {
      _showChat = false;
      _pageIdx = index;
      notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients &&
            _pageController.positions.length == 1) {
          _pageController.jumpToPage(index);
        } else {
          // PageView was offstaged — reset controller to correct page
          _pageController.dispose();
          _pageController = PageController(initialPage: index);
          notifyListeners();
        }
      });
    }
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

class CoderDashboardProvider extends ChangeNotifier {
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