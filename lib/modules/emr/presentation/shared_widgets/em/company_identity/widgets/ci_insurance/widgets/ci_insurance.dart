import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/ci_insurance_contract.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/ci_insurance_vendor.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/manage_insurance_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/company_identity_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/widgets/contract_add_dialog.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/widgets/custome_dialog.dart';

class CIInsurance extends StatefulWidget {
  final String officeId;
  final int docID;
  final int subDocID;
  final int companyID;

  const CIInsurance({
    super.key,
    required this.officeId,
    required this.docID,
    required this.subDocID,
    required this.companyID,
  });

  @override
  State<CIInsurance> createState() => _CiOrgDocumentState();
}

class _CiOrgDocumentState extends State<CIInsurance> {
  final PageController _tabPageController = PageController();
  // FIX: key lets us call fetchVendorContractZone() on the contract tab
  // directly after adding a contract, so the list refreshes immediately.
  final GlobalKey<State<CiInsuranceContract>> _contractKey =
  GlobalKey<State<CiInsuranceContract>>();
  TextEditingController vendorNameController = TextEditingController();
  TextEditingController contractNameController = TextEditingController();
  TextEditingController contractIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController dummyCtrl = TextEditingController();
  int _selectedIndex = 0;
  int selectedVendorId = 0;
  String? selectedVendorName;
  String? selectedExpiryType;

  bool isAddButtonEnabled = false;

