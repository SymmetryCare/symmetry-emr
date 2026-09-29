import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/related_parties_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographich_ai_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
// removed in extraction: import '../../../../../textfield_dropdown_constant/schedular_textfield_withbutton_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/address_map_screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_demographics/widgets/patients_related_party/add_button_screen.dart';
class EmergencyContactProvider extends ChangeNotifier {
  // === Emergency Contact State ===
  final List<GlobalKey<_AddEemergencyContactState>> _addEmergencyContactKeys = [];
  bool _isEmergencyVisible = false;

  // === Primary Caregiver State ===
  final List<GlobalKey<PrimaryCaregiverState>> _primaryCaregiverKeys = [];
  bool _isCaregiverVisible = false;

  // === Representative State ===
  final List<GlobalKey<_RepresentativeState>> _representativeKeys = [];
  bool _isRepresentativeVisible = false;

  // === Constructor ===
  EmergencyContactProvider() {
    if (_addEmergencyContactKeys.isEmpty) {
    }
    if (_primaryCaregiverKeys.isEmpty) {
      addCaregiver(initial: true);
    }
    if (_representativeKeys.isEmpty) {
    }
  }

  // === Emergency Contact Methods ===
  List<GlobalKey<_AddEemergencyContactState>> get addEmergencyContactKeys => _addEmergencyContactKeys;
  bool get isEmergencyVisible => _isEmergencyVisible;

  void loadDiagnosisFromApi(List<EmergencyContactData> apiData) {
    _addEmergencyContactKeys.clear();
    for (var _ in apiData) {
      _addEmergencyContactKeys.add(GlobalKey<_AddEemergencyContactState>());
    }
    notifyListeners();
  }

  void addEmergency({bool initial = false}) {
    _addEmergencyContactKeys.add(GlobalKey<_AddEemergencyContactState>());
    notifyListeners();
  }
  void updateEmergencyContact(int index, EmergencyContactData model) {
  }
  void removeEmergency(GlobalKey<_AddEemergencyContactState> key) {
    int index = _addEmergencyContactKeys.indexOf(key);
    if (index != -1) {
      _addEmergencyContactKeys.removeAt(index);
      notifyListeners();
    }
  }

  void setEmergencyVisibility(bool value) {
    _isEmergencyVisible = value;
    notifyListeners();
  }

  void toggleEmergencyVisibility() {
    _isEmergencyVisible = !_isEmergencyVisible;
    notifyListeners();
  }

  // === Primary Caregiver Methods ===
  List<GlobalKey<PrimaryCaregiverState>> get primaryCaregiverKeys => _primaryCaregiverKeys;
  bool get isCaregiverVisible => _isCaregiverVisible;

  void addCaregiver({bool initial = false}) {
    _primaryCaregiverKeys.add(GlobalKey<PrimaryCaregiverState>());
     if (!initial) notifyListeners();
  }

  void removeCaregiver(GlobalKey<PrimaryCaregiverState> key) {
    _primaryCaregiverKeys.remove(key);
    notifyListeners();
  }

  void setCaregiverVisibility(bool value) {
    _isCaregiverVisible = value;
    notifyListeners();
  }

  void toggleCaregiverVisibility() {
    _isCaregiverVisible = !_isCaregiverVisible;
    notifyListeners();
  }

  // === Representative Methods ===
  List<PatientRepresentativeData> _patientRepresentativeData = [];
  List<GlobalKey<_RepresentativeState>> get representativeKeys => _representativeKeys;
  bool get isRepresentativeVisible => _isRepresentativeVisible;
  List<PatientRepresentativeData> get patientRepresentativeData => _patientRepresentativeData;


  void loadRepresentativeFromApi(List<PatientRepresentativeData> apiData) {
    _representativeKeys.clear();
    _patientRepresentativeData = apiData;
    for (var _ in apiData) {
      _representativeKeys.add(GlobalKey<_RepresentativeState>());
    }
    notifyListeners();
  }
  void addRepresentative({bool initial = false}) {
    _representativeKeys.add(GlobalKey<_RepresentativeState>());
    notifyListeners();
  }
  void updateRepresentative(int index, PatientRepresentativeData model) {
    if (index >= 0 && index < _patientRepresentativeData.length) {
      _patientRepresentativeData[index] = model;
      notifyListeners();
    }
  }
  void removeRepresentative(GlobalKey<_RepresentativeState> key) {
    int index = _representativeKeys.indexOf(key);
    if (index != -1) {
      _representativeKeys.removeAt(index);
      _patientRepresentativeData!.removeAt(index);
      notifyListeners();
    }
  }

  void setRepresentativeVisibility(bool value) {
    _isRepresentativeVisible = value;
    notifyListeners();
  }

  void toggleRepresentativeVisibility() {
    _isRepresentativeVisible = !_isRepresentativeVisible;
    notifyListeners();
  }
}
class IntakeRelatedPartiesScreen extends StatefulWidget {
  final int patientId;
  final VoidCallback onIButtonPressed;
  final VoidCallback onSkip;

   const IntakeRelatedPartiesScreen({
    super.key,
    required this.patientId, required this.onIButtonPressed, required this.onSkip,
  });

  @override
  State<IntakeRelatedPartiesScreen> createState() => _IntakeRelatedPartiesScreenState();
}

class _IntakeRelatedPartiesScreenState extends State<IntakeRelatedPartiesScreen> {
   List<GlobalKey<_AddEemergencyContactState>> addEmergencyContactKeys = [];
   List<PatientRepresentativeData> patientRepresentativeData = [];
    List<GlobalKey<_RepresentativeState>> representativeKeys = [];
   List<EmergencyContactData> prefilledData = [];
   bool isLoading = false;
   bool isVisibleContact = false;
   bool copyEmergencyContactPR = false;
   bool copyPrimaryCaregiverPR = false;
   bool noPRData = false;
   void addRepresentative() {
     setState(() {
       representativeKeys.add(GlobalKey<_RepresentativeState>());
     });
   }
   void removeRepresentative(GlobalKey<_RepresentativeState> key) {
     setState(() {
       representativeKeys.remove(key);
     });
   }
   void addEmergency() {
     setState(() {
       addEmergencyContactKeys.add(GlobalKey<_AddEemergencyContactState>());
     });
   }
   void removeEmploymentForm(GlobalKey<_AddEemergencyContactState> key) {
     setState(() {
       addEmergencyContactKeys.remove(key);
     });
   }
  @override
  void initState() {
    // TODO: implement initState
    loadInitialemergencyData();
    loadInitialrepresentative();
    super.initState();
  }

