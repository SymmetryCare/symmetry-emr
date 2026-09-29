import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/Schedular_main_screens_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographich_ai_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/address_map_screen_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/schedular_manager/schedular_flow_api.dart';

class SmIntakeProviderManager extends ChangeNotifier{
  AIDemographichModelData? _fetchedData;
  bool _isContactTrue = false;
  bool _isRightSliderOpen = false;
  bool _isContactCallLive = false;
  bool _isEyeScreenVisible = false;
  bool _isLeftSidebarOpen = false;
  bool _isAutoSyncScreenVisible = false;
  int _initialIndex = 0;

  // Referal filter
  bool _isFilterOpen = false;
  bool _MContainerVisible = false;
  bool _OContainerVisible = false;
  bool _RContainerVisible = false;
  bool _AContainerVisible = false;
  bool _IContainerVisible = false;
  bool _ICContainerVisible = false;
  bool _PContainerVisible = false;// Track filter panel state
  bool _isAppBarVisible = false;

  TextEditingController _ctlrStreetProvider = TextEditingController();
  TextEditingController _ctlrCityProvider = TextEditingController();
  TextEditingController _ctlrStateProvider = TextEditingController();

  TextEditingController _ctlrStreetRelatedECProvider = TextEditingController();
  TextEditingController _ctlrCityRelatedECProvider = TextEditingController();
  TextEditingController _ctlrStateRelatedECProvider = TextEditingController();

  TextEditingController _ctlrStreetRelatedRPProvider = TextEditingController();
  TextEditingController _ctlrCityRelatedRPProvider = TextEditingController();
  TextEditingController _ctlrStateRelatedRPProvider = TextEditingController();

  TextEditingController _ctlrStreetInsurancePrimeProvider = TextEditingController();
  TextEditingController _ctlrCityInsurancePrimeProvider = TextEditingController();
  TextEditingController _ctlrStateInsurancePrimeProvider = TextEditingController();

  TextEditingController _ctlrStreetInsuranceSecondProvider = TextEditingController();
  TextEditingController _ctlrCityInsuranceSecondProvider = TextEditingController();
  TextEditingController _ctlrStateInsuranceSecondProvider = TextEditingController();

  TextEditingController _ctlrStreetPhysicalInfoProvider = TextEditingController();
  TextEditingController _ctlrCityPhysicalInfoProvider = TextEditingController();
  TextEditingController _ctlrStatePhysicalInfoProvider = TextEditingController();

  TextEditingController get ctlrStreetPhysicalInfoProvider => _ctlrStreetPhysicalInfoProvider;
  TextEditingController get ctlrCityPhysicalInfoProvider => _ctlrCityPhysicalInfoProvider;
  TextEditingController get ctlrStatePhysicalInfoProvider => _ctlrStatePhysicalInfoProvider;

  TextEditingController get ctlrStreetProvider => _ctlrStreetProvider;
  TextEditingController get ctlrCityProvider => _ctlrCityProvider;
  TextEditingController get ctlrStateProvider => _ctlrStateProvider;

  TextEditingController get ctlrStreetRelatedECProvider => _ctlrStreetRelatedECProvider;
  TextEditingController get ctlrCityRelatedECProvider => _ctlrCityRelatedECProvider;
  TextEditingController get ctlrStateRelatedECProvider => _ctlrStateRelatedECProvider;

  TextEditingController get ctlrStreetRelatedRPProvider => _ctlrStreetRelatedRPProvider;
  TextEditingController get ctlrCityRelatedRPProvider => _ctlrCityRelatedRPProvider;
  TextEditingController get ctlrStateRelatedRPProvider => _ctlrStateRelatedRPProvider;

  TextEditingController get ctlrStreetInsurancePrimeProvider => _ctlrStreetInsurancePrimeProvider;
  TextEditingController get ctlrCityInsurancePrimeProvider => _ctlrCityInsurancePrimeProvider;
  TextEditingController get ctlrStateInsurancePrimeProvider => _ctlrStateInsurancePrimeProvider;

