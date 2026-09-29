import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_flow_contgainer_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/async_data_controller.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/master_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';
// removed in extraction: import '../../../widgets/constant_widgets/schedular_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_orders/intake_orders_screen_controller.dart';


import 'package:flutter/material.dart';

class PriDiagnosisProvider with ChangeNotifier {
  bool _ordersSignAndDate = false;
  bool _isLoading = false;

  bool get ordersSignAndDate => _ordersSignAndDate;
  bool get isLoading => _isLoading;

  void toggleOrdersSignAndDate(bool? value) {
    _ordersSignAndDate = value ?? false;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // -------------------------------------------

  bool _isSaved = false;

  bool get isSaved => _isSaved;

  void setSaved(bool value) {
    _isSaved = value;
    notifyListeners();
  }

// -------------------------------------------
}






class SMIntakeOrdersScreen extends StatelessWidget {
  final int patientId;
  final VoidCallback onSkip;
  const SMIntakeOrdersScreen({super.key,
    required this.patientId, required this.onSkip
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IntakeOrdersScreenController>(
          create: (ctx) {
            final providerContact = Provider.of<SmIntakeProviderManager>(ctx, listen: false);
            return IntakeOrdersScreenController()..load(ctx, providerContact.isLinkeOpen);
          },
        ),
        ChangeNotifierProvider<AsyncDataController<List<PatientOrderData>>>(
          create: (ctx) {
            final diagnosisProvider = Provider.of<DiagnosisProvider>(ctx, listen: false);
            return AsyncDataController<List<PatientOrderData>>()
              ..load(() => getPatientOrderprifill(context: ctx, patientId: diagnosisProvider.patientId));
          },
        ),
      ],
      child: _SMIntakeOrdersScreenBody(patientId: patientId, onSkip: onSkip),
    );
  }
}

class _SMIntakeOrdersScreenBody extends StatefulWidget {
  final int patientId;
  final VoidCallback onSkip;
  const _SMIntakeOrdersScreenBody({
    required this.patientId, required this.onSkip
  });

  @override
  State<_SMIntakeOrdersScreenBody> createState() => _SMIntakeOrdersScreenBodyState();
}

class _SMIntakeOrdersScreenBodyState extends State<_SMIntakeOrdersScreenBody> with TickerProviderStateMixin{
  // int selectedIndex = 0;
  final StreamController<List<PatientDiagnosisWithIdData>> _streamDignosis = StreamController<List<PatientDiagnosisWithIdData>>.broadcast();

  TextEditingController possible = TextEditingController();

  TextEditingController icd = TextEditingController();

  TextEditingController pdgm = TextEditingController();

  int dgnIdSelected = 0;
  int? selectedOrderId;

  String dgnNameSelected = 'Select';

  bool dgnAddLoader = false;
  bool ordersSignAndDate = false;

  late AnimationController _animationLeftController;
  late Animation<Offset> _slideLeftAnimation;
  bool isSidebarLeftOpen = false;
  String? _pdfTextFutureLinkKey;

  // FIX: guards the one-time re-fetch below. The Primary Diagnosis
  // StreamBuilder only exists once patientOrdersController.isLoading clears
  // (it's nested inside that Consumer). _loadDiagnosisData() was fired from
  // initState() in parallel with that fetch — if the diagnosis fetch won
  // the race and resolved first, it pushed its one-and-only event into a
  // broadcast stream that had no listener yet (the StreamBuilder subtree
  // hadn't been built), and the event was silently dropped. That's exactly
  // why the loader under "Primary Diagnosis" never stopped: the
  // StreamBuilder stayed at ConnectionState.waiting forever. Re-firing once
  // we know the StreamBuilder is about to actually mount guarantees it's
  // listening in time. Same pattern already used for the insurance
  // attachments screen.
  bool _hasReloadedDiagnosisData = false;

