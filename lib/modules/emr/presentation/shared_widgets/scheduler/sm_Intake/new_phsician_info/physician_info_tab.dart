import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/intake_physician_info_manager.dart';
// removed in extraction: import 'package:prohealth/presentation/screens/em_module/dashboard/widgets/screens/office_location_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/new_phsician_info/physician_info_save_page.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/sm_physician_info/physician_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/sm_physician_info/physician_info.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_orders/intake_orders_screen.dart';
class PhysicianInfoTab extends StatelessWidget {
  final VoidCallback onSkip;
  final int physicianId;
  const
  PhysicianInfoTab({super.key, required this.onSkip, required this.physicianId,});

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    final providerContact = Provider.of<SmIntakeProviderManager>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AsyncDataController<List<PhysicianInfoPrefillData>>>(
          create: (ctx) => AsyncDataController<List<PhysicianInfoPrefillData>>()
            ..load(() => getPhysicianInfoById(context: ctx, patientId: diagnosisProvider.patientId, physicianId: physicianId)),
        ),
        ChangeNotifierProvider<AsyncDataController<List<PhysicianDropDownData>>>(
          create: (ctx) => AsyncDataController<List<PhysicianDropDownData>>()
            ..load(() => getPhysicianDropDown(context: ctx)),
        ),
        ChangeNotifierProvider<AsyncDataController<String>>(
          create: (ctx) => AsyncDataController<String>()
            ..load(() => extractTextFromPdf(providerContact.isLinkeOpen)),
        ),
      ],
      child: _PhysicianInfoTabBody(onSkip: onSkip, physicianId: physicianId),
    );
  }
}

class _PhysicianInfoTabBody extends StatefulWidget {
  final VoidCallback onSkip;
  final int physicianId;
  const _PhysicianInfoTabBody({required this.onSkip, required this.physicianId});

  @override
  State<_PhysicianInfoTabBody> createState() => _PhysicianInfoTabBodyState();
}

class _PhysicianInfoTabBodyState extends State<_PhysicianInfoTabBody> with TickerProviderStateMixin {

