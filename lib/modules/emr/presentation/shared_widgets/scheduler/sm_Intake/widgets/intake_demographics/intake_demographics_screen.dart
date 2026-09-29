import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_demographics/widgets/patients_info/intake_patients_info.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_demographics/widgets/patients_related_party/intake_patients_related_party.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_io/io.dart' as io;
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographic_patient_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographich_ai_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_demographics/intake_demographics_screen_controller.dart';

class SmIntakeDemographicsScreen extends StatelessWidget {
  final Function(int) onPatientIdGenerated;
  final VoidCallback iButtonClickd;
  final VoidCallback onSkip;
  const SmIntakeDemographicsScreen({super.key, required this.onPatientIdGenerated, required this.iButtonClickd, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SmIntakeDemographicsController>(
      create: (ctx) {
        final providerContact = Provider.of<SmIntakeProviderManager>(ctx, listen: false);
        return SmIntakeDemographicsController()..load(ctx, providerContact.isLinkeOpen);
      },
      child: _SmIntakeDemographicsScreenBody(
        onPatientIdGenerated: onPatientIdGenerated,
        iButtonClickd: iButtonClickd,
        onSkip: onSkip,
      ),
    );
  }
}

class _SmIntakeDemographicsScreenBody extends StatefulWidget {
  final Function(int) onPatientIdGenerated;
  final VoidCallback iButtonClickd;
  final VoidCallback onSkip;
  const _SmIntakeDemographicsScreenBody({required this.onPatientIdGenerated, required this.iButtonClickd, required this.onSkip});

  @override
  State<_SmIntakeDemographicsScreenBody> createState() => _SmIntakeDemographicsScreenBodyState();
}
class _SmIntakeDemographicsScreenBodyState extends State<_SmIntakeDemographicsScreenBody> with TickerProviderStateMixin{
  int selectedIndex = 0;
  bool showProfileBar = false;
  final PageController smIntakePageController = PageController();

