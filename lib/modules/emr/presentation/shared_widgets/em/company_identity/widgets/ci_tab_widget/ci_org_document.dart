import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/ci_corporate&compiliance_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/ci_policies&procedure.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/ci_vendor_contract.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/company_identity_screen.dart';

///provider
class CiOrgDocumentProvider with ChangeNotifier {
  final PageController tabPageController = PageController();
  int selectedIndex = 0;

  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calendarController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId1Licenses; // Default value
  String selectedSubDocType = "";

  // FIX: bumped after a successful Add so the active tab's list widget
  // gets a new key and remounts, forcing it to refetch immediately.
  int corporateRefreshCounter = 0;
  int vendorRefreshCounter = 0;
  int policiesRefreshCounter = 0;

  void bumpRefreshForCurrentTab() {
    if (selectedIndex == 0) {
      corporateRefreshCounter++;
    } else if (selectedIndex == 1) {
      vendorRefreshCounter++;
    } else {
      policiesRefreshCounter++;
    }
    notifyListeners();
  }

  CiOrgDocumentProvider() {
    updateSelectedSubDocId(selectedSubDocId);
  }

  void selectButton(int index) {
    if (selectedIndex == index) return;
    selectedIndex = index;
    if (selectedIndex == 0) {
      updateSelectedSubDocId( FrontendConfigStore.data!.config.subDocId1Licenses);
    } else if (selectedIndex == 1) {
      updateSelectedSubDocId(  FrontendConfigStore.data!.config.subDocId6Leases,);
    } else if (selectedIndex == 2) {
      updateSelectedSubDocId(FrontendConfigStore.data!.config.subDocId0);
    }

    tabPageController.jumpToPage(index);
    notifyListeners();
  }

  void updateSelectedSubDocId(int subDocId) {
    selectedSubDocId = subDocId;
    selectedSubDocType = getSubDocTypeText(subDocId);
    print('Updated SubDocId: $subDocId, SubDocTypeText: $selectedSubDocType'); // Debug print
    notifyListeners();
  }



  String getSubDocTypeText(int subDocId) {
    final cfg = FrontendConfigStore.data!.config;

    switch (subDocId) {
      case _ when subDocId == cfg.subDocId1Licenses:
        return AppStringEM.licenses;

      case _ when subDocId == cfg.subDocId2Adr:
        return AppStringEM.ard;

      case _ when subDocId == cfg.subDocId3CICCMedicalCR:
        return AppStringEM.mcr;

      case _ when subDocId == cfg.subDocId4CapReport:
        return AppStringEM.capReport;

      case  _ when subDocId == cfg.subDocId5BalReport:
        return AppStringEM.qbr;

      case  _ when subDocId == cfg.subDocId6Leases:
        return AppStringEM.leases;

      case  _ when subDocId == cfg.subDocId7SNF:
        return AppStringEM.snf;

      case  _ when subDocId == cfg.subDocId8DME:
        return AppStringEM.dme;

      case  _ when subDocId == cfg.subDocId9MD:
        return AppStringEM.md;

      case _ when subDocId == cfg.subDocId10MISC:
        return AppStringEM.misc;

      default:
        return "Unknown Document Type";
    }
  }


}