  Future<void> loadInitialrepresentative() async{
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    final providerState = Provider.of<EmergencyContactProvider>(context, listen: false);
    List<PatientRepresentativeData> apiDataRepresentative = await getPatientRepresentative(context: context, ptId: provider.patientId);
    if(apiDataRepresentative.isEmpty){
      setState(() {
        addRepresentative();
      });

    }else{
      setState(() {
        patientRepresentativeData = apiDataRepresentative; // Store the prefilled data
        representativeKeys = List.generate(
          patientRepresentativeData.length,
              (index) => GlobalKey<_RepresentativeState>(),
        );
      });
    }
  }
  Future<void> loadInitialemergencyData() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    final providerState = Provider.of<EmergencyContactProvider>(context, listen: false);
    List<EmergencyContactData> apiData = await getPatientEmergencyContact(context: context, ptId: provider.patientId);

    if (apiData.isEmpty) {
      // If no data exists, allow user to add a new form
      setState(() {
        addEmergency();
      });
    } else {
      setState(() {
        prefilledData = apiData; // Store the prefilled data
        addEmergencyContactKeys = List.generate(
          prefilledData.length,
              (index) => GlobalKey<_AddEemergencyContactState>(),
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final providerPtId = Provider.of<DiagnosisProvider>(context, listen: false);
    final providerUpdate = Provider.of<SmIntakeProviderManager>(context,listen: false);
    bool noEmergencyData = false;
    bool noEmergencyContact = false;
    return Scaffold(
      backgroundColor: ColorManager.white,
      body:  Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10,right: 36,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Review and confirm the data pulled is correct  ',
                            style: SMItalicTextConst.customTextStyle(context))
                      ],
                    ),
                  ),
                  providerUpdate.isLeftSidebarOpen ? Container(
                    child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap:(){
                          widget.onIButtonPressed();
                          providerUpdate.setLinkAndPageClear();
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
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: BlueBGHeadConst(HeadText: "Emergency Contact*",
                    body:  StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p50,),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: AppSize.s16),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                  ],
                                ),
                                const SizedBox(height: AppSize.s16),
                                noEmergencyData ? const Offstage() :Column(
                                  children: addEmergencyContactKeys.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    GlobalKey<_AddEemergencyContactState> key = entry.value;
                                    return AddEemergencyContact(
                                      key: key,
                                      index: index + 1,
                                      onRemove: () => removeEmploymentForm(key),
                                      patientId: widget.patientId,
                                      isVisible: isVisibleContact,
                                      oniButton: widget.onIButtonPressed,
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: AppSize.s16),
                                noEmergencyData ? const Offstage() :CustomIconButtonConst(
                                    width:  AppSize.s200,
                                    text: 'Add Emergency Contact',
                                    icon: Icons.add,
                                    onPressed: () {
                                      setState(() {
                                        isVisibleContact = true;
                                        addEmergency();
                                      });

                                      //Provider.of<EmergencyContactProvider>(context,listen: false).addEmergency();
                                    }),
                                const SizedBox(height: AppSize.s16),
                                const Divider(),
                              ],
                            ),
                          );}
                    ),
                        ),
                  ),

                  const SizedBox(height: AppSize.s40),
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: BlueBGHeadConst(HeadText: "Patient Representative*",
                    body:  StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Column(
                              children: [
                                const SizedBox(height: AppSize.s16),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                  ],
                                ),
                                noPRData ? const Offstage() :Column(
                                  children: representativeKeys.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    GlobalKey<_RepresentativeState> key = entry.value;
                                    //List<PatientRepresentativeData> data = provider._patientRepresentativeData;
                                    return Representative(
                                      key: key,
                                      index: index + 1,
                                      onRemove: () => removeRepresentative(key),
                                      patientId: widget.patientId,
                                      isVisible: isVisibleContact,
                                      oniButton: widget.onIButtonPressed,
                                      // patientRepresentativeData: data,
                                      // onChanged: (int index, PatientRepresentativeData updatedModel) {
                                      //   provider.updateRepresentative(index, updatedModel);
                                      // },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: AppSize.s16),
                                noPRData ? const Offstage() :CustomIconButtonConst(
                                    width:  AppSize.s170,
                                    text: 'Add Representative',
                                    icon: Icons.add,
                                    onPressed: () {
                                      setState(() {
                                        addRepresentative();
                                      });

                                    }),
                                const SizedBox(height: AppSize.s16),
                                const Divider(),
                              ],
                            ),
                          );}
                    ),),
                  ),

                  const SizedBox(height: AppSize.s80),
                  StatefulBuilder(
                   builder: (BuildContext context, void Function(void Function()) setState) {
                   return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        SkipButtonTransparent(
                          text: "Skip",
                          onPressed: () {
                            print("🔹 Skip button tapped - going to document screen");
                            widget.onSkip(); // This should trigger jumpToPage(4)
                          },
                        ),
                        CustomElevatedButton(
                          width: AppSize.s100,
                          text: AppString.save,
                          isLoading: isLoading,
                          onPressed: () async{
                            var responseEc;
                            var responseRr;
                            bool errorShown = false;
                            var state;
                            var rpState;
                            try{
                              setState(() {
                                isLoading = true; // Start loading
                              });
                              for (var key in addEmergencyContactKeys) {
                                 state = key.currentState!;
                                print('Prefill state ${state.isPrefill}');
                                 // final AddemergencyProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);
                                try {
                                    if(state.isPrefill == false || noEmergencyContact == true){
                                        responseEc = await addPatientEmergencyContact(
                                          context: context,
                                          no_emergency_contact: noEmergencyData,
                                          ec_fk_pt_id: providerPtId.patientId,
                                          ec_firstName: state.firstNameController.text,
                                          ec_lastname: state.lastNameController.text,
                                          ec_relationshipId: state.relationShipId,
                                          ec_street:  state.streetController.text,
                                          ec_suite: state.suitAptController.text,
                                          ec_city:state.cityController.text ,
                                          ec_state: state.stateController.text,
                                          ec_zipCode: state.zipCodeController.text,
                                          ec_phoneNumber: state.phoneNumberController.text,
                                          ec_email: state.emailController.text,
                                        );

                                    }
                                    else{
                                      print('No Data Updated');
                                    }

                                } catch (e) {
                                  print(e);
                                }
                              }
                              for (var key in representativeKeys ) {
                                rpState = key.currentState!;
                                print('Prefill PR state ${rpState.prefillDataRepresent}');
                                // final RepresentativeProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);
                                try {
                                  if(rpState.prefillDataRepresent == false || noPRData == true){
                                    // Proceed with posting the employment data if the conditions are met
                                      responseRr = await addPatientRepresent(
                                          context: context,
                                          no_patient_representative: noPRData,
                                          re_fk_pt_id: providerPtId.patientId,
                                          re_firstName: rpState
                                              .firstNamePRController.text,
                                          re_lastname: rpState
                                              .lastNamePRController.text,
                                          re_relationshipId: rpState
                                              .relationshipId,
                                          re_street: rpState.streetPRController
                                              .text ,
                                          re_suite: rpState.suitAptPRController
                                              .text,
                                          re_city: rpState.ctlrCity.text,
                                          re_state:rpState.ctlrState.text,
                                          re_zipCode: rpState
                                              .zipCodePRController.text,
                                          re_phoneNumber: rpState
                                              .phoneNumberPRController.text,
                                          re_email: rpState.emailPRController
                                              .text,
                                          re_role: rpState.roleId,
                                          re_type: rpState.typeId
                                      );

                                  }
                                  else{
                                    print('No Represent Data Updated');
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              }

                              // if(state.mailController.text.isEmpty || rpState.emailPRController.text.isEmpty){
                              //    errorShown = true;
                              // }else{
                              //   if(state.isPrefill == false || noEmergencyContact == true){
                              //     // Proceed with posting the employment data if the conditions are met
                              //     print('state email : ${ state.emailPRController.text}');
                              //       errorShown = false;
                              //       responseEc = await addPatientEmergencyContact(
                              //         context: context,
                              //         no_emergency_contact: noEmergencyData,
                              //         ec_fk_pt_id: providerPtId.patientId,
                              //         ec_firstName: state.firstNameController.text,
                              //         ec_lastname: state.lastNameController.text,
                              //         ec_relationshipId: state.relationShipId,
                              //         ec_street: state.streetController.text,
                              //         ec_suite: state.suitAptController.text,
                              //         ec_city: state.cityController.text,
                              //         ec_state: state.stateController.text,
                              //         ec_zipCode: state.zipCodeController.text,
                              //         ec_phoneNumber: state.phoneNumberController.text,
                              //         ec_email: state.emailController.text,
                              //       );
                              //
                              //   }
                              //   else{
                              //     print('No Data Updated');
                              //   }
                              //   if(rpState.prefillDataRepresent == false || noPRData == true){
                              //     // Proceed with posting the employment data if the conditions are met
                              //     print('pr email : ${rpState.emailPRController.text}');
                              //     errorShown = false;
                              //       responseRr =  await addPatientRepresent(
                              //           context: context,
                              //           no_patient_representative: noPRData,
                              //           re_fk_pt_id: providerPtId.patientId,
                              //           re_firstName: rpState.firstNamePRController.text,
                              //           re_lastname: rpState.lastNamePRController.text,
                              //           re_relationshipId: rpState.relationshipId,
                              //           re_street: rpState.streetPRController.text,
                              //           re_suite: rpState.suitAptPRController.text,
                              //           re_city: rpState.ctlrCity.text,
                              //           re_state: rpState.ctlrState.text,
                              //           re_zipCode: rpState.zipCodePRController.text,
                              //           re_phoneNumber: rpState.phoneNumberPRController.text,
                              //           re_email: rpState.emailPRController.text,
                              //           re_role: rpState.roleId,
                              //           re_type: rpState.typeId
                              //       );
                              //   }
                              //   else{
                              //     print('No Represent Data Updated');
                              //   }
                              // }

                            }finally{
                                if (responseEc.statusCode == 200 || responseEc.statusCode == 201
                                    ||responseRr.statusCode == 200 || responseRr.statusCode == 201) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const AddSuccessPopup(
                                        message: 'Data Saved successfully',
                                      );
                                    },
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const AddErrorPopup(
                                      message: 'Please Check Your Input And Try Again',
                                    ),
                                  );
                                  print(
                                      'API Error: responseEc=${responseEc?.statusCode}, responseRr=${responseRr?.statusCode}');

                                }
                                loadInitialrepresentative();
                                loadInitialemergencyData();


                              setState(() {
                                isLoading = false; // Start loading
                              });
                            }
                          },
                        ),
                      ],
                    );}
                  ),
                  const SizedBox(height: AppSize.s30),

                ],
              ),
            ),
          ),

    );
  }
}