  TextEditingController dummyCtrl = TextEditingController();
  String? statusType;
  void selectButton(int index) {
    setState(() {
      selectedIndex = index;
    });

    smIntakePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void toggleProfileBar() {
    setState(() {
      showProfileBar = true;
    });
  }



// Function to show an error message


  int patientId = 1;
  String? statustype;
  String? selectedStatus;
  String? selectedCountry;
  String? selectedRace;
  String? selectedState;
  String? selectedcity;
  String? selectedLanguage;
  String? selectedReligion;
  String? selectedMaritalStatus;

  bool isSidebarLeftOpen = false;
  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;
  String? _pdfTextFutureLinkKey;
  @override
  void initState() {
    super.initState();
    _animationLeftController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Off-screen to the right
      end: const Offset(0.0, 0.0), // On-screen
    ).animate(CurvedAnimation(parent: _animationLeftController, curve: Curves.easeInOut));
    // Seed the key-tracking field to the value the outer widget's
    // ChangeNotifierProvider already used for its initial fetch, so the
    // very next build() doesn't immediately refire the same fetch.
    _pdfTextFutureLinkKey = Provider.of<SmIntakeProviderManager>(context, listen: false).isLinkeOpen;
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
  String? selectedValue;

  Uint8List? _pdfBytes;
  bool _loading = true;
  final String pdfUrl = "https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf"; // Replace with your actual S3 file URL

  final List<String> items = ['Option 1', 'Option 2', 'Option 3'];
  @override
  Widget build(BuildContext context) {
    print('Build bytes ${_pdfBytes}');
    final providerContact = Provider.of<SmIntakeProviderManager>(context,listen: false);
    if (_pdfTextFutureLinkKey != providerContact.isLinkeOpen) {
      _pdfTextFutureLinkKey = providerContact.isLinkeOpen;
      final newLinkKey = providerContact.isLinkeOpen;
      // Defer the refetch: notifyListeners() inside load() must not fire
      // synchronously while this same build() is still constructing the
      // Consumer<SmIntakeDemographicsController> below.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SmIntakeDemographicsController>().reloadPdfText(newLinkKey);
        }
      });
    }
        return Row(
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
                                child:
                                IntrinsicHeight(
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
                                      Consumer<SmIntakeDemographicsController>(
                                        builder: (context, controller, _) {
                                          if(controller.isPdfTextLoading){
                                            return Padding(
                                              padding: const EdgeInsets.
                                                symmetric(vertical: 80),
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
                                          if((controller.pdfText ?? '').isEmpty){
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
                                                    child: Center(
                                                      child: Text('No Data!',style: CustomTextStylesCommon.commonStyle(
                                                        color:const Color(0xFF686464),
                                                        fontWeight: FontWeight.w400,fontSize: 12,),
                                                      ),
                                                    ),
                                                  )
                                              ),
                                            );
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
                                                  child: Text(controller.pdfText ?? '',style: CustomTextStylesCommon.commonStyle(
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
            ) : const Offstage(),
            Flexible(
              child: Column(
                children: [
                   const SizedBox(height: AppSize.s20),
                  Container(
                  height: AppSize.s30,
                  width: AppSize.s315,
                  decoration: BoxDecoration(
                      boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                    borderRadius: BorderRadius.circular(20),
                    color: ColorManager.blueprime,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Patient Info Button
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () => selectButton(0),
                        child: Container(
                          height: AppSize.s30,
                          width: AppSize.s160,
                          decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                            color: selectedIndex == 0
                                ? Colors.white
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              'Patient Info',
                              style: BlueBgTabbar.customTextStyle(
                                  0, selectedIndex),
                            ),
                          ),
                        ),
                      ),
                      // Related Parties Button
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () => selectButton(1),
                        child: Container(
                          height: AppSize.s30,
                          width: AppSize.s155,
                          decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                            color: selectedIndex == 1
                                ? Colors.white
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              'Related Parties',
                              style: BlueBgTabbar.customTextStyle(
                                  1, selectedIndex),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                                      ),
                   const SizedBox(height: AppSize.s20),
                  Expanded(
                    flex: 1,
                    child: PageView(
                      controller: smIntakePageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        IntakePatientsDatatInfo(
                          childState: Consumer<SmIntakeDemographicsController>(
                            builder: (context, controller, _) {
                              if (controller.isStateDropDownLoading) {
                                return SchedularTextField(
                                    width: 350,
                                    controller: dummyCtrl,
                                    labelText: 'State*');
                              }
                              if (controller.stateDropDown != null) {
                                List<DropdownMenuItem<String>> dropDownList = [];
                                for (var i in controller.stateDropDown!) {
                                  dropDownList.add(DropdownMenuItem<String>(
                                    child: Text(i.name!),
                                    value: i.name,
                                  ));
                                }

                                return CustomDropdownTextFieldsm(
                                    headText: 'State*',
                                    dropDownMenuList: dropDownList,
                                    onChanged: (newValue) {
                                      for (var a in controller.stateDropDown!) {
                                        if (a.name == newValue) {
                                          selectedState = a.name!;
                                        }
                                      }
                                    });
                              } else {
                                return const Offstage();
                              }
                            },
                          ),
                          childCountry: Consumer<SmIntakeDemographicsController>(
                            builder: (context, controller, _) {
                              if (controller.isCountryDropDownLoading) {
                                return SchedularTextField(
                                    controller: dummyCtrl, labelText: 'Country*');
                              }
                              if (controller.countryDropDown != null) {
                                List<DropdownMenuItem<String>> dropDownList = [];
                                for (var i in controller.countryDropDown!) {
                                  dropDownList.add(DropdownMenuItem<String>(
                                    child: Text(i.name!),
                                    value: i.name,
                                  ));
                                }

                                return CustomDropdownTextFieldsm(
                                    headText: 'Country*',
                                    dropDownMenuList: dropDownList,
                                    onChanged: (newValue) {
                                      for (var a in controller.countryDropDown!) {
                                        if (a.name == newValue) {
                                          selectedCountry = a.name!;
                                        }
                                      }
                                    });
                              } else {
                                return const Offstage();
                              }
                            },
                          ),
                          isIButtonPressed: providerContact.isRightSliderOpen == true ? (){
                        }:(){

                          toggleLeftSidebar();
                          providerContact.toogleContactProvider();
                          providerContact.toogleLeftSidebarProvider();
                        },onSkip: () {   selectButton(1); },
                        ),
                        IntakeRelatedPartiesScreen(
                          patientId: patientId, onIButtonPressed: providerContact.isRightSliderOpen == true ? (){
                        }:(){

                          toggleLeftSidebar();
                          providerContact.toogleContactProvider();
                          providerContact.toogleLeftSidebarProvider();
                        }, onSkip: () { widget.onSkip(); },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }
}