  TextEditingController physicianIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastController = TextEditingController();
  TextEditingController suffixController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController suitapiController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController faxnumController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController npiController = TextEditingController();
  TextEditingController upiController = TextEditingController();
  TextEditingController protocalController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController pecosController = TextEditingController();
  TextEditingController pecosStatus = TextEditingController();
  TextEditingController verificationController = TextEditingController();
  TextEditingController trakingController = TextEditingController();
  PhysicianInfoPrefillData? _prefillData;
  String? statustype;
  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;
  bool isSidebarLeftOpen = false;
  int physicianSelectedId = 0;
  String selectedPhyName = 'Select';
  String? _pdfTextFutureLinkKey;
  @override
  void initState() {
    super.initState();
    physicianSelectedId = widget.physicianId;
    _animationLeftController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Off-screen to the right
      end: const Offset(0.0, 0.0), // On-screen
    ).animate(CurvedAnimation(parent: _animationLeftController, curve: Curves.easeInOut));
    final providerContact = Provider.of<SmIntakeProviderManager>(context, listen: false);
    _pdfTextFutureLinkKey = providerContact.isLinkeOpen;
  }

  void _loadPhysicianInfo(int patientId) {
    context.read<AsyncDataController<List<PhysicianInfoPrefillData>>>().load(
      () => getPhysicianInfoById(context: context, patientId: patientId, physicianId: physicianSelectedId),
    );
  }

  void toggleLeftSidebar() {
    setState(() {
      isSidebarLeftOpen = !isSidebarLeftOpen;
      if (isSidebarLeftOpen ) {
        _animationLeftController.forward();
      } else {
        _animationLeftController.reverse();
      }
    });
  }



  bool isSaved = false;
  bool isLoading = false;
  bool _isChatbotVisible = false;
  void _toggleChatbotVisibility() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
    });
  }
  void clearController(){
    physicianIdController.clear();
    nameController.clear();
    lastController.clear();
    suffixController.clear();
    streetController.clear();
    suitapiController.clear();
    cityController.clear();
    stateController.clear();
    zipcodeController.clear();
    phonenumberController.clear();
    faxnumController.clear();
    emailController.clear();
    npiController.clear();
    upiController.clear();
    protocalController.clear();
    noteController.clear();
    verificationController.clear();
    trakingController.clear();
    pecosController.clear();
    pecosStatus.clear();
    statustype = null;
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context,listen: false);
    final saveProvider = Provider.of<PriDiagnosisProvider>(context);
    final int patientId = diagnosisProvider.patientId;
    final providerContact = Provider.of<SmIntakeProviderManager>(context,listen: false);

    if (_pdfTextFutureLinkKey != providerContact.isLinkeOpen) {
      final newLinkKey = providerContact.isLinkeOpen;
      _pdfTextFutureLinkKey = newLinkKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AsyncDataController<String>>().load(() => extractTextFromPdf(newLinkKey));
        }
      });
    }

    return Stack(
      children: [
        saveProvider.isSaved
            ? SavePagePhysicianInfo(
          onEdit: () {
            saveProvider.setSaved(false);
          }, physicianId: physicianSelectedId,
        )
            :   Row(
          children: [
            isSidebarLeftOpen == true ?   Flexible(
              flex: 0,
              child: AnimatedBuilder(
                animation: _slideLeftAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideLeftAnimation,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5,left: 10),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.24,
                          color: Colors.white,
                          padding: const EdgeInsets.all(1),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: MediaQuery.of(context).size.height,
                                    minWidth: MediaQuery.of(context).size.height
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 100,),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5,bottom: 10,left: 20),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Referred from ',
                                              style: CustomTextStylesCommon.commonStyle(
                                                  color:const Color(0xFF686464),
                                                  fontWeight: FontWeight.w700,fontSize: 12),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: '${providerContact.isLinkeFileName.toString()} ',
                                                  style: CustomTextStylesCommon.commonStyle(
                                                      color:const Color(0xFF51B5E6),
                                                      fontWeight: FontWeight.w700,fontSize: 12),
                                                ),
                                                TextSpan(
                                                  text: '(Page No.${providerContact.pageCountFromLink.toString()})',
                                                  style: CustomTextStylesCommon.commonStyle(
                                                      color:const Color(0xFF51B5E6),
                                                      fontWeight: FontWeight.w700,fontSize: 12),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Consumer<AsyncDataController<String>>(
                                          builder: (context,pdfTextController,_) {
                                            if(pdfTextController.isLoading){
                                              return Padding(
                                                padding: const EdgeInsets.
                                                symmetric(vertical: 50),
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 25,
                                                    width: 25,
                                                    child: CircularProgressIndicator(
                                                      color: ColorManager.blueprime,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            if(pdfTextController.data == null || pdfTextController.data!.isEmpty){
                                              return Padding(
                                                  padding: const EdgeInsets.
                                                  symmetric(vertical: 50),
                                                  child: Center(
                                                    child: Text('No Data!',style: CustomTextStylesCommon.commonStyle(
                                                      color:const Color(0xFF686464),
                                                      fontWeight: FontWeight.w400,fontSize: 12,),
                                                    ),
                                                  ));
                                            }
                                            return Container(
                                              width: MediaQuery.of(context).size.width / 1,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEEEEE),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child:Container(
                                                    color: Colors.white,
                                                    padding: const EdgeInsets.all(10),
                                                    child: Text(pdfTextController.data!,style: CustomTextStylesCommon.commonStyle(
                                                      color:const Color(0xFF686464),
                                                      fontWeight: FontWeight.w400,fontSize: 12,),),
                                                  )
                                              ),
                                            );
                                          }
                                      ),
                                      const SizedBox(height: 100,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                : const Offstage(),
            Flexible(
              child: Consumer<AsyncDataController<List<PhysicianInfoPrefillData>>>(
                  builder: (context,physicianInfoController,_) {
                    if(physicianInfoController.isLoading){
                      return Center(
                        child: CircularProgressIndicator(color: ColorManager.blueprime,),
                      );
                    }
                    if(physicianInfoController.hasError){
                      return const Center(
                        child: Text('Something went wrong!'),
                      );
                    }
                    final physicianInfoList = physicianInfoController.data!;
                    physicianIdController = TextEditingController(text: "${physicianInfoList[0].firstName.phyFirstName} ${physicianInfoList[0].lastName.phyLastName}");
                    nameController.text = nameController.text.isEmpty ? physicianInfoList[0].firstName.phyFirstName : nameController.text == physicianInfoList[0].firstName.phyFirstName ?physicianInfoList[0].firstName.phyFirstName:nameController.text ;
                    lastController.text =  lastController.text.isEmpty ? physicianInfoList[0].lastName.phyLastName : lastController.text;
                    suffixController.text = suffixController.text.isEmpty ? physicianInfoList[0].suffix.phySuffix ?? '' : suffixController.text;
                    streetController.text = streetController.text.isEmpty ? physicianInfoList[0].street.phyStreet ?? '' : streetController.text;
                    suitapiController.text = suitapiController.text.isEmpty ? physicianInfoList[0].suite.phySuite ?? '' : suitapiController.text;
                    cityController.text = cityController.text.isEmpty ? physicianInfoList[0].city.phyCity ?? '' : cityController.text;
                    stateController.text = stateController.text.isEmpty ? physicianInfoList[0].state.phyState ?? '' : stateController.text;
                    zipcodeController.text = zipcodeController.text.isEmpty ? physicianInfoList[0].zipcode.phyZipCode ?? '' : zipcodeController.text;
                    phonenumberController.text = phonenumberController.text.isEmpty ? physicianInfoList[0].contact.phyContact : phonenumberController.text;
                    faxnumController.text = faxnumController.text.isEmpty ? physicianInfoList[0].fax.phyFax ?? '' : faxnumController.text;
                    emailController.text = emailController.text.isEmpty ? physicianInfoList[0].email.phyEmail : emailController.text;
                    npiController.text = npiController.text.isEmpty ? physicianInfoList[0].phyNPI.phyNPI.toString() ?? "" : npiController.text;
                    upiController.text = upiController.text.isEmpty ? physicianInfoList[0].upi.phyUPI ?? '' : upiController.text;
                    protocalController.text = protocalController.text.isEmpty ? physicianInfoList[0].protocols.phyProtocols ?? '' : protocalController.text;
                    noteController.text = noteController.text.isEmpty ? physicianInfoList[0].notes.phyNotes ?? '' : noteController.text;
                    verificationController.text = verificationController.text.isEmpty ? physicianInfoList[0].verificationDetails.phyVerificationDetails ?? '' : verificationController.text;
                    trakingController.text = trakingController.text.isEmpty ? physicianInfoList[0].trackingNotes.phyTrackingNotes ?? '' : trakingController.text;
                    pecosController.text = pecosController.text.isEmpty ? physicianInfoList[0].picoNo.phyPicoNo : pecosController.text;
                    pecosStatus.text = pecosStatus.text.isEmpty ? physicianInfoList[0].phyPicoStatus.toString() : pecosStatus.text;
                    statustype = physicianInfoList[0].phyVerified == true ? "Yes" : "No";
                    return Consumer<SmIntakeProviderManager>(
                        builder: (context,providerState,child) {
                          return SingleChildScrollView(
                            child: Padding(
                              padding:  const EdgeInsets.only(right: 35, left:  35),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10,top:20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            'Review and confirm the data pulled is correct ',
                                            style: SMItalicTextConst.customTextStyle(context))

                                      ],),
                                  ),
                                  providerState.isLeftSidebarOpen ? Container(
                                    child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        onTap:(){
                                          toggleLeftSidebar();
                                          providerContact.toogleContactProvider();
                                          providerContact.toogleLeftSidebarProvider();
                                          providerState.setLinkAndPageClear();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 35,vertical: 10),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                size: IconSize.I16,
                                                color: ColorManager.mediumgrey,

                                              ),
                                              const SizedBox(width: 5,),
                                              Text(
                                                'Go Back',
                                                style:TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: ColorManager.mediumgrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ) : const Offstage(),
                                  BlueBGHeadConst(HeadText: "Certifying F2F Physician Or Allowed Practitioner",
                                    body: Column(
                                      children: [
                                        const SizedBox(height: AppSize.s10,),
                                        Padding(
                                          padding: EdgeInsets.only(left: 25, right: providerState.isContactTrue ? 0 : 25),
                                          child: Column(
                                              children: [
                                                const SizedBox(height: AppSize.s16),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Consumer<AsyncDataController<List<PhysicianDropDownData>>>(
                                                        builder: (context, dropDownController, _) {
                                                          if (dropDownController.isLoading) {
                                                            return SchedularTextField(
                                                                controller: TextEditingController(text:selectedPhyName ), labelText: 'Select from Database');
                                                          }
                                                          if (dropDownController.data != null) {
                                                            List<DropdownMenuItem<String>> dropDownList = [];
                                                            for (var i in dropDownController.data!) {
                                                              dropDownList.add(DropdownMenuItem<String>(
                                                                child: Text(i.physicianName!),
                                                                value: i.physicianName,
                                                              ));
                                                            }

                                                            return CustomDropdownTextFieldsm(
                                                                initialValue: selectedPhyName,
                                                                headText: 'Select from Database',
                                                                dropDownMenuList: dropDownList,
                                                                onChanged: (newValue) {
                                                                  for (var a in dropDownController.data!) {
                                                                    if (a.physicianName == newValue) {
                                                                      setState(() {
                                                                        selectedPhyName = a.physicianName!;
                                                                        physicianSelectedId = a.id;
                                                                        clearController();
                                                                        _loadPhysicianInfo(patientId);
                                                                      });

                                                                    }
                                                                  }
                                                                });
                                                          } else {
                                                            return const Offstage();
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                            controller: nameController,
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse(physicianInfoList[0].firstName.phyFirstNameLink).pathSegments.last,
                                                                  pageNo:physicianInfoList[0].firstName.phyFirstNamePgNo,
                                                                  isLinkeOpen:physicianInfoList[0].firstName.phyFirstNameLink );
                                                            },
                                                            isIconVisible: physicianInfoList[0] == null ? true :  physicianInfoList[0].firstName.phyFirstNameLink.isEmpty ? true : false,
                                                            labelText: 'First Name*',
                                                            initialValue: 'A')),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse(physicianInfoList[0].lastName.phyLastNameLink).pathSegments.last,
                                                                  pageNo:physicianInfoList[0].lastName.phyLastNamePgNo,
                                                                  isLinkeOpen:physicianInfoList[0].lastName.phyLastNameLink );
                                                            },
                                                            controller: lastController,
                                                            isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].lastName.phyLastNameLink.isEmpty ? true : false,
                                                            labelText: "Last Name*")),
                                                    const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ? const Offstage() : Flexible(
                                                        child: SchedularTextField(
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse(physicianInfoList[0].suffix.phySuffixLink).pathSegments.last,
                                                                  pageNo:physicianInfoList[0].suffix.phySuffixPgNo,
                                                                  isLinkeOpen: physicianInfoList[0].suffix.phySuffixLink);
                                                            },
                                                            controller: suffixController,
                                                            isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].suffix.phySuffixLink.isEmpty ? true : false,
                                                            labelText: "Suffix")),
                                                    providerState.isContactTrue ? const Offstage() :  const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ? const Offstage() : const Flexible(
                                                        child: SizedBox(width:0)),
                                                  ],
                                                ),
                                                const SizedBox(height: AppSize.s16),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIconClicked: true,
                                                          iconClickedPress:(){
                                                            providerState.openMapPhysicalInfoScreen(context:context);
                                                          },
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].street.phyStreetLink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].street.phyStreetPgNo,
                                                                isLinkeOpen:physicianInfoList[0].street.phyStreetLink );
                                                          },
                                                          controller: providerState.ctlrStreetPhysicalInfoProvider.text.isEmpty ? streetController : providerState.ctlrStreetPhysicalInfoProvider,
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].street.phyStreetLink.isEmpty ? true : false,
                                                          icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                                                          labelText: 'Street*',
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].suite.phySuiteLink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].suite.phySuitePgNo,
                                                                isLinkeOpen:physicianInfoList[0].suite.phySuiteLink );
                                                          },
                                                          controller: suitapiController,
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].suite.phySuiteLink.isEmpty ? true : false,
                                                          labelText: 'Suite/Apt#',
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].city.phyCityLink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].city.phyCityPgNo,
                                                                isLinkeOpen: physicianInfoList[0].city.phyCityLink);
                                                          },
                                                          controller: providerState.ctlrCityPhysicalInfoProvider.text.isEmpty ? cityController : providerState.ctlrCityPhysicalInfoProvider,
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].city.phyCityLink.isEmpty ? true : false,
                                                          labelText: 'City*',
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ?const Offstage() : Flexible(child: SchedularTextField(
                                                      isIClicked: providerContact.isRightSliderOpen == true ?
                                                          (){
                                                      }
                                                          :(){
                                                        toggleLeftSidebar();
                                                        providerContact.toogleContactProvider();
                                                        providerContact.toogleLeftSidebarProvider();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse(physicianInfoList[0].state.phyStateLink).pathSegments.last,
                                                            pageNo:physicianInfoList[0].state.phyStatePgNo,
                                                            isLinkeOpen: physicianInfoList[0].state.phyStateLink);
                                                      },
                                                      controller: providerState.ctlrStatePhysicalInfoProvider.text.isEmpty ? stateController : providerState.ctlrStatePhysicalInfoProvider,
                                                      labelText: 'State*',
                                                      isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].state.phyStateLink.isEmpty ? true : false,
                                                    )),
                                                    providerState.isContactTrue ?const Offstage() :  const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ?const Offstage() :  Flexible(
                                                        child: SchedularTextField(
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse(physicianInfoList[0].zipcode.phyZipCodeLink).pathSegments.last,
                                                                  pageNo:physicianInfoList[0].zipcode.phyZipCodePgNo,
                                                                  isLinkeOpen: physicianInfoList[0].zipcode.phyZipCodeLink);
                                                            },
                                                            controller: zipcodeController,
                                                            onlyAllowNumbers: true,
                                                            allowSSNBR: true,
                                                            isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].zipcode.phyZipCodeLink.isEmpty ? true : false,
                                                            labelText: "Zip Code*")
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: AppSize.s16),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].contact.phyContactLink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].contact.phyContactPgNo,
                                                                isLinkeOpen: physicianInfoList[0].contact.phyContactLink);
                                                          },
                                                          phoneField: true,
                                                          controller: phonenumberController,
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].contact.phyContactLink.isEmpty ? true : false,
                                                          labelText: "Phone Number*",
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].fax.phyFaxLink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].fax.phyFaxPgNo,
                                                                isLinkeOpen:physicianInfoList[0].fax.phyFaxLink );
                                                          },
                                                          controller: faxnumController,
                                                          isIconVisible:physicianInfoList[0] == null ? true :  physicianInfoList[0].fax.phyFaxLink.isEmpty ? true : false,
                                                          labelText: "Fax Number",
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse(physicianInfoList[0].email.phyEmailLink).pathSegments.last,
                                                                  pageNo:physicianInfoList[0].email.phyEmailPgNo,
                                                                  isLinkeOpen:physicianInfoList[0].email.phyEmailLink );
                                                            },
                                                            controller: emailController,
                                                            isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].email.phyEmailLink.isEmpty ? true : false,
                                                            labelText: "Email")),
                                                    providerState.isContactTrue ? const SizedBox(width: AppSize.s15) :  const SizedBox(width: AppSize.s30),
                                                    providerState.isContactTrue ?const Offstage() :  Flexible(
                                                        child: SizedBox(
                                                          width: 80,
                                                          child: InkWell(
                                                              hoverColor: Colors.transparent,
                                                              splashColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                              onTap: _toggleChatbotVisibility,
                                                              child: Image.asset("images/sm/contact_text.png",height: 60,)),)),
                                                    providerState.isContactTrue ?const SizedBox(width: 20,) : const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ?const Offstage() :  const Flexible(child: SizedBox(width:55)),
                                                  ],
                                                ),
                                                const SizedBox(height: AppSize.s16),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].phyNPI.phyNPILink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].phyNPI.phyFirstNamePgNo,
                                                                isLinkeOpen: physicianInfoList[0].phyNPI.phyNPILink);
                                                          },
                                                          controller: npiController,
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].phyNPI.phyNPILink.isEmpty ? true : false,
                                                          labelText: "NPI Number",
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].upi.phyUPILink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].upi.phyUPIPgNo,
                                                                isLinkeOpen: physicianInfoList[0].upi.phyUPILink);
                                                          },
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].upi.phyUPILink.isEmpty ? true : false,
                                                          controller: upiController,
                                                          labelText: "UPI Number",
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].protocols.phyProtocolsLink).pathSegments.last,
                                                                pageNo:physicianInfoList[0].protocols.phyProtocolsPgNo,
                                                                isLinkeOpen: physicianInfoList[0].protocols.phyProtocolsLink);
                                                          },
                                                          controller: protocalController,
                                                          isIconVisible:physicianInfoList[0] == null ? true :  physicianInfoList[0].protocols.phyProtocolsLink.isEmpty ? true : false,
                                                          labelText: "Protocols",
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ?const Offstage() :  Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse( physicianInfoList[0].notes.phyNotesLink).pathSegments.last,
                                                                pageNo: physicianInfoList[0].notes.phyNotesPgNo,
                                                                isLinkeOpen:physicianInfoList[0].notes.phyNotesLink );
                                                          },
                                                          controller: noteController,
                                                          isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].notes.phyNotesLink.isEmpty ? true : false,
                                                          labelText: "Notes",
                                                        )),
                                                    providerState.isContactTrue ?const Offstage() :  const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ?const Offstage() :  const Flexible(child: SizedBox(width:0)),
                                                  ],
                                                ),
                                                const SizedBox(height: AppSize.s16),
                                                providerState.isContactTrue
                                                    ?  Padding(
                                                  padding: const EdgeInsets.only(right: 35.0),
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                          child: SchedularTextField(
                                                              isIClicked: providerContact.isRightSliderOpen == true ?
                                                                  (){
                                                              }
                                                                  :(){
                                                                toggleLeftSidebar();
                                                                providerContact.toogleContactProvider();
                                                                providerContact.toogleLeftSidebarProvider();
                                                                providerState.setLinkAndPageNumber(
                                                                    selectLink: Uri.parse( physicianInfoList[0].suffix.phySuffixLink).pathSegments.last,
                                                                    pageNo: physicianInfoList[0].suffix.phySuffixPgNo,
                                                                    isLinkeOpen: physicianInfoList[0].suffix.phySuffixLink);
                                                              },
                                                              controller: suffixController,
                                                              isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].suffix.phySuffixLink.isEmpty ? true : false,
                                                              labelText: "Suffix")),
                                                      const SizedBox(width: AppSize.s35),
                                                      Flexible(
                                                          child: SchedularTextField(
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse( physicianInfoList[0].state.phyStateLink).pathSegments.last,
                                                                  pageNo: physicianInfoList[0].state.phyStatePgNo,
                                                                  isLinkeOpen: physicianInfoList[0].state.phyStateLink);
                                                            },
                                                            controller:providerState.ctlrStatePhysicalInfoProvider.text.isEmpty ?  stateController : providerState.ctlrStatePhysicalInfoProvider,
                                                            isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].state.phyStateLink.isEmpty ? true : false,
                                                            labelText: 'State*',
                                                          )),

                                                      const SizedBox(width: AppSize.s35),
                                                      Flexible(
                                                          child: SchedularTextField(
                                                              isIClicked: providerContact.isRightSliderOpen == true ?
                                                                  (){
                                                              }
                                                                  :(){
                                                                toggleLeftSidebar();
                                                                providerContact.toogleContactProvider();
                                                                providerContact.toogleLeftSidebarProvider();
                                                                providerState.setLinkAndPageNumber(
                                                                    selectLink: Uri.parse(physicianInfoList[0].zipcode.phyZipCodeLink).pathSegments.last,
                                                                    pageNo: physicianInfoList[0].zipcode.phyZipCodePgNo,
                                                                    isLinkeOpen: physicianInfoList[0].zipcode.phyZipCodeLink);
                                                              },
                                                              controller: zipcodeController,
                                                              isIconVisible:physicianInfoList[0] == null ? true :  physicianInfoList[0].zipcode.phyZipCodeLink.isEmpty ? true : false,
                                                              allowSSNBR: true,
                                                              labelText: "Zip Code*")
                                                      )
                                                    ],
                                                  ),
                                                ) : const Offstage(),
                                                const SizedBox(height: AppSize.s16,),
                                                providerState.isContactTrue ?
                                                Row(
                                                  children: [
                                                    Flexible(
                                                        child: SchedularTextField(
                                                          isIClicked: providerContact.isRightSliderOpen == true ?
                                                              (){
                                                          }
                                                              :(){
                                                            toggleLeftSidebar();
                                                            providerContact.toogleContactProvider();
                                                            providerContact.toogleLeftSidebarProvider();
                                                            providerState.setLinkAndPageNumber(
                                                                selectLink: Uri.parse(physicianInfoList[0].notes.phyNotesLink).pathSegments.last,
                                                                pageNo: physicianInfoList[0].notes.phyNotesPgNo,
                                                                isLinkeOpen:physicianInfoList[0].notes.phyNotesLink );
                                                          },
                                                          controller: noteController,
                                                          labelText: "Notes",
                                                          isIconVisible:physicianInfoList[0] == null ? true :  physicianInfoList[0].notes.phyNotesLink.isEmpty ? true : false,
                                                        )),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(
                                                        child: SizedBox(
                                                          child: InkWell(
                                                              hoverColor: Colors.transparent,
                                                              splashColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                              onTap: _toggleChatbotVisibility,
                                                              child: Image.asset("images/sm/contact_text.png",height: 60,)),)),
                                                    const SizedBox(width: AppSize.s35),
                                                    Flexible(child: Container()),
                                                    const SizedBox(width: AppSize.s35),
                                                    providerState.isContactTrue ?const Offstage() : Flexible(
                                                        child: SchedularTextField(
                                                            isIClicked: providerContact.isRightSliderOpen == true ?
                                                                (){
                                                            }
                                                                :(){
                                                              toggleLeftSidebar();
                                                              providerContact.toogleContactProvider();
                                                              providerContact.toogleLeftSidebarProvider();
                                                              providerState.setLinkAndPageNumber(
                                                                  selectLink: Uri.parse(physicianInfoList[0].suffix.phySuffixLink).pathSegments.last,
                                                                  pageNo: physicianInfoList[0].suffix.phySuffixPgNo,
                                                                  isLinkeOpen:physicianInfoList[0].suffix.phySuffixLink );
                                                            },
                                                            controller: suffixController,
                                                            isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].suffix.phySuffixLink.isEmpty ? true : false,
                                                            labelText: "Suffix")),
                                                    providerState.isContactTrue ?const Offstage() :  const SizedBox(width: AppSize.s35),

                                                  ],
                                                ) : const SizedBox(),
                                                providerState.isContactTrue ?   const SizedBox(height: AppSize.s25,) : const Offstage(),
                                                Row(
                                                  children: [
                                                    Text("Check PECOS Eligibility Status",style: CustomTextStylesCommon.commonStyle(
                                                      fontSize: FontSize.s14,
                                                      fontWeight: FontWeight.w700,
                                                      color: ColorManager.blueprime,
                                                    ),)
                                                  ],
                                                ),
                                                const SizedBox(height: AppSize.s16),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: StatefulBuilder(
                                                        builder: (BuildContext context, void Function(void Function()) setState) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('Physician Verified',
                                                                  style: SMTextfieldHeadings.customTextStyle(context)
                                                              ),
                                                              const SizedBox(height: 5),
                                                              SizedBox(
                                                                width: 205,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: CustomRadioListTileSMp(
                                                                        title: 'No',
                                                                        value: 'No',
                                                                        groupValue: statustype,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            statustype = value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    providerState.isContactTrue ? const SizedBox(width: 15,) : const Offstage(),
                                                                    Expanded(
                                                                      child: CustomRadioListTileSMp(
                                                                        title: 'Yes',
                                                                        value: 'Yes',
                                                                        groupValue: statustype,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            statustype = value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    providerState.isContactTrue ? const SizedBox(width: AppSize.s50) : const Offstage(),
                                                    Expanded(
                                                      flex:4,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 0),
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: SchedularTextField(
                                                                        width: 250 ,
                                                                        isIClicked: providerContact.isRightSliderOpen == true ?
                                                                            (){
                                                                        }
                                                                            :(){
                                                                          toggleLeftSidebar();
                                                                          providerContact.toogleContactProvider();
                                                                          providerContact.toogleLeftSidebarProvider();
                                                                          providerState.setLinkAndPageNumber(
                                                                              selectLink: Uri.parse(physicianInfoList[0].picoNo.phyPicoNoLink).pathSegments.last,
                                                                              pageNo: physicianInfoList[0].picoNo.phyPicoNoPgNo,
                                                                              isLinkeOpen:physicianInfoList[0].picoNo.phyPicoNoLink );
                                                                        },
                                                                        isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].picoNo.phyPicoNoLink.isEmpty ? true : false,
                                                                        controller: pecosStatus,
                                                                        enable: false,
                                                                        textStyle: TextStyle(fontWeight: FontWeight.w700,
                                                                          fontSize: FontSize.s12,
                                                                          color: ColorManager.greenDark,
                                                                        ),
                                                                        labelText: "PECOS Status"),
                                                                  ),
                                                                  const SizedBox(width: AppSize.s35),
                                                                  const Flexible(
                                                                      child: SizedBox(width:0)),
                                                                  const SizedBox(width: AppSize.s35),
                                                                  const Flexible(
                                                                      child: SizedBox(width:0)),
                                                                ],
                                                              ),
                                                            ),
                                                            providerState.isContactTrue ?const Offstage() : const SizedBox(width:0),
                                                            providerState.isContactTrue ?const Offstage() :  const SizedBox(width: AppSize.s35),
                                                            const SizedBox(width:0),
                                                            providerState.isContactTrue ?const Offstage() : const SizedBox(width: AppSize.s35),
                                                            providerState.isContactTrue ?const Offstage() : const SizedBox(width:0),
                                                            const SizedBox(height: AppSize.s16),
                                                            Padding(
                                                              padding:  const EdgeInsets.only(left: 0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Flexible(
                                                                    child: SchedularTextField(
                                                                        isIClicked: providerContact.isRightSliderOpen == true ?
                                                                            (){
                                                                        }
                                                                            :(){
                                                                          toggleLeftSidebar();
                                                                          providerContact.toogleContactProvider();
                                                                          providerContact.toogleLeftSidebarProvider();
                                                                          providerState.setLinkAndPageNumber(
                                                                              selectLink: Uri.parse(physicianInfoList[0].verificationDetails.phyVerificationDetailsLink).pathSegments.last,
                                                                              pageNo: physicianInfoList[0].verificationDetails.phyVerificationDetailsPgNo,
                                                                              isLinkeOpen:physicianInfoList[0].verificationDetails.phyVerificationDetailsLink );
                                                                        },
                                                                        isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].verificationDetails.phyVerificationDetailsLink.isEmpty ? true : false,
                                                                        width: providerState.isContactTrue?300 :375,
                                                                        controller: verificationController,
                                                                        labelText: "Verification Details"),
                                                                  ),
                                                                  const SizedBox(width: AppSize.s35),
                                                                  Flexible(
                                                                    child: SchedularTextField(
                                                                        isIClicked: providerContact.isRightSliderOpen == true ?
                                                                            (){
                                                                        }
                                                                            :(){
                                                                          toggleLeftSidebar();
                                                                          providerContact.toogleContactProvider();
                                                                          providerContact.toogleLeftSidebarProvider();
                                                                          providerState.setLinkAndPageNumber(
                                                                              selectLink: Uri.parse(physicianInfoList[0].trackingNotes.phyTrackingNotesLink).pathSegments.last,
                                                                              pageNo: physicianInfoList[0].trackingNotes.phyTrackingNotesPgNo,
                                                                              isLinkeOpen: physicianInfoList[0].trackingNotes.phyTrackingNotesLink);
                                                                        },
                                                                        width:  providerState.isContactTrue?300 :375,
                                                                        controller: trakingController,
                                                                        isIconVisible: physicianInfoList[0] == null ? true : physicianInfoList[0].trackingNotes.phyTrackingNotesLink.isEmpty ? true : false,
                                                                        labelText: "Tracking Notes"),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),




                                              ]),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 40),
                                          child: Divider(),
                                        ),
                                      ],
                                    ),),

                                  ///dont delete temp hide
                                  // BlueBGHeadConst(HeadText: "Other Physicians Or Allowed Practitioner"),
                                  // SizedBox(height: AppSize.s20,),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     SizedBox(
                                  //       width: 160,
                                  //       height: 35,
                                  //       child: ElevatedButton.icon(onPressed: () {
                                  //         // showDialog(
                                  //         //   context: context,
                                  //         //   builder: (BuildContext context) {
                                  //         //     return AddPopupConstant(title: 'Add Face to Face Attachment',);
                                  //         //   },
                                  //         // );
                                  //       },
                                  //         label: Text(
                                  //             "Add Physician",
                                  //             style: TextStyle(
                                  //               fontSize: FontSize.s13,
                                  //               fontWeight: FontWeight.w600,
                                  //               color: ColorManager.white,
                                  //               decoration: TextDecoration.none,
                                  //             )//BlueButtonTextConst.customTextStyle(context),
                                  //         ),
                                  //         icon:Icon(Icons.add),
                                  //
                                  //         style: ElevatedButton.styleFrom(
                                  //           backgroundColor:  ColorManager.bluebottom,
                                  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                                  //           ),),
                                  //       ),
                                  //     )
                                  //
                                  //   ],
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 25,bottom: 10),
                                  //   child: Divider(),
                                  // ),
                                  StatefulBuilder(
                                      builder: (BuildContext context, void Function(void Function())setState) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              SkipButtonTransparent(
                                                text: "Skip",
                                                onPressed: () {
                                                  print("🔹 Skip button tapped - going to initial contact screen");
                                                  widget.onSkip(); // This should trigger jumpToPage(4)
                                                },
                                              ),
                                              const SizedBox(width: AppSize.s30,),
                                              CustomElevatedButton(
                                                width: 100,
                                                text: AppString.save,
                                                isLoading: isLoading,
                                                onPressed: () async {
                                                  print('${physicianSelectedId}');
                                                  print('${nameController.text}');
                                                  print('${lastController.text}');
                                                  print('${suffixController.text}');
                                                  print('${pecosController.text}');
                                                  print('${bool.parse(pecosStatus.text)}');
                                                  print('${emailController.text}');
                                                  print('${phonenumberController.text}');
                                                  print('${ providerState.ctlrStreetPhysicalInfoProvider.text.isEmpty ? streetController.text : providerState.ctlrStreetPhysicalInfoProvider.text}');
                                                  print('${suitapiController.text}');
                                                  print('${providerState.ctlrCityPhysicalInfoProvider.text.isEmpty ? cityController.text : providerState.ctlrCityPhysicalInfoProvider.text}');
                                                  print('${providerState.ctlrStatePhysicalInfoProvider.text.isEmpty ? stateController.text : providerState.ctlrStatePhysicalInfoProvider.text}');
                                                  print('${zipcodeController.text}');
                                                  print('${faxnumController.text}');
                                                  print('${int.parse(npiController.text)}');
                                                  print('${upiController.text}');
                                                  print('${protocalController.text}');
                                                  print('${noteController.text}');
                                                  print('${statustype == "Yes" ? true : false}');
                                                  print('${verificationController.text}');
                                                  print('${verificationController.text}');
                                                  print('${trakingController.text}');
                                                  print('${diagnosisProvider.patientId}');


                                                  setState(() {
                                                    isLoading = true; // ✅ Start loader
                                                  });

                                                  try {
                                                    var response = await updatePhysicianMasterPatch(
                                                      context: context,
                                                      phyId: physicianSelectedId,//int.parse(physicianIdController.text),
                                                      phyFirstName: nameController.text,
                                                      phyLastName: lastController.text,
                                                      phySuffix: suffixController.text,
                                                      phyPicoNo: pecosController.text,
                                                      phyPicoStatus: bool.parse(pecosStatus.text),
                                                      phyEmail: emailController.text,
                                                      phyContact: phonenumberController.text,
                                                      phyStreet: providerState.ctlrStreetPhysicalInfoProvider.text.isEmpty ? streetController.text : providerState.ctlrStreetPhysicalInfoProvider.text,
                                                      phySuite: suitapiController.text,
                                                      phyCity:providerState.ctlrCityPhysicalInfoProvider.text.isEmpty ? cityController.text : providerState.ctlrCityPhysicalInfoProvider.text,
                                                      phyState:providerState.ctlrStatePhysicalInfoProvider.text.isEmpty ? stateController.text : providerState.ctlrStatePhysicalInfoProvider.text,
                                                      phyZipCode: zipcodeController.text,
                                                      phyFax: faxnumController.text,
                                                      phyNPI: int.parse(npiController.text),
                                                      phyUPI: upiController.text,
                                                      phyProtocols: protocalController.text,
                                                      phyNotes: noteController.text,
                                                      phyVerified: statustype == "Yes" ? true : false,
                                                      phyVerificationDetails: verificationController.text,
                                                      phyTrackingNotes: trakingController.text,
                                                      fk_pt_id: diagnosisProvider.patientId,
                                                    );
                                                    if (response.statusCode == 200 || response.statusCode == 201) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return const AddSuccessPopup(
                                                            message: 'Physician Info Updated Successfully',
                                                          );
                                                        },
                                                      );
                                                      saveProvider.setSaved(true);

                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => const AddErrorPopup(
                                                          message: 'Please Check Your Input And Try Again',
                                                        ),
                                                      );
                                                      print('API error: ${response.message}');
                                                      print('Please check your input and try again');

                                                    }

                                                  }
                                                  catch (e) {
                                                    print('Error saving physician info: $e');
                                                  }
                                                  finally {
                                                    setState(() {
                                                      isLoading = false; // ✅ Stop loader
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        );}
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                    );
                  }
              ),
            ),
          ],
        ),
        if (_isChatbotVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleChatbotVisibility, // Close popup on tapping outside
              child: Container(
                  color: Colors.transparent
              ),
            ),
          ),
      ],
    );
  }
}