  // FIX: extracted so it can be called once from initState instead of on
  // every StreamBuilder rebuild.
  void _loadDiagnosisData() {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    getPatientDiagnosisData(context: context, ptId: diagnosisProvider.patientId,).then((data) {
      _streamDignosis.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void initState() {
    super.initState();
    _prefillData();
    _loadDiagnosisData();
    _animationLeftController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Off-screen to the right
      end: const Offset(0.0, 0.0), // On-screen
    ).animate(CurvedAnimation(parent: _animationLeftController, curve: Curves.easeInOut));
    // _prefillPhysicianData();
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



  //final GlobalKey<_OrdersCheckboxState> _checkboxKey = GlobalKey();

  Future<void> _prefillData() async {
    try {
      final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
      final priDiagnosisProvider = Provider.of<PriDiagnosisProvider>(context, listen: false);

      final orders = await getPatientOrderprifill(
        context: context,
        patientId: diagnosisProvider.patientId,
      );

      if (orders.isNotEmpty) {
        final firstOrder = orders.first;

        // priDiagnosisProvider.toggleOrdersSignAndDate(firstOrder.ordersSignedDate == true);
        print(";;;;;;;Referral Source ID: ${firstOrder.referralSourceId}");
        print("Special Order IDs: ${firstOrder.specialOrderIds}");
        print(";;;;;Orders Signed Date: ${firstOrder.ordersSignedDate}");



        setState(() {
          selectedOrderId = firstOrder.orderId;
          ordersSignAndDate = firstOrder.ordersSignedDate;
          receivedDateController.text = firstOrder.dateReceived;
          orderDateController.text = firstOrder.orderDate;
          caseManagerController.text = firstOrder.caseManager.caseManager;
          trackingNotesController.text = firstOrder.trackingNotes.trackingNotes;
          trueSelectedList = firstOrder.ptDisciplines;
          Marketerid = firstOrder.marketerId;
          refersourceid = firstOrder.referralSourceId;
          selectedOrderIds = firstOrder.specialOrderIds;

        });
        print("✅ order_id to PATCH later: $selectedOrderId");


      }
    } catch (e) {
      print("❌ Error in _prefillData: $e");
    }
  }


  @override
  void dispose() {
    possible.dispose();
    icd.dispose();
    pdgm.dispose();
    receivedDateController.dispose();
    orderDateController.dispose();
    caseManagerController.dispose();
    trackingNotesController.dispose();
    residencyController.dispose();
    _streamDignosis.close();
    super.dispose();
  }

  TextEditingController receivedDateController = TextEditingController();
  TextEditingController orderDateController = TextEditingController();
  TextEditingController caseManagerController = TextEditingController();
  TextEditingController trackingNotesController = TextEditingController();
  int? Marketerid = 0;
  String? selectedSource ="Select";
  int? refersourceid = 0;
  TextEditingController residencyController = TextEditingController();

  String? selectedMarketer ="Select";
  List<int> trueSelectedList = [];
  List<int> falseSelectedList = [];
  Map<String, Set<int>> selectedTitleToIds = {};
  List<int> selectedOrderIds = [];

  @override
  Widget build(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context,listen: false);
    final providerContact = Provider.of<SmIntakeProviderManager>(context,listen: false);
    final int patientId = diagnosisProvider.patientId;
    if (_pdfTextFutureLinkKey != providerContact.isLinkeOpen) {
      _pdfTextFutureLinkKey = providerContact.isLinkeOpen;
      final newLinkKey = providerContact.isLinkeOpen;
      // Defer the refetch: notifyListeners() inside load() must not fire
      // synchronously while this same build() is still constructing the
      // Consumer<IntakeOrdersScreenController> below.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<IntakeOrdersScreenController>().reloadPdfText(newLinkKey);
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
                      //height: double.infinity,
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
                                  Consumer<IntakeOrdersScreenController>(
                                      builder: (context,ordersController,child) {
                                        if(ordersController.isPdfTextLoading){
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
                                        if((ordersController.pdfText ?? '').isEmpty){
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
                                                child: Text(ordersController.pdfText!,style: CustomTextStylesCommon.commonStyle(
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
          child: Consumer<AsyncDataController<List<PatientOrderData>>>(
              builder: (context, patientOrdersController, _) {
                if(patientOrdersController.isLoading){
                  return Center(
                    child: CircularProgressIndicator(color: ColorManager.blueprime,),
                  );
                }
                if(patientOrdersController.hasError){
                  return const Center(
                    child: Text('Something went wrong!'),
                  );
                }
                final snapshotPatientData = patientOrdersController.data;
                // FIX: see _hasReloadedDiagnosisData comment above — this is
                // the earliest point at which the Primary Diagnosis
                // StreamBuilder further down is guaranteed to actually mount,
                // so re-fetch here once to make sure a listener is attached
                // before any data arrives.
                if (!_hasReloadedDiagnosisData) {
                  _hasReloadedDiagnosisData = true;
                  _loadDiagnosisData();
                }
                return Consumer<SmIntakeProviderManager>(
                    builder: (context, providerState, child) {
                      //  final priDiagnosisProvider = Provider.of<PriDiagnosisProvider>(context, listen: false);
                      return Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: AppSize.s20,bottom: 10,right: 36,),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('Review and confirm the data pulled is correct  ',
                                        style: SMItalicTextConst.customTextStyle(context))
                                  ],
                                ),
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
                                              // fontSize: FontSize.s14,
                                              fontWeight: FontWeight.w700,
                                              color: ColorManager.mediumgrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ) : const Offstage(),
                              Padding(
                                padding:  const EdgeInsets.symmetric(horizontal: 35),
                                child: BlueBGHeadConst(HeadText: "Order Details",
                                  body:  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30, vertical: AppPadding.p30),
                                    child: Container(
                                      // height: height ?? AppSize.s500,
                                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30,),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white,
                                        border: Border(
                                          bottom: BorderSide(width: 0.5,color: ColorManager.lightGrey,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SchedularTextField(
                                                      dateFormateMMDDYYYY: true,
                                                      width:providerState.isContactTrue ? AppSize.s200 :AppSize.s300,
                                                      controller: receivedDateController,
                                                      labelText: 'Date Received',
                                                      enable: false,
                                                      showDatePicker:true,
                                                    ),
                                                    const SizedBox(height: AppSize.s14,),

                                                    SchedularTextField(
                                                      dateFormateMMDDYYYY: true,
                                                      width:providerState.isContactTrue ? AppSize.s200 :AppSize.s300,
                                                      controller: orderDateController,
                                                      labelText: 'Order Date',
                                                      enable: false,
                                                      showDatePicker:true,
                                                    ),

                                                    const SizedBox(height: AppSize.s14,),
                                                    StatefulBuilder(
                                                      builder: (context, setLocalState) {
                                                        return SizedBox(
                                                          width: 210,
                                                          child:  ExpCheckboxTileoo(
                                                            title: 'Orders Signed and Date',
                                                            value: ordersSignAndDate,
                                                            isInfoIconVisible: false,
                                                            onChanged: (value) {
                                                              setLocalState(() {
                                                                ordersSignAndDate = value! ;
                                                              });
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(left: providerState.isContactTrue ? 7 : 7,top: 3.3),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Disciplines',
                                                              style: AllPopupHeadings.customTextStyle(context),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Consumer<IntakeOrdersScreenController>(
                                                        builder: (context, ordersController, child) {
                                                          if (ordersController.isEmployeeClinicalLoading) {
                                                            return const Center(child: CircularProgressIndicator());
                                                          }

                                                          if (ordersController.employeeClinicalError != null || ordersController.employeeClinical == null || ordersController.employeeClinical!.isEmpty) {
                                                            return const SizedBox.shrink();
                                                          }

                                                          final clinicalData = ordersController.employeeClinical!;

                                                          // Group by actual empType from API
                                                          final Map<String, Set<int>> titleToEmpTypeIds = {};

                                                          for (final item in clinicalData) {
                                                            final title = item.empType.trim();

                                                            if (title.isNotEmpty) {
                                                              titleToEmpTypeIds.putIfAbsent(title, () => <int>{}).add(item.emptypeId);
                                                            }
                                                          }

                                                          final visibleTitles = titleToEmpTypeIds.keys.toList();

                                                          return Container(
                                                            padding: const EdgeInsets.all(12),// Minimal padding
                                                            child: LayoutBuilder(
                                                              builder: (context, constraints) {
                                                                // Divide available width into 3 equal columns (adjust spacing as needed)
                                                                double itemWidth =  providerState.isContactTrue ? (constraints.maxWidth - 2 * 12) / 2 : (constraints.maxWidth - 2 * 12) / 3;
                                                                // Force 2 columns when sidebar open


                                                                return Wrap(
                                                                  spacing: 12, // horizontal spacing
                                                                  runSpacing: 6, // 🔽 vertical spacing between rows (smaller = tighter)
                                                                  children: visibleTitles.map((title) {
                                                                    final ids = titleToEmpTypeIds[title]!;
                                                                    bool isChecked = ids.any((id) => trueSelectedList.contains(id));

                                                                    return SizedBox(
                                                                      width: itemWidth,
                                                                      child: StatefulBuilder(
                                                                        builder: (context, setTileState) {
                                                                          return ExpCheckboxTile(
                                                                            title: title,
                                                                            initialValue: isChecked,
                                                                            onChanged: (value) {
                                                                              setTileState(() {
                                                                                isChecked = value ?? false;

                                                                                if (isChecked) {
                                                                                  for (var id in ids) {
                                                                                    if (!trueSelectedList.contains(id)) {
                                                                                      trueSelectedList.add(id);
                                                                                    }
                                                                                    falseSelectedList.remove(id);
                                                                                  }
                                                                                  selectedTitleToIds[title] = ids;
                                                                                } else {
                                                                                  for (var id in ids) {
                                                                                    if (!falseSelectedList.contains(id)) {
                                                                                      falseSelectedList.add(id);
                                                                                    }
                                                                                    trueSelectedList.remove(id);
                                                                                  }
                                                                                  selectedTitleToIds.remove(title);
                                                                                }


                                                                                selectedTitleToIds.forEach((key, value) {
                                                                                  print('Title: $key, IDs: ${value.join(", ")}');
                                                                                });
                                                                              });
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ),

                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Consumer<IntakeOrdersScreenController>(
                                                      builder: (context, ordersController, child) {
                                                        if (ordersController.isMarketerLoading) {


                                                          return SchedularTextField(
                                                              width:providerState.isContactTrue ? AppSize.s190 :AppSize.s300,
                                                              controller:residencyController ,
                                                              labelText: 'Marketer');
                                                        }
                                                        if (ordersController.marketer != null) {
                                                          List<DropdownMenuItem<String>> dropDownList = [];
                                                          for (var i in ordersController.marketer!) {
                                                            dropDownList.add(DropdownMenuItem<String>(
                                                              child: Text(i.firstName),
                                                              value: i.firstName,
                                                            ));
                                                            if (i.employeeId == Marketerid ) {
                                                              selectedMarketer = i.firstName;
                                                            }
                                                          }
                                                          String initialValue = selectedMarketer ?? "Select";


                                                          return Padding(
                                                            padding:  const EdgeInsets.symmetric(vertical: 4),
                                                            child: CustomDropdownTextFieldsm(
                                                                width:providerState.isContactTrue ? AppSize.s190 :AppSize.s300,
                                                                headText: 'Marketer',
                                                                dropDownMenuList: dropDownList,
                                                                hintText:initialValue ,
                                                                onChanged: (newValue) {
                                                                  for (var a in ordersController.marketer!) {
                                                                    if (a.firstName == newValue) {
                                                                      selectedMarketer = a.firstName;
                                                                      Marketerid =a.employeeId;
                                                                    }
                                                                  }
                                                                }),
                                                          );
                                                        } else {
                                                          return const Offstage();
                                                        }
                                                      },
                                                    ),


                                                    const SizedBox(height: AppSize.s14,),
                                                    Consumer<IntakeOrdersScreenController>(
                                                      builder: (context, ordersController, child) {
                                                        if (ordersController.isReferralSourceLoading) {


                                                          return SchedularTextField(
                                                              width:providerState.isContactTrue ? AppSize.s190 :AppSize.s300,
                                                              controller:residencyController ,
                                                              labelText: 'Referral Source');
                                                        }
                                                        if (ordersController.referralSource != null) {
                                                          List<DropdownMenuItem<String>> dropDownList = [];
                                                          for (var i in ordersController.referralSource!) {
                                                            dropDownList.add(DropdownMenuItem<String>(
                                                              child: Text(i.sourcename),
                                                              value: i.sourcename,
                                                            ));
                                                            if (i.refsouid == refersourceid) {
                                                              selectedSource = i.sourcename;
                                                            }
                                                          }
                                                          String initialValue =  selectedSource ?? "Select";

                                                          return Padding(
                                                            padding: const  EdgeInsets.symmetric(vertical: 4),
                                                            child: CustomDropdownTextFieldsm(
                                                                width:providerState.isContactTrue ? AppSize.s190 :AppSize.s300,
                                                                headText: 'Referral Source',
                                                                hintText: initialValue,
                                                                dropDownMenuList: dropDownList,
                                                                onChanged: (newValue) {
                                                                  for (var a in ordersController.referralSource!) {
                                                                    if (a.sourcename == newValue) {
                                                                      selectedSource = a.sourcename;
                                                                      refersourceid =a.refsouid;
                                                                    }
                                                                  }
                                                                }),
                                                          );
                                                        } else {
                                                          return const Offstage();
                                                        }
                                                      },
                                                    ),

                                                    const SizedBox(height: AppSize.s14,),
                                                    SchedularTextField(
                                                      isIClicked: providerContact.isRightSliderOpen == true ?
                                                          (){
                                                      }
                                                          :(){
                                                        toggleLeftSidebar();
                                                        providerContact.toogleContactProvider();
                                                        providerContact.toogleLeftSidebarProvider();
                                                        providerState.setLinkAndPageNumber(
                                                            selectLink: Uri.parse( snapshotPatientData![0].caseManager.caseManagerLink).pathSegments.last,
                                                            pageNo: snapshotPatientData![0].caseManager.caseManagerPgNo,
                                                            isLinkeOpen:snapshotPatientData![0].caseManager.caseManagerLink );
                                                      },
                                                      isIconVisible: (snapshotPatientData != null && snapshotPatientData!.isNotEmpty)
                                                          ? snapshotPatientData![0].caseManager.caseManagerLink.isEmpty
                                                          : true,
                                                      width: providerState.isContactTrue ? AppSize.s190 : AppSize.s300,
                                                      controller: caseManagerController,
                                                      labelText: 'Case Manager',
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),


                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SchedularTextField(
                                                isIClicked: providerContact.isRightSliderOpen == true ?
                                                    (){
                                                }
                                                    :(){
                                                  toggleLeftSidebar();
                                                  providerContact.toogleContactProvider();
                                                  providerContact.toogleLeftSidebarProvider();
                                                  providerState.setLinkAndPageNumber(
                                                      selectLink: Uri.parse( snapshotPatientData![0].trackingNotes.trackingNotesLink).pathSegments.last,
                                                      pageNo: snapshotPatientData![0].trackingNotes.trackingNotesPgNo,
                                                      isLinkeOpen:snapshotPatientData![0].trackingNotes.trackingNotesLink );
                                                },
                                                isIconVisible:(snapshotPatientData != null && snapshotPatientData!.isNotEmpty)
                                                    ? snapshotPatientData![0].trackingNotes.trackingNotesLink.isEmpty
                                                    : true,
                                                width: providerState.isContactTrue ? AppSize.s190 : AppSize.s300,
                                                controller: trackingNotesController,
                                                labelText: 'Tracking Notes',
                                                hintText: 'Enter Text',
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),),
                              ),

                              const SizedBox(height: AppSize.s40),
                              Padding(
                                padding:  const EdgeInsets.symmetric(horizontal: 35),
                                child: BlueBGHeadConst(HeadText: "Primary Diagnosis",
                                  body: Column(
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
                                        child: StreamBuilder<List<PatientDiagnosisWithIdData>>(
                                            stream: _streamDignosis.stream,
                                            builder: (context,snapshotDiagnosis) {
                                              if(snapshotDiagnosis.connectionState == ConnectionState.waiting){
                                                return Center(
                                                  child: CircularProgressIndicator(color: ColorManager.blueprime,),
                                                );
                                              }
                                              if(snapshotDiagnosis.data!.isEmpty){
                                                return  Center(
                                                    child: Padding(
                                                      padding:const EdgeInsets.symmetric(vertical: 76),
                                                      child: Text(
                                                        AppStringSMModule.patientDiagnosisNoData,
                                                        style: AllNoDataAvailable.customTextStyle(context),
                                                      ),
                                                    ));
                                              }
                                              if(snapshotDiagnosis.hasData){
                                                return Container(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: snapshotDiagnosis.data!.length,
                                                      itemBuilder: (context,index) {
                                                        possible = TextEditingController(text: snapshotDiagnosis.data![index].dgnName);
                                                        icd = TextEditingController(text: snapshotDiagnosis.data![index].dgnCode);
                                                        pdgm = TextEditingController(text: snapshotDiagnosis.data![index].pdgm ? 'YES' : 'NO');
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(height: 90,width: 5,color:
                                                                  snapshotDiagnosis.data![index].colorId == 0
                                                                      ? ColorManager.red
                                                                      : snapshotDiagnosis.data![index].colorId == 1
                                                                      ? ColorManager.greenDark
                                                                      : Colors.white,
                                                                  ),
                                                                  const SizedBox(width: AppSize.s30,),
                                                                  Expanded(
                                                                    child: SchedularTextField(controller: possible,
                                                                        isIconVisible: true,
                                                                        labelText: "Possible Diagnosis"),
                                                                  ),
                                                                  const SizedBox(width: AppSize.s60,),
                                                                  Expanded(
                                                                    child: SchedularTextField(controller: icd,
                                                                        isIconVisible: true,
                                                                        labelText: "ICD Code"),
                                                                  ),
                                                                  const SizedBox(width: AppSize.s60,),
                                                                  Expanded(
                                                                    child: SchedularTextField(controller: pdgm,
                                                                        isIconVisible: true,
                                                                        textColor:
                                                                        snapshotDiagnosis.data![index].colorId == 0
                                                                            ? ColorManager.red
                                                                            : snapshotDiagnosis.data![index].colorId == 1
                                                                            ? ColorManager.greenDark
                                                                            : Colors.black,
                                                                        labelText: "PDGM - Acceptable"),
                                                                  ),
                                                                  const SizedBox(width: AppSize.s30,),
                                                                  providerState.isContactTrue ?const Offstage()  :Expanded(
                                                                    child: Container(
                                                                      height: 30,
                                                                      width: AppSize.s354,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: AppSize.s30,),
                                                                  providerState.isContactTrue ? const Offstage() :Expanded(
                                                                    child: Container(
                                                                      height: 30,
                                                                      width: AppSize.s354,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              Divider(
                                                                color: ColorManager.containerBorderGrey,
                                                                thickness: 1,
                                                                height: 2,
                                                              ),
                                                              const SizedBox(height: AppSize.s30,),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                );
                                              }
                                              else{
                                                return const Offstage();
                                              }

                                            }
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [ Container(
                                          height: AppSize.s30,
                                          child: CustomIconButton(
                                            color:  ColorManager.blueprime,
                                            icon: Icons.add,
                                            textWeight: FontWeight.w700,
                                            textSize: FontSize.s12,
                                            text: "Add Diagnosis",
                                            onPressed: ()async {
                                              // FIX: no refresh was wired up after this dialog
                                              // closed, so a newly-added diagnosis never showed
                                              // in the list until the whole screen was reopened.
                                              // Reload the diagnosis stream once the dialog pops,
                                              // regardless of how it was dismissed.
                                              showDialog(
                                                context: context,
                                                builder: (context) => AddDiagnosisDialog(),
                                              ).then((_) {
                                                _loadDiagnosisData();
                                              });
                                            }, isNotPopUpButton: false,
                                          ),
                                        ),],
                                      ),
                                      const SizedBox(height: AppSize.s16),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 50),
                                        child: Divider(),
                                      )
                                    ],
                                  ),),
                              ),

                              const SizedBox(height: AppSize.s40),
                              Padding(
                                padding:  const EdgeInsets.symmetric(horizontal: 35),
                                child: BlueBGHeadConst(HeadText: "Special Orders",
                                  body:   Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 60),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Padding(
                                              padding:const EdgeInsets.only(top: 20,),
                                              child: Text('Flags',style:
                                              SMTextfieldHeadings.customTextStyle(context)
                                              )),
                                        ],),
                                        const SizedBox(height: 10,),
                                        Consumer<IntakeOrdersScreenController>(
                                          builder: (context, ordersController, child) {
                                            if (ordersController.isSpecialOrderLoading) {
                                              return const Center(child: CircularProgressIndicator());
                                            } else if (ordersController.specialOrderError != null) {
                                              return const Text("Failed to load special orders.");
                                            } else if (ordersController.specialOrder == null || ordersController.specialOrder!.isEmpty) {
                                              return const Text("No special orders found.");
                                            }

                                            final specialOrders = ordersController.specialOrder!;
                                            return Wrap(
                                              spacing: 70.0,
                                              runSpacing: 0.0,
                                              children: specialOrders.map((order) {
                                                return StatefulBuilder(
                                                  builder: (context, setTileState) {
                                                    bool isChecked = selectedOrderIds.contains(order.spcialorderid);

                                                    return SizedBox(
                                                      width: 170,
                                                      child: ExpCheckboxTile(
                                                        title: order.spcialordername,
                                                        initialValue: isChecked,
                                                        isInfoIconVisible: false,
                                                        onChanged: (value) {
                                                          setTileState(() {
                                                            if (value == true) {
                                                              if (!selectedOrderIds.contains(order.spcialorderid)) {
                                                                selectedOrderIds.add(order.spcialorderid);
                                                              }
                                                            } else {
                                                              selectedOrderIds.remove(order.spcialorderid);
                                                            }

                                                            print("✅ Selected Special Order IDs: $selectedOrderIds");
                                                          });
                                                        },
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),

                                        const Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Divider(),
                                        )
                                      ],
                                    ),
                                  ),),
                              ),

                              const SizedBox(height: AppSize.s40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  SkipButtonTransparent(
                                    text: "Skip",
                                    onPressed: () {
                                      print("🔹 Skip button tapped - going to initial contact screen");
                                      widget.onSkip(); // This should trigger jumpToPage(4)
                                    },
                                  ),

                                  Consumer<PriDiagnosisProvider>(
                                    builder: (context, priDiagnosisProvider, child) {
                                      return CustomElevatedButton(
                                        width: AppSize.s100,
                                        text: AppString.save,
                                        isLoading: priDiagnosisProvider.isLoading,
                                        onPressed: () async {
                                          priDiagnosisProvider.setLoading(true);

                                          final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
                                          // ✅ Parse dates from controller and convert to ISO 8601 format
                                          String? isoDateReceived;
                                          String? isoOrderDate;

                                          try {
                                            DateTime _parseMMDDYYYY(String dateStr) {
                                              final parts = dateStr.split('/'); // [MM, DD, YYYY]
                                              if (parts.length != 3) {
                                                throw FormatException('Invalid date format: $dateStr');
                                              }
                                              final month = int.parse(parts[0]);
                                              final day = int.parse(parts[1]);
                                              final year = int.parse(parts[2]);
                                              return DateTime(year, month, day);
                                            }

// Use it:
                                            final receivedDate = _parseMMDDYYYY(receivedDateController.text);
                                            final orderDate = _parseMMDDYYYY(orderDateController.text);

                                            isoDateReceived = receivedDate.toUtc().toIso8601String();
                                            isoOrderDate = orderDate.toUtc().toIso8601String();
                                          } catch (e) {
                                            print("❌ Date parsing error: $e");
                                            showDialog(
                                              context: context,
                                              builder: (_) => const AddErrorPopup(
                                                message: 'Please Check Your Input And Try Again',
                                              ),
                                            );
                                            priDiagnosisProvider.setLoading(false);
                                            return;
                                          }

                                          // ✅ Print all relevant data before API call
                                          print('🔽 Submitting Data to API:');
                                          print('📌 Patient ID: ${diagnosisProvider.patientId}');
                                          print('📌 order ID: $selectedOrderId');
                                          print('📝 Selected Special Order IDs: $selectedOrderIds');
                                          print('📅 Date Received: $isoDateReceived');
                                          print('📅 Order Date: $isoOrderDate');
                                          print('🩺 Selected PT Discipline IDs: $trueSelectedList');
                                          print('📈 Marketer ID: $Marketerid');
                                          print('📊 Referral Source ID: $refersourceid');
                                          print('👩‍⚕️ Case Manager: ${caseManagerController.text}');
                                          print('🗒️ Tracking Notes: ${trackingNotesController.text}');
                                          print('✍️ Order Signature + Date: $ordersSignAndDate');



                                          var response = await patchOrderbyOrderID(
                                            context: context,
                                            orderId: selectedOrderId!, // <-- Make sure to provide the correct order ID here
                                            patientid: diagnosisProvider.patientId,
                                            specialOrderId: selectedOrderIds,
                                            dateReceived: isoDateReceived,
                                            orderdate: isoOrderDate,
                                            ptDisciplines: trueSelectedList,
                                            merkatereid: Marketerid!,
                                            refersourceid: refersourceid!,
                                            casemanger: caseManagerController.text,
                                            trackingnote: trackingNotesController.text,
                                            ordersignature: ordersSignAndDate,
                                          );

                                          if (response.statusCode == 200 || response.statusCode == 201) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const AddSuccessPopup(
                                                  message: 'Patient Order Successfully',
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
                                            print('Please check your input and try again');
                                            print('❌ API error: ${response.statusCode}');
                                          }

                                          priDiagnosisProvider.setLoading(false);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSize.s30),
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
    );

  }
}






class OrdersCheckbox extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const OrdersCheckbox({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _OrdersCheckboxState createState() => _OrdersCheckboxState();
}

class _OrdersCheckboxState extends State<OrdersCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.initialValue;
  }

  // Call this externally to update the checkbox
  void update(bool value) {
    setState(() {
      _checked = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpCheckboxTile(
      title: 'Orders Signed and Date',
      initialValue: _checked,
      isInfoIconVisible: true,
      onChanged: (value) {
        setState(() {
          _checked = value ?? false;
        });
        widget.onChanged(_checked);
      },
    );
  }
}