/// Emergency contact
class AddEemergencyContact extends StatefulWidget {
  final int patientId;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  final VoidCallback oniButton;
  // final List<EmergencyContactData> emergencyContactData;
  // final Function(int index, EmergencyContactData updatedModel) onChanged;
  const AddEemergencyContact({super.key, required this.patientId, required this.onRemove, required this.index, required this.isVisible, required this.oniButton,
    // required this.emergencyContactData,
    // required this.onChanged
  });

  @override
  _AddEemergencyContactState createState() => _AddEemergencyContactState();
}

class _AddEemergencyContactState extends State<AddEemergencyContact> {
  bool isPrefill = true;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController suitAptController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  int relationShipId = 0;
  int contactId = 0;
  int ptId = 0;
  late Future<List<RelationshipData>> _relationshipDropDownFuture;

  @override
  void initState() {
    super.initState();
    _relationshipDropDownFuture = getRelationshipDropDown(context);
    _initializeFormWithPrefilledData();
    // fetchAIdemoData();
    // if (widget.emergencyContactData.length >= widget.index) {
    //   final data = widget.emergencyContactData[widget.index];
    //   firstNameController.text = data.firstName;
    //   lastNameController.text = data.lastName;
    //   suitAptController.text = data.suite;
    //   streetController.text = data.street;
    //   stateController.text = data.state;
    //   cityController.text = data.city;
    //   phoneNumberController.text = data.phoneNumber;
    //   zipCodeController.text = data.zipCode;
    //   emailController.text = data.email;
    //   relationShipId = data.fk_Relationship;
    //   contactId = data.contactId;
    //   ptId = data.fk_pt_id;
    // }
    //
    // firstNameController.addListener(_updateModel);
    // lastNameController.addListener(_updateModel);
    // suitAptController.addListener(_updateModel);
    // streetController.addListener(_updateModel);
    // stateController.addListener(_updateModel);
    // cityController.addListener(_updateModel);
    // phoneNumberController.addListener(_updateModel);
    // zipCodeController.addListener(_updateModel);
    // emailController.addListener(_updateModel);
  }
  // AiEmergencyContactData? fetchedData;
  // var data;
  // // final providerPatientId = Provider.of<DiagnosisProvider>(context,listen: false);
  // Future<void> fetchAIdemoData() async{
  //   final providerPatientId = Provider.of<DiagnosisProvider>(context,listen: false);
  //   data = await getAIEmergencyContact(context: context, ptId: providerPatientId.patientId);
  //   // notifyListeners();
  //   setState(() {
  //     fetchedData = data;
  //   });
  //   // fetchedData = data;
  // }
  // void _updateModel() {
  //   final updatedModel = EmergencyContactData(
  //       contactId: contactId,
  //       fk_pt_id: ptId,
  //       firstName: firstNameController.text,
  //       lastName: lastNameController.text,
  //       fk_Relationship: relationShipId,
  //       street: streetController.text,
  //       suite: suitAptController.text,
  //       city: cityController.text,
  //       state: stateController.text,
  //       zipCode: zipCodeController.text,
  //       phoneNumber: phoneNumberController.text,
  //       email: emailController.text
  //
  //   );
  //
  //   widget.onChanged(widget.index, updatedModel);
  // }
  void openMapRelatedECScreen() async {
    // clearMapAddressOnRelatedPartiesController();
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
        streetController.text = result['address'] ?? '';
        cityController.text = result['city'] ?? '';
        stateController.text = result['state'] ?? '';
        // = TextEditingController(text:address );
        // notifyListeners();
        // });
      }
    }
  }
  List<EmergencyContactData> prefilledData = [];

  Future<void> _initializeFormWithPrefilledData() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    final AddemergencyProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);
    try {
      prefilledData =  await getPatientEmergencyContact(context: context, ptId: provider.patientId);
      if (prefilledData.isNotEmpty) {
        var data = prefilledData[widget.index - 1]; // Assuming index matches the data list
        setState(() {
          firstNameController.text = firstNameController.text.isEmpty ? data.firstName.value ?? '' : firstNameController.text;
          cityController.text = cityController.text.isEmpty ? data.city.city ?? '' :  cityController.text;
          lastNameController.text = lastNameController.text.isEmpty ? data.lastName.value ?? '' : lastNameController.text;
          cityController.text = cityController.text.isEmpty ? data.city.city ?? '' : cityController.text;
          suitAptController.text = suitAptController.text.isEmpty ? data.suite.suite ?? '' : suitAptController.text;
          stateController.text = data.state.state ?? '';
          streetController.text = AddemergencyProvider.ctlrStreetRelatedECProvider.text.isEmpty ?  data.street.street ?? '' : AddemergencyProvider.ctlrStreetRelatedECProvider.text;
          relationShipId = data.relationship.relationshipId??0;
          emailController.text = emailController.text.isEmpty ? data.email.value?? '' : emailController.text;
          phoneNumberController.text = phoneNumberController.text.isEmpty ? data.phoneNumber.value ?? '' : phoneNumberController.text;
          zipCodeController.text = zipCodeController.text.isEmpty ? data.zipcode.zipcode ?? '' : zipCodeController.text;
          contactId = data.contactId ??0;
          ptId = data.fkPtId ?? 0;


        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    print('First name ${firstNameController.text}');
    String? selectedRelationshipEC;
    final AddemergencyProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.index > 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              child:Column(
                children: [
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: Icon(Icons.delete_outline_rounded, color:   ColorManager.blueprime, ),
                        onPressed: ()async {
                        var response = await deletePatientEmergencyContact(context: context, recordId: contactId);
                          widget.onRemove();
                        },
                      ),
                    ],
                  )
                ],
              ) ,),
          ),
        const SizedBox(height: 16,),
        AddemergencyProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].firstName.link).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].firstName.pageNo,
                        isLinkeOpen: prefilledData[widget.index - 1].firstName.link);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].firstName.link.isEmpty ? true : false),
                  controller: firstNameController,
                  labelText: 'First Name*',
                  onChanged: (value){
                    if(value.isNotEmpty ){
                      isPrefill= false;
                    }
                  },
                )),
            SizedBox(width:AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].lastName.link).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].lastName.pageNo,
                        isLinkeOpen: prefilledData[widget.index - 1].lastName.link);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].lastName.link.isEmpty ? true : false),
                  controller: lastNameController,
                  labelText: 'Last Name*',
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                )),
            SizedBox(width: AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
              child:FutureBuilder<List<RelationshipData>>(
                future: _relationshipDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(
                      initialValue: 'Select',
                      headText: 'Relationship*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.relationship!),
                        value: i.relationship,
                      ));
                    }

                    // Match prefilled value from snapshot data
                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.relationshipId == relationShipId) {
                        prefillValue = rel.relationship;
                        break;
                      }
                    }

                    return CustomDropdownTextFieldsm(
                      headText: 'Relationship*',
                      dropDownMenuList: dropDownList,
                      hintText: prefillValue ?? 'Select',
                      onChanged: (newValue) {
                        for (var a in snapshot.data!) {
                          if (a.relationship == newValue) {
                            selectedRelationshipEC = a.relationship!;
                            relationShipId = a.relationshipId;

                            //country = a
                            // int? docType = a.companyOfficeID;
                          }
                        }
                      },);


                  } else {
                    return const Offstage();
                  }
                },
              ),
            ),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].firstName.link).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].firstName.pageNo,
                        isLinkeOpen: prefilledData[widget.index - 1].firstName.link);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].firstName.link.isEmpty ? true : false),
                  controller: firstNameController,
                  labelText: 'First Name*',
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                )),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].lastName.link).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].lastName.pageNo,
                        isLinkeOpen: prefilledData[widget.index - 1].lastName.link);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].lastName.link.isEmpty ? true : false),
                  controller: lastNameController,
                  labelText: 'Last Name*',
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                )),
            const SizedBox(width: AppSize.s35),
            Flexible(
              child:FutureBuilder<List<RelationshipData>>(
                future: _relationshipDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(

                      headText: 'Relationship*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.relationship!),
                        value: i.relationship,
                      ));
                    }

                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.relationshipId == relationShipId) {
                        prefillValue = rel.relationship;
                        break;
                      }
                    }

                    return CustomDropdownTextFieldsm(headText: 'Relationship*',dropDownMenuList: dropDownList,
                      hintText: prefillValue ?? 'Select',
                      onChanged: (newValue) {
                        for (var a in snapshot.data!) {
                          if (a.relationship == newValue) {
                            selectedRelationshipEC = a.relationship!;
                            relationShipId = a.relationshipId;
                            //country = a
                            // int? docType = a.companyOfficeID;
                          }
                        }
                      },);


                  } else {
                    return const Offstage();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSize.s35),
            const Flexible(
                child: SizedBox()),
            const SizedBox(width: AppSize.s35),
            const Flexible(
                child: SizedBox()),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        AddemergencyProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    isIconClicked: true,
                    iconClickedPress:(){
                      openMapRelatedECScreen();
                    },
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].street.streetLink).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].street.streetPgNo,
                          isLinkeOpen: prefilledData[widget.index - 1].street.streetLink);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
    ? true
        : (prefilledData[widget.index - 1].street.streetLink.isEmpty ? true : false),
                    controller: streetController,
                    icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                    labelText: "Street*")),
            SizedBox(width:AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].suite.suiteLink).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].suite.suitePgNo,
                          isLinkeOpen: prefilledData[widget.index - 1].suite.suiteLink);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].suite.suiteLink.isEmpty ? true : false),
                    controller: suitAptController,
                    labelText: "Suite/Apt#")),
            SizedBox(width: AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
              // child: FutureBuilder<List<CityData>>(
              //   future: getCityDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'City*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.cityName!),
              //           value: i.cityName,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'City*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.cityName == newValue) {
              //               selectedCityEC = a.cityName!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),
              ///
              child: SchedularTextField(
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].city.cityLink).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].city.cityPgNo,
                        isLinkeOpen: prefilledData[widget.index - 1].city.cityLink);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].city.cityLink.isEmpty ? true : false),
                  controller: AddemergencyProvider.ctlrCityRelatedECProvider.text.isEmpty ? cityController : AddemergencyProvider.ctlrCityRelatedECProvider,
                  labelText: "City*"),
            ),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    isIconClicked: true,
                    iconClickedPress:(){
                      openMapRelatedECScreen();
                    },
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].street.streetLink).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].street.streetPgNo,
                          isLinkeOpen: prefilledData[widget.index - 1].street.streetLink);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].street.streetLink.isEmpty ? true : false),
                    controller: streetController,
                    icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                    labelText: "Street*")),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].suite.suiteLink).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].suite.suitePgNo,
                          isLinkeOpen: prefilledData[widget.index - 1].suite.suiteLink);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].suite.suiteLink.isEmpty ? true : false),
                    controller: suitAptController,
                    labelText: "Suite/Apt#")),
            const SizedBox(width: AppSize.s35),
            Flexible(
              // child: FutureBuilder<List<CityData>>(
              //   future: getCityDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'City*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.cityName!),
              //           value: i.cityName,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'City*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.cityName == newValue) {
              //               selectedCityEC = a.cityName!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),
              ///
              child: SchedularTextField(
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].city.cityLink).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].city.cityPgNo,
                        isLinkeOpen: prefilledData[widget.index - 1].city.cityLink);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].city.cityLink.isEmpty ? true : false),
                  controller:  cityController,
                  labelText: "City*"),
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
              // child:FutureBuilder<List<StateData>>(
              //   future: getStateDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'State*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.name),
              //           value: i.name,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'State*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.name == newValue) {
              //               selectedStateEC = a.name!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),
              ///
              child: SchedularTextField(
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].state.stateLink).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].state.statePgNo,
                        isLinkeOpen: prefilledData[widget.index - 1].state.stateLink);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].state.stateLink.isEmpty ? true : false),
                  controller:  stateController,
                  labelText: "State*"),
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].zipcode.zipcodeLink).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].zipcode.zipcodePgNo,
                          isLinkeOpen: prefilledData[widget.index - 1].zipcode.zipcodeLink);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].zipcode.zipcodeLink.isEmpty ? true : false),
                    controller: zipCodeController,
                    allowSSNBR: true,
                    // onlyAllowNumbers: true,
                    labelText: "Zip Code*")),

          ],
        ),
        const SizedBox(height: AppSize.s16),
        AddemergencyProvider.isContactTrue ?  Row(
          children: [
            Flexible(
              // child:FutureBuilder<List<StateData>>(
              //   future: getStateDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'State*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.name),
              //           value: i.name,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'State*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.name == newValue) {
              //               selectedStateEC = a.name!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),
              ///
              child: SchedularTextField(
                  onChanged: (value){
                    if(value.isNotEmpty){
                      isPrefill= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    AddemergencyProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(prefilledData[widget.index - 1].state.stateLink).pathSegments.last,
                        pageNo: prefilledData[widget.index - 1].state.statePgNo,
                        isLinkeOpen: prefilledData[widget.index - 1].state.stateLink);

                  },
                  isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                      ? true
                      : (prefilledData[widget.index - 1].state.stateLink.isEmpty ? true : false),
                  controller: stateController,
                  labelText: "State*"),
            ),
            SizedBox(width:AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].zipcode.zipcodeLink).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].zipcode.zipcodePgNo,
                          isLinkeOpen: prefilledData[widget.index - 1].zipcode.zipcodeLink);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].zipcode.zipcodeLink.isEmpty ? true : false),
                    controller: zipCodeController,
                    allowSSNBR: true,
                    // onlyAllowNumbers: true,
                    labelText: "Zip Code*")),
            SizedBox(width: AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty ){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].phoneNumber.link).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].phoneNumber.pageNo,
                          isLinkeOpen: prefilledData[widget.index - 1].phoneNumber.link);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].phoneNumber.link.isEmpty ? true : false),
                    controller: phoneNumberController,
                    phoneField: true,
                    labelText: "Phone Number*")),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].phoneNumber.link).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].phoneNumber.pageNo,
                          isLinkeOpen: prefilledData[widget.index - 1].phoneNumber.link);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].phoneNumber.link.isEmpty ? true : false),
                    controller: phoneNumberController,
                    phoneField: true,
                    labelText: "Phone Number*")),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].email.link).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].email.pageNo,
                          isLinkeOpen: prefilledData[widget.index - 1].email.link);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].email.link.isEmpty ? true : false),
                    controller: emailController,
                    labelText: "Email")),
            // Empty container for alignment
            const SizedBox(width: AppSize.s35),
            Flexible(child: Container()),
            const SizedBox(width: AppSize.s35),
            Flexible(child: Container()),
            const SizedBox(width: AppSize.s35),
            Flexible(child: Container()),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        AddemergencyProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    onChanged: (value){
                      if(value.isNotEmpty){
                        isPrefill= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      AddemergencyProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(prefilledData[widget.index - 1].email.link).pathSegments.last,
                          pageNo: prefilledData[widget.index - 1].email.pageNo,
                          isLinkeOpen: prefilledData[widget.index - 1].email.link);

                    },
                    isIconVisible:(prefilledData.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= prefilledData.length)
                        ? true
                        : (prefilledData[widget.index - 1].email.link.isEmpty ? true : false),
                    controller: emailController,
                    labelText: "Email")),
            // Empty container for alignment
            SizedBox(width:AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(child: Container()),
            SizedBox(width: AddemergencyProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(child: Container()),
          ],
        )
            : const Offstage(),
      ],
    );
  }
}


