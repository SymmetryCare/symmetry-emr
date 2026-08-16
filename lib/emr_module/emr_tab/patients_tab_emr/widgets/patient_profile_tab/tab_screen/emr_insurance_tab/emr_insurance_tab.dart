import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../../../../../app/resources/provider/sm_provider/sm_slider_provider.dart';
import '../../../../../../../../../app/resources/theme_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../app/services/api/managers/sm_module_manager/intake/patient_insurance_manager.dart';
import '../../../../../../../../../data/api_data/sm_data/sm_intake_data/intake_demographics/patient_insurance_data.dart';
import '../../../../../../../scheduler_model/sm_Intake/widgets/intake_insurance/widgets/intake_insurance_primary/intake_insurance_primary_screen.dart';
import '../../../../../../../scheduler_model/sm_Intake/widgets/intake_insurance/widgets/intake_insurance_secondary/intake_insurance_secondary_screen.dart';
import '../../../../../../../scheduler_model/sm_Intake/widgets/intake_insurance/widgets/save_page/insurance_save_page.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import '../../../../../../../scheduler_model/widgets/constant_widgets/pdf_viewer.dart';
import 'emr_primary_tab.dart';
import 'emr_secondery_tab.dart';

class EmrIsuerenceTab extends StatefulWidget {
  final int patientId;
  const EmrIsuerenceTab({super.key, required this.patientId});

  @override
  State<EmrIsuerenceTab> createState() => _EmrIsuerenceTabState();
}

class _EmrIsuerenceTabState extends State<EmrIsuerenceTab> {
  int selectedIndex = 0;
  final PageController smIntakePageController = PageController();
  bool isSidebarLeftOpen = false;
  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;
  List<PatientInsuranceInfoData> insurancePatientData = [];
  int previousIndex = 0;
  @override
  void initState() {
    super.initState();
    // fetchAIdemoData();
    // final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    fetchPrimaryInsuranceData(ptId: widget.patientId);
    // _animationLeftController = AnimationController(
    //   duration: Duration(milliseconds: 300),
    //   vsync: this,
    // );
    // _slideLeftAnimation = Tween<Offset>(
    //   begin: Offset(-1.0, 0.0), // Off-screen to the right
    //   end: Offset(0.0, 0.0), // On-screen
    // ).animate(CurvedAnimation(parent: _animationLeftController, curve: Curves.easeInOut));


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
  // Future<void> fetchSecoundaryInsuranceData({required int ptId}) async {
  //   final data = await getPatientInsuranceinfo(context: context, ptId: ptId);
  //
  //   // check your condition
  //   final filled = data.isNotEmpty &&
  //       data[1].street.rptiStreet.isNotEmpty &&
  //       data[1].groupName.rptiGroupName.isNotEmpty &&
  //       data[1].email.rptiEmail.isNotEmpty &&
  //       data[1].rptiEffectiveFrom.isNotEmpty &&
  //       data[1].rptiEffectiveTo.isNotEmpty &&
  //       data[1].city.rptiCity.isNotEmpty;
  //
  //   setState(() {
  //     insurancePatientData = data;
  //     previousIndex = filled ? 2 : 1;
  //   });
  //
  //   // jump PageView to index 2 automatically
  //   if (filled) {
  //     smIntakePageController.jumpToPage(2);
  //   }
  // }
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
      // isShowingInsuranceSavePage = false;
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
    // final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
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
                      //height: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(1),
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
                                              color:Color(0xFF686464),
                                              fontWeight: FontWeight.w700,fontSize: 12),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: '${providerContact.isLinkeFileName.toString()} ',
                                              style: CustomTextStylesCommon.commonStyle(
                                                  color:Color(0xFF51B5E6),
                                                  fontWeight: FontWeight.w700,fontSize: 12),
                                            ),
                                            TextSpan(
                                              text: '(Page No.${providerContact.pageCountFromLink.toString()})',
                                              style: CustomTextStylesCommon.commonStyle(
                                                  color:Color(0xFF51B5E6),
                                                  fontWeight: FontWeight.w700,fontSize: 12),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                      future: extractTextFromPdf(providerContact.isLinkeOpen),
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
                                                  color:Color(0xFF686464),
                                                  fontWeight: FontWeight.w400,fontSize: 12,),
                                                ),
                                              ));
                                        }
                                        return Container(
                                          width: MediaQuery.of(context).size.width / 1,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFEEEEEE),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child:Container(
                                                color: Colors.white,
                                                padding: EdgeInsets.all(10),
                                                child: Text(snapshot.data!,style: CustomTextStylesCommon.commonStyle(
                                                  color:Color(0xFF686464),
                                                  fontWeight: FontWeight.w400,fontSize: 12,),),
                                              )

                                          ),
                                        );
                                      }
                                  ),
                                  SizedBox(height: 100,),
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
            : Offstage(),
        Flexible(
          child: Column(
            children: [
              SizedBox(height: AppSize.s25,),
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
                            offset: Offset(0, 4),
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
                      EMRPrimaryScreen(
                        patientId:widget.patientId,
                        onSave: (){
                          selectButton(2);
                        }
                        , onEditScreen: (){
                          selectButton(2);
                        },
                        isIButtonPressed: providerContact.isRightSliderOpen == true ?
                            (){
                          // toggleLeftSidebar();
                          // //providerContact.toogleContactProvider();
                          // providerContact.toogleLeftSidebarProvider();
                          // providerContact.toogleRightSliderProvider();
                        }
                            :(){
                          toggleLeftSidebar();
                          providerContact.toogleContactProvider();
                          // providerContact.toogleLeftSidebarProvider();
                        }, onSkip: () {   selectButton(1); },

                      ),
                      EMRSecondaryScreen(
                        patientId:widget.patientId,
                        //patientId: widget.patientId,
                        onSave: () {selectButton(2);  },
                        isIButtonPressed: providerContact.isRightSliderOpen == true ?
                            (){
                          // toggleLeftSidebar();
                          // //providerContact.toogleContactProvider();
                          // providerContact.toogleLeftSidebarProvider();
                          // providerContact.toogleRightSliderProvider();
                        }
                            :(){
                          toggleLeftSidebar();
                          providerContact.toogleContactProvider();
                          providerContact.toogleLeftSidebarProvider();
                        }, onSkip: () {  },),
                      // InsuranceSavePage(
                      //   //patientId: widget.patientId,
                      //   patientId: 0,
                      //   onPrimaryBack: (){
                      //     selectButton(0);
                      //   },
                      //   onSecondBack: () {
                      //     selectButton(1);
                      //
                      //   },
                      // )
                      // InsuranceSavePage(onBack: () {  }, patientId: 1,),
                      //
                    ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