class CiOrgDocument extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CiOrgDocumentProvider(),
      child: Consumer<CiOrgDocumentProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: AppSize.s20, width: AppSize.s150),

                    Expanded(
                      child: Material(
                          elevation: 4,
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          child: IntrinsicHeight(
                            child: Container(
                              constraints: const BoxConstraints(minHeight: AppSize.s30,),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                color: ColorManager.blueprime,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  tabButton(
                                    context,
                                    0,
                                    AppStringEM.corporateAndComplianceDocuments,
                                  ),
                                  tabButton(
                                    context,
                                    1,
                                    AppStringEM.vendorContracts,
                                  ),
                                  tabButton(
                                    context,
                                    2,
                                    AppStringEM.policiesAndProcedures,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ),

                    const SizedBox(width: AppSizeConst.A20),
                    _buildAddButton(context, provider),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.s25),
              Expanded(
                child: Stack(
                  children: [
                    provider.selectedIndex == 2
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
                              height: 8, // Adjust the height of the shadow effect
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

                    // PageView Content
                    NonScrollablePageView(
                      controller: provider.tabPageController,
                      onPageChanged: provider.selectButton,
                      children: [
                        CICorporateCompilianceDocument(
                          key: ValueKey('corporate_${provider.corporateRefreshCounter}'),
                          docID:FrontendConfigStore.data!.config.corporateAndCompliance,
                          selectedSubDocType: provider.selectedSubDocType,
                          onSubDocIdSelected: provider.updateSelectedSubDocId,
                        ),
                        CIVendorContract(
                          key: ValueKey('vendor_${provider.vendorRefreshCounter}'),
                          docId:  FrontendConfigStore.data!.config.vendorContracts,
                          onSubDocIdSelected: provider.updateSelectedSubDocId,
                          selectedSubDocType: provider.selectedSubDocType,
                        ),
                        ChangeNotifierProvider(
                          key: ValueKey('policies_${provider.policiesRefreshCounter}'),
                          create: (context) => CIPoliciesProcedureProvider(),
                          child: CIPoliciesProcedure(
                            docId: FrontendConfigStore.data!.config.policiesAndProcedure,
                            subDocId: FrontendConfigStore.data!.config.subDocId0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget tabButton(BuildContext context, int index, String text) {
    final provider = Provider.of<CiOrgDocumentProvider>(context, listen: false);
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () => provider.selectButton(index),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSize.s30),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: provider.selectedIndex == index
                ? Colors.white
                : Colors.transparent,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                text,
                textAlign: TextAlign.center,
                softWrap: true,
                style: BlueBgTabbar.customTextStyle(index, provider.selectedIndex).copyWith(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, CiOrgDocumentProvider provider) {
    return Align(
      alignment: Alignment.bottomRight,
      child: CustomIconButtonConst(
        width: AppSize.s137,
        height: AppSize.s30,
        icon: Icons.add,
        text: AddPopupString.addDocType,
        onPressed: ()async{
          showDialog(
            context: context,
            builder: (context) {
              return ChangeNotifierProvider(
                create: (_) => AddNewOrgDocButtonProvider(
                    docTypeId: provider.selectedIndex == 0
                        ? FrontendConfigStore.data!.config.corporateAndCompliance : provider.selectedIndex == 1
                        ?  FrontendConfigStore.data!.config.vendorContracts : FrontendConfigStore.data!.config.policiesAndProcedure,
                  subDocTypeId: provider.selectedIndex == 2
                      ? FrontendConfigStore.data!.config.subDocId0 : provider.selectedSubDocId,),
                child: AddNewOrgDocButton(
                  title: provider.selectedIndex == 0 ? AddPopupString.addCorporate : provider.selectedIndex == 1 ? AddPopupString.addVendor : AddPopupString.addPolicy,
                  docTypeText:  provider.selectedIndex == 0
                      ? AppStringEM.corporateAndComplianceDocuments : provider.selectedIndex == 1
                      ? AppStringEM.vendorContracts : AppStringEM.policiesAndProcedures,
                  docTypeId: provider.selectedIndex == 0
                      ? FrontendConfigStore.data!.config.corporateAndCompliance : provider.selectedIndex == 1
                      ? FrontendConfigStore.data!.config.vendorContracts :FrontendConfigStore.data!.config.policiesAndProcedure,

                  selectedSubDocType:provider.selectedSubDocType,
                  subDocTypeId: provider.selectedIndex == 2
                      ? FrontendConfigStore.data!.config.subDocId0 : provider.selectedSubDocId,
                  subDocTypeText: provider.selectedSubDocType,
                ),
              );
            },
          ).then((_) {
            // FIX: remounts the active tab's list widget via its refresh-counter key
            provider.bumpRefreshForCurrentTab();
          });
        },
      ),
    );
  }
}