  TextEditingController get ctlrStreetInsuranceSecondProvider => _ctlrStreetInsuranceSecondProvider;
  TextEditingController get ctlrCityInsuranceSecondProvider => _ctlrCityInsuranceSecondProvider;
  TextEditingController get ctlrStateInsuranceSecondProvider => _ctlrStateInsuranceSecondProvider;


  bool get isAppVarVisible => _isAppBarVisible;
  int get initialIndex => _initialIndex;
  bool get isContactTrue => _isContactTrue;
  bool get isRightSliderOpen => _isRightSliderOpen;
  bool get isContactCallLive => _isContactCallLive;
  bool get isEyeScreenVisible => _isEyeScreenVisible;
  bool get isLeftSidebarOpen => _isLeftSidebarOpen;
  bool get isAutoSyncScreenOpen => _isAutoSyncScreenVisible;

  // Referal filter
  bool get isFilterOpen => _isFilterOpen;
  bool get MContainerVisible => _MContainerVisible;
  bool get OContainerVisible => _OContainerVisible;
  bool get RContainerVisible => _RContainerVisible;
  bool get AContainerVisible => _AContainerVisible;
  bool get IContainerVisible => _IContainerVisible;
  bool get ICContainerVisible => _ICContainerVisible;
  bool get PContainerVisible => _PContainerVisible;

  String get marketerId => _marketerId;
  String get referralSourceId => _referralSourceId;
  String get pcpId => _pcpId;
  AIDemographichModelData get fetchedData => _fetchedData!;
  ///srefferl
  int _currentPagepp = 1;
  int _currentPageaa = 1;
  int _currentPagemm = 1;

  int get currentPage => _currentPagepp;
  int get currentPageaa => _currentPageaa;
  int get currentPagemm => _currentPagemm;

  ///intake
  int _currentPageinfo = 1;
  int _currentPagess = 1;
  int _currentPageno = 1;

  int get currentPageinfo => _currentPageinfo;
  int get currentPagess => _currentPagess;
  int get currentPageno => _currentPageno;



  ///schedler
  int _currentPagepps = 1;
  int _currentPato = 1;
  int _currentPages = 1;

  String _isLinkeFileName = '';
  int _pageCountFromLink = 0;
  String _isLinkeOpen = '';
  String _data = '';

  int get currentPagesps => _currentPagepps;
  int get currentPagesst => _currentPato;
  int get currentPagesss => _currentPages;

  int get pageCountFromLink => _pageCountFromLink;
  String get isLinkeFileName => _isLinkeFileName;
  String get isLinkeOpen => _isLinkeOpen;
  String get data => _data;


