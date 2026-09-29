import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/patient_insurance_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';

class EMRPrimaryScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback onEditScreen;
  final VoidCallback onSave;
  final VoidCallback isIButtonPressed;
  final VoidCallback onSkip;

  EMRPrimaryScreen({
    super.key,
    required this.patientId,
    required this.onSave,
    required this.onEditScreen,
    required this.isIButtonPressed,
    required this.onSkip,
  });

  @override
  State<EMRPrimaryScreen> createState() => _EMRPrimaryScreenState();
}

class _EMRPrimaryScreenState extends State<EMRPrimaryScreen> {
  late Future<List<PatientInsuranceInfoData>> _insuranceFuture;
  bool _hasInitializedSelfPay = false;

  // Replaced the old StreamController/StreamBuilder pattern with a plain
  // Future + FutureBuilder. The broadcast StreamController had a race: if
  // the API resolved and pushed its one-and-only event before the
  // StreamBuilder had mounted and subscribed (which could happen because it
  // was nested under another FutureBuilder still loading), that event was
  // silently dropped and the loader spun forever. A Future has no such
  // "no listener yet" failure mode — FutureBuilder always resolves once the
  // Future completes, no matter when it was built.
  late Future<List<PatientInsuranceDocumentData>> _insuranceDocFuture;

