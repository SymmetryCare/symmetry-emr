import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/all_intake_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/move_to_scheduler_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_clickable_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/dropdown_constant_sm.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/sm_intake_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_orders/intake_orders_screen.dart';

class InformationUpdateProvider extends ChangeNotifier {
  final VoidCallback onUpdateButtonPressed;
  final void Function(int patientId) onPatientIdReceived;

  InformationUpdateProvider({required this.onUpdateButtonPressed, required this.onPatientIdReceived});

  void handlePatientId(int patientId) {
    onPatientIdReceived(patientId);
  }

  bool _isChatbotVisible = false;

  void _toggleChatbotVisibility() {
    _isChatbotVisible = !_isChatbotVisible;
    notifyListeners();
  }

  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  int _patientId = 0;
  int _physicianId = 0;

  bool _isDemographicFilled = false;
  bool _isDocumentationUpload = false;
  bool _isPrimaryInsuranceFilled = false;
  bool _isPhysicianFilled = false;
  bool _isOrdersFilled = false;
  bool _isInitialContactFilled = false;

  bool get isDemographicFilled => _isDemographicFilled;
  bool get isDocumentationUpload => _isDocumentationUpload;
  bool get isPrimaryInsuranceFilled => _isPrimaryInsuranceFilled;
  bool get isPhysicianFilled => _isPhysicianFilled;
  bool get isOrdersFilled => _isOrdersFilled;
  bool get isInitialContactFilled => _isInitialContactFilled;
  int get ptID => _patientId;
  int get physicianId => _physicianId;

  void setPatientStatusFromModel({
    required bool demo,
    required bool doc,
    required bool insurance,
    required bool physician,
    required bool contactI,
    required bool ordern,
    required int ptId,
    required int physicianId,
  }) {
    _patientId = ptId;
    _isDemographicFilled = demo;
    _isDocumentationUpload = doc;
    _isPrimaryInsuranceFilled = insurance;
    _isPhysicianFilled = physician;
    _isOrdersFilled = ordern;
    _isInitialContactFilled = contactI;
    _physicianId = physicianId;
    notifyListeners();
  }
}

class InformationUpdateScreen extends StatefulWidget {
  final VoidCallback selectUploadButton;
  const InformationUpdateScreen({required this.selectUploadButton, super.key});

  @override
  State<InformationUpdateScreen> createState() => _InformationUpdateScreenState();
}