/// Representive screen
class Representative extends StatefulWidget {
  final int patientId;
  final VoidCallback onRemove;
  final int index;
  final bool isVisible;
  final VoidCallback oniButton;
  // final List<PatientRepresentativeData> patientRepresentativeData;
  // final Function(int index, PatientRepresentativeData updatedModel) onChanged;
  const Representative({super.key, required this.patientId, required this.onRemove, required this.index, required this.isVisible, required this.oniButton,
    // required this.patientRepresentativeData, required this.onChanged
  });

  @override
  _RepresentativeState createState() => _RepresentativeState();
}

class _RepresentativeState extends State<Representative> {
  bool prefillDataRepresent = true;
  TextEditingController firstNamePRController = TextEditingController();
  TextEditingController lastNamePRController = TextEditingController();
  TextEditingController streetPRController = TextEditingController();
  TextEditingController ctlrCity = TextEditingController();
  TextEditingController suitAptPRController = TextEditingController();
  TextEditingController phoneNumberPRController = TextEditingController();
  TextEditingController zipCodePRController = TextEditingController();
  TextEditingController emailPRController = TextEditingController();
  TextEditingController ctlrState = TextEditingController();
  String roleName = 'Select';
  String typeName = 'Select';
  int relationshipId = 0;
  int roleId = 0;
  int typeId = 0;
  int ptId = 0;
  int representId = 0;
  late Future<List<RelationshipData>> _relationshipDropDownFuture;
  late Future<List<RelatedPartiesRoleData>> _relataedRoleDropDownFuture;
  late Future<List<RelatedPatiesTypeData>> _relataedTypeDropDownFuture;
  @override
  void initState() {
    super.initState();
    _relationshipDropDownFuture = getRelationshipDropDown(context);
    _relataedRoleDropDownFuture = getRelataedRoleDropDown(context: context);
    _relataedTypeDropDownFuture = getRelataedTypeDropDown(context: context);
    _initializeFormWithPrefilledData();
    // fetchAIdemoData();
  }
  void openMapRelatedRPScreen() async {
    // clearMapAddressOnRelatedPartiesController();
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
        streetPRController.text = result['address'] ?? '';
        ctlrCity.text = result['city'] ?? '';
        ctlrState.text = result['state'] ?? '';
        // = TextEditingController(text:address );
        // });
      }
    }
  }
  List<PatientRepresentativeData> apiDataRepresentative = [];
  bool _isLoading = false;
  Future<void> _initializeFormWithPrefilledData() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);
    final RepresentativeProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      apiDataRepresentative   = await getPatientRepresentative(context: context, ptId: provider.patientId);
      if (apiDataRepresentative.isNotEmpty) {
        var data = apiDataRepresentative[widget.index - 1]; // Assuming index matches the data list
        setState(() {
          firstNamePRController.text = firstNamePRController.text.isEmpty ? data.firstName.value ?? '' : firstNamePRController.text;
          ctlrCity.text = data.city.city ?? '' ;
          lastNamePRController.text = lastNamePRController.text.isEmpty ? data.lastName.value ?? '' : lastNamePRController.text;
          suitAptPRController.text =suitAptPRController.text.isEmpty ? data.suite.suite ?? '' : suitAptPRController.text;
          ctlrState.text = data.state.state ?? '' ;
          streetPRController.text = data.street.street ?? '';
          relationshipId = data.relationship.relationshipId??0;
          emailPRController.text = emailPRController.text.isEmpty ? data.email.value ?? '' : emailPRController.text;
          phoneNumberPRController.text = phoneNumberPRController.text.isEmpty ? data.phoneNumber.value ?? '' : phoneNumberPRController.text;
          zipCodePRController.text = zipCodePRController.text.isEmpty ? data.zipcode.zipcode ?? '' : zipCodePRController.text;
          representId = data.representative_id ??0;
          ptId = data.fkPtId ?? 0;
          roleId = data.role.roleId ?? 0;
          typeId = data.type.typeId ?? 0;
          roleName = data.role.roleName ?? '';
          typeName = data.type.typeName ?? '';
          print('role Name ${roleName}');
          print('type Name ${typeName}');
        });
      }
      // setState(() {
      //   _isLoading = false;
      // });
    } catch (e) {
      print('Failed to load prefilled data: $e');
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }
  @override
  Widget build(BuildContext context) {
    final RepresentativeProvider = Provider.of<SmIntakeProviderManager>(context, listen: false);

    String? selectedRelationshipEC;
    String? selectedRole;
    String? selectedType;
    bool copyEmergencyContactPR = false;
    bool copyPrimaryCaregiverPR = false;
    bool noPRData = false;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.index > 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              child:Column(
                children: [
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        icon: Icon(Icons.delete_outline_rounded, color:   ColorManager.blueprime, ),
                        onPressed: ()async {
                          var response = await deletePatientRepresent(context: context, recordId: representId);
                          widget.onRemove();
                        },
                      ),
                    ],
                  )
                ],
              ) ,),
          ),

        // Padding(
        //   padding: EdgeInsets.only(top: widget.index > 1 ? 10 : 20),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: [
        //           CheckboxTile(
        //             title: 'Copy Emergency Contact',
        //             initialValue: copyEmergencyContactPR,
        //             onChanged: (value) {
        //               // Handle state change
        //             },
        //           ),
        //           const SizedBox(width: 20),
        //           CheckboxTile(
        //             title: 'Copy Primary Caregiver',
        //             initialValue: copyPrimaryCaregiverPR,
        //             onChanged: (value) {
        //               // Handle state change
        //             },
        //           ),
        //         ],
        //       ),
        //       (widget.index > 1)
        //           ? IconButton(
        //         splashColor: Colors.transparent,
        //         highlightColor: Colors.transparent,
        //         hoverColor: Colors.transparent,
        //         icon: Icon(Icons.delete_outline_rounded, color: ColorManager.bluebottom),
        //         onPressed: widget.onRemove,
        //       )
        //           : CheckboxTile(
        //         title: 'No Selected Representative',
        //         initialValue: noPRData,
        //         onChanged: (value) {
        //           setState(() {
        //             noPRData = value;
        //           });
        //           // Handle state change
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: AppSize.s16),
        RepresentativeProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].firstName.link.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].firstName.link).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].firstName.pageNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].firstName.link);

                  },
                  controller: firstNamePRController,
                  labelText: 'First Name*',

                )),
            SizedBox(width:RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].lastName.link.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].lastName.link).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].lastName.pageNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].lastName.link);

                  },
                  controller: lastNamePRController,
                  labelText: 'Last Name*',
                )),
            SizedBox(width: RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
              child:FutureBuilder<List<RelationshipData>>(
                future: _relationshipDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(
                      headText: 'Relationship*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.relationship!),
                        value: i.relationship,
                      ));
                    }
                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.relationshipId == relationshipId) {
                        prefillValue = rel.relationship;
                        break;
                      }
                    }

                    return
                      CustomDropdownTextFieldsm(headText: 'Relationship*',
                        dropDownMenuList: dropDownList,
                        hintText: prefillValue ?? 'Select',
                        onChanged: (newValue) {
                          for (var a in snapshot.data!) {
                            if (a.relationship == newValue) {
                              selectedRelationshipEC = a.relationship!;
                              relationshipId = a.relationshipId;
                              //country = a
                              // int? docType = a.companyOfficeID;
                            }
                          }
                        },);


                  } else {
                    return const Offstage();
                  }
                },
              ),
            ),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].firstName.link.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].firstName.link).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].firstName.pageNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].firstName.link);

                  },
                  controller: firstNamePRController,
                  labelText: 'First Name*',

                )),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].lastName.link.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].lastName.link).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].lastName.pageNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].lastName.link);

                  },
                  controller: lastNamePRController,
                  labelText: 'Last Name*',
                )),
            const SizedBox(width: AppSize.s35),
            Flexible(
              child:FutureBuilder<List<RelationshipData>>(
                future: _relationshipDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(

                      headText: 'Relationship*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.relationship!),
                        value: i.relationship,
                      ));
                    }
                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.relationshipId == relationshipId) {
                        prefillValue = rel.relationship;
                        break;
                      }
                    }

                    return
                      CustomDropdownTextFieldsm(headText: 'Relationship*',dropDownMenuList: dropDownList,
                        hintText: prefillValue ?? 'Select',
                        onChanged: (newValue) {
                          for (var a in snapshot.data!) {
                            if (a.relationship == newValue) {
                              selectedRelationshipEC = a.relationship!;
                              relationshipId = a.relationshipId;
                              //country = a
                              // int? docType = a.companyOfficeID;
                            }
                          }
                        },);


                  } else {
                    return const Offstage();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
              child: FutureBuilder<List<RelatedPartiesRoleData>>(
                future: _relataedRoleDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(

                      headText: 'Role*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.roleName!),
                        value: i.roleName,
                      ));
                    }
                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.roleId == roleId) {
                        prefillValue = rel.roleName;
                        break;
                      }
                    }


                    return
                      CustomDropdownTextFieldsm(headText: 'Role*',dropDownMenuList: dropDownList,
                        hintText: prefillValue ?? 'Select',
                        onChanged: (newValue) {
                          for (var a in snapshot.data!) {
                            if (a.roleName == newValue) {
                              selectedRole = a.roleName!;
                              roleId = a.roleId;
                              roleName = a.roleName;
                              //country = a
                              // int? docType = a.companyOfficeID;
                            }
                          }
                        },);


                  } else {
                    return const Offstage();
                  }
                },
              ),),
            const SizedBox(width: AppSize.s35),
            Flexible(child: FutureBuilder<List<RelatedPatiesTypeData>>(
              future: _relataedTypeDropDownFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CustomDropdownTextFieldsm(

                    headText: 'Type*',items: const [],
                    onChanged: (newValue) {

                    },);
                }
                if (snapshot.hasData) {
                  List<DropdownMenuItem<String>> dropDownList = [];
                  for (var i in snapshot.data!) {
                    dropDownList.add(DropdownMenuItem<String>(
                      child: Text(i.typeName!),
                      value: i.typeName,
                    ));
                  }
                  String? prefillValue;
                  for (var rel in snapshot.data!) {
                    if (rel.typeId == typeId) {
                      prefillValue = rel.typeName;
                      break;
                    }
                  }
                  return
                    CustomDropdownTextFieldsm(headText: 'Type*',dropDownMenuList: dropDownList,
                      hintText: prefillValue ?? 'Select',
                      onChanged: (newValue) {
                        for (var a in snapshot.data!) {
                          if (a.typeName == newValue) {
                            selectedType = a.typeName!;
                            typeId = a.typeId;
                            typeName = a.typeName;
                            //country = a
                            // int? docType = a.companyOfficeID;
                          }
                        }
                      },);
                } else {
                  return const Offstage();
                }
              },
            ),),

          ],
        ),
        const SizedBox(height: AppSize.s16),
        RepresentativeProvider.isContactTrue ?  Row(
          children: [
            Flexible(
              child: FutureBuilder<List<RelatedPartiesRoleData>>(
                future: _relataedRoleDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(
                      headText: 'Role*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.roleName!),
                        value: i.roleName,
                      ));
                    }
                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.roleId == roleId) {
                        prefillValue = rel.roleName;
                        break;
                      }
                    }

