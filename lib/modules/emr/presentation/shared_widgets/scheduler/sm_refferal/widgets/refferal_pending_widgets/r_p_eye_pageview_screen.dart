import 'dart:async';
import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_integration_provider.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/master_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/sm_signature_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/referringdiagnosis_data/sm_signature_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/manage_history_version.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';

class DiagnosisProvider extends ChangeNotifier {
  int _patientId = 0;
  int get patientId => _patientId;
  String _fileName = '';
  dynamic _filePath;
  bool _fileAbove20Mb = false;

  dynamic get filePath => _filePath;
  String get fileName => _fileName;
  bool get fileAbove20Mb => _fileAbove20Mb;

  void passPatientId({required int patientIdNo}) {
    _patientId = patientIdNo;
    notifyListeners();
  }

  void passPatientIdClear() {
    _patientId = 0;
    notifyListeners();
  }

  List<GlobalKey<_DiagosisListState>> _diagnosisKeys = [];
  List<PatientDiagnosesModel> _diagnosisData = [];
  bool _isVisible = false;

  List<GlobalKey<_DiagosisListState>> get diagnosisKeys => _diagnosisKeys;
  List<PatientDiagnosesModel> get diagnosisData => _diagnosisData;
  bool get isVisible => _isVisible;

  void pickPatientFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );
    final fileSize = result?.files.first.size;
    final isAbove20MB = fileSize! > (20 * 1024 * 1024);
    if (result != null) {
      _filePath = result.files.first.bytes;
      _fileName = result.files.first.name;
      _fileAbove20Mb = !isAbove20MB;
      notifyListeners();
    }
  }

  void loadDiagnosisFromApi(List<PatientDiagnosesModel> apiData) {
    _diagnosisKeys.clear();
    _diagnosisData = apiData;
    for (var _ in apiData) {
      _diagnosisKeys.add(GlobalKey<_DiagosisListState>());
    }
    notifyListeners();
  }

  void addDiagnosis() {
    _diagnosisKeys.add(GlobalKey<_DiagosisListState>());
    _diagnosisData.add(
      PatientDiagnosesModel(
        rpt_dgn_id: 0,
        dgnName: '',
        dgnCode: '',
        fk_pt_id: 0,
        fk_dgn_id: 0,
        rpt_pdgm: false,
        rpt_isPrimary: false,
        color: 2,
      ),
    );
    notifyListeners();
  }

  void removeDiagnosis(GlobalKey<_DiagosisListState> key) {
    int index = _diagnosisKeys.indexOf(key);
    if (index != -1) {
      _diagnosisKeys.removeAt(index);
      _diagnosisData.removeAt(index);
      notifyListeners();
    }
  }

  void setVisibility(bool value) {
    _isVisible = value;
    notifyListeners();
  }

  void updateDiagnosis(int index, PatientDiagnosesModel model) {
    if (index >= 0 && index < _diagnosisData.length) {
      _diagnosisData[index] = model;
      notifyListeners();
    }
  }

  final Map<String, String> _patientSelectedTypes = {};

  String getSelectedType(String patientId) {
    return _patientSelectedTypes[patientId] ?? 'Insurance';
  }

  void setSelectedType(String patientId, String value) {
    if (_patientSelectedTypes[patientId] != value) {
      _patientSelectedTypes[patientId] = value;
      notifyListeners();
    }
  }

  bool isSelfPay(String patientId) {
    return getSelectedType(patientId) == 'Self Pay';
  }

  void resetPatientSelection(String patientId) {
    _patientSelectedTypes.remove(patientId);
    notifyListeners();
  }

  String getSelectedTypeForInt(int patientId) {
    return getSelectedType(patientId.toString());
  }

  void setSelectedTypeForInt(int patientId, String value) {
    setSelectedType(patientId.toString(), value);
  }

  bool isSelfPayForInt(int patientId) {
    return isSelfPay(patientId.toString());
  }

  void resetPatientSelectionForInt(int patientId) {
    resetPatientSelection(patientId.toString());
  }
}

class ReferalPendingEyePageview extends StatelessWidget {
  final VoidCallback onGoBackPressed;
  const ReferalPendingEyePageview({super.key, required this.onGoBackPressed});

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(context, listen: false);
    final patientId = diagnosisProvider.patientId;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AsyncDataController<PatientModel>>(
          create: (ctx) => AsyncDataController<PatientModel>()
            ..load(() => getPatientReffrealsDataUsingId(
                context: ctx, patientId: patientId)),
        ),
        ChangeNotifierProvider<
            AsyncDataController<List<ServicePatientReffralsData>>>(
          create: (ctx) => AsyncDataController<List<ServicePatientReffralsData>>()
            ..load(() => getReferealsServiceList(context: ctx)),
        ),
      ],
      child: _ReferalPendingEyePageviewBody(onGoBackPressed: onGoBackPressed),
    );
  }
}

class _ReferalPendingEyePageviewBody extends StatefulWidget {
  final VoidCallback onGoBackPressed;
  const _ReferalPendingEyePageviewBody({required this.onGoBackPressed});

  @override
  State<_ReferalPendingEyePageviewBody> createState() =>
      _ReferalPendingEyePageviewBodyState();
}