  void _selectButton(int index,[bool? selected]) {
    setState(() {
      _selectedIndex = index;
      selected = false;
    });
    _tabPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  // FIX: clears the Contract tab's vendor selection. Previously
  // selectedVendorId/selectedValue/isAddButtonEnabled stayed set even after
  // leaving the Contract tab, so coming back later showed a dropdown that
  // visually said "Select" (its initialValue is hardcoded) while the
  // contract list underneath and the "Add Doctype" button still reflected
  // the old, no-longer-visible selection. Called whenever the user manually
  // switches to the Vendor tab so the Contract tab starts genuinely fresh
  // next time.
  void _resetContractSelection() {
    setState(() {
      selectedValue = null;
      selectedVendorId = 0;
      isAddButtonEnabled = false;
    });
  }

  // FIX: called whenever a vendor is deleted or edited in the Vendor tab,
  // so the Contract tab's dropdown (fed by _companyVendorFuture) stops
  // showing stale/deleted vendors. Also clears the current selection since
  // the selected vendor may be the one that was just removed.
  void _refreshVendorDropdown() {
    setState(() {
      _companyVendorFuture =
          companyVendorGet(context, widget.officeId, 1, 50);
      selectedValue = null;
      selectedVendorId = 0;
      isAddButtonEnabled = false;
    });
  }

  String? expiryType;
  String? selectedValue;
  late Future<List<ManageVendorData>> _companyVendorFuture;

  @override
  void initState() {
    super.initState();
    _companyVendorFuture = companyVendorGet(context, widget.officeId, 1, 50);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSizeConst.A40,top : AppSizeConst.A20,right: AppSizeConst.A40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child:  _selectedIndex == 0
                      ? Container(width: AppSize.s285)
                      : FutureBuilder<List<ManageVendorData>>(
                    future: _companyVendorFuture,
                    builder: (context, snapshotZone) {
                      if (snapshotZone.connectionState == ConnectionState.waiting &&
                          selectedValue == null) {
                        return Container(
                          width:  AppSize.s285,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColorManager.containerBorderGrey, width: AppSize.s1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: AppSize.s10),
                              Expanded(
                                child: Text(
                                  "Select",
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshotZone.hasError || snapshotZone.data == null) {
                        return Container(width:  AppSize.s285,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColorManager.containerBorderGrey, width: AppSize.s1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: AppSize.s10),
                              Expanded(
                                child: Text(
                                  "Select",
                                  style: DocumentTypeDataStyle.customTextStyle(context),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: AppPadding.p8),
                                child: Icon(Icons.arrow_drop_down),
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshotZone.data!.isEmpty) {
                        return Container(
                          width:  AppSize.s285,
                          height: AppSize.s30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColorManager.containerBorderGrey, width: AppSize.s1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(ErrorMessageString.noVendorAdded,
                              style: DocumentTypeDataStyle.customTextStyle(context),),
                          ),
                        );

                      }
                      if (snapshotZone.hasData) {
                        List<DropdownMenuItem<String>> dropDownTypesList = [];
                        for (var i in snapshotZone.data!) {
                          dropDownTypesList.add(
                            DropdownMenuItem<String>(
                              value: i.vendorName,
                              child: Text(i.vendorName),
                            ),
                          );
                        }
                        if (selectedValue == null && dropDownTypesList.isNotEmpty) {
                          selectedValue = dropDownTypesList[0].value;
                        }

                        return CICCDropdown(
                          initialValue: "Select",
                          onChange: (val) {
                            setState(() {
                              selectedValue = val;
                              for (var a in snapshotZone.data!) {
                                if (a.vendorName == val) {
                                  int docType = a.insuranceVendorId;
                                  print("Insurance vendor id :: ${a.insuranceVendorId}");
                                  selectedVendorId = docType;
                                  isAddButtonEnabled = true;
                                  _selectButton(1);
                                  break;
                                }
                              }
                            });
                          },
                          items: dropDownTypesList,
                        );
                      }

                      return const SizedBox();
                    },
                  ),),
                Expanded(
                    flex: 2,
                    child: Container(
                      height: 30,
                    )),
                ///tabbar
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppPadding.p8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          EMTabbar(onTap: (int index){
                            // FIX: manually leaving the Contract tab for the
                            // Vendor tab clears the stale selection so the
                            // Contract tab starts fresh (dropdown "Select" +
                            // empty list) the next time it's opened.
                            _resetContractSelection();
                            _selectButton(0);
                          }, index: 0, grpIndex: _selectedIndex, heading: AppStringEM.vendor),
                          EMTabbar(onTap: (int index){
                            _selectButton(1);
                          }, index: 1, grpIndex: _selectedIndex, heading: AppStringEM.contract),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Container(
                      height: 30,
                    )),
                ///buttons
                _selectedIndex == 0
                    ? CustomIconButtonConst(
                    icon: Icons.add,
                    text: AppStringEM.addVendor,
                    width: AppSize.s140,
                    onPressed: () {
                      vendorNameController.clear();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddVendorPopup(
                            namecontroller: vendorNameController,
                            officeID: widget.officeId,

                          );

                        },


                      ).then((_) => setState(() {
                        // FIX: _companyVendorFuture backs the vendor dropdown
                        // shown on the Contract tab, but it was only ever
                        // fetched once in initState — a plain setState()
                        // rebuild doesn't re-fire a FutureBuilder bound to an
                        // already-completed Future, so a newly added vendor
                        // never showed up there. Re-fetch it here.
                        _companyVendorFuture =
                            companyVendorGet(context, widget.officeId, 1, 50);
                      }));
                    })
                    : CustomIconButtonConst(
                  icon: Icons.add,
                  width: AppSize.s140,
                  text: AppStringEM.adddoctype,
                  onPressed: isAddButtonEnabled ? () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return ContractAddDialog(
                              selectedVendorId :selectedVendorId,
                              officeid:widget.officeId,
                              title: 'Add Contract',
                            );
                          },
                        );
                      },
                    ).then((_) {
                      // FIX: refresh contract list after adding so the new contract shows immediately
                      (_contractKey.currentState as dynamic)?.fetchVendorContractZone();
                    });
                  }
                      : () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const VendorSelectNoti(message: "No Vendor Added.",);
                      },
                    );
                  },
                  enabled: isAddButtonEnabled,
                )

              ],
            ),
          ),
          const SizedBox(height: AppSizeConst.A20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizeConst.A40),
              child: NonScrollablePageView(
                controller: _tabPageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  // Page 1
                  CiInsuranceVendor(
                    officeId: widget.officeId,
                    onVendorChanged: _refreshVendorDropdown, // FIX: keep Contract-tab dropdown in sync with delete/edit
                  ),
                  CiInsuranceContract(
                    key: _contractKey,
                    insuranceVendorId: selectedVendorId,
                    officeId: widget.officeId,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}