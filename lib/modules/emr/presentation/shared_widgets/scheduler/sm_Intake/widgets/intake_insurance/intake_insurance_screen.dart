import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/widgets/intake_insurance_primary/intake_insurance_primary_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/widgets/intake_insurance_secondary/intake_insurance_secondary_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_insurance/widgets/save_page/insurance_save_page.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/patient_insurance_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';
// removed in extraction: import '../../../widgets/constant_widgets/schedular_success_popup.dart';

class IntakeInsuranceScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback onSkip;
  const IntakeInsuranceScreen({super.key, required this.patientId, required this.onSkip,});

  @override
  State<IntakeInsuranceScreen> createState() => _IntakeInsuranceScreenState();
}

class _IntakeInsuranceScreenState extends State<IntakeInsuranceScreen> with TickerProviderStateMixin {
  int selectedIndex = 0;
  final PageController smIntakePageController = PageController();
  bool isSidebarLeftOpen = false;
  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;
  List<PatientInsuranceInfoData> insurancePatientData = [];
  int previousIndex = 0;
  String? _pdfTextFutureLinkKey;
  late Future<String> _pdfTextFuture;
  @override
  void initState() {
    super.initState();
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    fetchPrimaryInsuranceData(ptId: diagnosisProvider.patientId);
    _animationLeftController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Off-screen to the right
      end: const Offset(0.0, 0.0), // On-screen
    ).animate(CurvedAnimation(parent: _animationLeftController, curve: Curves.easeInOut));


  }
  Future<void> fetchPrimaryInsuranceData({required int ptId}) async {
    final data = await getPatientInsuranceinfo(context: context, ptId: ptId);

    // check your condition
    final filled = data.isNotEmpty &&
        data[0].street.rptiStreet.isNotEmpty &&
        data[0].groupName.rptiGroupName.isNotEmpty &&
        data[0].email.rptiEmail.isNotEmpty &&
        data[0].rptiEffectiveFrom.isNotEmpty &&
        data[0].rptiEffectiveTo.isNotEmpty &&
        data[0].city.rptiCity.isNotEmpty;

    setState(() {
      insurancePatientData = data;
      previousIndex = filled ? 2 : 0;
    });

    // jump PageView to index 2 automatically
    if (filled) {
      smIntakePageController.jumpToPage(2);
    }
  }
  bool isShowingInsuranceSavePage = false;
  void switchToInsuranceSavePage() {
    setState(() {
      isShowingInsuranceSavePage = true;
    });
  }

  void goBackToInsuranceTabView() {
    setState(() {
      isShowingInsuranceSavePage = false;
    });
  }

  void selectButton(int index) {
    setState(() {
      previousIndex = selectedIndex;
      selectedIndex = index;
    });

     smIntakePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }
  Object? data;
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


  @override
  Widget build(BuildContext context) {
    final providerContact = Provider.of<SmIntakeProviderManager>(context,listen: false);
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    if (_pdfTextFutureLinkKey != providerContact.isLinkeOpen) {
      _pdfTextFutureLinkKey = providerContact.isLinkeOpen;
      _pdfTextFuture = extractTextFromPdf(providerContact.isLinkeOpen);
    }
    return Row(
      children: [
        isSidebarLeftOpen == true ? Flexible(
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
                                  FutureBuilder<String>(
                                      future: _pdfTextFuture,
                                      builder: (context,snapshot) {
                                        if(snapshot.connectionState == ConnectionState.waiting){
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
                                        if(snapshot.data!.isEmpty){
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
                                                child: Text(snapshot.data!,style: CustomTextStylesCommon.commonStyle(
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
          child: Column(
                children: [
                  const SizedBox(height: AppSize.s25,),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                              // Shift & Batch Button
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
                                    color: selectedIndex == 0 || (previousIndex == 0 && selectedIndex == 2)
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Primary',
                                      style: selectedIndex == 0 || (previousIndex == 0 && selectedIndex == 2) ? BlueBgTabbar.customTextStyle(
                                          0, 0) : BlueBgTabbar.customTextStyle(
                                          0, 1),
                                    ),
                                  ),
                                ),
                              ),
                              // Define Holiday Button
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  selectButton(1);
                                },
                                child: Container(
                                  height: AppSize.s30,
                                  width: AppSize.s155,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                    color: selectedIndex == 1 || (previousIndex == 1 && selectedIndex == 2)
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Secondary',
                                      style: selectedIndex == 1 || (previousIndex == 1 && selectedIndex == 2)? BlueBgTabbar.customTextStyle(
                                          1, 1):BlueBgTabbar.customTextStyle(
                                          1, 2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: 10,
                    child:PageView(
                        controller: smIntakePageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          IntakePrimaryScreen(patientId: widget.patientId,
                            onSave: (){
                            selectButton(2);
                            }
                             , onEditScreen: (){
                              selectButton(2);
                            },
                            isIButtonPressed: providerContact.isRightSliderOpen == true ?
                                (){
                              }
                              :(){
                                toggleLeftSidebar();
                                providerContact.toogleContactProvider();
                                providerContact.toogleLeftSidebarProvider();
                              }, onSkip: () {   selectButton(1); },

                          ),
                          IntakeSecondaryScreen(patientId: widget.patientId, onSave: () {selectButton(2);  },
                            isIButtonPressed: providerContact.isRightSliderOpen == true ?
                                (){
                            }
                                :(){
                              toggleLeftSidebar();
                              providerContact.toogleContactProvider();
                              providerContact.toogleLeftSidebarProvider();
                            }, onSkip: () { widget.onSkip(); },),
                          InsuranceSavePage(
                            patientId: widget.patientId,
                            onPrimaryBack: (){
                              selectButton(0);
                            },
                            onSecondBack: () {
                              selectButton(1);

                            },
                          )
                        ]),
                  ),
                ],
              ),
        ),
      ],
    );
  }
}