class _ReferalPendingEyePageviewBodyState extends State<_ReferalPendingEyePageviewBody> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController patientsController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController patientsSummary = TextEditingController();
  TextEditingController referredfor = TextEditingController();
  TextEditingController policy = TextEditingController();
  TextEditingController plan = TextEditingController();
  TextEditingController provider = TextEditingController();
  TextEditingController possiblePrime = TextEditingController();
  TextEditingController icdPrime = TextEditingController();
  TextEditingController pdgmPrime = TextEditingController();

  bool isChecked = false;
  List<bool> isCheckedList = List.generate(5, (index) => false);
  String? selectedFileName;
  String? selectedSignatureFileName;

  bool dgnAddLoader = false;
  bool nursing = true;
  bool physicalTherapy = true;
  bool occupationalTherapy = true;
  bool speechTherapy = false;
  bool medicalSocialServices = false;
  bool homeHealthAide = true;
  bool dietician = false;

  void _pickFile() async {}

  var Nursing = '';
  var PhysicalTherapy = '';
  var OccupationalTherapy = '';
  var SpeechTherapy = '';
  var MedicalSocialServices = '';
  var HomeHealthAide = '';
  var Dietician = '';
  int dgnIdSelected = 0;
  String dgnNameSelected = 'Select';
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadInitialDiagnosis();
    loadInitialinsurance();
  }

  List<EmployeeClinicalData> employeeClinicalData = [];

  Future<void> loadInitialDiagnosis() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    PatientModel apiData = await getPatientReffrealsDataUsingId(
        context: context, patientId: provider.patientId);
    provider.loadDiagnosisFromApi(apiData.patientDiagnoses);
    provider.setVisibility(true);
  }

  Future<void> loadInitialinsurance() async {
    employeeClinicalData =
        await getEmployeeClinicalInReffreals(context: context);
  }

  bool isTypeInitialized = false;
  double _sliderValue = 100;
  int patientInsuranceId = 0;

  final StreamController<List<PatientDocumentsData>> _streamController =
      StreamController<List<PatientDocumentsData>>.broadcast();
  final StreamController<List<PatientDiagnosisWithIdData>> _streamDignosis =
      StreamController<List<PatientDiagnosisWithIdData>>.broadcast();
  final StreamController<List<SignatureFormDocumentData>> _streamSignature =
      StreamController<List<SignatureFormDocumentData>>.broadcast();

  int? selectedRptiId;
  TextEditingController possible = TextEditingController();
  TextEditingController icd = TextEditingController();
  TextEditingController pdgm = TextEditingController();

  @override
  void dispose() {
    _streamController.close();
    _streamDignosis.close();
    _streamSignature.close();
    firstNameController.dispose();
    lastNameController.dispose();
    patientsController.dispose();
    zipCodeController.dispose();
    patientsSummary.dispose();
    referredfor.dispose();
    policy.dispose();
    plan.dispose();
    provider.dispose();
    possiblePrime.dispose();
    icdPrime.dispose();
    pdgmPrime.dispose();
    possible.dispose();
    icd.dispose();
    pdgm.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider =
        Provider.of<DiagnosisProvider>(context, listen: false);
    final int patientId = diagnosisProvider.patientId;

    return Consumer<AsyncDataController<PatientModel>>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 76),
            child: Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            ),
          );
        }

        patientInsuranceId = controller.data!.fkRptiId!;
        firstNameController =
            TextEditingController(text: controller.data!.ptFirstName);
        lastNameController =
            TextEditingController(text: controller.data!.ptLastName);
        patientsController =
            TextEditingController(text: controller.data!.ptContactNo);
        zipCodeController =
            TextEditingController(text: controller.data!.ptZipCode);
        patientsSummary = TextEditingController(text: controller.data!.ptSummary);

        List<String> desciplineModel = [];
        List<String> desciplineModelAbbrivation = [];
        List<String> desciplineModelAbbrivationColor = [];
        List<int> desciplineintList = [];

        for (var a in controller.data!.disciplines) {
          desciplineModel.add(a.employeeType);
          desciplineintList.add(a.employeeTypeId);
          desciplineModelAbbrivation.add(a.abbreviation);
          desciplineModelAbbrivationColor.add(a.color);
        }

        String formattedCreatedTime =
            DateFormat.jm().format(DateTime.parse(controller.data!.createdAt));

        return LayoutBuilder(builder: (context, constraints) {
          const double minContentWidth = 1200;
          final double contentWidth = constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;
          return CustomScrollbar(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.p10),
                      child: SizedBox(
                          width: contentWidth,
                          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      border: Border(
                        top:
                            BorderSide(color: ColorManager.blueprime, width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Provider.of<SmIntakeProviderManager>(
                                            context,
                                            listen: false)
                                        .triggerMIntakeTabReload();
                                    widget.onGoBackPressed();
                                  },
                                  child: Icon(Icons.arrow_back,
                                      size: IconSize.I16,
                                      color: ColorManager.mediumgrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ClipOval(
                                child: controller.data!.ptImgUrl == 'imgurl' ||
                                        controller.data!.ptImgUrl == null
                                    ? CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.transparent,
                                        child: Image.asset(
                                            "images/profilepic.png"),
                                      )
                                    : Image.network(
                                        controller.data!.ptImgUrl!,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.transparent,
                                          child: Image.asset(
                                              "images/profilepic.png"),
                                        ),
                                        fit: BoxFit.cover,
                                        height: 45,
                                        width: 45,
                                      ),
                              ),
                              Text(
                                "${controller.data!.ptFirstName} ${controller.data!.ptLastName}",
                                textAlign: TextAlign.center,
                                style: CustomTextStylesCommon.commonStyle(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w700,
                                    color: ColorManager.black),
                              ),
                              Text("Ch #1",
                                  textAlign: TextAlign.center,
                                  style: CustomTextStylesCommon.commonStyle(
                                      fontSize: FontSize.s12,
                                      fontWeight: FontWeight.w400,
                                      color: ColorManager.mediumgrey)),
                              Text(
                                "Received Date: ${controller.data!.ptRefferalDate}  | $formattedCreatedTime",
                                textAlign: TextAlign.center,
                                style: CustomTextStylesCommon.commonStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorManager.mediumgrey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 50),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              Row(children: [
                                Expanded(
                                    child: Text("Referral Date :  ",
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s11,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    ColorManager.mediumgrey))),
                                Expanded(
                                    flex: 2,
                                    child: Text(controller.data!.ptRefferalDate,
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    ColorManager.mediumgrey))),
                              ]),
                              const SizedBox(height: 20),
                              Row(children: [
                                Expanded(
                                    child: Text("Primary Diagnosis: ",
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s11,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    ColorManager.mediumgrey))),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        controller.data!.patientDiagnoses.isEmpty
                                            ? ""
                                            : controller.data!.patientDiagnoses[0]
                                                .dgnName,
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    ColorManager.mediumgrey))),
                              ]),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              Row(children: [
                                Expanded(
                                    child: Text("Referral Source: ",
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s11,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    ColorManager.mediumgrey))),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        controller
                                            .data!.referralSource.sourceName,
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    ColorManager.mediumgrey))),
                              ]),
                              const SizedBox(height: 20),
                              Row(children: [
                                Expanded(
                                    child: Text("PCP:  ",
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s11,
                                                fontWeight: FontWeight.w400,
                                                color:
                                                    ColorManager.mediumgrey))),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        "${controller.data!.pcp.phyFirstName} ${controller.data!.pcp.phyFirstName}",
                                        textAlign: TextAlign.start,
                                        style:
                                            CustomTextStylesCommon.commonStyle(
                                                fontSize: FontSize.s12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    ColorManager.mediumgrey))),
                              ]),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Text("Marketer: ",
                                    style: CustomTextStylesCommon.commonStyle(
                                        fontSize: FontSize.s12,
                                        fontWeight: FontWeight.w400,
                                        color: ColorManager.mediumgrey)),
                                const SizedBox(width: AppSize.s25),
                                ClipOval(
                                  child: controller.data!.ptImgUrl == 'imgurl' ||
                                          controller.data!.ptImgUrl == null
                                      ? CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                          child: Image.asset(
                                              "images/profilepic.png"),
                                        )
                                      : Image.network(
                                          controller.data!.marketer.imgurl,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.transparent,
                                            child: Image.asset(
                                                "images/profilepic.png"),
                                          ),
                                          fit: BoxFit.cover,
                                          height: 45,
                                          width: 41,
                                        ),
                                ),
                                const SizedBox(width: AppSize.s15),
                                Text(
                                    "${controller.data!.marketer.firstName} ${controller.data!.marketer.lastName}",
                                    textAlign: TextAlign.center,
                                    style: CustomTextStylesCommon.commonStyle(
                                        fontSize: FontSize.s12,
                                        fontWeight: FontWeight.w700,
                                        color: ColorManager.mediumgrey)),
                                const SizedBox(width: AppSize.s7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s20),

                  // ── Patient Information ───────────────────────────────
                  BlueBGHeadConst(
                    HeadText: "Patient Information",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s20),
                        Row(
                          children: [
                            const SizedBox(width: AppSize.s25),
                            Expanded(
                              child: SMTextFConst(
                                  controller: firstNameController,
                                  isAsteric: false,
                                  onChangeField: (value) {
                                    updateReferralPatient(
                                        context: context,
                                        patientId: patientId,
                                        isUpdatePatiendData: true,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        contactNo: patientsController.text,
                                        summary: patientsSummary.text,
                                        zipCode: zipCodeController.text,
                                        serviceId: controller.data!.fkSrvId,
                                        disciplineIds: desciplineintList,
                                        insuranceId: patientInsuranceId);
                                  },
                                  keyboardType: TextInputType.text,
                                  text: "First Name"),
                            ),
                            const SizedBox(width: AppSize.s30),
                            Expanded(
                              child: SMTextFConst(
                                  controller: lastNameController,
                                  isAsteric: false,
                                  onChangeField: (value) {
                                    updateReferralPatient(
                                        context: context,
                                        patientId: patientId,
                                        isUpdatePatiendData: true,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        contactNo: patientsController.text,
                                        summary: patientsSummary.text,
                                        zipCode: zipCodeController.text,
                                        serviceId: controller.data!.fkSrvId,
                                        disciplineIds: desciplineintList,
                                        insuranceId: patientInsuranceId);
                                  },
                                  keyboardType: TextInputType.text,
                                  text: "Last Name"),
                            ),
                            const SizedBox(width: AppSize.s30),
                            Expanded(
                              child: SMTextFConstPhone(
                                  controller: patientsController,
                                  isAsteric: true,
                                  onChanged: (value) {
                                    updateReferralPatient(
                                        context: context,
                                        patientId: patientId,
                                        isUpdatePatiendData: true,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        contactNo: patientsController.text,
                                        summary: patientsSummary.text,
                                        zipCode: zipCodeController.text,
                                        serviceId: controller.data!.fkSrvId,
                                        disciplineIds: desciplineintList,
                                        insuranceId: patientInsuranceId);
                                  },
                                  keyboardType: TextInputType.text,
                                  text: "Patient or Caregiver Phone Number"),
                            ),
                            const SizedBox(width: AppSize.s30),
                            Expanded(
                              child: SMTextFConst(
                                  controller: zipCodeController,
                                  isAsteric: false,
                                  onChangeField: (value) {
                                    updateReferralPatient(
                                        context: context,
                                        patientId: patientId,
                                        isUpdatePatiendData: true,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        contactNo: patientsController.text,
                                        summary: patientsSummary.text,
                                        zipCode: zipCodeController.text,
                                        serviceId: controller.data!.fkSrvId,
                                        disciplineIds: desciplineintList,
                                        insuranceId: patientInsuranceId);
                                  },
                                  keyboardType: TextInputType.text,
                                  text: "Zip Code"),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSize.s10),
                        Row(
                          children: [
                            const SizedBox(width: AppSize.s25),
                            Expanded(
                              child: Consumer<AsyncDataController<
                                  List<ServicePatientReffralsData>>>(
                                builder: (context, snapshotService, _) {
                                  if (snapshotService.isLoading) {
                                    return SchedularTextField(
                                      isIconVisible: true,
                                      controller: TextEditingController(
                                          text: controller.data!.service.srvName),
                                      labelText: 'Referred for',
                                    );
                                  }
                                  if (snapshotService.data != null) {
                                    List<DropdownMenuItem<String>>
                                        dropDownList = [];
                                    for (var i in snapshotService.data!) {
                                      dropDownList.add(DropdownMenuItem<String>(
                                          child: Text(i.serviceName!),
                                          value: i.serviceName));
                                    }
                                    return CustomDropdownTextFieldsm(
                                      isIconVisible: false,
                                      headText: 'Referred for',
                                      initialValue:
                                          controller.data!.service.srvName,
                                      dropDownMenuList: dropDownList,
                                      onChanged: (newValue) {
                                        for (var a in snapshotService.data!) {
                                          updateReferralPatient(
                                              context: context,
                                              patientId: patientId,
                                              isUpdatePatiendData: true,
                                              firstName:
                                                  firstNameController.text,
                                              lastName: lastNameController.text,
                                              contactNo:
                                                  patientsController.text,
                                              summary: patientsSummary.text,
                                              zipCode: zipCodeController.text,
                                              serviceId: a.serviceId,
                                              disciplineIds: desciplineintList,
                                              insuranceId: patientInsuranceId);
                                        }
                                      },
                                    );
                                  } else {
                                    return const Offstage();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: AppSize.s30),
                            Expanded(
                              child: SMTextFConst(
                                  controller: patientsSummary,
                                  isAsteric: false,
                                  onChangeField: (value) {
                                    updateReferralPatient(
                                        context: context,
                                        patientId: patientId,
                                        isUpdatePatiendData: true,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        contactNo: patientsController.text,
                                        summary: patientsSummary.text,
                                        zipCode: zipCodeController.text,
                                        serviceId: controller.data!.fkSrvId,
                                        disciplineIds: desciplineintList,
                                        insuranceId: patientInsuranceId);
                                  },
                                  keyboardType: TextInputType.text,
                                  text: "Patient Summary"),
                            ),
                            const SizedBox(width: AppSize.s30),
                            Expanded(
                                child:
                                    Container(height: 30,)),
                            const SizedBox(width: AppSize.s30),
                            Expanded(
                                child:
                                    Container(height: 30, )),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s50),

                  // ── Insurance ─────────────────────────────────────────
                  BlueBGHeadConst(
                    HeadText: "Insurance",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s20),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            final diagnosisProvider =
                                Provider.of<DiagnosisProvider>(context);
                            final selectedType = diagnosisProvider
                                .getSelectedTypeForInt(patientId);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 15),
                                    EyePageRadioButton(
                                      value: 'Insurance',
                                      groupValue: selectedType,
                                      onChanged: (value) async {
                                        await updateReferralPatientselfpay(
                                            context: context,
                                            patientId: patientId,
                                            isselfpay: false);
                                        setState(() {
                                          diagnosisProvider
                                              .setSelectedTypeForInt(
                                                  patientId, value!);
                                          selectedRptiId = 0;
                                        });
                                      },
                                      title: 'Insurance',
                                    ),
                                    const SizedBox(width: 110),
                                    EyePageRadioButton(
                                      value: 'Self Pay',
                                      groupValue: selectedType,
                                      onChanged: (value) async {
                                        setState(() {
                                          diagnosisProvider
                                              .setSelectedTypeForInt(
                                                  patientId, value!);
                                          selectedRptiId = 0;
                                        });
                                        if (value == 'Self Pay') {
                                          await updateReferralPatientselfpay(
                                              context: context,
                                              patientId: patientId,
                                              isselfpay: true);
                                        }
                                      },
                                      title: 'Self Pay',
                                    ),
                                  ],
                                ),
                                Opacity(
                                  opacity:
                                      selectedType == 'Self Pay' ? 0.2 : 0.9,
                                  child: IgnorePointer(
                                    ignoring: selectedType == 'Self Pay',
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, top: 6),
                                      child: Text('Mark as Primary',
                                          style:
                                              AllPopupHeadings.customTextStyle(
                                                  context)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Opacity(
                                  opacity:
                                      selectedType == 'Self Pay' ? 0.2 : 0.9,
                                  child: IgnorePointer(
                                    ignoring: selectedType == 'Self Pay',
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          controller.data!.insurance.length,
                                      itemBuilder: (context, index) {
                                        policy = TextEditingController(
                                            text: controller
                                                .data!.insurance[index].policy);
                                        provider = TextEditingController(
                                            text: controller
                                                .data!
                                                .insurance[index]
                                                .insuranceProvider);
                                        plan = TextEditingController(
                                            text: controller
                                                .data!
                                                .insurance[index]
                                                .insurancePlan);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Insurance  #${index + 1}',
                                                style: TextStyle(
                                                    fontSize: FontSize.s14,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        ColorManager.mediumgrey,
                                                    decoration:
                                                        TextDecoration.none),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      child: Checkbox(
                                                        splashRadius: 0,
                                                        checkColor:
                                                            ColorManager.white,
                                                        activeColor:
                                                            ColorManager
                                                                .blueprime,
                                                        side: BorderSide(
                                                            color: ColorManager
                                                                .blueprime,
                                                            width: 2),
                                                        value: selectedRptiId ==
                                                                controller
                                                                    .data!
                                                                    .insurance[
                                                                        index]
                                                                    .rptiId ||
                                                            (selectedRptiId ==
                                                                    null &&
                                                                controller.data!
                                                                        .fkRptiId ==
                                                                    controller
                                                                        .data!
                                                                        .insurance[
                                                                            index]
                                                                        .rptiId),
                                                        onChanged: (bool?
                                                            value) async {
                                                          final currentId =
                                                              controller
                                                                  .data!
                                                                  .insurance[
                                                                      index]
                                                                  .rptiId;
                                                          if (value == true &&
                                                              selectedRptiId !=
                                                                  currentId) {
                                                            await updateReferralPatientInsuranceRpti(
                                                                context:
                                                                    context,
                                                                patientId:
                                                                    patientId,
                                                                fkrptiID:
                                                                    currentId);
                                                            setState(() =>
                                                                selectedRptiId =
                                                                    currentId);
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Expanded(
                                                      flex: 2,
                                                      child: SMTextFConst(
                                                          readOnly: true,
                                                          controller: policy,
                                                          isAsteric: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          text: "Policy #")),
                                                  Expanded(child: Container()),
                                                  Expanded(
                                                      flex: 2,
                                                      child: SMTextFConst(
                                                          controller: provider,
                                                          readOnly: true,
                                                          isAsteric: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          textColor:
                                                              ColorManager
                                                                  .blueprime,
                                                          text:
                                                              "Insurance Provider :")),
                                                  Expanded(child: Container()),
                                                  Expanded(
                                                      flex: 2,
                                                      child: SMTextFConst(
                                                          controller: plan,
                                                          readOnly: true,
                                                          isAsteric: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          textColor:
                                                              ColorManager
                                                                  .blueprime,
                                                          text:
                                                              "Insurance Plan :")),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text("Eligibility:",
                                                            style: AllPopupHeadings
                                                                .customTextStyle(
                                                                    context)),
                                                        const SizedBox(
                                                            height: 12),
                                                        Container(
                                                          height: 30,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 45,
                                                                  right: 20),
                                                          child: Text(
                                                            controller
                                                                        .data!
                                                                        .insurance[
                                                                            index]
                                                                        .eligibility ==
                                                                    false
                                                                ? "Not all visit\ncovered"
                                                                : "Eligibility",
                                                            style: TextStyle(
                                                                fontSize: FontSize
                                                                    .s12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: controller
                                                                            .data!
                                                                            .insurance[
                                                                                index]
                                                                            .eligibility ==
                                                                        false
                                                                    ? ColorManager
                                                                        .incidentskinSM
                                                                    : ColorManager
                                                                        .greenDark),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: controller
                                                                  .data!
                                                                  .insurance[
                                                                      index]
                                                                  .eligibility ==
                                                              false
                                                          ? ColorManager
                                                              .incidentskinSM
                                                          : ColorManager
                                                              .greenDark,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                    ),
                                                    child: Center(
                                                        child: Text("A",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    FontSize
                                                                        .s12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    ColorManager
                                                                        .white))),
                                                  ),
                                                  const SizedBox(width: 30),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      children: [
                                                        CustomElevatedButton(
                                                            width: AppSize.s130,
                                                            height: AppSize.s30,
                                                            text:
                                                                "Check Eligibility",
                                                            color: ColorManager
                                                                .blueprime,
                                                            onPressed: () {}),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          "Last checked at: ${controller.data!.insurance[index].lastCheckedTime == null || controller.data!.insurance[index].lastCheckedTime == "null" ? "00" : controller.data!.insurance[index].lastCheckedTime} AM",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  FontSize.s12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: ColorManager
                                                                  .mediumgrey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              const Divider(
                                                  thickness: 1, height: 30),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s20),

                  // ── Diagnosis ─────────────────────────────────────────
                  BlueBGHeadConst(
                    HeadText: "Diagnosis",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s10),
                        StreamBuilder<List<PatientDiagnosisWithIdData>>(
                          stream: _streamDignosis.stream,
                          builder: (context, snapshotDiagnosis) {
                            getPatientDiagnosisData(
                                    context: context, ptId: patientId)
                                .then((data) => _streamDignosis.add(data))
                                .catchError((error) {});
                            if (snapshotDiagnosis.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      color: ColorManager.blueprime));
                            }
                            if (snapshotDiagnosis.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 76),
                                  child: Text(
                                      AppStringSMModule.patientDiagnosisNoData,
                                      style: AllNoDataAvailable.customTextStyle(
                                          context)),
                                ),
                              );
                            }
                            if (snapshotDiagnosis.hasData) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshotDiagnosis.data!.length,
                                itemBuilder: (context, index) {
                                  possible = TextEditingController(
                                      text: snapshotDiagnosis
                                          .data![index].dgnName);
                                  icd = TextEditingController(
                                      text: snapshotDiagnosis
                                          .data![index].dgnCode);
                                  pdgm = TextEditingController(
                                      text: snapshotDiagnosis.data![index].pdgm
                                          ? 'YES'
                                          : 'NO');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                height: 90,
                                                width: 5,
                                                color: snapshotDiagnosis
                                                            .data![index]
                                                            .colorId ==
                                                        0
                                                    ? ColorManager.red
                                                    : controller
                                                                .data!
                                                                .patientDiagnoses[
                                                                    index]
                                                                .color ==
                                                            1
                                                        ? ColorManager.greenDark
                                                        : Colors.white),
                                            const SizedBox(width: AppSize.s30),
                                            Expanded(
                                                child: SMTextFConst(
                                                    controller: possible,
                                                    isAsteric: false,
                                                    enable: false,
                                                    isIcon: false,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    text:
                                                        "Possible Diagnosis")),
                                            const SizedBox(width: AppSize.s60),
                                            Expanded(
                                                child: SMTextFConst(
                                                    controller: icd,
                                                    isAsteric: false,
                                                    isIcon: false,
                                                    enable: false,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    text: "ICD Code")),
                                            const SizedBox(width: AppSize.s60),
                                            Expanded(
                                                child: SMTextFConst(
                                                    controller: pdgm,
                                                    isAsteric: false,
                                                    isIcon: false,
                                                    enable: false,
                                                    textColor: snapshotDiagnosis
                                                                .data![index]
                                                                .colorId ==
                                                            0
                                                        ? ColorManager.red
                                                        : snapshotDiagnosis
                                                                    .data![
                                                                        index]
                                                                    .colorId ==
                                                                1
                                                            ? ColorManager
                                                                .greenDark
                                                            : Colors.black,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    text: "PDGM - Acceptable")),
                                            const SizedBox(width: AppSize.s30),
                                            Expanded(
                                                child: Container(
                                                    height: 30,
                                                    width: AppSize.s354)),
                                            const SizedBox(width: AppSize.s30),
                                            Expanded(
                                                child: Container(
                                                    height: 30,
                                                    width: AppSize.s354)),
                                          ],
                                        ),
                                        Divider(
                                            color: ColorManager
                                                .containerBorderGrey,
                                            thickness: 1,
                                            height: 2),
                                        const SizedBox(height: AppSize.s30),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Offstage();
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: AppSize.s30,
                              child: CustomIconButton(
                                color: ColorManager.blueprime,
                                icon: Icons.add,
                                textWeight: FontWeight.w700,
                                textSize: FontSize.s12,
                                text: "Add Diagnosis",
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AddDiagnosisDialog());
                                }, isNotPopUpButton: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s40),

                  // ── Disciplines Ordered ───────────────────────────────
                  BlueBGHeadConst(
                    HeadText: "Disciplines Ordered",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s10),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 25),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Disciplines",
                                                style: TextStyle(
                                                    fontSize: FontSize.s14,
                                                    fontWeight: FontWeight.w700,
                                                    color: ColorManager
                                                        .mediumgrey)),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: List.generate(
                                                  employeeClinicalData.length,
                                                  (index) {
                                                bool isCheckedValue =
                                                    desciplineModel.contains(
                                                        employeeClinicalData[
                                                                index]
                                                            .empType);
                                                return buildCheckbox(
                                                  employeeClinicalData[index]
                                                      .empType,
                                                  isCheckedValue,
                                                  (value) {
                                                    setState(() {
                                                      if (value!) {
                                                        desciplineModel.add(
                                                            employeeClinicalData[
                                                                    index]
                                                                .empType);
                                                        desciplineintList.add(
                                                            employeeClinicalData[
                                                                    index]
                                                                .emptypeId);
                                                        desciplineModelAbbrivation.add(
                                                            employeeClinicalData[
                                                                    index]
                                                                .abbreviation);
                                                        desciplineModelAbbrivationColor
                                                            .add(
                                                                employeeClinicalData[
                                                                        index]
                                                                    .color);
                                                        updateReferralPatientdisciplain(
                                                            context: context,
                                                            patientId:
                                                                patientId,
                                                            disciplineIds:
                                                                desciplineintList);
                                                      } else {
                                                        desciplineModel.remove(
                                                            employeeClinicalData[
                                                                    index]
                                                                .empType);
                                                        desciplineintList.remove(
                                                            employeeClinicalData[
                                                                    index]
                                                                .emptypeId);
                                                        desciplineModelAbbrivation
                                                            .remove(
                                                                employeeClinicalData[
                                                                        index]
                                                                    .abbreviation);
                                                        desciplineModelAbbrivationColor
                                                            .remove(
                                                                employeeClinicalData[
                                                                        index]
                                                                    .color);
                                                        updateReferralPatientdisciplain(
                                                            context: context,
                                                            patientId:
                                                                patientId,
                                                            disciplineIds:
                                                                desciplineintList);
                                                      }
                                                    });
                                                  },
                                                  desciplineModel,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                                "Distance from Patient's Home",
                                                style: CustomTextStylesCommon
                                                    .commonStyle(
                                                        color: ColorManager
                                                            .mediumgrey,
                                                        fontSize: FontSize.s12,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          ),
                                          StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            return Container(
                                              width: 600,
                                              child: SliderTheme(
                                                data: const SliderThemeData(
                                                    thumbShape:
                                                        RoundSliderThumbShape(
                                                            enabledThumbRadius:
                                                                12)),
                                                child: Slider(
                                                  value: _sliderValue,
                                                  min: 0,
                                                  max: 200,
                                                  divisions: 4,
                                                  onChanged: (value) {
                                                    setState(() =>
                                                        _sliderValue = value);
                                                  },
                                                ),
                                              ),
                                            );
                                          }),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: List.generate(
                                                  5,
                                                  (index) =>
                                                      Text("${index * 50}")),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text("Available Clinicians",
                                                style: CustomTextStylesCommon
                                                    .commonStyle(
                                                        color: ColorManager
                                                            .mediumgrey,
                                                        fontSize: FontSize.s12,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Wrap(
                                              spacing: 20,
                                              runSpacing: 10,
                                              children: List.generate(
                                                  desciplineModelAbbrivation
                                                      .length, (index) {
                                                var hexColor =
                                                    desciplineModelAbbrivationColor[
                                                            index]
                                                        .replaceAll("#", "");
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.25),
                                                              spreadRadius: 0,
                                                              blurRadius: 2.38,
                                                              offset:
                                                                  const Offset(
                                                                      0, 1.19))
                                                        ],
                                                      ),
                                                      child: Chip(
                                                        label: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5.0),
                                                          child: Text(
                                                            desciplineModelAbbrivation[
                                                                index],
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 11),
                                                          ),
                                                        ),
                                                        backgroundColor: Color(
                                                            int.parse(
                                                                '0xFF$hexColor')),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Text("112",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s30),

                  // ── Documents ─────────────────────────────────────────
                  BlueBGHeadConst(
                    HeadText: "Documents",
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSize.s30),

                        // ── Upload Bulk Document ──────────────────────
                        Text(
                          'Upload Bulk Document',
                          style: TextStyle(
                              fontSize: FontSize.s16,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.mediumgrey),
                        ),
                        const SizedBox(height: 8),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DottedBorder(
                              color: const Color(0xFFDBDBDB),
                              strokeWidth: 1,
                              dashPattern: const [6, 3],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              borderPadding: const EdgeInsets.only(right: 0.5),
                              child: Container(
                                width: double.infinity,
                                height: 80,
                                alignment: Alignment.center,
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [
                                        // 'svg',
                                        // 'png',
                                        // 'jpg',
                                        // 'gif',
                                        'pdf'
                                      ],
                                    );
                                    final fileSize = result?.files.first.size;
                                    final isAbove20MB = fileSize != null &&
                                        fileSize > (20 * 1024 * 1024);
                                    if (isAbove20MB) {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const AddErrorPopup(
                                                  message:
                                                      'File is too large!'));
                                      return;
                                    }
                                    if (result != null) {
                                      setState(() => selectedFileName =
                                          result.files.single.name);
                                      ApiData apiData =
                                          await postReferralPatientDocuments(
                                        context: context,
                                        fk_pt_id: patientId,
                                        rptd_document_type: FrontendConfigStore
                                            .data!.config.clinicianAttachment,
                                        rptd_content: "",
                                      );
                                      if (apiData.statusCode == 200 ||
                                          apiData.statusCode == 201) {
                                        var uploadPatientDoc =
                                            await uploadPatientReffrelsDocuments(
                                          context: context,
                                          rptd_id: apiData.rptd_id!,
                                          documentFile:
                                              result.files.first.bytes,
                                          documentName: result.files.first.name,
                                        );
                                        if (uploadPatientDoc.success == true) {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  const AddSuccessPopup(
                                                      message:
                                                          'Document Uploaded Successfully'));
                                        }
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: const Color(0xFFE6F1FE)),
                                        child: Center(
                                            child: SvgPicture.asset(
                                                'images/doc_vector.svg',
                                                height: 30,
                                                width: 30)),
                                      ),
                                      const SizedBox(width: 30),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: "Drop your files here or ",
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: "Click to upload",
                                                  style: TextStyle(
                                                      color: ColorManager
                                                          .blueBorder,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text("PDF (max. 20 MB)",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (selectedFileName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("Selected file: $selectedFileName",
                                style: const TextStyle(color: Colors.green)),
                          ),

                        // ── Bulk Documents List ───────────────────────
                        StreamBuilder<List<PatientDocumentsData>>(
                          stream: _streamController.stream,
                          builder: (context, snapshotDoc) {
                            getReffrealsPatientDocuments(
                                    context: context, patientId: patientId)
                                .then((data) => _streamController.add(data))
                                .catchError((error) {});
                            if (snapshotDoc.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                          color: ColorManager.blueprime)));
                            }
                            if (snapshotDoc.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 76),
                                  child: Text(
                                      AppStringSMModule.patientDocNoData,
                                      style: AllNoDataAvailable.customTextStyle(
                                          context)),
                                ),
                              );
                            }
                            if (snapshotDoc.hasData) {
                              return Container(
                                height: 200,
                                child: ScrollConfiguration(
                                  behavior: const ScrollBehavior()
                                      .copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    itemCount: snapshotDoc.data!.length,
                                    itemBuilder: (context, index) {
                                      var fileUrl =
                                          snapshotDoc.data![index].rptd_url;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: AppPadding.p8),
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: AppSize.s5),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              height: AppSize.s65,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal:
                                                            AppPadding.p30),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            downloadFile(context: context,
                                                                fileUrl: fileUrl,
                                                                documentName:snapshotDoc.data![index]
                                                                    .documentName,
                                                                apiPath: DownloadDocumentRepository.getReferralSourcesDocumentByFileName()),
                                                        child: Container(
                                                          width: AppSize.s62,
                                                          height: AppSize.s45,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      AppPadding
                                                                          .p10,
                                                                  vertical:
                                                                      AppPadding
                                                                          .p8),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              border: Border.all(
                                                                  width: 2,
                                                                  color: ColorManager
                                                                      .faintGrey)),
                                                          child: SvgPicture.asset(
                                                              'images/doc_vector.svg'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: AppSize.s10),
                                                      Text(
                                                        snapshotDoc.data![index]
                                                            .documentName,
                                                        style: DocDefineTableData
                                                            .customTextStyle(
                                                                context),
                                                      ),
                                                    ]),
                                                    Row(children: [
                                                      IconButton(
                                                        onPressed: () =>
                                      downloadFile(context: context,
                                      fileUrl: fileUrl,
                                      documentName:snapshotDoc.data![index].documentName,
                                      apiPath: DownloadDocumentRepository.getReferralSourcesDocumentByFileName()),
                                                        icon: Icon(
                                                            Icons
                                                                .print_outlined,
                                                            size: IconSize.I22,
                                                            color:
                                                                IconColorManager
                                                                    .blueprime),
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                      ),
                                                      const SizedBox(
                                                          width: AppSize.s10),
                                                      PdfDownloadButton(
                                                        apiPath: DownloadDocumentRepository.getReferralSourcesDocumentByFileName(),
                                                          apiUrl: snapshotDoc
                                                              .data![index]
                                                              .rptd_url,
                                                          iconsize:
                                                              IconSize.I22,
                                                          documentName:
                                                              snapshotDoc
                                                                  .data![index]
                                                                  .documentName),
                                                      const SizedBox(
                                                          width: AppSize.s10),
                                                      IconButton(
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                                bool
                                                                    _isLoading =
                                                                    false;
                                                                return DeletePopup(
                                                                  loadingDuration:
                                                                      _isLoading,
                                                                  title:
                                                                      'Delete Document',
                                                                  onCancel: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  onDelete:
                                                                      () async {
                                                                    setState(() =>
                                                                        _isLoading =
                                                                            true);
                                                                    try {
                                                                      var response =
                                                                          await deletePatientDocument(
                                                                        context:
                                                                            context,
                                                                        docId: snapshotDoc
                                                                            .data![index]
                                                                            .rptd_id,
                                                                      );
                                                                      if (response.statusCode ==
                                                                              200 ||
                                                                          response.statusCode ==
                                                                              201) {
                                                                        Navigator.pop(
                                                                            context);
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                const DeleteSuccessPopup());
                                                                      }
                                                                    } finally {
                                                                      setState(() =>
                                                                          _isLoading =
                                                                              false);
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        icon: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: IconSize.I24,
                                                            color:
                                                                IconColorManager
                                                                    .red),
                                                      ),
                                                    ]),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),

                        const SizedBox(height: AppSize.s15),

                        // ── Upload Signature ──────────────────────────
                        Text(
                          'Upload Signature',
                          style: TextStyle(
                              fontSize: FontSize.s16,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.mediumgrey),
                        ),
                        const SizedBox(height: 8),
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DottedBorder(
                              color: const Color(0xFFDBDBDB),
                              strokeWidth: 1,
                              dashPattern: const [6, 3],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              borderPadding: const EdgeInsets.only(right: 0.5),
                              child: Container(
                                width: double.infinity,
                                height: 80,
                                alignment: Alignment.center,
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [
                                        // 'svg',
                                        // 'png',
                                        // 'jpg',
                                        // 'gif',
                                        'pdf'
                                      ],
                                    );
                                    final fileSize = result?.files.first.size;
                                    final isAbove20MB = fileSize != null &&
                                        fileSize > (20 * 1024 * 1024);
                                    if (isAbove20MB) {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const AddErrorPopup(
                                                  message:
                                                      'File is too large!'));
                                      return;
                                    }
                                    if (result != null) {
                                      final bytes = result.files.first.bytes;
                                      if (bytes == null) return;
                                      final base64String = base64Encode(bytes);
                                      final docName = result.files.first.name;
                                      setState(() =>
                                          selectedSignatureFileName = docName);
                                      ApiData apiData =
                                          await createAndAttachSignatureFormDocument(
                                        context,
                                        patientId,
                                        base64String,
                                        docName,
                                      );
                                      if (apiData.success) {
                                        final sigData =
                                            await getSignatureFormDocumentsByPatient(
                                                context, patientId);
                                        _streamSignature.add(sigData);
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const AddSuccessPopup(
                                                    message:
                                                        'Signature Uploaded Successfully'));
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AddErrorPopup(
                                                message: apiData.message));
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: const Color(0xFFE6F1FE)),
                                        child: Center(
                                            child: SvgPicture.asset(
                                                'images/sm/sm_refferal/file_sign.svg',
                                                height: 30,
                                                width: 30)),
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        "Click to upload signature",
                                        style: TextStyle(
                                            color: ColorManager.blueBorder,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (selectedSignatureFileName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                "Selected file: $selectedSignatureFileName",
                                style: const TextStyle(color: Colors.green)),
                          ),

                        // ── Signature Documents List ──────────────────
                        StreamBuilder<List<SignatureFormDocumentData>>(
                          stream: _streamSignature.stream,
                          builder: (context, snapshotSig) {
                            getSignatureFormDocumentsByPatient(
                                    context, patientId)
                                .then((data) => _streamSignature.add(data))
                                .catchError((error) {});
                            if (snapshotSig.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                          color: ColorManager.blueprime)));
                            }
                            if (snapshotSig.data == null ||
                                snapshotSig.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Text('No signature documents found',
                                      style: AllNoDataAvailable.customTextStyle(
                                          context)),
                                ),
                              );
                            }
                            return Container(
                              height: 200,
                              child: ScrollConfiguration(
                                behavior: const ScrollBehavior()
                                    .copyWith(scrollbars: false),
                                child: ListView.builder(
                                  itemCount: snapshotSig.data!.length,
                                  itemBuilder: (context, index) {
                                    final sigDoc = snapshotSig.data![index];
                                    final fileUrl = sigDoc.sigDocUrl;
                                    final isImage = [
                                      'jpg',
                                      'jpeg',
                                      'png',
                                      'gif'
                                    ].any((ext) =>
                                        fileUrl.toLowerCase().contains(ext));
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: AppPadding.p8),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: AppSize.s5),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            height: AppSize.s65,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppPadding.p30),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Left — thumbnail + name
                                                  Row(children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          downloadFile(context: context,
                                                              fileUrl: fileUrl,
                                                              documentName:sigDoc.sigDocName,
                                                              apiPath: DownloadDocumentRepository.getReferralSourcesDocumentByFileName()),
                                                      child: Container(
                                                        width: AppSize.s62,
                                                        height: AppSize.s45,
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            AppPadding
                                                                .p10,
                                                            vertical:
                                                            AppPadding
                                                                .p8),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                4),
                                                            border: Border.all(
                                                                width: 2,
                                                                color: ColorManager
                                                                    .faintGrey)),
                                                        child: SvgPicture.asset(
                                                            'images/doc_vector.svg'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: AppSize.s10),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(sigDoc.sigDocName,
                                                            style: DocDefineTableData
                                                                .customTextStyle(
                                                                    context)),

                                                      ],
                                                    ),
                                                  ]),

                                                  // Right — print + download + delete
                                                  Row(children: [
                                                    IconButton(
                                                      onPressed: () =>
                                                          downloadFile(context: context,
                                                              fileUrl: fileUrl,
                                                              documentName:sigDoc.sigDocName,
                                                              apiPath: DownloadDocumentRepository.getReferralSourcesDocumentByFileName()),
                                                      icon: Icon(
                                                          Icons.print_outlined,
                                                          size: IconSize.I22,
                                                          color:
                                                              IconColorManager
                                                                  .blueprime),
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                    ),
                                                    const SizedBox(
                                                        width: AppSize.s10),
                                                    PdfDownloadButton(
                                                      apiPath: DownloadDocumentRepository.getReferralSourcesDocumentByFileName(),
                                                        apiUrl: fileUrl,
                                                        iconsize: IconSize.I22,
                                                        documentName:
                                                            sigDoc.sigDocName),
                                                    const SizedBox(
                                                        width: AppSize.s10),
                                                    // ── Delete ────────
                                                    IconButton(
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              StatefulBuilder(
                                                            builder: (context,
                                                                setState) {
                                                              bool _isLoading =
                                                                  false;
                                                              return DeletePopup(
                                                                loadingDuration:
                                                                    _isLoading,
                                                                title:
                                                                    'Delete Signature',
                                                                onCancel: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                onDelete:
                                                                    () async {
                                                                  setState(() =>
                                                                      _isLoading =
                                                                          true);
                                                                  try {
                                                                    var response =
                                                                        await deleteSignatureFormDocument(
                                                                      context,
                                                                      sigDoc
                                                                          .sigDocId,
                                                                    );
                                                                    if (response.statusCode ==
                                                                            200 ||
                                                                        response.statusCode ==
                                                                            201) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              const DeleteSuccessPopup());
                                                                      // Reload signature list
                                                                      final sigData = await getSignatureFormDocumentsByPatient(
                                                                          context,
                                                                          patientId);
                                                                      _streamSignature
                                                                          .add(
                                                                              sigData);
                                                                    }
                                                                  } finally {
                                                                    setState(() =>
                                                                        _isLoading =
                                                                            false);
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                          Icons.delete_outline,
                                                          size: IconSize.I24,
                                                          color:
                                                              IconColorManager
                                                                  .red),
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
                      ),
                  ),
              ),
          );
        });
      },
    );
  }

  Widget buildCheckbox(String title, bool value, Function(bool?) onChanged,
      List<String> prefillData) {
    return SizedBox(
      width: 170,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Checkbox(
                splashRadius: 0,
                hoverColor: Colors.transparent,
                value: value,
                activeColor: ColorManager.blueprime,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 3,
                  softWrap: true,
                  style: CustomTextStylesCommon.commonStyle(
                      color: ColorManager.mediumgrey,
                      fontSize: FontSize.s12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiagosisList extends StatefulWidget {
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  final List<PatientDiagnosesModel> diagnosisData;
  final Function(int index, PatientDiagnosesModel updatedModel) onChanged;

  const DiagosisList({
    Key? key,
    required this.onRemove,
    required this.index,
    required this.isVisible,
    required this.diagnosisData,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DiagosisListState createState() => _DiagosisListState();
}

class _DiagosisListState extends State<DiagosisList> {
  TextEditingController possible = TextEditingController();
  TextEditingController icd = TextEditingController();
  TextEditingController pdgm = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.diagnosisData.length > widget.index) {
      final data = widget.diagnosisData[widget.index];
      possible.text = data.dgnName;
      icd.text = data.dgnCode;
      pdgm.text = data.rpt_pdgm ? 'YES' : 'NO';
    }
    possible.addListener(_updateModel);
    icd.addListener(_updateModel);
    pdgm.addListener(_updateModel);
  }

  void _updateModel() {
    widget.onChanged(
      widget.index,
      PatientDiagnosesModel(
        rpt_dgn_id: 0,
        dgnName: possible.text,
        dgnCode: icd.text,
        fk_pt_id: 0,
        fk_dgn_id: 0,
        rpt_pdgm: pdgm.text.toUpperCase() == 'YES',
        rpt_isPrimary: false,
        color: 2,
      ),
    );
  }

  @override
  void dispose() {
    possible.dispose();
    icd.dispose();
    pdgm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = widget.diagnosisData[widget.index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 90,
                width: 5,
                color: diagnosis.color == 0
                    ? ColorManager.red
                    : diagnosis.color == 1
                        ? ColorManager.greenDark
                        : Colors.white,
              ),
              const SizedBox(width: AppSize.s30),
              Expanded(
                  child: SMTextFConst(
                      controller: possible,
                      isAsteric: false,
                      isIcon: true,
                      keyboardType: TextInputType.text,
                      text: "Possible Diagnosis")),
              const SizedBox(width: AppSize.s60),
              Expanded(
                  child: SMTextFConst(
                      controller: icd,
                      isAsteric: false,
                      isIcon: true,
                      keyboardType: TextInputType.text,
                      text: "ICD Code")),
              const SizedBox(width: AppSize.s60),
              Expanded(
                  child: SMTextFConst(
                      controller: pdgm,
                      isAsteric: false,
                      isIcon: false,
                      textColor: diagnosis.color == 0
                          ? ColorManager.red
                          : diagnosis.color == 1
                              ? ColorManager.greenDark
                              : Colors.black,
                      keyboardType: TextInputType.text,
                      text: "PDGM - Acceptable")),
              const SizedBox(width: AppSize.s30),
              Expanded(child: Container(height: 30, width: AppSize.s354)),
              const SizedBox(width: AppSize.s30),
              Expanded(child: Container(height: 30, width: AppSize.s354)),
            ],
          ),
          Divider(
              color: ColorManager.containerBorderGrey, thickness: 1, height: 2),
          const SizedBox(height: AppSize.s30),
        ],
      ),
    );
  }
}