  void setLinkAndPageNumber({required String selectLink, required int pageNo,
    required String isLinkeOpen,
    String? data
  }){
    _pageCountFromLink = pageNo;
    _isLinkeFileName = selectLink;
    _isLinkeOpen = isLinkeOpen;
    _data = data!;
    notifyListeners();
  }
  void setLinkAndPageClear(){
    _pageCountFromLink = 0;
    _isLinkeFileName = ' ';
    _data = '';
    notifyListeners();
  }
  ///
  void clearMapAddressController(){
    _ctlrStreetProvider.text = '';
    _ctlrCityProvider.text =  '';
    _ctlrStateProvider.text = '';

    _ctlrStreetRelatedECProvider.text =  '';
    _ctlrCityRelatedECProvider.text = '';
    _ctlrStateRelatedECProvider.text = '';

    _ctlrStreetRelatedRPProvider.text = '';
    _ctlrCityRelatedRPProvider.text = '';
    _ctlrStateRelatedRPProvider.text = '';

    _ctlrStreetInsurancePrimeProvider.text = '';
    _ctlrCityInsurancePrimeProvider.text =  '';
    _ctlrStateInsurancePrimeProvider.text = '';

    _ctlrStreetInsuranceSecondProvider.text =  '';
    _ctlrCityInsuranceSecondProvider.text = '';
    _ctlrStateInsuranceSecondProvider.text = '';

    _ctlrStreetPhysicalInfoProvider.text = '';
    _ctlrCityPhysicalInfoProvider.text = '';
    _ctlrStatePhysicalInfoProvider.text = '';
    notifyListeners();
  }
  void clearMapAddressOnRelatedPartiesController(){
    _ctlrStreetProvider.text = '';
    _ctlrCityProvider.text =  '';
    _ctlrStateProvider.text = '';

    _ctlrStreetInsurancePrimeProvider.text = '';
    _ctlrCityInsurancePrimeProvider.text =  '';
    _ctlrStateInsurancePrimeProvider.text = '';

    _ctlrStreetInsuranceSecondProvider.text =  '';
    _ctlrCityInsuranceSecondProvider.text = '';
    _ctlrStateInsuranceSecondProvider.text = '';

    _ctlrStreetPhysicalInfoProvider.text = '';
    _ctlrCityPhysicalInfoProvider.text = '';
    _ctlrStatePhysicalInfoProvider.text = '';
    notifyListeners();
  }
  void openMapScreen({required BuildContext context}) async {
    clearMapAddressController();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressMapScreenConst(
          initialLocation:  const LatLng(41.603357, -103.040278), // Default location
          onLocationPicked: (_) {},
        ),
      ),
    );

    if (result != null) {
      String address = result['address'];
      print('Selected address ${address}');
      print('Selected State ${result['state']}');
      print('Selected City ${result['city']}');
      if (address != null) {
        // setState(() {
        _ctlrStreetProvider.text = result['address'] ?? '';
        _ctlrCityProvider.text = result['city'] ?? '';
        _ctlrStateProvider.text = result['state'] ?? '';
        // = TextEditingController(text:address );
        notifyListeners();
        // });
      }
    }
  }
  void openMapPhysicalInfoScreen({required BuildContext context}) async {
    clearMapAddressController();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressMapScreenConst(
          initialLocation:  const LatLng(41.603357, -103.040278), // Default location
          onLocationPicked: (_) {},
        ),
      ),
    );

    if (result != null) {
      String address = result['address'];
      if (address != null) {
        // setState(() {
        _ctlrStreetPhysicalInfoProvider.text =result['address'] ?? '';
        _ctlrCityPhysicalInfoProvider.text = result['city'] ?? '';
        _ctlrStatePhysicalInfoProvider.text = result['state'] ?? '';
        // = TextEditingController(text:address );
        notifyListeners();
        // });
      }
    }
  }
  void openMapInsurancePrimeScreen({required BuildContext context}) async {
    clearMapAddressController();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressMapScreenConst(
          initialLocation:  const LatLng(41.603357, -103.040278), // Default location
          onLocationPicked: (_) {},
        ),
      ),
    );

    if (result != null) {
      String address = result['address'];
      print('Selected address ${address}');
      print('Selected State ${result['state']}');
      print('Selected City ${result['city']}');
      if (address != null) {
        // setState(() {
        _ctlrStreetInsurancePrimeProvider.text = result['address'] ?? '';
        _ctlrCityInsurancePrimeProvider.text = result['city'] ?? '';
        _ctlrStateInsurancePrimeProvider.text = result['state'] ?? '';
        // = TextEditingController(text:address );
        notifyListeners();
        // });
      }
    }
  }
  void openMapInsuranceSecondScreen({required BuildContext context}) async {
    clearMapAddressController();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressMapScreenConst(
          initialLocation: const LatLng(41.603357, -103.040278), // Default location
          onLocationPicked: (_) {},
        ),
      ),
    );

    if (result != null) {
      String address = result['address'];
      print('Selected address ${address}');
      print('Selected State ${result['state']}');
      print('Selected City ${result['city']}');
      if (address != null) {
        // setState(() {
        _ctlrStreetInsuranceSecondProvider.text = result['address'] ?? '';
        _ctlrCityInsuranceSecondProvider.text = result['city'] ?? '';
        _ctlrStateInsuranceSecondProvider.text = result['state'] ?? '';
        // = TextEditingController(text:address );
        notifyListeners();
        // });
      }
    }
  }
  Future<void> fetchAIdemoData({required BuildContext context}) async{
    final providerPatientId = Provider.of<DiagnosisProvider>(context,listen: false);
    _fetchedData = await getAIDemographichData(context: context, ptId: providerPatientId.patientId);
    notifyListeners();
    // setState(() {
    //   //fetchedData = Data;
    // });
    // fetchedData = data;
  }

  ///refferl
  void setCurrentPage(int pagepprr) {
    _currentPagepp = pagepprr;
    notifyListeners();
  }

  void aaCurrentPage(int pageaarrr) {
    _currentPageaa = pageaarrr;
    notifyListeners();
  }
  void mmCurrentPage(int pagemmrrrr) {
    _currentPagemm = pagemmrrrr;
    notifyListeners();
  }


  ///intake

  void intakesetCurrentPage(int pageppi) {
    _currentPageinfo = pageppi;
    notifyListeners();
  }

  void iiCurrentPage(int pageaaii) {
    _currentPagess = pageaaii;
    notifyListeners();
  }
  void iinoCurrentPage(int pagemmiii) {
    _currentPageno = pagemmiii;
    notifyListeners();
  }


  ///schedular
  void sssetCurrentPage(int pagepps) {
    _currentPagepps = pagepps;
    notifyListeners();
  }

  void ssCurrentPage(int pageaass) {
    _currentPato = pageaass;
    notifyListeners();
  }
  void stsCurrentPage(int pagemmsss) {
    _currentPages = pagemmsss;
    notifyListeners();
  }

  ///

  void toogleContactProvider(){
    _isContactTrue = !_isContactTrue;
    notifyListeners();
  }
  void toogleRightSliderProvider(){
    _isRightSliderOpen = !_isRightSliderOpen;
    notifyListeners();
  }
  void toogleContactProviderclear(){
    _isContactTrue = false;
    notifyListeners();
  }
  void toogleContactProviderTrue(){
    _isContactTrue = true;
    notifyListeners();
  }
  void toogleContactCallLiveProvider(){
    _isContactCallLive = !_isContactCallLive;
    notifyListeners();
  }
  void toogleEyeScreenProvider(){
    _isEyeScreenVisible = !_isEyeScreenVisible;
    notifyListeners();
  }
  void toogleAutoSyncScreenProvider(){
    _isAutoSyncScreenVisible = !_isAutoSyncScreenVisible;
    notifyListeners();
  }
  void toogleLeftSidebarProvider(){
    _isLeftSidebarOpen = !_isLeftSidebarOpen;
    notifyListeners();
  }
  void indexChnage(int index){
    _initialIndex = index;
    notifyListeners();
  }

  /// SM referal
  void toggleFilter() {
    _isFilterOpen = !_isFilterOpen;
    notifyListeners();// Toggle panel visibility
  }
  void toggleContainerM() {
    _MContainerVisible = !_MContainerVisible;
    notifyListeners();
  }

  void toggleContainerO() {
    _OContainerVisible = !_OContainerVisible;
    notifyListeners();
  }

  void toggleContainerR() {
    _RContainerVisible = !_RContainerVisible;
    notifyListeners();
  }

  void toggleContainerA() {
    _AContainerVisible = !_AContainerVisible;
    notifyListeners();
  }

  void toggleContainerI() {
    _IContainerVisible = !_IContainerVisible;
    notifyListeners();
  }

  void toggleContainerIC() {
    _ICContainerVisible = !_ICContainerVisible;
    notifyListeners();

  }

  void toggleContainerP() {
    _PContainerVisible = !_PContainerVisible;
    notifyListeners();
  }

  void toogleAppBar(){
    _isAppBarVisible = !_isAppBarVisible;
    notifyListeners();
  }

  String _marketerId = 'all';
  String _referralSourceId = 'all';
  String _pcpId = 'all';

  final TextEditingController searchController = TextEditingController();
  // Dedicated search controller for the Archived tab so it no longer shares
  // the Pending tab's `searchController` instance (that was the root cause of
  // search text leaking between tabs).
  final TextEditingController archivedSearchController = TextEditingController();
  final StreamController<List<PatientModel>> _streamController = StreamController<List<PatientModel>>.broadcast();

  RefferalFilterScreenType _currentScreen = RefferalFilterScreenType.pending;
  // Getter for screen type
  RefferalFilterScreenType get currentScreen => _currentScreen;
  // Stream getter
  Stream<List<PatientModel>> get patientReferralsStream => _streamController.stream;
  // Set current screen
  void setCurrentScreen(RefferalFilterScreenType screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void updateSearchText(String searchText) {
    searchController.text = searchText;
    notifyListeners();
  }

  Future<void> filterIdIntegration({
    required BuildContext context,
    required String marketerId,
    required String sourceId,
    required String pcpId,
  }) async {
    _marketerId = marketerId;
    _referralSourceId = sourceId;
    _pcpId = pcpId;
    notifyListeners();
    await _applyFilters(context: context);
  }

  Future<void> _applyFilters({required BuildContext context}) async {
    try {
      String isIntake = 'false';
      String isArchived = 'false';

      switch (_currentScreen) {
        case RefferalFilterScreenType.archive:
          isArchived = 'true';
          break;
        case RefferalFilterScreenType.intake:
          isIntake = 'true';
          break;
        case RefferalFilterScreenType.pending:
          break;
      }

      // Pick the correct controller's text depending on which tab
      // triggered this call, instead of always reading `searchController`
      // (which previously caused Archived's search to read Pending's text).
      final String searchText = _currentScreen == RefferalFilterScreenType.archive
          ? archivedSearchController.text
          : searchController.text;

      final data = await getPatientReffrealsData(
          context: context,
          pageNo: 1,
          nbrOfRows: 9999,
          isIntake: isIntake,
          intakeSort: "asc",
          isArchived: isArchived,
          archivedSort: "asc",
          isScheduled: 'false',
          scheduledSort: "asc",
          searchName: searchText.isEmpty ? 'all' : searchText,
          marketerId: _marketerId,
          referralSourceId: _referralSourceId,
          pcpId: _pcpId, isNotAdmit: 'false', nonAdmitSort: "asc"
      );

      _streamController.add(data);
    } catch (e) {
      print("Error applying filters: $e");
      _streamController.addError("Failed to load data");
    }
  }

  ///
  ///intake

  // intakesearchController belongs to the Information Update tab only.
  // sendToSchedController is dedicated to the Send to Scheduler tab so it no
  // longer shares Information Update's controller (that was causing search text
  // typed in one intake sub-tab to appear in the other).
  final TextEditingController intakesearchController = TextEditingController();
  final TextEditingController sendToSchedController = TextEditingController();
  final StreamController<List<PatientModel>> _intakestreamController = StreamController<List<PatientModel>>.broadcast();

  IntakefilterScreenType _currentScreenintake = IntakefilterScreenType.infoupdate;

  IntakefilterScreenType get currentScreenIntake => _currentScreenintake;
  Stream<List<PatientModel>> get patientReferralsStreamIntake => _intakestreamController.stream;

  void setCurrentScreenIntake(IntakefilterScreenType screen) {
    _currentScreenintake = screen;
    notifyListeners();
  }

  void updateSearchTextIntake(String searchText) {
    intakesearchController.text = searchText;
    notifyListeners();
  }

  // Setter for the Send to Scheduler tab's own search text
  void updateSearchTextSendToSched(String searchText) {
    sendToSchedController.text = searchText;
    notifyListeners();
  }

  Future<void> filterIdIntegrationIntake({
    required BuildContext context,
    required String marketerId,
    required String sourceId,
    required String pcpId,
  }) async {
    _marketerId = marketerId;
    _referralSourceId = sourceId;
    _pcpId = pcpId;
    notifyListeners();
    await _applyFiltersIntake(context: context);
  }

  Future<void> _applyFiltersIntake({required BuildContext context}) async {
    try {
      // Default to all false
      String isIntake = 'false';
      String isScheduled = 'false';
      String isNotAdmit = 'false';

      switch (_currentScreenintake) {
        case IntakefilterScreenType.infoupdate:
          isIntake = 'true'; // Intake screen
          break;
        case IntakefilterScreenType.sendtosech:
          isScheduled = 'true';
          isIntake = 'true';
          break;
        case IntakefilterScreenType.nonadmit:
          isNotAdmit = 'true'; // Non-admit screen
          break;
      }

      // Pick the correct controller's text depending on which intake
      // sub-tab triggered this call, instead of always reading
      // intakesearchController (which previously caused Send to Scheduler's
      // search to read Information Update's text, and vice versa).
      final String searchText = _currentScreenintake == IntakefilterScreenType.sendtosech
          ? sendToSchedController.text
          : intakesearchController.text;

      final data = await getPatientReffrealsData(
        context: context,
        pageNo: 1,
        nbrOfRows: 9999,
        isIntake: isIntake,
        intakeSort: "asc",
        isArchived:'false',
        archivedSort: "asc",
        isScheduled: isScheduled,
        scheduledSort: "asc",
        isNotAdmit: isNotAdmit,
        nonAdmitSort: "asc",
        searchName: searchText.isEmpty ? 'all' : searchText,
        marketerId: _marketerId,
        referralSourceId: _referralSourceId,
        pcpId: _pcpId,
      );

      _intakestreamController.add(data);
    } catch (e) {
      print("Error applying filters: $e");
      _intakestreamController.addError("Failed to load data");
    }
  }



  ///
  ///
  /// schedular
  final TextEditingController searchControllerSchedular = TextEditingController();
  final StreamController<List<SchedularFlowPatientModel>> _streamControllerSchedular = StreamController<List<SchedularFlowPatientModel>>.broadcast();
  Stream<List<SchedularFlowPatientModel>> get patientSchedularStream => _streamControllerSchedular.stream;
  SchedulerFilterScreenType _currentScreenSchedule = SchedulerFilterScreenType.pending;
  void setCurrentScreenSchedular(SchedulerFilterScreenType screen) {
    _currentScreenSchedule = screen;
    notifyListeners();
  }

  void updateSearchTextSchedular(String searchText) {
    searchControllerSchedular.text = searchText;
    notifyListeners();
  }

  Future<void> filterIdScedularIntegration({
    required BuildContext context,
    required String marketerId,
    required String sourceId,
    required String pcpId,
  }) async {
    _marketerId = marketerId;
    _referralSourceId = sourceId;
    _pcpId = pcpId;
    notifyListeners();
    await _applyFiltersSchedular(context: context);
  }

  Future<void> _applyFiltersSchedular({required BuildContext context}) async {
    try {
      String isScheduler = 'true';
      String isNonAdmit = 'false';


      // 🔄 Map enum to string
      String screen;
      String sort;
      switch (_currentScreenSchedule) {
        case SchedulerFilterScreenType.pending:
          screen = "pending";
          sort = "asc";
          break;
        case SchedulerFilterScreenType.toBeScheduled:
          screen = "toBeScheduled";
          sort = "asc";
          break;
        case SchedulerFilterScreenType.scheduled:
          screen = "scheduled";
          sort = "desc";
          break;
      }

      final data = await getSchedulerFlowPatientData(
        context: context,
        screen: screen, // ✅ Use correct value
        pgNbr: 1,
        nbrOfRows: 9999,
        sort: sort,
        isScheduler: isScheduler,
        isNonAdmit: isNonAdmit,
        searchName: searchControllerSchedular.text.isEmpty
            ? 'all'
            : searchControllerSchedular.text,
        marketerId: _marketerId,
        referralSourceId: _referralSourceId,
        pcpId: _pcpId,
      );

      _streamControllerSchedular.add(data);
    } catch (e) {
      print("Error applying filters: $e");
      _streamControllerSchedular.addError("Failed to load data");
    }
  }

  ///non admit
  final TextEditingController searchControllerNonAdmit = TextEditingController();
  final StreamController<List<NonAdmitData>> _streamControllerNonAdmit = StreamController<List<NonAdmitData>>.broadcast();
  Stream<List<NonAdmitData>> get patientNonAdmitStream => _streamControllerNonAdmit.stream;
  NonAdmitScreenType _currentNonAdmitScreen = NonAdmitScreenType.nonAdmit;

  void setCurrentScreenNonAdmit(NonAdmitScreenType screen) {
    _currentNonAdmitScreen = screen;
    notifyListeners();
  }
  void updateSearchTextNonAdmit(String searchText) {
    searchControllerNonAdmit.text = searchText;
    notifyListeners();
  }

  Future<void> filterIdNonAdmitIntegration({
    required BuildContext context,
    required String marketerId,
    required String sourceId,
    required String pcpId,
  }) async {
    _marketerId = marketerId;
    _referralSourceId = sourceId;
    _pcpId = pcpId;
    notifyListeners();
    await _applyFiltersNonAdmit(context: context);
  }

  Future<void> _applyFiltersNonAdmit({required BuildContext context}) async {
    try {
      final data = await getInfoUpdateNonAdmit(
        context: context,
        pageNo: 1,
        nbrOfRows: 9999,
        sort: "asc",
        searchName: searchControllerNonAdmit.text.isEmpty
            ? 'all'
            : searchControllerNonAdmit.text,
        marketerId: _marketerId,
        referralSourceId: _referralSourceId,
        pcpId: _pcpId,
      );
      _streamControllerNonAdmit.add(data);
    } catch (e) {
      print("Error applying non admit filters: $e");
      _streamControllerNonAdmit.addError("Failed to load data");
    }
  }


//------------- send to schedular back ------

  bool _shouldReloadSchedulerTab = false;

  bool get shouldReloadSchedulerTab => _shouldReloadSchedulerTab;

  void triggerSchedulerTabReload() {
    _shouldReloadSchedulerTab = true;
    notifyListeners();
  }

  void clearSchedulerTabReloadFlag() {
    _shouldReloadSchedulerTab = false;
  }



  // --------------------------------
  bool _isSelfPay = false;

  bool get isSelfPay => _isSelfPay;

  void setSelfPay(bool value) {
    _isSelfPay = value;
    notifyListeners();
  }

  //============Movetointake
  bool _shouldReloadMovetointake = false;

  bool get shouldReloadMovetointake => _shouldReloadMovetointake;

  void triggerMIntakeTabReload() {
    _shouldReloadMovetointake = true;
    notifyListeners();
  }

  void clearMIntakeTabReloadFlag() {
    _shouldReloadMovetointake = false;
  }


}

enum SchedulerFilterScreenType {
  pending,
  toBeScheduled,
  scheduled,
}

enum RefferalFilterScreenType {
  pending,
  intake,
  archive,
}
enum IntakefilterScreenType{
  infoupdate,
  sendtosech,
  nonadmit,
}

enum NonAdmitScreenType{
  nonAdmit,
}