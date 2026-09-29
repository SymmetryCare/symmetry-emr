import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/manage_insurance_data.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/widgets/custome_dialog.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';

class CiInsuranceVendor extends StatefulWidget {
  final String officeId;
  // FIX: lets the parent (CIInsurance) know the vendor list changed
  // (deleted/edited) so it can refetch the Contract tab's vendor dropdown,
  // which otherwise keeps showing stale/deleted vendors.
  final VoidCallback? onVendorChanged;

  const CiInsuranceVendor({
    super.key,
    required this.officeId,
    this.onVendorChanged,
  });

  @override
  State<CiInsuranceVendor> createState() => _CiInsuranceVendorState();
}

class _CiInsuranceVendorState extends State<CiInsuranceVendor> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController workemailController = TextEditingController();
  TextEditingController workphoneController = TextEditingController();
  final StreamController<List<ManageVendorData>> _companyVendor =
  StreamController<List<ManageVendorData>>();

  @override
  void initState() {
    super.initState();
  }
  String? selectedZoneName;
  String? selectedCityName;
  bool _isLoading = false;
  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: AppSize.s30,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  AppString.srNo,
                  style:TableHeading.customTextStyle(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Name',
                    textAlign: TextAlign.start,
                    style:TableHeading.customTextStyle(context),),
                ),

                Text(AppString.actions,
                  textAlign: TextAlign.start,
                  style:TableHeading.customTextStyle(context),),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSize.s5,),
        Expanded(
          child: StreamBuilder<List<ManageVendorData>>(
              stream: _companyVendor.stream,
              builder: (context, snapshot) {
                companyVendorGet(context,widget.officeId,1,9999).then((data) {
                  _companyVendor.add(data);
                }).catchError((error) {
                  // Handle error
                });
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
                        ErrorMessageString.noVendor,
                        style:AllNoDataAvailable.customTextStyle(context),)
                  );
                }
                if (snapshot.hasData) {
                  int totalItems = snapshot.data!.length;
                  int totalPages = (totalItems / itemsPerPage).ceil();
                  List<ManageVendorData> paginatedData = snapshot.data!.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();
                  return Column(
                    children: [
                      Expanded(
                        child:  ScrollConfiguration(
                          behavior: const ScrollBehavior().copyWith(scrollbars: false),
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: paginatedData.length,
                              itemBuilder: (context, index) {
                                int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                ManageVendorData vendorData = paginatedData[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: AppSize.s8,),
                                    Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff000000)
                                                  .withOpacity(0.25),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        height: AppSize.s50,
                                        margin: const EdgeInsets.symmetric(horizontal: AppMargin.m5),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p15),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: AppSize.s165),
                                                  child: Text(
                                                    formattedSerialNumber,
                                                    textAlign: TextAlign.center,
                                                    style:  TableSubHeading.customTextStyle(context),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  vendorData.vendorName
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style:  TableSubHeading.customTextStyle(context),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                              context) {
                                                                return _VendorEditDialogContent(
                                                                  insuranceVendorId: vendorData.insuranceVendorId,
                                                                  officeId: widget.officeId,
                                                                  outer: this,
                                                                );
                                                              }).then((_) {
                                                            setState(() {}); // refresh vendor list after editing
                                                            widget.onVendorChanged?.call(); // FIX: keep parent dropdown in sync (name may have changed)
                                                          });
                                                        },

                                                        icon: Icon(Icons.edit_outlined,
                                                          size:IconSize.I22,color: IconColorManager.blueprime,)),
                                                       const SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        onPressed: () {
                                                          bool dialogIsOpen = true;
                                                          showDialog(context: context,
                                                              builder: (context) => StatefulBuilder(
                                                                builder: (BuildContext context, void Function(void Function()) setDialogState) {
                                                                  return  DeletePopup(
                                                                      title: 'Delete Vendor',
                                                                      loadingDuration: _isLoading,
                                                                      onCancel: (){
                                                                        dialogIsOpen = false;
                                                                        Navigator.pop(context);
                                                                      }, onDelete: () async{
                                                                    setState(() {
                                                                      _isLoading = true;
                                                                    });
                                                                    if (dialogIsOpen) setDialogState(() {});
                                                                    try {
                                                                      await deleteVendor(context, vendorData.insuranceVendorId!);
                                                                      dialogIsOpen = false;
                                                                      Navigator.pop(context);
                                                                      showDialog(context: context, builder: (context) => const DeleteSuccessPopup());
                                                                      widget.onVendorChanged?.call(); // FIX: tell parent dropdown to refetch — vendor no longer exists
                                                                    } finally {
                                                                      // FIX: guard against calling the dialog's setState after it has been popped
                                                                      if (mounted) setState(() { _isLoading = false; });
                                                                      if (dialogIsOpen) setDialogState(() {});
                                                                    }
                                                                  });
                                                                },

                                                              )).then((_) => setState(() {})); // FIX: refresh vendor list after deleting
                                                        },
                                                        icon:  Icon(Icons.delete_outline,size:IconSize.I22,color: IconColorManager.red,)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ],
                                );
                              }),
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
                            currentPage = currentPage < totalPages ? currentPage + 1 : totalPages;
                          });
                        },
                      ),
                    ],
                  );
                }
                return const Offstage();
              }),
        ),
      ],
    );
  }
}

// FIX: wraps the Edit Vendor dialog content so getPrefillVendor() is
// fetched exactly once (in initState) instead of being called inline in a
// FutureBuilder, which re-fired the API call on every rebuild of the dialog.
class _VendorEditDialogContent extends StatefulWidget {
  final int insuranceVendorId;
  final String officeId;
  final _CiInsuranceVendorState outer;

  const _VendorEditDialogContent({
    required this.insuranceVendorId,
    required this.officeId,
    required this.outer,
  });

  @override
  State<_VendorEditDialogContent> createState() =>
      _VendorEditDialogContentState();
}

class _VendorEditDialogContentState extends State<_VendorEditDialogContent> {
  late Future<ManageVendorPrefill> _prefillFuture;

  @override
  void initState() {
    super.initState();
    _prefillFuture = getPrefillVendor(context, widget.insuranceVendorId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ManageVendorPrefill>(
        future: _prefillFuture,
        builder: (context, snapshotPrefill) {
          if (snapshotPrefill.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime,),
            );
          }
          var name = snapshotPrefill.data!.vendorName;
          widget.outer.nameController =
              TextEditingController(text: snapshotPrefill.data!.vendorName);
          return CustomPopup(
            namecontroller: snapshotPrefill.data!.vendorName!,
            insuranceVendorId: widget.insuranceVendorId,
            officeId: widget.officeId,
          );
        }
    );
  }
}