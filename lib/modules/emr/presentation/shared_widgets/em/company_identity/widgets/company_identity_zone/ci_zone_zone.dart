import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/company_identity_zone/widgets/zone_widgets_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';

class CIZoneZone extends StatefulWidget {
  final int countyId;
  final int companyID;
  final String officeId;
  const CIZoneZone(
      {super.key,
      required this.companyID,
      required this.officeId,
      required this.countyId});
  @override
  State<CIZoneZone> createState() => _CIZoneZoneState();
}

class _CIZoneZoneState extends State<CIZoneZone> {
  TextEditingController countynameController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController mapController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController zoneNumberController = TextEditingController();
  late StreamController<List<AllCountyZoneGet>> _zoneController;
  late Future<List<AllCountyGetList>> _countyZoneListFuture;
  int countyId = 0;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }
  @override
  void initState() {
    super.initState();
    _zoneController = StreamController<List<AllCountyZoneGet>>.broadcast();
    _countyZoneListFuture = getCountyZoneList(context);
    fetchCountyZone();
  }
  @override
  void didUpdateWidget(covariant CIZoneZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countyId != widget.countyId) {
      fetchCountyZone();
    }
  }
  void fetchCountyZone() {
    if (widget.countyId != 0 ) {
      getZoneByCounty(context, widget.officeId,widget.countyId, 1, 9999).then((data) {
        _zoneController.add(data);
      }).catchError((error) {
        _zoneController.add([]);
        debugPrint("Error loading Zone: $error");
      });
    }
  }
  @override
  void dispose() {
    _zoneController.close(); // also close stream
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizeConst.A20),
        Container(
          height: AppSize.s30,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSize.s10),
                    child: Center(
                      child: Text(
                        AppStringEM.zoneName,
                        style:TableHeading.customTextStyle(context),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(AppStringEM.zipCodes,
                      style:TableHeading.customTextStyle(context),),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(AppStringEM.county,
                      style:TableHeading.customTextStyle(context),),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      AppStringEM.actions,
                      style:TableHeading.customTextStyle(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: AppSize.s8,
        ),
        Expanded(
          child: StreamBuilder<List<AllCountyZoneGet>>(
            stream: _zoneController.stream,
            builder: (context, snapshot) {
              print('1111111');
              if(widget.countyId == 0){
                return Center(
                  child: Text(
                    ErrorMessageString.noZones,
                    style: AllNoDataAvailable.customTextStyle(context),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.blueprime,
                  ),
                );
              }
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    ErrorMessageString.noZones,
                    style: AllNoDataAvailable.customTextStyle(context),
                  ),
                );
              }
              if (snapshot.hasData) {
                int totalItems = snapshot.data!.length;
                int totalPages = (totalItems / itemsPerPage).ceil();
                List<AllCountyZoneGet> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();
                return Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(scrollbars: false),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: paginatedData.length,
                            itemBuilder: (context, index) {
                              // Reverse the index to show newly added items at the top
                              int reverseIndex = paginatedData.length - 1 - index;
                              int serialNumber = reverseIndex + 1 + (currentPage - 1) * itemsPerPage;
                              String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                              AllCountyZoneGet zone = paginatedData[index];  // Use reverseIndex here
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xff000000).withOpacity(0.25),
                                            spreadRadius: 0,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      margin: const EdgeInsets.symmetric(horizontal: AppMargin.m5),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppPadding.p15,
                                            vertical: AppPadding.p8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                zone.zoneName
                                                    .toString(),
                                                style:  TableSubHeading.customTextStyle(context),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Builder(
                                                builder: (context) {
                                                  final raw = zone.zipcodes.toString();
                                                  if (raw == '--' || raw.isEmpty) {
                                                    return Text(
                                                      raw,
                                                      textAlign: TextAlign.center,
                                                      style: TableSubHeading.customTextStyle(context).copyWith(height: 1.5),
                                                    );
                                                  }
                                                  final allZips = raw
                                                      .split(',')
                                                      .map((e) => e.trim())
                                                      .where((e) => e.isNotEmpty)
                                                      .toList();
                                                  final List<List<String>> chunks = [];
                                                  for (int i = 0; i < allZips.length; i += 6) {
                                                    chunks.add(allZips.sublist(i, (i + 6).clamp(0, allZips.length)));
                                                  }
                                                  return Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: chunks
                                                        .asMap()
                                                        .entries
                                                        .map((entry) => Text(
                                                              entry.value.join(', ') + (entry.key < chunks.length - 1 ? ',' : ''),
                                                              textAlign: TextAlign.center,
                                                              style: TableSubHeading.customTextStyle(context).copyWith(height: 1.5),
                                                            ))
                                                        .toList(),
                                                  );
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                zone.countyName
                                                    .toString(),
                                                style:  DocumentTypeDataStyle.customTextStyle(context),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      splashColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      onPressed: () {
                                                        final Future<CountyZonePrefillGet> zoneCountyPrefillFuture =
                                                            getZoneByCountyPrefill(context, zone.zoneId);
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return FutureBuilder<CountyZonePrefillGet>(
                                                                  future: zoneCountyPrefillFuture,
                                                                  builder: (context, snapshotPrefill) {
                                                                    if (snapshotPrefill.connectionState == ConnectionState.waiting) {
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color: ColorManager
                                                                              .blueprime,
                                                                        ),
                                                                      );
                                                                    }
                                                                    var zoneNumber =
                                                                        snapshotPrefill
                                                                            .data!
                                                                            .zoneName
                                                                            .toString();
                                                                    var countyPreId =
                                                                        snapshotPrefill
                                                                            .data!
                                                                            .countyId;
                                                                    countyId =
                                                                        countyPreId;
                                                                    zoneNumberController =
                                                                        TextEditingController(
                                                                            text: snapshotPrefill
                                                                                .data!
                                                                                .zoneName
                                                                                .toString());
                                                                    return AddZonePopup(
                                                                      countyNameController: TextEditingController(text: snapshotPrefill.data!.countyName),
                                                                      buttonTitle: AppStringEM.save,
                                                                      zoneNumberController:
                                                                          zoneNumberController,
                                                                      title:
                                                                          'Edit Zone',
                                                                      onSavePressed:
                                                                          () async {
                                                                       var response =  await updateZoneCountyData(
                                                                            context,
                                                                           zone.zoneId,
                                                                            zoneNumber ==
                                                                                zoneNumberController.text
                                                                                ? zoneNumber.toString()
                                                                                : zoneNumberController.text,
                                                                            countyPreId ==
                                                                                    countyId
                                                                                ? countyPreId
                                                                                : countyId,
                                                                            widget
                                                                                .officeId,
                                                                            widget
                                                                                .companyID);
                                                                        zoneNumberController
                                                                            .clear();
                                                                        countyId = 0;
                                                                       Navigator.pop(context);
                                                                       if(response.statusCode == 200 || response.statusCode == 201){
                                                                         showDialog(
                                                                           context: context,
                                                                           builder: (BuildContext context) {
                                                                             return const AddSuccessPopup(
                                                                               message: 'Zone Edited Successfully',
                                                                             );
                                                                           },
                                                                         );
                                                                       }else if(response.statusCode == 400 || response.statusCode == 404){
                                                                         Navigator.pop(context);
                                                                         showDialog(
                                                                           context: context,
                                                                           builder: (BuildContext context) => const FourNotFourPopup(),
                                                                         );
                                                                       }
                                                                       else {
                                                                         Navigator.pop(context);
                                                                         showDialog(
                                                                           context: context,
                                                                           builder: (BuildContext context) => FailedPopup(text: response.message),
                                                                         );
                                                                       }
                                                                      },
                                                                      child: FutureBuilder<
                                                                          List<AllCountyGetList>>(
                                                                          future: _countyZoneListFuture,
                                                                          builder:
                                                                              (context,
                                                                                  snapshotZone) {
                                                                            if (snapshotZone
                                                                                    .connectionState ==
                                                                                ConnectionState
                                                                                    .waiting) {
                                                                              return Container(
                                                                                width: 354,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(
                                                                                      color: ColorManager.containerBorderGrey, width: AppSize.s1),
                                                                                  borderRadius: BorderRadius.circular(4),
                                                                                ),
                                                                                child: const Text(
                                                                                  "",
                                                                                ),
                                                                              );
                                                                            }
                                                                            if (snapshotZone
                                                                                .data!
                                                                                .isEmpty) {
                                                                              return Center(
                                                                                child:
                                                                                    Text(
                                                                                      ErrorMessageString.noCountyAdded,
                                                                                  style:
                                                                                  DocumentTypeDataStyle.customTextStyle(context)
                                                                                ),
                                                                              );
                                                                            }
                                                                            if (snapshotZone
                                                                                .hasData) {
                                                                              List
                                                                                  dropDown =
                                                                                  [];
                                                                              int docType =
                                                                                  0;
                                                                              List<DropdownMenuItem<String>>
                                                                                  dropDownTypesList =
                                                                                  [];
                                                                              for (var i
                                                                                  in snapshotZone.data!) {
                                                                                dropDownTypesList
                                                                                    .add(
                                                                                  DropdownMenuItem<String>(
                                                                                    value: i.countyName,
                                                                                    child: Text(i.countyName),
                                                                                  ),
                                                                                );
                                                                              }
                                                                              return CICCDropdown(
                                                                                  initialValue: dropDownTypesList[0]
                                                                                      .value,
                                                                                  onChange:
                                                                                      (val) {
                                                                                    for (var a in snapshotZone.data!) {
                                                                                      if (a.countyName == val) {
                                                                                        docType = a.countyId;
                                                                                        print("County id :: ${a.companyId}");
                                                                                        countyId = docType;
                                                                                      }
                                                                                    }
                                                                                    print(":::${docType}");
                                                                                    print(":::<>${countyId}");
                                                                                  },
                                                                                  items:
                                                                                      dropDownTypesList);
                                                                            }
                                                                            return const SizedBox();
                                                                          }),
                                                                    );
                                                                  });
                                                            }).then((_) => fetchCountyZone());
                                                      },
                                                      icon:Icon(Icons.edit_outlined,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,),),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 8),
                                ],
                              );
                            }),
                      ),
                    ),
                    // Pagination Controls
                    PaginationControlsWidget(
                      currentPage: currentPage,
                      items: snapshot.data!,
                      itemsPerPage: itemsPerPage,
                      onPreviousPagePressed: () {
                        setState(() {
                          currentPage = currentPage > 1 ? currentPage - 1 : 1;
                        });
                      },
                      onPageNumberPressed: (pageNumber) {
                        setState(() {
                          currentPage = pageNumber;
                        });
                      },
                      onNextPagePressed: () {
                        setState(() {
                          currentPage = currentPage < totalPages ? currentPage + 1 : totalPages;
                        });
                      },
                    ),
                  ],
                );
              }
              return const Offstage();
            },
          ),
        ),
      ],
    );
  }
}
