import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/widgets/Contract_edit_dialog.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/manage_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';

class CiInsuranceContract extends StatefulWidget {
  final int insuranceVendorId;
  final String officeId;

  const CiInsuranceContract({
    super.key,
    required this.insuranceVendorId,
    required this.officeId,
  });

  @override
  State<CiInsuranceContract> createState() => _CiInsuranceContractState();
}

class _CiInsuranceContractState extends State<CiInsuranceContract> {
  TextEditingController contractNameController = TextEditingController();
  TextEditingController contractIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  late StreamController<List<ManageInsuranceContractData>> _controller;

  int currentPage = 1;
  final int itemsPerPage = 10;
  String? expiryType;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _controller = StreamController<List<ManageInsuranceContractData>>.broadcast();
    fetchVendorContractZone();
  }
  @override
  void didUpdateWidget(covariant CiInsuranceContract oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insuranceVendorId != widget.insuranceVendorId) {
      fetchVendorContractZone();
    }
  }
  void fetchVendorContractZone() {
    if (widget.insuranceVendorId != 0 ) {
      companyContractGetByVendorId(
          context,
          widget.officeId,
          widget.insuranceVendorId,
          1,9999
      ).then((data) {
        _controller.add(data);
      }).catchError((error) {
        _controller.add([]);
        debugPrint("Error loading Zone: $error");
      });
    }
  }
  @override
  void dispose() {
    _controller.close(); // also close stream
    super.dispose();
  }
  static const double _kDesignWidth = 855;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ManageInsuranceContractData>>(
              stream: _controller.stream,
              builder: (context, snapshot) {
                if(widget.insuranceVendorId == 0){
                  return Center(
                    child: Text(
                      ErrorMessageString.noContract,
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
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load data',
                      style: CommonErrorMsg.customTextStyle(context),
                    ),
                  );
                }
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      ErrorMessageString.noContract,
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  );
                }
                if(snapshot.hasData){
                  int totalItems = snapshot.data!.length;
                  int totalPages = (totalItems / itemsPerPage).ceil();
                  List<ManageInsuranceContractData> paginatedData = snapshot.data!
                      .skip((currentPage - 1) * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior().copyWith(scrollbars: false),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: paginatedData.length,
                            itemBuilder: (context, index) {
                              ManageInsuranceContractData contract =
                              paginatedData[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                          const Color(0xff000000).withOpacity(0.25),
                                          spreadRadius: 0,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    height: AppSize.s65,
                                    margin: const EdgeInsets.symmetric(horizontal: AppMargin.m2),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: AppPadding.p30, left: AppPadding.p15),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  // Implement the view action
                                                },
                                                child: Container(
                                                  width: 62,
                                                  height: 45,
                                                  child: Image.asset(
                                                    'images/eye.png',
                                                    height: 15,
                                                    width: 22,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: AppSize.s10),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "ID: ${contract.contractId}",
                                                    textAlign: TextAlign.center,
                                                    style:  DocDefineTableDataID.customTextStyle(context),
                                                  ),
                                                  const SizedBox(height: AppSize.s8,),
                                                  Text(
                                                    contract.contractName
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style:  DocDefineTableData.customTextStyle(context),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  String? selectedExpiryType =
                                                      expiryType;
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return _ContractEditDialogContent(
                                                        insuranceVendorContracId:
                                                        snapshot.data![index].insuranceVendorContracId,
                                                      );
                                                    },
                                                  ).then((_) => fetchVendorContractZone());
                                                },
                                                icon: Icon(Icons.edit_outlined,
                                                  size:IconSize.I22,color: IconColorManager.blueprime,),
                                                splashColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                              ),
                                              const SizedBox(width: AppSize.s10,),
                                              IconButton(
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  onPressed: () {
                                                    showDialog(context: context,
                                                        builder: (context) => StatefulBuilder(
                                                          builder: (BuildContext context, void Function(void Function()) setState) {
                                                            return  DeletePopup(
                                                                title: 'Delete Contract',
                                                                loadingDuration: _isLoading,
                                                                onCancel: (){
                                                                  Navigator.pop(context);
                                                                }, onDelete: () async{
                                                              setState(() {
                                                                _isLoading = true;
                                                              });
                                                              try {
                                                                await deleteContract(context, contract.insuranceVendorContracId);
                                                                Navigator.pop(context);
                                                                showDialog(context: context, builder: (context) => const DeleteSuccessPopup());
                                                              } finally {
                                                                setState(() {
                                                                  _isLoading = false;
                                                                });
                                                              }
                                                            });
                                                          },

                                                        )).then((_) => fetchVendorContractZone());
                                                  },
                                                  icon:  Icon(Icons.delete_outline,size:IconSize.I22,color: IconColorManager.red,)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSize.s8,),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
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
                            currentPage = currentPage < totalPages
                                ? currentPage + 1
                                : totalPages;
                          });
                        },
                      ),
                    ],
                  );
                }
                else{
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// FIX: wraps the Edit Contract dialog content so getPrefillContract() is
// fetched exactly once (in initState) instead of being called inline in a
// FutureBuilder, which re-fired the API call on every rebuild of the dialog.
class _ContractEditDialogContent extends StatefulWidget {
  final int insuranceVendorContracId;

  const _ContractEditDialogContent({required this.insuranceVendorContracId});

  @override
  State<_ContractEditDialogContent> createState() =>
      _ContractEditDialogContentState();
}

class _ContractEditDialogContentState
    extends State<_ContractEditDialogContent> {
  late Future<ManageContractPrefill> _prefillFuture;

  @override
  void initState() {
    super.initState();
    _prefillFuture =
        getPrefillContract(context, widget.insuranceVendorContracId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ManageContractPrefill>(
        future: _prefillFuture,
        builder: (context, snapshotPrefill) {
          if (snapshotPrefill.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
              ),
            );
          }
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return ContractEditDialog(
                title: 'Edit Contract',
                insuranceVendorContracId:
                snapshotPrefill.data!.insuranceVendorContracId,
                selectedVendorId: snapshotPrefill.data!.insuranceVendorId,
                contractName: snapshotPrefill.data!.contractName!,
                contractId: snapshotPrefill.data!.contractId!,
                officeid: snapshotPrefill.data!.officeId,
                expiryType: snapshotPrefill.data!.expiryType,
                expiryDate: snapshotPrefill.data!.expiryDate,
                threshhold: snapshotPrefill.data!.threshold,
              );
            },
          );
        });
  }
}
