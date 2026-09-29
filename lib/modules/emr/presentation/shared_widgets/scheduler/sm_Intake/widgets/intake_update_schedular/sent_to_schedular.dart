import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_update_schedular/information_update.dart';
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
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';

class SentToSchedularScreen extends StatefulWidget {
  const SentToSchedularScreen({super.key});

  @override
  State<SentToSchedularScreen> createState() => _SentToSchedularScreenState();
}

class _SentToSchedularScreenState extends State<SentToSchedularScreen> {

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
      final provider = Provider.of<SmIntakeProviderManager>(context, listen: false);

      provider.setCurrentScreenIntake(IntakefilterScreenType.sendtosech); // Intake screen
      provider.iiCurrentPage(1);
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

  // NEW: extracted row builder so it renders identically regardless of the state branch above it.
  // Also FIXED — the original row used `snapshot.data![index]` to color/label the SOC
  // status text, which is the index into the FULL unpaginated list, not the paginated
  // slice. On page 2+ this pointed at the wrong patient entirely. Now uses `sendtosche`
  // (the correct paginated item) consistently throughout.
  Widget _buildSentToSchedularRow(BuildContext context, PatientModel sendtosche) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: IntakeContainer(
            child: Container(
              decoration: BoxDecoration(
                border:  Border(
                  left: BorderSide(
                    color:
                    sendtosche.thresould == 0
                        ? ColorManager.greenDark
                        : sendtosche.thresould == 1
                        ? const Color(0xFFFEBD4D)
                        : ColorManager.red,
                    width: 6,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(12)),
              ),
              child: Column(
                  children: [
                    const SizedBox(height: AppSize.s16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ClipOval(
                              child: sendtosche.ptImgUrl == 'imgurl' ||
                                  sendtosche.ptImgUrl == null
                                  ? CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.transparent,
                                child: Image.asset("images/profilepic.png"),
                              )
                                  : Image.network(
                                sendtosche.ptImgUrl!,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
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
                          ///name
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${sendtosche.ptFirstName} ${sendtosche.ptLastName}",
                                  textAlign: TextAlign.center,
                                  style:
                                  CustomTextStylesCommon.commonStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Intake Date: ${sendtosche.ptRefferalDate}",
                                  textAlign: TextAlign.center,
                                  style:
                                  CustomTextStylesCommon.commonStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Potential DC Date :",
                                        textAlign: TextAlign.center,
                                        style: CustomTextStylesCommon.commonStyle(
                                          fontSize: FontSize.s11,
                                          fontWeight: FontWeight.w600,
                                          color: ColorManager.mediumgrey,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        sendtosche.potentialDischargeDate,
                                        textAlign: TextAlign.center,
                                        style: CustomTextStylesCommon
                                            .commonStyle(
                                          fontSize: FontSize.s11,
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
                          const SizedBox(width: AppSize.s10),
                          Expanded(
                            flex: 2,
                            child:  Center(
                              child:Text(sendtosche.referralSource.sourceName,
                                textAlign: TextAlign.start,
                                style: CustomTextStylesCommon.commonStyle(fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorManager.textBlack,),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSize.s10),
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: ColorManager.blueprime,
                                  size: IconSize.I20,
                                ),
                                const SizedBox(width: 10,),
                                Flexible(
                                  child: Text(
                                    sendtosche.ptAddress,
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
                          ),
                          const SizedBox(width: AppSize.s20),
                          ///UI new
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Center(
                                  child: SizedBox(
                                      height: sendtosche.detailedDisciplines.isEmpty
                                          ? 80
                                          : max(80, sendtosche.detailedDisciplines.length * (55 * (1 - .4))),
                                      child: sendtosche.allCliniciansAssigned
                                          ? LayoutBuilder(
                                        builder: (context, constraints) {
                                          double itemHeight = 45 * (1 - .4); // vertical spacing per item
                                          double totalStackHeight = sendtosche.detailedDisciplines.length * itemHeight;
                                          double containerHeight = constraints.maxHeight;

                                          // Calculate the top starting point to center the list vertically
                                          double startingTop = max(0, (containerHeight - totalStackHeight) / 2);

                                          return Stack(
                                            children: [
                                              for (var i = 0; i < sendtosche.detailedDisciplines.length; i++)
                                                Positioned(
                                                  left: 0,
                                                  top: startingTop + (i * itemHeight),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: Colors.white,
                                                        radius: 16,
                                                        child: ClipOval(
                                                          child: sendtosche.detailedDisciplines[i].imgUrl == null ||
                                                              sendtosche.detailedDisciplines[i].imgUrl.isEmpty
                                                              ? Image.asset(
                                                            'images/profilepic.png',
                                                            fit: BoxFit.cover,
                                                            width: 32,
                                                            height: 32,
                                                          ) : Image.network(
                                                            sendtosche.detailedDisciplines[i].imgUrl,
                                                            fit: BoxFit.cover,
                                                            width: 32,
                                                            height: 32,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Image.asset('images/profilepic.png', fit: BoxFit.cover);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: AppSize.s12),
                                                      Container(
                                                        width: AppSize.s40,
                                                        height: AppSize.s20,
                                                        decoration: BoxDecoration(
                                                          color:  HexColor.fromHex(sendtosche.detailedDisciplines[i].color),
                                                          border: Border.all(color: HexColor.fromHex(sendtosche.detailedDisciplines[i].color)),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            sendtosche.detailedDisciplines[i].abbreviation,
                                                            style: CustomTextStylesCommon.commonStyle(
                                                              fontSize: FontSize.s12,
                                                              fontWeight: FontWeight.w400,
                                                              color: HexColor.fromHex(sendtosche.detailedDisciplines[i].color) == '#FFFFFF' ? ColorManager.mediumgrey :Colors.white,
                                                            ),

                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: AppSize.s12),
                                                      Text(
                                                        "${sendtosche.detailedDisciplines[i].firstName} ${sendtosche.detailedDisciplines[i].lastName}",
                                                        style: CustomTextStylesCommon.commonStyle(
                                                          fontSize: FontSize.s12,
                                                          fontWeight: FontWeight.w400,
                                                          color: ColorManager.textBlack,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          );   },)
                                          :Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 16,
                                            child: ClipOval(
                                              child: Image.asset(
                                                'images/profilepic.png',
                                                fit: BoxFit.cover,
                                                width: 32,
                                                height: 32,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSize.s24),
                                          Text(
                                            "Pending",
                                            style: CustomTextStylesCommon.commonStyle(
                                              fontSize: FontSize.s12,
                                              fontWeight: FontWeight.w400,
                                              color: ColorManager.textBlack,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),


                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE2F2F8),
                                  borderRadius:
                                  BorderRadius.circular(5)),

                              width: 22,
                              height: 20,
                              child: const Center(
                                child: Text(
                                  "A",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: FontSize.s12,
                                    color: Color(0xFF1696C8),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              sendtosche.allCliniciansAssigned ? "Scheduled" : "--",
                              textAlign: TextAlign.start,
                              style: CustomTextStylesCommon.commonStyle(
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.Violet,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              // FIXED — was `snapshot.data![index].ptSOCStatus` which
                              // could index the wrong patient on page 2+; now uses
                              // the actual paginated item passed into this row.
                              sendtosche.ptSOCStatus ? "SOC Completed" : "SOC Pending",
                              textAlign: TextAlign.start,
                              style: CustomTextStylesCommon.commonStyle(
                                fontSize: FontSize.s12,
                                fontWeight: FontWeight.w600,
                                color: sendtosche.ptSOCStatus ? ColorManager.greenDark : ColorManager.red,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: _toggleChatbotVisibility,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                      "images/sm/contact_icon.png",
                                      height: 25),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  const Text(
                                    "Contact",
                                    style: TextStyle(
                                      fontSize: FontSize.s11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2F6D8A),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSize.s5),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s5),
                  ] ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    final providerContact = Provider.of<SmIntakeProviderManager>(context,listen: false);
    final pageProvider = Provider.of<SmIntakeProviderManager>(context);
    return Stack(children: [
      LayoutBuilder(builder: (context, constraints) {
        const double minContentWidth = 1200;
        final double contentWidth = constraints.maxWidth > minContentWidth
            ? constraints.maxWidth
            : minContentWidth;
        return StreamBuilder<List<PatientModel>>(
            stream: Provider.of<SmIntakeProviderManager>(context).patientReferralsStreamIntake,
            builder: (context ,snapshot) {
              // CHANGED: derive state flags instead of early-returning the whole
              // screen (which previously hid the search bar during loading/empty states).
              final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
              final List<PatientModel> items = snapshot.data ?? [];
              final bool isEmpty = !isLoading && items.isEmpty;

              if (!isLoading) {
                print(' data length from send to schedular ::::::::::::::::::::::::::::::${items.length}');
              }

              final totalItems = items.length;
              final totalPages = (totalItems / itemsPerPage).ceil();
              final currentPage = pageProvider.currentPagess;

              if (!isLoading && !isEmpty) {
                if (currentPage > totalPages && totalPages > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageProvider.iiCurrentPage(totalPages);
                  });
                } else if (totalPages == 0 && currentPage != 1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    pageProvider.iiCurrentPage(1);
                  });
                }
              }

              final paginatedItems = isEmpty
                  ? <PatientModel>[]
                  : items.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

              return  Column(
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
                                  const SizedBox(height: 10,),
                                  // ── Search + filter row — ALWAYS RENDERED ──
                                  Row(
                                    children: [
                                      CustomSearchFieldSM(
                                        searchController: pageProvider.sendToSchedController,
                                        onPressed: () {
                                          pageProvider.filterIdIntegrationIntake(
                                            context: context,
                                            marketerId: pageProvider.marketerId,
                                            sourceId: pageProvider.referralSourceId,
                                            pcpId: pageProvider.pcpId,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 20,),
                                      IconButton(
                                          hoverColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onPressed: providerContact.toggleFilter,
                                          icon: Image.asset("images/sm/sm_refferal/filter_icon.png",
                                              height: AppSize.s18,
                                              width: AppSize.s16)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s20,),

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
                                        AppStringSMModule.sendToSchedNoData,
                                        style: AllNoDataAvailable.customTextStyle(context),
                                      ),
                                    )
                                        : ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                      child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        itemCount: paginatedItems.length,
                                        itemBuilder: (context, index) {
                                          final sendtosche = paginatedItems[index];
                                          return _buildSentToSchedularRow(context, sendtosche);
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
                  // ── Pagination only when data exists ───────────────────
                  if (!isLoading && !isEmpty) ...[
                    const SizedBox(height: AppSize.s10),
                    PaginationControlsWidget(
                      currentPage: currentPage,
                      items: items, // Full list passed here
                      itemsPerPage: itemsPerPage,
                      onPreviousPagePressed: () {
                        if (currentPage > 1) {
                          pageProvider.iiCurrentPage(currentPage - 1);
                        }
                      },
                      onPageNumberPressed: (pageNumber) {
                        pageProvider.iiCurrentPage(pageNumber);
                      },
                      onNextPagePressed: () {
                        if (currentPage < totalPages) {
                          pageProvider.iiCurrentPage(currentPage + 1);
                        }
                      },
                    ),
                  ],
                ],
              );
            }
        );
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