///
                    return
                      CustomDropdownTextFieldsm(headText: 'Role*',dropDownMenuList: dropDownList,
                        hintText: prefillValue ?? 'Select',
                        onChanged: (newValue) {
                          for (var a in snapshot.data!) {
                            if (a.roleName == newValue) {
                              selectedRole = a.roleName!;
                              roleId = a.roleId;
                              roleName = a.roleName;
                              //country = a
                              // int? docType = a.companyOfficeID;
                            }
                          }
                        },);


                  } else {
                    return const Offstage();
                  }
                },
              ),),
            SizedBox(width: RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),

            Flexible(child: FutureBuilder<List<RelatedPatiesTypeData>>(
                future: _relataedTypeDropDownFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CustomDropdownTextFieldsm(

                      headText: 'Type*',items: const [],
                      onChanged: (newValue) {

                      },);
                  }
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> dropDownList = [];
                    for (var i in snapshot.data!) {
                      dropDownList.add(DropdownMenuItem<String>(
                        child: Text(i.typeName!),
                        value: i.typeName,
                      ));
                    }
                    String? prefillValue;
                    for (var rel in snapshot.data!) {
                      if (rel.typeId == typeId) {
                        prefillValue = rel.typeName;
                        break;
                      }
                    }
                    return
                      CustomDropdownTextFieldsm(headText: 'Type*',dropDownMenuList: dropDownList,
                        hintText: prefillValue ?? 'Select',
                        onChanged: (newValue) {
                          for (var a in snapshot.data!) {
                            if (a.typeName == newValue) {
                              selectedType = a.typeName!;
                              typeId = a.typeId;
                              typeName = a.typeName;
                              //country = a
                              // int? docType = a.companyOfficeID;
                            }
                          }
                        },);
                  } else {
                    return const Offstage();
                  }
                },
              ),),


            SizedBox(width: RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    isIconClicked: true,
                    iconClickedPress:(){
                      openMapRelatedRPScreen();
                    },
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].street.streetLink.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].street.streetLink).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].street.streetPgNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].street.streetLink);

                    },
                    controller:streetPRController,
                    icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                    labelText: "Street*")),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    isIconClicked: true,
                    iconClickedPress:(){
                      openMapRelatedRPScreen();
                    },
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].street.streetLink.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].street.streetLink).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].street.streetPgNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].street.streetLink);

                    },
                    controller: streetPRController,
                    icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime,size: IconSize.I18,),
                    labelText: "Street*")),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].suite.suiteLink.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].suite.suiteLink).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].suite.suitePgNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].suite.suiteLink);

                    },
                    controller: suitAptPRController,
                    labelText: "Suite/Apt#")),
            const SizedBox(width: AppSize.s35),
            Flexible(
              // child: FutureBuilder<List<CityData>>(
              //   future: getCityDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'City*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.cityName!),
              //           value: i.cityName,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'City*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.cityName == newValue) {
              //               selectedCityEC = a.cityName!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),

              child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].city.cityLink.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].city.cityLink).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].city.cityPgNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].city.cityLink);

                  },
                  controller:ctlrCity,
                  labelText: AppString.city),
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
              // child:FutureBuilder<List<StateData>>(
              //   future: getStateDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'State*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.name),
              //           value: i.name,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'State*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.name == newValue) {
              //               selectedStateEC = a.name!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),
              //
                child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].state.stateLink.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].state.stateLink).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].state.statePgNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].state.stateLink);

                  },
                  labelText: "State*",
                  controller:ctlrState ,
                )
            ),
            const SizedBox(width: AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].zipcode.zipcodeLink.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].zipcode.zipcodeLink).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].zipcode.zipcodePgNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].zipcode.zipcodeLink);

                    },
                    controller: zipCodePRController,
                    allowSSNBR: true,
                    labelText: "Zip Code*")),

          ],
        ),
        const SizedBox(height: AppSize.s16),
        RepresentativeProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].suite.suiteLink.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].suite.suiteLink).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].suite.suitePgNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].suite.suiteLink);

                    },
                    controller: suitAptPRController,
                    labelText: "Suite/Apt#")),
            SizedBox(width:RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
              // child: FutureBuilder<List<CityData>>(
              //   future: getCityDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'City*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.cityName!),
              //           value: i.cityName,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'City*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.cityName == newValue) {
              //               selectedCityEC = a.cityName!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),

              child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].city.cityLink.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },isIClicked: (){
                widget.oniButton();
                RepresentativeProvider.setLinkAndPageNumber(
                    selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].city.cityLink).pathSegments.last,
                    pageNo: apiDataRepresentative[widget.index - 1].city.cityPgNo,
                    isLinkeOpen: apiDataRepresentative[widget.index - 1].city.cityLink);

              },
                  controller:ctlrCity,
                  labelText: AppString.city),
            ),
            SizedBox(width: RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
              // child:FutureBuilder<List<StateData>>(
              //   future: getStateDropDown(context),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState ==
              //         ConnectionState.waiting) {
              //       return CustomDropdownTextFieldsm(
              //         initialValue: 'Select',
              //         headText: 'State*',items: [],
              //         onChanged: (newValue) {
              //
              //         },);
              //     }
              //     if (snapshot.hasData) {
              //       List<DropdownMenuItem<String>> dropDownList = [];
              //       for (var i in snapshot.data!) {
              //         dropDownList.add(DropdownMenuItem<String>(
              //           child: Text(i.name),
              //           value: i.name,
              //         ));
              //       }
              //
              //       return CustomDropdownTextFieldsm(headText: 'State*',dropDownMenuList: dropDownList,
              //         onChanged: (newValue) {
              //           for (var a in snapshot.data!) {
              //             if (a.name == newValue) {
              //               selectedStateEC = a.name!;
              //               //country = a
              //               // int? docType = a.companyOfficeID;
              //             }
              //           }
              //         },);
              //
              //
              //     } else {
              //       return const Offstage();
              //     }
              //   },
              // ),

                child: SchedularTextField(
                  isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                      ? true
                      : (apiDataRepresentative[widget.index - 1].state.stateLink.isEmpty ? true : false),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      prefillDataRepresent= false;
                    }
                  },
                  isIClicked: (){
                    widget.oniButton();
                    RepresentativeProvider.setLinkAndPageNumber(
                        selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].state.stateLink).pathSegments.last,
                        pageNo: apiDataRepresentative[widget.index - 1].state.statePgNo,
                        isLinkeOpen: apiDataRepresentative[widget.index - 1].state.stateLink);

                  },
                  labelText: "State*",
                  controller: ctlrState,
                )
            ),
          ],
        ):
        Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].phoneNumber.link.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].phoneNumber.link).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].phoneNumber.pageNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].phoneNumber.link);

                    },
                    controller: phoneNumberPRController,
                    phoneField:true,
                    labelText: "Phone Number*")),
            SizedBox(width: RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].email.link.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].email.link).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].email.pageNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].email.link);

                    },
                    controller: emailPRController,
                    labelText: "Email")),
            // Empty container for alignment
            SizedBox(width: RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 : AppSize.s35),
            Flexible(child: Container()),
            SizedBox(width:RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(child: Container()),
            SizedBox(width:RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(child: Container()),
          ],
        ),
        const SizedBox(height: AppSize.s16),
        RepresentativeProvider.isContactTrue ?  Row(
          children: [
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].zipcode.zipcodeLink.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].zipcode.zipcodeLink).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].zipcode.zipcodePgNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].zipcode.zipcodeLink);

                    },
                    controller: zipCodePRController,
                    allowSSNBR: true,
                    labelText: "Zip Code*")),
            SizedBox(width:RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].phoneNumber.link.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].phoneNumber.link).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].phoneNumber.pageNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].phoneNumber.link);

                    },
                    controller: phoneNumberPRController,
                    phoneField:true,
                    labelText: "Phone Number*")),
            SizedBox(width:RepresentativeProvider.isLeftSidebarOpen ?  AppSize.s70 :  AppSize.s35),
            Flexible(
                child: SchedularTextField(
                    isIconVisible:(apiDataRepresentative.isEmpty || widget.index - 1 < 0 || widget.index - 1 >= apiDataRepresentative.length)
                        ? true
                        : (apiDataRepresentative[widget.index - 1].email.link.isEmpty ? true : false),
                    onChanged: (value){
                      if(value.isNotEmpty){
                        prefillDataRepresent= false;
                      }
                    },
                    isIClicked: (){
                      widget.oniButton();
                      RepresentativeProvider.setLinkAndPageNumber(
                          selectLink: Uri.parse(apiDataRepresentative[widget.index - 1].email.link).pathSegments.last,
                          pageNo: apiDataRepresentative[widget.index - 1].email.pageNo,
                          isLinkeOpen: apiDataRepresentative[widget.index - 1].email.link);

                    },
                    controller: emailPRController,
                    labelText: "Email")),
          ],
        ):
        const Offstage(),
      ],
    );
  }
}
