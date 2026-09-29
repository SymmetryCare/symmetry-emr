import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/ci_org_doc_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/ci_cc_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_insurance/widgets/ci_insurance.dart';
// removed in extraction: import 'package:prohealth/presentation/screens/em_module/company_identity/widgets/ci_templates/ci_tempalets.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/company_identity_details.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/company_identity_zone/zone.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/device_tab/device_tab_ui.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/policies_procedures/policies_procedures.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

typedef BackButtonCallBack = void Function(bool val);

class ManageWidget extends StatefulWidget {
  final double officeLat;
  final double officeLon;
  final String officeID;
  final int companyID;
  final int companyOfficeId;
  final String officeName;
  final String stateName;
  final String countryName;
  final BackButtonCallBack backButtonCallBack;
  const ManageWidget({
    Key? key,
    required this.officeID,
    required this.officeName,
    required this.backButtonCallBack,
    required this.companyID,
    required this.companyOfficeId, required this.stateName, required this.countryName, required this.officeLat, required this.officeLon,
  }) : super(key: key);

  @override
  State<ManageWidget> createState() => _ManageWidgetState();
}

class _ManageWidgetState extends State<ManageWidget> {
  final List<String> _categories = [
    'Details',
    'Zones',
    'Insurance',
    'Templates'
  ];
  final PageController _managePageController = PageController();

  int _selectedIndex = 0;

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _managePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  int listIndex = 0;

  void _listButton(int index) {
    setState(() {
      listIndex = index;
    });

    _managePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  @override
  void initState() {
    super.initState();
    documentTypeGet(context);
    officeName = widget.officeName;
  }

  String officeName = '';  // local state for office name
  void updateOfficeName(String newName) {
    setState(() {
      officeName = newName;
    });
  }

  int docID = 1;
  final ScrollController _horizontalScrollController = ScrollController();

  Widget _buildTabButton(BuildContext context, int index, String text) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () => _selectButton(index),
      child: Container(
        height: AppSize.s30,
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? Colors.white : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              text,
              maxLines: 1,
              style: BlueBgTabbar.customTextStyle(index, _selectedIndex)
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: LayoutBuilder(builder: (context, constraints) {
        const double minContentWidth = 1200;
        final double contentWidth = constraints.maxWidth > minContentWidth
            ? constraints.maxWidth
            : minContentWidth;
        return CustomScrollbar(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p10),
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: AppSizeConst.A40, bottom: AppPadding.p20,top: AppPadding.p10),
                      child: Row(
                        children: [
                          InkWell(
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              onTap: () {
                                widget.backButtonCallBack(true);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: IconSize.I16,
                                color: ColorManager.mediumgrey,

                              )),
                          const SizedBox(width: AppSize.s25),
                          Text(
                            officeName,
                            style: CompanyIdentityManageHeadings.customTextStyle(context).copyWith(fontSize: FontSize.s16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
                      child: Container(
                        height: AppSize.s30,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.black.withOpacity(0.25),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            color: ColorManager.blueprime,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Expanded(child: _buildTabButton(context, 0, ManagaeButtonheading.details,)),
                            Expanded(child: _buildTabButton(context, 1, ManagaeButtonheading.zones,)),
                            Expanded(flex: 2, child: _buildTabButton(context, 2, ManagaeButtonheading.cc,)),
                            Expanded(child: _buildTabButton(context, 3, ManagaeButtonheading.insurance,)),
                            Expanded(child: _buildTabButton(context, 4, ManagaeButtonheading.vc,)),
                            Expanded(flex: 2,child: _buildTabButton(context, 5, ManagaeButtonheading.pp,)),
                            Expanded(child: _buildTabButton(context, 6, ManagaeButtonheading.equipments,)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizeConst.A20,),
                    Expanded(
                      flex: 10,
                      child: Stack(children: [
                        _selectedIndex == 0
                            ? const Offstage()
                            : Container(
                          height: MediaQuery.of(context).size.height / 3.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2F9FC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Inner shadow effect at the top
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding:  const EdgeInsets.only(top: AppPadding.p10),
                                  height: 6, // Adjust the height of the shadow effect
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.2), // Darker at top
                                        Colors.transparent, // Fades out
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PageView(
                            controller: _managePageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              CIDetailsScreen(
                                companyID: widget.companyID,
                                officeId: widget.officeID,
                                docTD: docID,
                                companyId: widget.companyID,
                                companyOfficeid: widget.companyOfficeId, stateName: widget.stateName,
                                countryName: widget.countryName, updateOfficeName: updateOfficeName,
                              ),
                              CiZone(
                                companyID: widget.companyID,
                                officeId: widget.officeID,
                                docId: docID, stateName: widget.stateName, countryName: widget.countryName,
                                officeLat: widget.officeLat, officeLon: widget.officeLon,
                              ),
                              CiCorporateComplianceScreen(
                                docId: FrontendConfigStore.data!.config.corporateAndCompliance,
                                officeId: widget.officeID,
                                companyID: widget.companyID,
                              ),
                              CIInsurance(
                                officeId: widget.officeID,
                                docID:FrontendConfigStore.data!.config.corporateAndCompliance,
                                subDocID:FrontendConfigStore.data!.config.subDocId0,
                                companyID: widget.companyID,
                              ),
                              CiCcVendorContractScreen(
                                companyID: widget.companyID,
                                officeId: widget.officeID,
                                docId:  FrontendConfigStore.data!.config.vendorContracts,
                              ),
                              CiPoliciesAndProcedures(
                                docID:  FrontendConfigStore.data!.config.policiesAndProcedure,
                                subDocID: FrontendConfigStore.data!.config.subDocId0,
                                companyID: widget.companyID,
                                officeId: widget.officeID,
                              ),
                              DeviceTabUi(
                                companyID: widget.companyID,
                              )
                            ]),
                      ]),
                    ),
                  ],          // Column children
                ),            // Column
              ),    // SizedBox
            ),      // Padding
          ),        // SingleChildScrollView
        );          // CustomScrollbar
      }),           // LayoutBuilder
    );
  }
}

class CustomButtonList extends StatelessWidget {
  final String buttonText;
  final int isSelected;
  final int docID;
  final Function() onTap;

  const CustomButtonList({
    required this.buttonText,
    required this.isSelected,
    required this.onTap,
    Key? key,
    required this.docID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppSize.s30,
        width: MediaQuery.of(context).size.width / 8.62,
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected == docID ? ColorManager.white : null,
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.bold,
            color: isSelected == docID ? Colors.grey[600] : ColorManager.white,
          ),
        ),
      ),
    );
  }
}