  void _reloadInsuranceDoc() {
    setState(() {
      _insuranceDocFuture = getPatientInsuranceDocuments(
        context: context,
        patientId: widget.patientId,
        isPrimary: true,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _insuranceFuture = getPatientInsuranceinfo(
      context: context,
      ptId: widget.patientId,
    );
    _insuranceDocFuture = getPatientInsuranceDocuments(
      context: context,
      patientId: widget.patientId,
      isPrimary: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  var data;

  TextEditingController pharmaSelectDB = TextEditingController();
  TextEditingController pharmaName = TextEditingController();
  TextEditingController pharmaphone = TextEditingController();
  TextEditingController pharmaType = TextEditingController();
  TextEditingController pharmaCategory = TextEditingController();
  TextEditingController pharmaSuitApt = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pharmacyaddress = TextEditingController();
  TextEditingController pharmacyzipcode = TextEditingController();
  TextEditingController pharmaPolicyHicNo = TextEditingController();
  TextEditingController pharmaGrpName = TextEditingController();
  TextEditingController pharmaGrpNo = TextEditingController();
  TextEditingController pharmaEmail = TextEditingController();
  TextEditingController pharmaAuth = TextEditingController();
  TextEditingController pharmaEftDateForm = TextEditingController();
  TextEditingController pharmaEftDateFormTo = TextEditingController();
  TextEditingController pharmacycontactsecond = TextEditingController();
  TextEditingController dummyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String? statustype;
    String? dmeSupplies;
    String? pharmacydd;
    String? pharmacystate;
    String? pharmacycity;
    bool _isLoading = false;
    bool fileAbove20Mb = false;

    return FutureBuilder<List<PatientInsuranceInfoData>>(
      future: _insuranceFuture,
      builder: (context, snapshot) {
        // ── Loading ────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            ),
          );
        }

        // ── Error ──────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'Failed to load insurance data.',
                style: AllNoDataAvailable.customTextStyle(context),
              ),
            ),
          );
        }

        // Guard against empty list BEFORE accessing snapshot.data![0].
        final bool hasData =
            snapshot.hasData && snapshot.data!.isNotEmpty;

        // ── One-time self-pay init ─────────────────────────────────────
        if (hasData && !_hasInitializedSelfPay) {
          final isSelfPayFromApi = snapshot.data![0].isSelfPay;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final intakeProvider =
            Provider.of<SmIntakeProviderManager>(context, listen: false);
            intakeProvider.setSelfPay(isSelfPayFromApi);
          });
          _hasInitializedSelfPay = true;
        }

        // ── Helper: safe accessor ──────────────────────────────────────
        final d = hasData ? snapshot.data![0] : null;

        return Consumer<SmIntakeProviderManager>(
          builder: (context, providerstate, child) {
            if (d != null) {
              if (pharmaSelectDB.text.isEmpty)
                pharmaSelectDB =
                    TextEditingController(text: d.policy.rptiPolicy);
              if (pharmaName.text.isEmpty)
                pharmaName = TextEditingController(
                    text: d.insuranceProvider.rptiInsuranceProvider);
              if (pharmaType.text.isEmpty)
                pharmaType = TextEditingController(
                    text: d.insurancePlan.rptiInsurancePlan);
              if (pharmaCategory.text.isEmpty)
                pharmaCategory =
                    TextEditingController(text: d.category.rptiCategory);
              if (pharmacyaddress.text.isEmpty)
                pharmacyaddress =
                    TextEditingController(text: d.street.rptiStreet);
              if (pharmaSuitApt.text.isEmpty)
                pharmaSuitApt =
                    TextEditingController(text: d.suite.rptiSuite);
              if (city.text.isEmpty)
                city = TextEditingController(text: d.city.rptiCity);
              if (state.text.isEmpty)
                state = TextEditingController(text: d.state.rptiState);
              if (pharmacyzipcode.text.isEmpty)
                pharmacyzipcode =
                    TextEditingController(text: d.zipcode.rptiZipcode);
              if (pharmaphone.text.isEmpty)
                pharmaphone =
                    TextEditingController(text: d.contact.rptiContact);
              pharmaAuth = TextEditingController(
                  text: d.rptiAuthorization ? 'NOT REQUIRED' : 'REQUIRED');
              if (pharmaEftDateForm.text.isEmpty)
                pharmaEftDateForm =
                    TextEditingController(text: d.rptiEffectiveFrom);
              if (pharmaEftDateFormTo.text.isEmpty)
                pharmaEftDateFormTo =
                    TextEditingController(text: d.rptiEffectiveTo);
              if (pharmaPolicyHicNo.text.isEmpty)
                pharmaPolicyHicNo =
                    TextEditingController(text: d.policy.rptiPolicy);
              if (pharmaGrpNo.text.isEmpty)
                pharmaGrpNo = TextEditingController(
                    text: d.groupNumber.rptiGroupNumber.toString());
              if (pharmaGrpName.text.isEmpty)
                pharmaGrpName =
                    TextEditingController(text: d.groupName.rptiGroupName);
              if (pharmaEmail.text.isEmpty)
                pharmaEmail =
                    TextEditingController(text: d.email.rptiEmail);
              statustype = d.rptiVerified ? 'Yes' : 'No';
            }

            // ── Empty-state UI ─────────────────────────────────────────
            if (!hasData) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Text(
                    'No insurance data available!',
                    style: AllNoDataAvailable.customTextStyle(context),
                  ),
                ),
              );
            }

            // ── Main UI ────────────────────────────────────────────────
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Review and confirm the data pulled is correct ',
                          style: SMItalicTextConst.customTextStyle(context),
                        )
                      ],
                    ),
                  ),
                  providerstate.isLeftSidebarOpen
                      ? InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: widget.isIButtonPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back,
                              size: IconSize.I16,
                              color: ColorManager.mediumgrey),
                          const SizedBox(width: 5),
                          Text(
                            'Go Back',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : const Offstage(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Self Pay',
                          style: DocumentTypeDataStyle.customTextStyle(context),
                        ),
                        Checkbox(
                          splashRadius: 0,
                          checkColor: ColorManager.white,
                          activeColor: ColorManager.blueprime,
                          side: BorderSide(
                              color: ColorManager.blueprime, width: 2),
                          value: providerstate.isSelfPay,
                          onChanged: (bool? value) async {
                            final newValue = value ?? false;
                            context
                                .read<SmIntakeProviderManager>()
                                .setSelfPay(newValue);
                            await updateReferralPatientselfpay(
                              context: context,
                              patientId: widget.patientId,
                              isselfpay: newValue,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BlueBGHeadConst(
                      HeadText: "Policy Details",
                      body: Opacity(
                        opacity: providerstate.isSelfPay ? 0.2 : 1.0,
                        child: IgnorePointer(
                          ignoring: providerstate.isSelfPay,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return IntakeFlowContainerConst(
                                height: providerstate.isContactTrue
                                    ? AppSize.s560
                                    : AppSize.s410,
                                containerPadding: providerstate.isContactTrue
                                    ? const EdgeInsets.only(
                                    left: AppPadding.p20,
                                    top: AppPadding.p30,
                                    bottom: AppPadding.p30)
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    providerstate.isContactTrue
                                        ? Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          labelText: 'Policy Number',
                                          isIconVisible: d!.policy
                                              .rptiPolicyLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .policy
                                                  .rptiPolicyLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.policy.rptiPolicyPgNo,
                                              isLinkeOpen:
                                              d.policy.rptiPolicyLink,
                                            );
                                          },
                                          controller: pharmaSelectDB,
                                          enable: true,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d
                                              .insuranceProvider
                                              .rptiInsuranceProviderLink
                                              .isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .insuranceProvider
                                                  .rptiInsuranceProviderLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d
                                                  .insuranceProvider
                                                  .rptiInsuranceProviderPgNo,
                                              isLinkeOpen: d
                                                  .insuranceProvider
                                                  .rptiInsuranceProviderLink,
                                            );
                                          },
                                          controller: pharmaName,
                                          labelText: 'Name*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d
                                              .insurancePlan
                                              .rptiInsurancePlanLink
                                              .isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .insurancePlan
                                                  .rptiInsurancePlanLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.insurancePlan
                                                  .rptiInsurancePlanPgNo,
                                              isLinkeOpen: d.insurancePlan
                                                  .rptiInsurancePlanLink,
                                            );
                                          },
                                          controller: pharmaType,
                                          labelText: 'Type*',
                                        ),
                                      ),
                                    ])
                                        : Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d!.policy
                                              .rptiPolicyLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .policy
                                                  .rptiPolicyLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.policy.rptiPolicyPgNo,
                                              isLinkeOpen:
                                              d.policy.rptiPolicyLink,
                                            );
                                          },
                                          labelText: 'Policy Number',
                                          controller: pharmaSelectDB,
                                          enable: true,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d
                                              .insuranceProvider
                                              .rptiInsuranceProviderLink
                                              .isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .insuranceProvider
                                                  .rptiInsuranceProviderLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d
                                                  .insuranceProvider
                                                  .rptiInsuranceProviderPgNo,
                                              isLinkeOpen: d
                                                  .insuranceProvider
                                                  .rptiInsuranceProviderLink,
                                            );
                                          },
                                          controller: pharmaName,
                                          labelText: 'Name*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d
                                              .insurancePlan
                                              .rptiInsurancePlanLink
                                              .isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .insurancePlan
                                                  .rptiInsurancePlanLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.insurancePlan
                                                  .rptiInsurancePlanPgNo,
                                              isLinkeOpen: d.insurancePlan
                                                  .rptiInsurancePlanLink,
                                            );
                                          },
                                          controller: pharmaType,
                                          labelText: 'Type*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.category
                                              .rptiCategoryLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .category
                                                  .rptiCategoryLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.category
                                                  .rptiCategoryPgNo,
                                              isLinkeOpen: d
                                                  .category
                                                  .rptiCategoryLink,
                                            );
                                          },
                                          controller: pharmaCategory,
                                          labelText: 'Category',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      const Flexible(child: SizedBox()),
                                    ]),
                                    const SizedBox(height: AppSize.s16),
                                    providerstate.isContactTrue
                                        ? Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d!.category
                                              .rptiCategoryLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .category
                                                  .rptiCategoryLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.category
                                                  .rptiCategoryPgNo,
                                              isLinkeOpen: d
                                                  .category
                                                  .rptiCategoryLink,
                                            );
                                          },
                                          controller: pharmaCategory,
                                          labelText: 'Category',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconClicked: true,
                                          iconClickedPress: () =>
                                              providerstate
                                                  .openMapInsurancePrimeScreen(
                                                  context: context),
                                          isIconVisible: d.street
                                              .rptiStreetLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .street
                                                  .rptiStreetLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.street.rptiStreetPgNo,
                                              isLinkeOpen:
                                              d.street.rptiStreetLink,
                                            );
                                          },
                                          controller: providerstate
                                              .ctlrStreetInsurancePrimeProvider
                                              .text
                                              .isEmpty
                                              ? pharmacyaddress
                                              : providerstate
                                              .ctlrStreetInsurancePrimeProvider,
                                          icon: Icon(
                                              Icons.location_on_outlined,
                                              color: ColorManager
                                                  .blueprime,
                                              size: IconSize.I18),
                                          labelText: 'Street*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.suite
                                              .rptiSuiteLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(
                                                  d.suite.rptiSuiteLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.suite.rptiSuitePgNo,
                                              isLinkeOpen:
                                              d.suite.rptiSuiteLink,
                                            );
                                          },
                                          controller: pharmaSuitApt,
                                          labelText: 'Suite/Apt#',
                                        ),
                                      ),
                                    ])
                                        : Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconClicked: true,
                                          iconClickedPress: () =>
                                              providerstate
                                                  .openMapInsurancePrimeScreen(
                                                  context: context),
                                          controller: providerstate
                                              .ctlrStreetInsurancePrimeProvider
                                              .text
                                              .isEmpty
                                              ? pharmacyaddress
                                              : providerstate
                                              .ctlrStreetInsurancePrimeProvider,
                                          isIconVisible: d!.street
                                              .rptiStreetLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .street
                                                  .rptiStreetLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.street.rptiStreetPgNo,
                                              isLinkeOpen:
                                              d.street.rptiStreetLink,
                                            );
                                          },
                                          icon: Icon(
                                              Icons.location_on_outlined,
                                              color: ColorManager
                                                  .blueprime,
                                              size: IconSize.I18),
                                          labelText: 'Street*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.suite
                                              .rptiSuiteLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(
                                                  d.suite.rptiSuiteLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.suite.rptiSuitePgNo,
                                              isLinkeOpen:
                                              d.suite.rptiSuiteLink,
                                            );
                                          },
                                          controller: pharmaSuitApt,
                                          labelText: 'Suite/Apt#',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.city
                                              .rptiCityLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(
                                                  d.city.rptiCityLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.city.rptiCityPgNo,
                                              isLinkeOpen:
                                              d.city.rptiCityLink,
                                            );
                                          },
                                          controller: providerstate
                                              .ctlrCityInsurancePrimeProvider
                                              .text
                                              .isEmpty
                                              ? city
                                              : providerstate
                                              .ctlrCityInsurancePrimeProvider,
                                          labelText: 'City*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.state
                                              .rptiStateLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .state
                                                  .rptiStateLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.state.rptiStatePgNo,
                                              isLinkeOpen:
                                              d.state.rptiStateLink,
                                            );
                                          },
                                          labelText: 'State*',
                                          controller: providerstate
                                              .ctlrStateInsurancePrimeProvider
                                              .text
                                              .isEmpty
                                              ? state
                                              : providerstate
                                              .ctlrStateInsurancePrimeProvider,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.zipcode
                                              .rptiZipcodeLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .zipcode
                                                  .rptiZipcodeLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d
                                                  .zipcode.rptiZipcodePgNo,
                                              isLinkeOpen: d
                                                  .zipcode.rptiZipcodeLink,
                                            );
                                          },
                                          controller: pharmacyzipcode,
                                          allowSSNBR: true,
                                          labelText: 'Zip Code*',
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: AppSize.s16),
                                    providerstate.isContactTrue
                                        ? Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d!.city
                                              .rptiCityLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(
                                                  d.city.rptiCityLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.city.rptiCityPgNo,
                                              isLinkeOpen:
                                              d.city.rptiCityLink,
                                            );
                                          },
                                          controller: providerstate
                                              .ctlrCityInsurancePrimeProvider
                                              .text
                                              .isEmpty
                                              ? city
                                              : providerstate
                                              .ctlrCityInsurancePrimeProvider,
                                          labelText: 'City*',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.state
                                              .rptiStateLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .state
                                                  .rptiStateLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.state.rptiStatePgNo,
                                              isLinkeOpen:
                                              d.state.rptiStateLink,
                                            );
                                          },
                                          labelText: 'State*',
                                          controller: state,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.zipcode
                                              .rptiZipcodeLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .zipcode
                                                  .rptiZipcodeLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d
                                                  .zipcode.rptiZipcodePgNo,
                                              isLinkeOpen: d
                                                  .zipcode.rptiZipcodeLink,
                                            );
                                          },
                                          controller: pharmacyzipcode,
                                          allowSSNBR: true,
                                          labelText: 'Zip Code*',
                                        ),
                                      ),
                                    ])
                                        : Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d!.contact
                                              .rptiContactLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .contact
                                                  .rptiContactLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d
                                                  .contact.rptiContactPgNo,
                                              isLinkeOpen: d
                                                  .contact.rptiContactLink,
                                            );
                                          },
                                          controller: pharmaphone,
                                          phoneField: true,
                                          labelText: 'Phone Number',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          textColor:
                                          const Color(0xff04BF00),
                                          controller: pharmaAuth,
                                          labelText: 'Auth Status',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          controller: pharmaEftDateForm,
                                          labelText: 'Effective From',
                                          showDatePicker: true,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          controller: pharmaEftDateFormTo,
                                          labelText: 'Effective to',
                                          showDatePicker: true,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          labelText: 'Eligibility Status',
                                          controller: TextEditingController(
                                              text: statustype),
                                          enable: true,
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: AppSize.s16),
                                    providerstate.isContactTrue
                                        ? Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d!.contact
                                              .rptiContactLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .contact
                                                  .rptiContactLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d
                                                  .contact.rptiContactPgNo,
                                              isLinkeOpen: d
                                                  .contact.rptiContactLink,
                                            );
                                          },
                                          controller: pharmaphone,
                                          phoneField: true,
                                          labelText: 'Phone Number',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          textColor:
                                          const Color(0xff04BF00),
                                          controller: pharmaAuth,
                                          labelText: 'Auth Status',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          controller: pharmaEftDateForm,
                                          labelText: 'Effective From',
                                          showDatePicker: true,
                                        ),
                                      ),
                                    ])
                                        : Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Flexible(
                                            child: SchedularTextField(
                                              controller:
                                              pharmaPolicyHicNo,
                                              isIconVisible: d!
                                                  .policy
                                                  .rptiPolicyLink
                                                  .isEmpty,
                                              isIClicked: () {
                                                widget
                                                    .isIButtonPressed();
                                                providerstate
                                                    .setLinkAndPageNumber(
                                                  selectLink: Uri.parse(
                                                      d
                                                          .policy
                                                          .rptiPolicyLink)
                                                      .pathSegments
                                                      .last,
                                                  pageNo: d.policy
                                                      .rptiPolicyPgNo,
                                                  isLinkeOpen: d.policy
                                                      .rptiPolicyLink,
                                                );
                                              },
                                              enable: true,
                                              labelText:
                                              'Policy/HIC Number',
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSize.s35),
                                          Flexible(
                                            child: SchedularTextField(
                                              hintText: "###-###-####",
                                              isIconVisible: d
                                                  .groupNumber
                                                  .rptiGroupNumberLink
                                                  .isEmpty,
                                              isIClicked: () {
                                                widget
                                                    .isIButtonPressed();
                                                providerstate
                                                    .setLinkAndPageNumber(
                                                  selectLink: Uri.parse(
                                                      d
                                                          .groupNumber
                                                          .rptiGroupNumberLink)
                                                      .pathSegments
                                                      .last,
                                                  pageNo: d.groupNumber
                                                      .rptiGroupNumberPgNo,
                                                  isLinkeOpen: d
                                                      .groupNumber
                                                      .rptiGroupNumberLink,
                                                );
                                              },
                                              controller: pharmaGrpNo,
                                              onlyAllowNumbers: true,
                                              labelText: 'Group Number',
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSize.s35),
                                          Flexible(
                                            child: SchedularTextField(
                                              isIconVisible: d
                                                  .groupName
                                                  .rptiGroupNameLink
                                                  .isEmpty,
                                              isIClicked: () {
                                                widget
                                                    .isIButtonPressed();
                                                providerstate
                                                    .setLinkAndPageNumber(
                                                  selectLink: Uri.parse(
                                                      d
                                                          .groupName
                                                          .rptiGroupNameLink)
                                                      .pathSegments
                                                      .last,
                                                  pageNo: d.groupName
                                                      .rptiGroupNamePgNo,
                                                  isLinkeOpen: d
                                                      .groupName
                                                      .rptiGroupNameLink,
                                                );
                                              },
                                              controller: pharmaGrpName,
                                              labelText: 'Group Name',
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSize.s35),
                                          Flexible(
                                            child: SchedularTextField(
                                              isIconVisible: d.email
                                                  .rptiEmailLink.isEmpty,
                                              isIClicked: () {
                                                widget
                                                    .isIButtonPressed();
                                                providerstate
                                                    .setLinkAndPageNumber(
                                                  selectLink: Uri.parse(
                                                      d
                                                          .email
                                                          .rptiEmailLink)
                                                      .pathSegments
                                                      .last,
                                                  pageNo: d
                                                      .email.rptiEmailPgNo,
                                                  isLinkeOpen: d
                                                      .email.rptiEmailLink,
                                                );
                                              },
                                              controller: pharmaEmail,
                                              labelText: 'Primary Email',
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSize.s35),
                                          const Flexible(
                                              child: SizedBox()),
                                        ]),
                                        const SizedBox(
                                            height: AppSize.s16),
                                        SizedBox(
                                          width: 200,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      'Insurance Verified',
                                                      style: providerstate
                                                          .isContactTrue
                                                          ? SMTextfieldResponsiveHeadings
                                                          .customTextStyle(
                                                          context)
                                                          : SMTextfieldHeadings
                                                          .customTextStyle(
                                                          context),
                                                    ),
                                                    const SizedBox(
                                                        height: 10),
                                                    StatefulBuilder(
                                                      builder: (context,
                                                          setLocalState) {
                                                        return Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                              CustomRadioListTileSMp(
                                                                title:
                                                                'Yes',
                                                                value:
                                                                'Yes',
                                                                groupValue:
                                                                statustype,
                                                                onChanged: (value) =>
                                                                    setLocalState(() =>
                                                                    statustype = value),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child:
                                                              CustomRadioListTileSMp(
                                                                title:
                                                                'No',
                                                                value:
                                                                'No',
                                                                groupValue:
                                                                statustype,
                                                                onChanged: (value) =>
                                                                    setLocalState(() =>
                                                                    statustype = value),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSize.s16),
                                    providerstate.isContactTrue
                                        ? Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          controller: pharmaEftDateFormTo,
                                          labelText: 'Effective to',
                                          showDatePicker: true,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          labelText: 'Eligibility Status',
                                          controller: TextEditingController(
                                              text: statustype),
                                          enable: true,
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d!.policy
                                              .rptiPolicyLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .policy
                                                  .rptiPolicyLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo:
                                              d.policy.rptiPolicyPgNo,
                                              isLinkeOpen:
                                              d.policy.rptiPolicyLink,
                                            );
                                          },
                                          enable: true,
                                          controller: pharmaPolicyHicNo,
                                          labelText: 'Policy/HIC Number',
                                        ),
                                      ),
                                    ])
                                        : const Offstage(),
                                    const SizedBox(height: AppSize.s16),
                                    providerstate.isContactTrue
                                        ? Row(children: [
                                      Flexible(
                                        child: SchedularTextField(
                                          hintText: "###-###-####",
                                          controller: pharmaGrpNo,
                                          isIconVisible: d!
                                              .groupNumber
                                              .rptiGroupNumberLink
                                              .isEmpty,
                                          onlyAllowNumbers: true,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .groupNumber
                                                  .rptiGroupNumberLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.groupNumber
                                                  .rptiGroupNumberPgNo,
                                              isLinkeOpen: d.groupNumber
                                                  .rptiGroupNumberLink,
                                            );
                                          },
                                          labelText: 'Group Number',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.groupName
                                              .rptiGroupNameLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(d
                                                  .groupName
                                                  .rptiGroupNameLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.groupName
                                                  .rptiGroupNamePgNo,
                                              isLinkeOpen: d.groupName
                                                  .rptiGroupNameLink,
                                            );
                                          },
                                          controller: pharmaGrpName,
                                          labelText: 'Group Name',
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s35),
                                      Flexible(
                                        child: SchedularTextField(
                                          isIconVisible: d.email
                                              .rptiEmailLink.isEmpty,
                                          isIClicked: () {
                                            widget.isIButtonPressed();
                                            providerstate
                                                .setLinkAndPageNumber(
                                              selectLink: Uri.parse(
                                                  d.email.rptiEmailLink)
                                                  .pathSegments
                                                  .last,
                                              pageNo: d.email.rptiEmailPgNo,
                                              isLinkeOpen:
                                              d.email.rptiEmailLink,
                                            );
                                          },
                                          controller: pharmaEmail,
                                          labelText: 'Primary Email',
                                        ),
                                      ),
                                    ])
                                        : const Offstage(),
                                    const SizedBox(height: AppSize.s16),
                                    providerstate.isContactTrue
                                        ? SizedBox(
                                      width: 200,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  'Insurance Verified',
                                                  style:
                                                  SMTextfieldResponsiveHeadings
                                                      .customTextStyle(
                                                      context),
                                                ),
                                                const SizedBox(
                                                    height: 10),
                                                StatefulBuilder(
                                                  builder: (context,
                                                      setLocalState) {
                                                    return Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                          CustomRadioListTileSMp(
                                                            title: 'Yes',
                                                            value: 'Yes',
                                                            groupValue:
                                                            statustype,
                                                            onChanged: (value) =>
                                                                setLocalState(() =>
                                                                statustype =
                                                                    value),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                          CustomRadioListTileSMp(
                                                            title: 'No',
                                                            value: 'No',
                                                            groupValue:
                                                            statustype,
                                                            onChanged: (value) =>
                                                                setLocalState(() =>
                                                                statustype =
                                                                    value),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                        : const Offstage(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s5),

                  // ── Attachments ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BlueBGHeadConst(
                      HeadText: "Attachments",
                      body: Opacity(
                        opacity: providerstate.isSelfPay ? 0.2 : 1.0,
                        child: IgnorePointer(
                          ignoring: providerstate.isSelfPay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p40,
                                vertical: AppPadding.p15),
                            child: Column(
                              children: [
                                FutureBuilder<
                                    List<PatientInsuranceDocumentData>>(
                                  future: _insuranceDocFuture,
                                  builder: (context, snapshotDoc) {
                                    if (snapshotDoc.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                            color: ColorManager.blueprime),
                                      );
                                    }

                                    // A Future always resolves to either data,
                                    // an error, or an empty list — never hangs
                                    // indefinitely the way a broadcast stream
                                    // could if nothing was listening yet.
                                    if (snapshotDoc.hasError ||
                                        !snapshotDoc.hasData ||
                                        snapshotDoc.data!.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 76),
                                          child: Text(
                                            AppStringSMModule
                                                .patientInsuranceDocNoData,
                                            style: AllNoDataAvailable
                                                .customTextStyle(context),
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemCount: snapshotDoc.data!.length,
                                      itemBuilder: (context, index) {
                                        final doc = snapshotDoc.data![index];
                                        if (doc.isPrimary != true) {
                                          return const Offstage();
                                        }
                                        final formattedDate =
                                        DateFormat('yyyy/MM/dd')
                                            .format(doc.createdAt);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40.0, vertical: 10),
                                          child: Container(
                                            height: AppSize.s65,
                                            decoration: BoxDecoration(
                                              color: ColorManager.white,
                                              border: Border(
                                                bottom: BorderSide(
                                                    width: 0.5,
                                                    color: ColorManager
                                                        .lightGrey),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const VerticalDivider(
                                                        color:
                                                        Color(0xFF50B5E5),
                                                        thickness: 4.5),
                                                    const SizedBox(
                                                        width: AppSize.s20),
                                                    Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text('${doc.docName}',
                                                            style: DocDefineTableData
                                                                .customTextStyle(
                                                                context)),
                                                        const SizedBox(
                                                            height:
                                                            AppSize.s8),
                                                        Text(
                                                          "Uploaded $formattedDate, ${DateFormat.jm().format(doc.createdAt)} PST by ${doc.updatedBy}",
                                                          style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            fontSize:
                                                            FontSize.s12,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: ColorManager
                                                                .mediumgrey,
                                                            decoration:
                                                            TextDecoration
                                                                .none,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
                                                      hoverColor:
                                                      Colors.transparent,
                                                      onPressed: () =>
                                                          downloadFile(
                                                              context: context,
                                                              fileUrl:
                                                              doc.docUrl,
                                                              documentName:
                                                              doc.docName,
                                                              apiPath: DownloadDocumentRepository
                                                                  .getPatientInsuranceDocumentByFileName()),
                                                      icon: const Icon(
                                                          Icons.print_outlined,
                                                          color: Color(
                                                              0xFF686464)),
                                                      iconSize: providerstate
                                                          .isContactTrue
                                                          ? IconSize.I20
                                                          : IconSize.I22,
                                                    ),
                                                    const SizedBox(
                                                        width: AppSize.s10),
                                                    PdfDownloadButton(
                                                      apiPath:
                                                      DownloadDocumentRepository
                                                          .getPatientInsuranceDocumentByFileName(),
                                                      apiUrl: doc.docUrl,
                                                      iconsize: IconSize.I22,
                                                      documentName:
                                                      doc.docName,
                                                      iconColor: const Color(
                                                          0xFF686464),
                                                    ),
                                                    const SizedBox(
                                                        width: AppSize.s10),
                                                    IconButton(
                                                      onPressed: () async {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              StatefulBuilder(
                                                                builder: (context,
                                                                    setDialogState) {
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
                                                                      setDialogState(
                                                                              () =>
                                                                          _isLoading =
                                                                          true);
                                                                      try {
                                                                        var response =
                                                                        await deletePatientInsuranceDocument(
                                                                          context:
                                                                          context,
                                                                          documentId:
                                                                          doc.insuranceDocumentId,
                                                                        );
                                                                        if (response
                                                                            .statusCode ==
                                                                            200 ||
                                                                            response
                                                                                .statusCode ==
                                                                                201) {
                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                          // FIX: refresh the attachments list after a successful
                                                                          // delete — previously the deleted doc stayed visible
                                                                          // until the whole screen remounted.
                                                                          _reloadInsuranceDoc();
                                                                          showDialog(
                                                                            context:
                                                                            context,
                                                                            builder: (_) =>
                                                                            const DeleteSuccessPopup(),
                                                                          );
                                                                        }
                                                                      } finally {
                                                                        setDialogState(
                                                                                () =>
                                                                            _isLoading =
                                                                            false);
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Color(
                                                              0xFF686464)),
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
                                                      hoverColor:
                                                      Colors.transparent,
                                                      iconSize: providerstate
                                                          .isContactTrue
                                                          ? IconSize.I20
                                                          : IconSize.I22,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSize.s25),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s60),
                  const SizedBox(height: AppSize.s30),
                ],
              ),
            );
          },
        );
      },
    );
  }
}