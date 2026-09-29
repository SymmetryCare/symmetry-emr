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
import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_update_schedular/information_update.dart';

class NonAdmitPage extends StatefulWidget {
  const NonAdmitPage({super.key});

  @override
  State<NonAdmitPage> createState() => _NonAdmitPageState();
}

class _NonAdmitPageState extends State<NonAdmitPage> {
  bool _isFilterOpen = false; // Track filter panel state

  bool _isChatbotVisible = false;

  void _toggleChatbotVisibility() {
    setState(() {
      _isChatbotVisible = !_isChatbotVisible;
    });
  }

  final int itemsPerPage = 10;

  final ScrollController _horizontalScrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
      Provider.of<SmIntakeProviderManager>(context, listen: false);

      provider.setCurrentScreenNonAdmit(
          NonAdmitScreenType.nonAdmit); // Intake screen
      provider.iinoCurrentPage(1);
      provider.filterIdNonAdmitIntegration(
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
    _searchController.dispose();
    super.dispose();
  }

  // NEW: extracted row builder so it renders identically regardless of the state branch above it
  Widget _buildNonAdmitRow(
      BuildContext context,
      NonAdmitData nonadmit,
      SmIntakeProviderManager providerContact,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
          vertical: 7),
      child: IntakeContainer(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: nonadmit
                    .thresould ==
                    0
                    ? ColorManager
                    .greenDark
                    : nonadmit.thresould ==
                    1
                    ? const Color(
                    0xFFFEBD4D)
                    : ColorManager
                    .red,
                width: 6,
              ),
            ),
            borderRadius:
            const BorderRadius.only(
                bottomLeft:
                Radius.circular(
                    10),
                topLeft:
                Radius.circular(
                    12)),
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .end,
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                      children: [
                        Container(
                            width:
                            AppSize
                                .s60,
                            height:
                            AppSize
                                .s16,
                            decoration:
                            BoxDecoration(
                              color: ColorManager
                                  .blueprime
                                  .withOpacity(
                                  0.12),
                              borderRadius: const BorderRadius
                                  .only(
                                  topRight:
                                  Radius.circular(8)),
                            ),
                            child:
                            Center(
                              child: Text(
                                  'Chart #${nonadmit.ptChartNo}',
                                  textAlign: TextAlign
                                      .center,
                                  style: CustomTextStylesCommon.commonStyle(
                                      color: const Color(0xFF1696C8),
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w700)),
                            )),
                      ]),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.p20,
                        right: AppPadding.p50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0),
                          child: ClipOval(
                            child: nonadmit.ptImgUrl == 'imgurl' || nonadmit.ptImgUrl == null
                                ? CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.transparent,
                              child: Image.asset("images/profilepic.png"),
                            )
                                : Image.network(
                              nonadmit.ptImgUrl!,
                              loadingBuilder: (context,
                                  child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                    ),
                                  );
                                }
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
                        const SizedBox(width: 10,),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${nonadmit.ptFirstName} ${nonadmit.ptLastName}",
                                textAlign: TextAlign.center,
                                style: CustomTextStylesCommon.commonStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Text(
                                "Intake Date:  ${nonadmit.ptRefferalDate}",
                                textAlign: TextAlign.center,
                                style: CustomTextStylesCommon.commonStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                              const SizedBox(height: 3,),
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
                                      nonadmit.potentialDischargeDate,
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
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              nonadmit
                                  .referralSource
                                  .sourceName,
                              textAlign:
                              TextAlign
                                  .start,
                              style: CustomTextStylesCommon
                                  .commonStyle(
                                fontSize:
                                FontSize.s12,
                                fontWeight:
                                FontWeight.w400,
                                color: ColorManager
                                    .textBlack,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(
                              context)
                              .size
                              .width /
                              25,
                        ),
                        Expanded(
                          flex: 7,
                          child: Wrap(
                            spacing: 17,
                            children: [
                              SMDashboardMenuButtons(
                                  activeColor: nonadmit
                                      .isDemographicFilled,
                                  onTap: (int
                                  index) {
                                  },
                                  index:
                                  0,
                                  grpIndex:
                                  0,
                                  heading:
                                  "Demographics"),
                              SMDashboardMenuButtons(
                                  activeColor: nonadmit
                                      .isDocumentationUpload,
                                  onTap: (int
                                  index) {
                                  },
                                  index:
                                  0,
                                  grpIndex:
                                  0,
                                  heading:
                                  "Documentation"),
                              SMDashboardMenuButtons(
                                  activeColor: nonadmit
                                      .isPrimaryInsuranceFilled,
                                  onTap: (int
                                  index) {
                                  },
                                  index:
                                  0,
                                  grpIndex:
                                  0,
                                  heading:
                                  "Insurance"),
                              SMDashboardMenuButtons(
                                  activeColor: nonadmit
                                      .isPhysicianFilled,
                                  onTap: (int
                                  index) {
                                  },
                                  index:
                                  0,
                                  grpIndex:
                                  0,
                                  heading:
                                  "Physician Info"),
                              SMDashboardMenuButtons(
                                  activeColor: nonadmit
                                      .isOrdersFilled,
                                  onTap: (int
                                  index) {
                                  },
                                  index:
                                  0,
                                  grpIndex:
                                  0,
                                  heading:
                                  "Orders"),
                              SMDashboardMenuButtons(
                                  activeColor: nonadmit
                                      .isInitialContactFilled,
                                  onTap: (int
                                  index) {
                                  },
                                  index:
                                  0,
                                  grpIndex:
                                  0,
                                  heading:
                                  "Initial Contact"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child:
                          InkWell(
                            splashColor:
                            Colors
                                .transparent,
                            highlightColor:
                            Colors
                                .transparent,
                            hoverColor:
                            Colors
                                .transparent,
                            onTap:
                            _toggleChatbotVisibility,
                            child:
                            Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [
                                Image.asset(
                                    "images/sm/contact_icon.png",
                                    height:
                                    25),
                                const SizedBox(
                                  height:
                                  6,
                                ),
                                const Text(
                                  "Contact",
                                  style:
                                  TextStyle(
                                    fontSize:
                                    FontSize.s11,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    Color(0xFF2F6D8A),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () async {
                                var response =
                                await updateNonAdmitPatient(
                                  context:
                                  context,
                                  patientId:
                                  nonadmit.ptId,
                                  isIntake:
                                  true,
                                  isNotAdmit:
                                  false, // ✅ Restore means not marked as "Not Admit"
                                );
                                if (response.statusCode ==
                                    200 ||
                                    response.statusCode ==
                                        201) {
                                  await showDialog(
                                    context:
                                    context,
                                    builder:
                                        (BuildContext context) {
                                      return const AddSuccessPopup(
                                        message: 'Patient restored successfully',
                                      );
                                    },
                                  );

                                  Provider.of<SmIntakeProviderManager>(context, listen: false)
                                      .filterIdNonAdmitIntegration(
                                    context:
                                    context,
                                    marketerId:
                                    providerContact.marketerId,
                                    sourceId:
                                    providerContact.referralSourceId,
                                    pcpId:
                                    providerContact.pcpId,
                                  );
                                } else {
                                  await showDialog(
                                    context:
                                    context,
                                    builder:
                                        (BuildContext context) {
                                      return AddFailePopup(
                                        message: response.message,
                                      );
                                    },
                                  );
                                  print(
                                      'API error: ${response.message}');
                                }
                              },
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Image
                                      .asset(
                                    "images/sm/left_bottom.png",
                                    height:
                                    20,
                                    width:
                                    20,
                                  ),
                                  const SizedBox(
                                    height:
                                    8,
                                  ),
                                  const Text(
                                    "Restore",
                                    style:
                                    TextStyle(
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2F6D8A),
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: AppSize.s5),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerContact =
    Provider.of<SmIntakeProviderManager>(context, listen: false);
    final pageProvider = Provider.of<SmIntakeProviderManager>(context);
    return Stack(children: [
      LayoutBuilder(builder: (context, constraints) {
        const double minContentWidth = 1200;
        final double contentWidth = constraints.maxWidth > minContentWidth
            ? constraints.maxWidth
            : minContentWidth;
        return StreamBuilder<List<NonAdmitData>>(
            stream: Provider.of<SmIntakeProviderManager>(context)
                .patientNonAdmitStream,
            builder: (context, snapshot) {
              // CHANGED: derive state flags instead of early-returning the whole
              // screen (which previously hid the search bar during loading/empty states).
              final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
              final List<NonAdmitData> items = snapshot.data ?? [];
              final bool isEmpty = !isLoading && items.isEmpty;

              final totalItems = items.length;
              final totalPages = (totalItems / itemsPerPage).ceil();
              final currentPage = pageProvider.currentPageno;

              if (!isLoading && !isEmpty) {
                if (currentPage > totalPages && totalPages > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageProvider.iinoCurrentPage(totalPages);
                  });
                } else if (totalPages == 0 && currentPage != 1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageProvider.iinoCurrentPage(1);
                  });
                }
              }

              final paginatedItems = isEmpty
                  ? <NonAdmitData>[]
                  : items.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

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
                          padding:
                          const EdgeInsets.only(bottom: AppPadding.p10),
                          child: SizedBox(
                            width: contentWidth,
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  // ── Search + filter row — ALWAYS RENDERED ──
                                  Row(
                                    children: [
                                      CustomSearchFieldSM(
                                        searchController: pageProvider.searchControllerNonAdmit,
                                        onPressed: () {
                                          pageProvider
                                              .filterIdNonAdmitIntegration(
                                            context: context,
                                            marketerId:
                                            pageProvider.marketerId,
                                            sourceId:
                                            pageProvider.referralSourceId,
                                            pcpId: pageProvider.pcpId,
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      IconButton(
                                          hoverColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed:
                                          providerContact.toggleFilter,
                                          icon: Image.asset(
                                              "images/sm/sm_refferal/filter_icon.png",
                                              height: AppSize.s18,
                                              width: AppSize.s16)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppSize.s20,
                                  ),

                                  // ── List area — ONLY this switches state now ──
                                  Expanded(
                                    child: isLoading
                                        ? Center(
                                      child: CircularProgressIndicator(
                                        color: ColorManager.blueprime,
                                      ),
                                    )
                                        : isEmpty
                                        ? Center(
                                      child: Text(
                                        AppStringSMModule.NoAdmitData,
                                        style: AllNoDataAvailable.customTextStyle(context),
                                      ),
                                    )
                                        : ScrollConfiguration(
                                      behavior: const ScrollBehavior()
                                          .copyWith(scrollbars: false),
                                      child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount: paginatedItems.length,
                                        itemBuilder: (context, index) {
                                          final nonadmit =
                                          paginatedItems[index];
                                          return _buildNonAdmitRow(context, nonadmit, providerContact);
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
                      currentPage: currentPage,
                      items: items, // Full list passed here
                      itemsPerPage: itemsPerPage,
                      onPreviousPagePressed: () {
                        if (currentPage > 1) {
                          pageProvider.iinoCurrentPage(currentPage - 1);
                        }
                      },
                      onPageNumberPressed: (pageNumber) {
                        pageProvider.iinoCurrentPage(pageNumber);
                      },
                      onNextPagePressed: () {
                        if (currentPage < totalPages) {
                          pageProvider.iinoCurrentPage(currentPage + 1);
                        }
                      },
                    ),
                  ],
                ],
              );
            });
      }),
      if (_isChatbotVisible)
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleChatbotVisibility, // Close popup on tapping outside
            child: Container(color: Colors.transparent),
          ),
        ),
    ]);
  }
}