class _InformationUpdateScreenState extends State<InformationUpdateScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  final int itemsPerPage = 10;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SmIntakeProviderManager>(context, listen: false);
      provider.setCurrentScreenIntake(IntakefilterScreenType.infoupdate);
      provider.intakesetCurrentPage(1);
      provider.filterIdIntegrationIntake(
        context: context,
        marketerId: 'all',
        sourceId: 'all',
        pcpId: 'all',
      );
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // NEW: extracted row builder — unchanged content, just pulled out so the
  // build() control-flow restructuring below doesn't need to duplicate it.
  Widget _buildInfoUpdateRow(
      BuildContext context,
      PatientModel infoupdate,
      SmIntakeProviderManager providerContact,
      DiagnosisProvider providerPatientId,
      PriDiagnosisProvider saveProvider,
      InformationUpdateProvider tabSaveProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: IntakeContainer(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: infoupdate.thresould == 0
                    ? ColorManager.greenDark
                    : infoupdate.thresould == 1
                    ? const Color(0xFFFEBD4D)
                    : ColorManager.red,
                width: 6,
              ),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: AppSize.s60,
                    height: AppSize.s15,
                    decoration: BoxDecoration(
                      color: ColorManager.blueprime.withOpacity(0.12),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Chart #${infoupdate.ptChartNo}',
                        textAlign: TextAlign.center,
                        style: CustomTextStylesCommon.commonStyle(
                          color: const Color(0xFF1696C8),
                          fontSize: FontSize.s11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppPadding.p20,
                  right: AppPadding.p20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Profile image ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ClipOval(
                        child: infoupdate.ptImgUrl == 'imgurl' || infoupdate.ptImgUrl == null
                            ? CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.transparent,
                          child: Image.asset("images/profilepic.png"),
                        )
                            : Image.network(
                          infoupdate.ptImgUrl!,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return CircleAvatar(
                              radius: 21,
                              backgroundColor: Colors.transparent,
                              child: Image.asset("images/profilepic.png"),
                            );
                          },
                          fit: BoxFit.cover,
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ── Patient info ───────────────────────────
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${infoupdate.ptFirstName} ${infoupdate.ptLastName}",
                            textAlign: TextAlign.center,
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Intake Date: ${infoupdate.ptRefferalDate}",
                            textAlign: TextAlign.center,
                            style: CustomTextStylesCommon.commonStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "Potential DC Date :",
                                  textAlign: TextAlign.center,
                                  style: CustomTextStylesCommon.commonStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  infoupdate.potentialDischargeDate,
                                  textAlign: TextAlign.center,
                                  style: CustomTextStylesCommon.commonStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Referral source ────────────────────────
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          infoupdate.referralSource.sourceName,
                          textAlign: TextAlign.start,
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.textBlack,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),
                    SizedBox(width: MediaQuery.of(context).size.width / 35),

                    // ── Status buttons ─────────────────────────
                    Expanded(
                      flex: 5,
                      child: Wrap(
                        spacing: 16,
                        children: [
                          SMDashboardMenuButtons(
                            activeColor: infoupdate.isDemographicFilled,
                            onTap: (int index) {
                              print("demographi filled : ${infoupdate.isDemographicFilled}");
                            },
                            index: 0,
                            grpIndex: 0,
                            heading: "Demographics",
                          ),
                          SMDashboardMenuButtons(
                            activeColor: infoupdate.isDocumentationUpload,
                            onTap: (int index) {
                              print("documentation filled : ${infoupdate.isDocumentationUpload}");
                            },
                            index: 0,
                            grpIndex: 0,
                            heading: "Documentation",
                          ),
                          SMDashboardMenuButtons(
                            activeColor: infoupdate.isPrimaryInsuranceFilled,
                            onTap: (int index) {
                              print("Insurance filled : ${infoupdate.isPrimaryInsuranceFilled}");
                            },
                            index: 0,
                            grpIndex: 0,
                            heading: "Insurance",
                          ),
                          SMDashboardMenuButtons(
                            activeColor: infoupdate.isPhysicianFilled,
                            onTap: (int index) {},
                            index: 0,
                            grpIndex: 0,
                            heading: "Physician Info",
                          ),
                          SMDashboardMenuButtons(
                            activeColor: infoupdate.isOrdersFilled,
                            onTap: (int index) {},
                            index: 0,
                            grpIndex: 0,
                            heading: "Orders",
                          ),
                          SMDashboardMenuButtons(
                            activeColor: infoupdate.isInitialContactFilled,
                            onTap: (int index) {},
                            index: 0,
                            grpIndex: 0,
                            heading: "Initial Contact",
                          ),
                        ],
                      ),
                    ),

                    // ── Update button ──────────────────────────
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          tabSaveProvider.setPatientStatusFromModel(
                            demo: infoupdate.isDemographicFilled,
                            doc: infoupdate.isDocumentationUpload,
                            insurance: infoupdate.isPrimaryInsuranceFilled,
                            physician: infoupdate.isPhysicianFilled,
                            contactI: infoupdate.isInitialContactFilled,
                            ordern: infoupdate.isOrdersFilled,
                            ptId: infoupdate.ptId,
                            physicianId: infoupdate.fkPtPcp,
                          );
                          providerContact.clearMapAddressController();
                          saveProvider.setSaved(false);
                          await Future.delayed(const Duration(milliseconds: 100));
                          print("@@@@@@@@@@@@@@@@@@@ update clicked demographic ${tabSaveProvider.isDemographicFilled}");
                          print("@@@@@@@@@@@@@@@@@@@ update clicked  insurance${tabSaveProvider.isPrimaryInsuranceFilled}");
                          print("@@@@@@@@@@@@@@@@@@@ update clicked documentation ${tabSaveProvider.isDocumentationUpload}");
                          print("@@@@@@@@@@@@@@@@@@@ update clicked  physician${tabSaveProvider.isPhysicianFilled}");
                          print("@@@@@@@@@@@@@@@@@@@ update clicked order ${tabSaveProvider.isOrdersFilled}");
                          print("@@@@@@@@@@@@@@@@@@@ update clicked initial contact ${tabSaveProvider.isInitialContactFilled}");
                          providerPatientId.passPatientId(patientIdNo: infoupdate.ptId);
                          print("@@@@@@@@@@@@@@@@@@@ update clicked patient id  ${providerPatientId.patientId}");
                          widget.selectUploadButton();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/sm/cloud_uploade.png", height: 20, width: 20),
                            const SizedBox(height: 8),
                            const Text(
                              "Update",
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F6D8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Move to Scheduler button ───────────────
                    Expanded(
                      flex: 1,
                      child: Opacity(
                        opacity: infoupdate.isDemographicFilled ? 1.0 : 0.3,
                        child: IgnorePointer(
                          ignoring: !infoupdate.isDemographicFilled,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () async {
                              final DateTime now = DateTime.now();
                              final DateTime tomorrow = now.add(const Duration(days: 1));
                              final int hour = now.hour.clamp(10, 19);
                              final int minute = now.hour >= 19 ? 0 : now.minute;

                              final DateTime visitFrom = DateTime(
                                tomorrow.year,
                                tomorrow.month,
                                tomorrow.day,
                                hour,
                                minute,
                              );
                              final DateTime visitTo = visitFrom.add(const Duration(hours: 1));
                              final visitResponse = await scheduleVisits(
                                context: context,
                                patientId: infoupdate.ptId,
                                employeeVisits: [{
                                  "visits": [
                                    {
                                      "visitTimeDateFrom": visitFrom.toIso8601String(),
                                      "visitTimeDateTo": visitTo.toIso8601String(),
                                    }
                                  ],
                                }],
                                sentAsRequest: true,
                              );
                              if (visitResponse.success) {
                                await showDialog(
                                  context: context,
                                  builder: (_) => const AddSuccessPopup(
                                    message: 'Visits scheduled successfully',
                                  ),
                                );
                                Provider.of<SmIntakeProviderManager>(context, listen: false)
                                    .filterIdIntegrationIntake(
                                  context: context,
                                  marketerId: providerContact.marketerId,
                                  sourceId: providerContact.referralSourceId,
                                  pcpId: providerContact.pcpId,
                                );
                              } else {
                                await showDialog(
                                  context: context,
                                  builder: (_) => AddFailePopup(message: visitResponse.message),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 3),
                                Image.asset(
                                  "images/sm/move_to_s.png",
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  " Move to\nScheduler",
                                  style: TextStyle(
                                    fontSize: FontSize.s11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2F6D8A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Non-Admit button ───────────────────────
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () async {
                          var response = await updateNonAdmitPatient(
                            context: context,
                            patientId: infoupdate.ptId,
                            isIntake: false,
                            isNotAdmit: true,
                          );
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddSuccessPopup(message: 'Data Updated Successfully');
                              },
                            );
                            Provider.of<SmIntakeProviderManager>(context, listen: false)
                                .filterIdIntegrationIntake(
                              context: context,
                              marketerId: providerContact.marketerId,
                              sourceId: providerContact.referralSourceId,
                              pcpId: providerContact.pcpId,
                            );
                          } else {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddFailePopup(message: response.message);
                              },
                            );
                            print('Api error');
                          }
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block_flipped, size: IconSize.I18, color: Color(0xFF2F6D8A), weight: 10),
                            SizedBox(height: 8),
                            Text(
                              "Non-Admit",
                              style: TextStyle(
                                fontSize: FontSize.s11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2F6D8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerContact = Provider.of<SmIntakeProviderManager>(context, listen: false);
    final providerPatientId = Provider.of<DiagnosisProvider>(context, listen: false);
    final pageProvider = Provider.of<SmIntakeProviderManager>(context);
    final saveProvider = Provider.of<PriDiagnosisProvider>(context);
    final infoProvider = Provider.of<InformationUpdateProvider>(context);
    final tabSaveProvider = Provider.of<InformationUpdateProvider>(context);

    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          const double minContentWidth = 1200;
          final double contentWidth = constraints.maxWidth > minContentWidth
              ? constraints.maxWidth
              : minContentWidth;
          return StreamBuilder<List<PatientModel>>(
            stream: Provider.of<SmIntakeProviderManager>(context).patientReferralsStreamIntake,
            builder: (context, snapshot) {
              // CHANGED: derive state flags instead of early-returning the whole screen
              // (which was wiping out the search bar / filter icon on loading or empty results).
              final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
              final List<PatientModel> items = snapshot.data ?? [];
              final bool isEmpty = !isLoading && items.isEmpty;

              final totalItems = items.length;
              final totalPages = (totalItems / itemsPerPage).ceil();
              final currentPage = pageProvider.currentPageinfo;

              if (!isLoading && !isEmpty) {
                if (currentPage > totalPages && totalPages > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageProvider.intakesetCurrentPage(totalPages);
                  });
                } else if (totalPages == 0 && currentPage != 1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageProvider.intakesetCurrentPage(1);
                  });
                }
              }

              final paginatedItems = isEmpty
                  ? <PatientModel>[]
                  : items
                  .skip((currentPage - 1) * itemsPerPage)
                  .take(itemsPerPage)
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollbar(
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
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: AppSize.s10),
                                  // ── Search + filter row — ALWAYS RENDERED ──
                                  Row(
                                    children: [
                                      CustomSearchFieldSM(
                                        searchController: pageProvider.intakesearchController,
                                        onPressed: () {
                                          pageProvider.filterIdIntegrationIntake(
                                            context: context,
                                            marketerId: pageProvider.marketerId,
                                            sourceId: pageProvider.referralSourceId,
                                            pcpId: pageProvider.pcpId,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 20),
                                      IconButton(
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: providerContact.toggleFilter,
                                        icon: Image.asset(
                                          "images/sm/sm_refferal/filter_icon.png",
                                          height: AppSize.s18,
                                          width: AppSize.s16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: AppSize.s20),

                                  // ── List area — ONLY this switches state now ──
                                  Expanded(
                                    child: isLoading
                                        ? Center(
                                      child: CircularProgressIndicator(color: ColorManager.blueprime),
                                    )
                                        : isEmpty
                                        ? Center(
                                      child: Text(
                                        AppStringSMModule.infoUpdateNoData,
                                        style: AllNoDataAvailable.customTextStyle(context),
                                      ),
                                    )
                                        : ScrollConfiguration(
                                      behavior: const ScrollBehavior().copyWith(scrollbars: false),
                                      child: ListView.builder(
                                        itemCount: paginatedItems.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          final infoupdate = paginatedItems[index];
                                          return _buildInfoUpdateRow(
                                            context,
                                            infoupdate,
                                            providerContact,
                                            providerPatientId,
                                            saveProvider,
                                            tabSaveProvider,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── Pagination only when data exists ───
                  if (!isLoading && !isEmpty) ...[
                    const SizedBox(height: AppSize.s10),
                    PaginationControlsWidget(
                      currentPage: pageProvider.currentPageinfo,
                      items: items,
                      itemsPerPage: itemsPerPage,
                      onPreviousPagePressed: () {
                        if (pageProvider.currentPageinfo > 1) {
                          pageProvider.intakesetCurrentPage(pageProvider.currentPageinfo - 1);
                        }
                      },
                      onPageNumberPressed: (pageNumber) {
                        pageProvider.intakesetCurrentPage(pageNumber);
                      },
                      onNextPagePressed: () {
                        if (pageProvider.currentPageinfo < totalPages) {
                          pageProvider.intakesetCurrentPage(pageProvider.currentPageinfo + 1);
                        }
                      },
                    ),
                  ],
                ],
              );
            },
          );
        }),
        if (infoProvider._isChatbotVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: infoProvider._toggleChatbotVisibility,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}


typedef void OnManuButtonTapCallBack(int index);

class SMDashboardMenuButtons extends StatelessWidget {
  const SMDashboardMenuButtons({
    super.key,
    required this.onTap,
    required this.index,
    required this.grpIndex,
    required this.heading,
    required this.activeColor,
  });

  final OnManuButtonTapCallBack onTap;
  final int index;
  final int grpIndex;
  final String heading;
  final bool activeColor;

  @override
  Widget build(BuildContext context) {
    return AppClickableWidget(
      onTap: () {
        onTap(index);
      },
      onHover: (bool val) {},
      child: Column(
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w400,
              color: ColorManager.mediumgrey,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: heading,
                  style: const TextStyle(
                    fontSize: FontSize.s10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              final textWidth = textPainter.size.width;
              print("textwidth :::::::: $heading $textWidth");
              return Container(
                margin: const EdgeInsets.only(top: 8, bottom: 9),
                height: 6,
                width: 70,
                decoration: BoxDecoration(
                  color: activeColor == true ? ColorManager.greenDark : ColorManager.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class IntakeContainer extends StatelessWidget {
  final Widget child;
  const IntakeContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 3),
          left: BorderSide(color: Colors.grey.shade300, width: 1),
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: child,
    );
  }
}