import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/master_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/patient_insurances_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';

class EmrOrderTab extends StatefulWidget {
  final int patientId;
  const EmrOrderTab({super.key, required this.patientId});

  @override
  State<EmrOrderTab> createState() => _EmrOrderTabState();
}

class _EmrOrderTabState extends State<EmrOrderTab>
    with TickerProviderStateMixin {

  // ── Streams ───────────────────────────────────────────────────────────────
  final StreamController<List<PatientDiagnosisWithIdData>> _streamDiagnosis =
  StreamController<List<PatientDiagnosisWithIdData>>.broadcast();

  // ── Controllers ───────────────────────────────────────────────────────────
  TextEditingController possible             = TextEditingController();
  TextEditingController icd                  = TextEditingController();
  TextEditingController pdgm                 = TextEditingController();
  TextEditingController receivedDateController = TextEditingController();
  TextEditingController orderDateController  = TextEditingController();
  TextEditingController caseManagerController = TextEditingController();
  TextEditingController trackingNotesController = TextEditingController();
  TextEditingController residencyController  = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  int?   selectedOrderId;
  int?   Marketerid     = 0;
  int?   refersourceid  = 0;
  String? selectedSource  = 'Select';
  String? selectedMarketer = 'Select';
  bool   ordersSignAndDate = false;

  List<int>           trueSelectedList  = [];
  List<int>           falseSelectedList = [];
  Map<String, Set<int>> selectedTitleToIds = {};
  List<int>           selectedOrderIds  = [];

  // ── Sidebar animation ─────────────────────────────────────────────────────
  late AnimationController _animationLeftController;
  late Animation<Offset>   _slideLeftAnimation;
  bool isSidebarLeftOpen = false;

  // ── Cached future ─────────────────────────────────────────────────────────
  late Future<List<PatientOrderData>> _orderFuture;

  // ── Cached "referred from" PDF text-extraction future — recomputed only
  // when the linked file actually changes, not on every rebuild ───────────
  String? _lastExtractedLinkOpen;
  late Future<String> _extractedTextFuture;

  // ── Cached dropdown/list futures — these sit inside a Consumer that
  // rebuilds on every provider notification (e.g. every field edit), so
  // calling the API inline inside their FutureBuilders was re-firing on
  // every such rebuild. Fetched once here instead. ──────────────────────
  late Future<List<EmployeeClinicalData>> _clinicalInReferralsFuture;
  late Future<List<PatientMarketerData>> _marketerFuture;
  late Future<List<ReferralSourcesData>> _referralSourceFuture;
  late Future<List<SpacialOrderData>> _specialOrderFuture;

  @override
  void initState() {
    super.initState();

    _animationLeftController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end:   const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
        parent: _animationLeftController, curve: Curves.easeInOut));

    // FIX: Initialize the future directly in initState.
    // addPostFrameCallback fires AFTER the first build, so the FutureBuilder
    // would access _orderFuture before it was set -> LateInitializationError.
    _orderFuture = getPatientOrderprifill(
      context: context,
      patientId: widget.patientId,
    );
    _clinicalInReferralsFuture =
        getEmployeeClinicalInReffreals(context: context);
    _marketerFuture = getMarketerWithDeptId(
      context: context,
      deptId: FrontendConfigStore.data!.config.salesId,
    );
    _referralSourceFuture = getReferalSourceDD(context: context);
    _specialOrderFuture = getSpecialOrder(context: context);
    // _prefillData uses setState so addPostFrameCallback is fine here.
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillData());
  }

  void toggleLeftSidebar() {
    setState(() {
      isSidebarLeftOpen = !isSidebarLeftOpen;
      if (isSidebarLeftOpen) {
        _animationLeftController.forward();
      } else {
        _animationLeftController.reverse();
      }
    });
  }

  Future<void> _prefillData() async {
    try {
      final orders = await getPatientOrderprifill(
        context: context,
        patientId: widget.patientId,
      );

      if (orders.isNotEmpty) {
        final first = orders.first;
        setState(() {
          selectedOrderId              = first.orderId;
          ordersSignAndDate            = first.ordersSignedDate;
          receivedDateController.text  = first.dateReceived;
          orderDateController.text     = first.orderDate;
          caseManagerController.text   = first.caseManager.caseManager;
          trackingNotesController.text = first.trackingNotes.trackingNotes;
          trueSelectedList             = first.ptDisciplines;
          Marketerid                   = first.marketerId;
          refersourceid                = first.referralSourceId;
          selectedOrderIds             = first.specialOrderIds;
        });
      }
    } catch (e) {
      debugPrint('❌ Error in _prefillData: $e');
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
    _streamDiagnosis.close();
    _animationLeftController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final providerContact =
    Provider.of<SmIntakeProviderManager>(context, listen: false);

    // FIX: only recompute the extraction future when the linked file
    // actually changes — previously this ran inline inside the
    // FutureBuilder below, re-firing on every rebuild of this tab.
    if (_lastExtractedLinkOpen != providerContact.isLinkeOpen) {
      _lastExtractedLinkOpen = providerContact.isLinkeOpen;
      _extractedTextFuture = extractTextFromPdf(providerContact.isLinkeOpen);
    }

    return Row(
      children: [
        // ── Left reference sidebar ────────────────────────────────────────
        isSidebarLeftOpen
            ? Flexible(
          flex: 0,
          child: AnimatedBuilder(
            animation: _slideLeftAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideLeftAnimation,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(top: 5, left: 10),
                    child: Container(
                      width:
                      MediaQuery.of(context).size.width * 0.24,
                      color: Colors.white,
                      padding: const EdgeInsets.all(1),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                              MediaQuery.of(context).size.height,
                              minWidth:
                              MediaQuery.of(context).size.height,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 100),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 10,
                                        left: 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Referred from ',
                                          style: CustomTextStylesCommon
                                              .commonStyle(
                                            color: const Color(
                                                0xFF686464),
                                            fontWeight:
                                            FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                              '${providerContact.isLinkeFileName} ',
                                              style: CustomTextStylesCommon
                                                  .commonStyle(
                                                color: const Color(
                                                    0xFF51B5E6),
                                                fontWeight:
                                                FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              '(Page No.${providerContact.pageCountFromLink})',
                                              style: CustomTextStylesCommon
                                                  .commonStyle(
                                                color: const Color(
                                                    0xFF51B5E6),
                                                fontWeight:
                                                FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<String>(
                                    future: _extractedTextFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 50),
                                          child: Center(
                                            child: SizedBox(
                                              height: 25,
                                              width: 25,
                                              child:
                                              CircularProgressIndicator(
                                                color: ColorManager
                                                    .blueprime,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (snapshot.data!.isEmpty) {
                                        return Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 50),
                                          child: Center(
                                            child: Text(
                                              'No Data!',
                                              style: AllNoDataAvailable.customTextStyle(context),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width,
                                        decoration: BoxDecoration(
                                          color:
                                          const Color(0xFFEEEEEE),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(20),
                                          child: Container(
                                            color: Colors.white,
                                            padding:
                                            const EdgeInsets.all(10),
                                            child: Text(
                                              snapshot.data!,
                                              style: CustomTextStylesCommon
                                                  .commonStyle(
                                                color: const Color(
                                                    0xFF686464),
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 100),
                                ],
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

        // ── Main content ──────────────────────────────────────────────────
        Flexible(
          child: FutureBuilder<List<PatientOrderData>>(
            future: _orderFuture,
            builder: (context, snapshotPatient) {
              if (snapshotPatient.connectionState ==
                  ConnectionState.waiting) {
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: ColorManager.blueprime),
                  ),
                );
              }
              if (snapshotPatient.hasError) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                      child: Text('Something went wrong!')),
                );
              }

              // FIX: guard empty list before accessing [0]
              final bool hasOrderData = snapshotPatient.hasData &&
                  snapshotPatient.data!.isNotEmpty;

              return Consumer<SmIntakeProviderManager>(
                builder: (context, providerState, child) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                        children: [
                          // Review hint
                          Padding(
                            padding: const EdgeInsets.only(
                                top: AppSize.s25,
                                bottom: 10,
                                right: 35),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Review and confirm the data pulled is correct ',
                                  style: SMItalicTextConst
                                      .customTextStyle(context),
                                ),
                              ],
                            ),
                          ),

                          // Go Back (sidebar open)
                          providerState.isLeftSidebarOpen
                              ? InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              toggleLeftSidebar();
                              providerContact
                                  .toogleContactProvider();
                              providerContact
                                  .toogleLeftSidebarProvider();
                              providerState.setLinkAndPageClear();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back,
                                      size: IconSize.I16,
                                      color:
                                      ColorManager.mediumgrey),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Go Back',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color:
                                      ColorManager.mediumgrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : const Offstage(),

                          // ── Order Details ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35),
                            child: BlueBGHeadConst(
                              HeadText: 'Order Details',
                              body: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppPadding.p30,
                                    vertical: AppPadding.p30),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppPadding.p30),
                                  decoration: BoxDecoration(
                                    color: ColorManager.white,
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 0.5,
                                          color: ColorManager.lightGrey),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Left — dates + checkbox
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                SchedularTextField(
                                                  dateFormateMMDDYYYY:
                                                  true,
                                                  width: providerState
                                                      .isContactTrue
                                                      ? AppSize.s200
                                                      : AppSize.s300,
                                                  controller:
                                                  receivedDateController,
                                                  labelText:
                                                  'Date Received',
                                                  enable: false,
                                                  showDatePicker: true,
                                                ),
                                                const SizedBox(
                                                    height:
                                                    AppSize.s14),
                                                SchedularTextField(
                                                  dateFormateMMDDYYYY:
                                                  true,
                                                  width: providerState
                                                      .isContactTrue
                                                      ? AppSize.s200
                                                      : AppSize.s300,
                                                  controller:
                                                  orderDateController,
                                                  labelText:
                                                  'Order Date',
                                                  enable: false,
                                                  showDatePicker: true,
                                                ),
                                                const SizedBox(
                                                    height:
                                                    AppSize.s14),
                                                StatefulBuilder(
                                                  builder: (context,
                                                      setLocal) {
                                                    return SizedBox(
                                                      width: 210,
                                                      child:
                                                      ExpCheckboxTileoo(
                                                        title:
                                                        'Orders Signed and Date',
                                                        value:
                                                        ordersSignAndDate,
                                                        isInfoIconVisible:
                                                        false,
                                                        onChanged:
                                                            (value) {
                                                          setLocal(() {
                                                            ordersSignAndDate =
                                                            value!;
                                                          });
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Centre — disciplines
                                          Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  left: 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        top: 3.3),
                                                    child: Text(
                                                      'Disciplines',
                                                      style: AllPopupHeadings
                                                          .customTextStyle(
                                                          context),
                                                    ),
                                                  ),
                                                  FutureBuilder<
                                                      List<
                                                          EmployeeClinicalData>>(
                                                    future:
                                                    _clinicalInReferralsFuture,
                                                    builder: (context,
                                                        snapshot) {
                                                      if (snapshot
                                                          .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const Center(
                                                            child:
                                                            CircularProgressIndicator());
                                                      }
                                                      if (snapshot
                                                          .hasError ||
                                                          !snapshot
                                                              .hasData ||
                                                          snapshot.data!
                                                              .isEmpty) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }

                                                      final clinicalData =
                                                      snapshot.data!;
                                                      final Map<String,
                                                          Set<int>>
                                                      titleToIds = {};
                                                      for (final item
                                                      in clinicalData) {
                                                        final title =
                                                        item.empType
                                                            .trim();
                                                        if (title
                                                            .isNotEmpty) {
                                                          titleToIds
                                                              .putIfAbsent(
                                                              title,
                                                                  () => <
                                                                  int>{})
                                                              .add(item
                                                              .emptypeId);
                                                        }
                                                      }

                                                      final visibleTitles =
                                                      titleToIds.keys
                                                          .toList();

                                                      return Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(12),
                                                        child:
                                                        LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                            final double
                                                            itemWidth =
                                                            providerState
                                                                .isContactTrue
                                                                ? (constraints.maxWidth -
                                                                2 *
                                                                    12) /
                                                                2
                                                                : (constraints.maxWidth -
                                                                2 *
                                                                    12) /
                                                                3;
                                                            return Wrap(
                                                              spacing: 12,
                                                              runSpacing:
                                                              6,
                                                              children: visibleTitles
                                                                  .map(
                                                                      (title) {
                                                                    final ids =
                                                                    titleToIds[title]!;
                                                                    bool
                                                                    isChecked =
                                                                    ids.any((id) =>
                                                                        trueSelectedList
                                                                            .contains(id));
                                                                    return SizedBox(
                                                                      width:
                                                                      itemWidth,
                                                                      child:
                                                                      StatefulBuilder(
                                                                        builder: (context,
                                                                            setTile) {
                                                                          return ExpCheckboxTile(
                                                                            title:
                                                                            title,
                                                                            initialValue:
                                                                            isChecked,
                                                                            onChanged:
                                                                                (value) {
                                                                              setTile(() {
                                                                                isChecked = value ??  false;
                                                                                if (isChecked) {
                                                                                  for (var id in ids) {
                                                                                    if (!trueSelectedList.contains(id)) trueSelectedList.add(id);
                                                                                    falseSelectedList.remove(id);
                                                                                  }
                                                                                  selectedTitleToIds[title] = ids;
                                                                                } else {
                                                                                  for (var id in ids) {
                                                                                    if (!falseSelectedList.contains(id)) falseSelectedList.add(id);
                                                                                    trueSelectedList.remove(id);
                                                                                  }
                                                                                  selectedTitleToIds.remove(title);
                                                                                }
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

                                          // Right — Marketer / Referral Source / Case Manager
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .end,
                                              children: [
                                                // Marketer
                                                FutureBuilder<
                                                    List<PatientMarketerData>>(
                                                  future:
                                                  _marketerFuture,
                                                  builder: (context,
                                                      snapshot) {
                                                    if (snapshot
                                                        .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return SchedularTextField(
                                                        width: providerState
                                                            .isContactTrue
                                                            ? AppSize
                                                            .s190
                                                            : AppSize
                                                            .s300,
                                                        controller:
                                                        residencyController,
                                                        labelText:
                                                        'Marketer',
                                                      );
                                                    }
                                                    if (snapshot
                                                        .hasData) {
                                                      final items =
                                                      <DropdownMenuItem<
                                                          String>>[];
                                                      for (var i in snapshot
                                                          .data!) {
                                                        items.add(
                                                            DropdownMenuItem(
                                                              child: Text(
                                                                  i.firstName),
                                                              value:
                                                              i.firstName,
                                                            ));
                                                        if (i.employeeId ==
                                                            Marketerid) {
                                                          selectedMarketer =
                                                              i.firstName;
                                                        }
                                                      }
                                                      return Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                            4),
                                                        child:
                                                        CustomDropdownTextFieldsm(
                                                          width: providerState
                                                              .isContactTrue
                                                              ? AppSize
                                                              .s190
                                                              : AppSize
                                                              .s300,
                                                          headText:
                                                          'Marketer',
                                                          dropDownMenuList:
                                                          items,
                                                          hintText:
                                                          selectedMarketer ??
                                                              'Select',
                                                          onChanged:
                                                              (newValue) {
                                                            for (var a
                                                            in snapshot
                                                                .data!) {
                                                              if (a.firstName ==
                                                                  newValue) {
                                                                selectedMarketer =
                                                                    a.firstName;
                                                                Marketerid =
                                                                    a.employeeId;
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    }
                                                    return const Offstage();
                                                  },
                                                ),

                                                const SizedBox(
                                                    height:
                                                    AppSize.s14),

                                                // Referral Source
                                                FutureBuilder<
                                                    List<
                                                        ReferralSourcesData>>(
                                                  future:
                                                  _referralSourceFuture,
                                                  builder: (context,
                                                      snapshot) {
                                                    if (snapshot
                                                        .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return SchedularTextField(
                                                        width: providerState
                                                            .isContactTrue
                                                            ? AppSize
                                                            .s190
                                                            : AppSize
                                                            .s300,
                                                        controller:
                                                        residencyController,
                                                        labelText:
                                                        'Referral Source',
                                                      );
                                                    }
                                                    if (snapshot
                                                        .hasData) {
                                                      final items =
                                                      <DropdownMenuItem<
                                                          String>>[];
                                                      for (var i in snapshot
                                                          .data!) {
                                                        items.add(
                                                            DropdownMenuItem(
                                                              child: Text(
                                                                  i.sourcename),
                                                              value:
                                                              i.sourcename,
                                                            ));
                                                        if (i.refsouid ==
                                                            refersourceid) {
                                                          selectedSource =
                                                              i.sourcename;
                                                        }
                                                      }
                                                      return Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                            4),
                                                        child:
                                                        CustomDropdownTextFieldsm(
                                                          width: providerState
                                                              .isContactTrue
                                                              ? AppSize
                                                              .s190
                                                              : AppSize
                                                              .s300,
                                                          headText:
                                                          'Referral Source',
                                                          hintText:
                                                          selectedSource ??
                                                              'Select',
                                                          dropDownMenuList:
                                                          items,
                                                          onChanged:
                                                              (newValue) {
                                                            for (var a
                                                            in snapshot
                                                                .data!) {
                                                              if (a.sourcename ==
                                                                  newValue) {
                                                                selectedSource =
                                                                    a.sourcename;
                                                                refersourceid =
                                                                    a.refsouid;
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    }
                                                    return const Offstage();
                                                  },
                                                ),

                                                const SizedBox(
                                                    height:
                                                    AppSize.s14),

                                                // Case Manager
                                                SchedularTextField(
                                                  isIClicked: providerContact
                                                      .isRightSliderOpen
                                                      ? () {}
                                                      : () {
                                                    toggleLeftSidebar();
                                                    providerContact
                                                        .toogleContactProvider();
                                                    providerContact
                                                        .toogleLeftSidebarProvider();
                                                    if (hasOrderData) {
                                                      providerState
                                                          .setLinkAndPageNumber(
                                                        selectLink: Uri.parse(snapshotPatient.data![0].caseManager.caseManagerLink).pathSegments.last,
                                                        pageNo: snapshotPatient.data![0].caseManager.caseManagerPgNo,
                                                        isLinkeOpen: snapshotPatient.data![0].caseManager.caseManagerLink,
                                                      );
                                                    }
                                                  },
                                                  isIconVisible: hasOrderData
                                                      ? snapshotPatient
                                                      .data![0]
                                                      .caseManager
                                                      .caseManagerLink
                                                      .isEmpty
                                                      : true,
                                                  width: providerState
                                                      .isContactTrue
                                                      ? AppSize.s190
                                                      : AppSize.s300,
                                                  controller:
                                                  caseManagerController,
                                                  labelText:
                                                  'Case Manager',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Tracking Notes row
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          SchedularTextField(
                                            isIClicked: providerContact
                                                .isRightSliderOpen
                                                ? () {}
                                                : () {
                                              toggleLeftSidebar();
                                              providerContact
                                                  .toogleContactProvider();
                                              providerContact
                                                  .toogleLeftSidebarProvider();
                                              if (hasOrderData) {
                                                providerState
                                                    .setLinkAndPageNumber(
                                                  selectLink: Uri.parse(snapshotPatient.data![0].trackingNotes.trackingNotesLink).pathSegments.last,
                                                  pageNo: snapshotPatient.data![0].trackingNotes.trackingNotesPgNo,
                                                  isLinkeOpen: snapshotPatient.data![0].trackingNotes.trackingNotesLink,
                                                );
                                              }
                                            },
                                            isIconVisible: hasOrderData
                                                ? snapshotPatient
                                                .data![0]
                                                .trackingNotes
                                                .trackingNotesLink
                                                .isEmpty
                                                : true,
                                            width: providerState
                                                .isContactTrue
                                                ? AppSize.s190
                                                : AppSize.s300,
                                            controller:
                                            trackingNotesController,
                                            labelText: 'Tracking Notes',
                                            hintText: 'Enter Text',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSize.s20),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSize.s20),

                          // ── Primary Diagnosis ─────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35),
                            child: BlueBGHeadConst(
                              HeadText: 'Primary Diagnosis',
                              body: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 10),
                                    child: StreamBuilder<
                                        List<
                                            PatientDiagnosisWithIdData>>(
                                      stream:
                                      _streamDiagnosis.stream,
                                      builder:
                                          (context, snapshotDiagnosis) {
                                        getPatientDiagnosisData(
                                          context: context,
                                          ptId:
                                          widget.patientId,
                                        ).then((data) {
                                          _streamDiagnosis.add(data);
                                        }).catchError((error) {});

                                        if (snapshotDiagnosis
                                            .connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child:
                                            CircularProgressIndicator(
                                                color: ColorManager
                                                    .blueprime),
                                          );
                                        }

                                        // Guard empty
                                        if (!snapshotDiagnosis.hasData ||
                                            snapshotDiagnosis
                                                .data!.isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 76),
                                              child: Text(
                                                AppStringSMModule
                                                    .patientDiagnosisNoData,
                                                style: AllNoDataAvailable
                                                    .customTextStyle(
                                                    context),
                                              ),
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                          const NeverScrollableScrollPhysics(),
                                          itemCount: snapshotDiagnosis
                                              .data!.length,
                                          itemBuilder: (context, index) {
                                            final item = snapshotDiagnosis
                                                .data![index];
                                            possible =
                                                TextEditingController(
                                                    text: item.dgnName);
                                            icd = TextEditingController(
                                                text: item.dgnCode);
                                            pdgm = TextEditingController(
                                                text: item.pdgm
                                                    ? 'YES'
                                                    : 'NO');

                                            return Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Row(children: [
                                                    Container(
                                                      height: 90,
                                                      width: 5,
                                                      color: item.colorId ==
                                                          0
                                                          ? ColorManager.red
                                                          : item.colorId ==
                                                          1
                                                          ? ColorManager
                                                          .greenDark
                                                          : Colors.white,
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                        AppSize.s30),
                                                    Expanded(
                                                      child:
                                                      SchedularTextField(
                                                        controller: possible,
                                                        isIconVisible: true,
                                                        labelText:
                                                        'Possible Diagnosis',
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                        AppSize.s60),
                                                    Expanded(
                                                      child:
                                                      SchedularTextField(
                                                        controller: icd,
                                                        isIconVisible: true,
                                                        labelText:
                                                        'ICD Code',
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                        AppSize.s60),
                                                    Expanded(
                                                      child:
                                                      SchedularTextField(
                                                        controller: pdgm,
                                                        isIconVisible: true,
                                                        textColor: item
                                                            .colorId ==
                                                            0
                                                            ? ColorManager
                                                            .red
                                                            : item.colorId ==
                                                            1
                                                            ? ColorManager
                                                            .greenDark
                                                            : Colors
                                                            .black,
                                                        labelText:
                                                        'PDGM - Acceptable',
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                        AppSize.s30),
                                                    if (!providerState
                                                        .isContactTrue) ...[
                                                      Expanded(
                                                          child: Container(
                                                              height: 30,
                                                              width: AppSize
                                                                  .s354)),
                                                      const SizedBox(
                                                          width:
                                                          AppSize.s30),
                                                      Expanded(
                                                          child: Container(
                                                              height: 30,
                                                              width: AppSize
                                                                  .s354)),
                                                    ],
                                                  ]),
                                                  Divider(
                                                    color: ColorManager
                                                        .containerBorderGrey,
                                                    thickness: 1,
                                                    height: 2,
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                      AppSize.s30),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  // Add Diagnosis button
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: AppSize.s30,
                                        child: CustomIconButton(
                                          color: ColorManager.blueprime,
                                          icon: Icons.add,
                                          textWeight: FontWeight.w700,
                                          textSize: FontSize.s12,
                                          text: 'Add Diagnosis',
                                          onPressed: () async{
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AddDiagnosisDialog(),
                                            );
                                          }, isNotPopUpButton: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s16),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50),
                                    child: Divider(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSize.s40),

                          // ── Special Orders ────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35),
                            child: BlueBGHeadConst(
                              HeadText: 'Special Orders',
                              body: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 60),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20),
                                      child: Text(
                                        'Flags',
                                        style: SMTextfieldHeadings
                                            .customTextStyle(context),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FutureBuilder<List<SpacialOrderData>>(
                                      future: _specialOrderFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                              CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return const Text(
                                              'Failed to load special orders.');
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Text('No special orders found!',
                                          style: AllNoDataAvailable.customTextStyle(context),);
                                        }

                                        final specialOrders =
                                        snapshot.data!;
                                        return Wrap(
                                          spacing: 70.0,
                                          runSpacing: 0.0,
                                          children: specialOrders
                                              .map((order) {
                                            return StatefulBuilder(
                                              builder:
                                                  (context, setTile) {
                                                bool isChecked =
                                                selectedOrderIds
                                                    .contains(order
                                                    .spcialorderid);
                                                return SizedBox(
                                                  width: 170,
                                                  child: ExpCheckboxTile(
                                                    title: order
                                                        .spcialordername,
                                                    initialValue:
                                                    isChecked,
                                                    isInfoIconVisible:
                                                    false,
                                                    onChanged: (value) {
                                                      setTile(() {
                                                        if (value ==
                                                            true) {
                                                          if (!selectedOrderIds
                                                              .contains(order
                                                              .spcialorderid)) {
                                                            selectedOrderIds
                                                                .add(order
                                                                .spcialorderid);
                                                          }
                                                        } else {
                                                          selectedOrderIds
                                                              .remove(order
                                                              .spcialorderid);
                                                        }
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSize.s30),
                        ],
                      ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}