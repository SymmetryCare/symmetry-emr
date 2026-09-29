import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_adr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_cap_report.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_license.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_medical_cost_report.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_corporate&compiliancedoc_tab/ci_ccd_quarterly_balance_report.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';

class CICorporateComplianceState with ChangeNotifier {
  late int _selectedIndex;
  late String _selectedSubDocType;

  // FIX: accept the index this state should boot up on instead of always
  // starting at 0 (Licenses). This lets the parent tell us where the user
  // actually was, since this widget gets fully recreated (new key) after
  // a successful Add and would otherwise lose the previously selected tab.
  CICorporateComplianceState({int initialIndex = 0}) {
    _selectedIndex = initialIndex;
    _selectedSubDocType = getSubDocTypeForIndex(initialIndex);
  }

  String get selectedSubDocType => _selectedSubDocType;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    _selectedSubDocType = getSubDocTypeForIndex(index);
    notifyListeners();
  }

  String getSubDocTypeForIndex(int index) {
    switch (index) {
      case 0:
        return AppStringEM.licenses;
      case 1:
        return AppStringEM.ard;
      case 2:
        return AppStringEM.mcr;
      case 3:
        return AppStringEM.capReport;
      case 4:
        return AppStringEM.qbr;
      default:
        return "";
    }
  }

  int getSubDocIdForIndex(int index) {
    switch (index) {
      case 0:
        return FrontendConfigStore.data!.config.subDocId1Licenses;
      case 1:
        return FrontendConfigStore.data!.config.subDocId2Adr;
      case 2:
        return FrontendConfigStore.data!.config.subDocId3CICCMedicalCR;
      case 3:
        return FrontendConfigStore.data!.config.subDocId4CapReport;
      case 4:
        return FrontendConfigStore.data!.config.subDocId5BalReport;
      default:
        return 0;
    }
  }
}

class CICorporateCompilianceDocument extends StatelessWidget {
  final int docID;
  final Function(int) onSubDocIdSelected;
  final String selectedSubDocType;

  const CICorporateCompilianceDocument({
    Key? key,
    required this.docID,
    required this.onSubDocIdSelected,
    required this.selectedSubDocType,
  }) : super(key: key);

  // FIX: reverse-map the incoming selectedSubDocType (the tab the user was
  // actually on, tracked by the parent CiOrgDocumentProvider) back into a
  // tab index, so a remount (new ValueKey after Add) boots on the same tab
  // instead of resetting to Licenses.
  int _initialIndexForType(String type) {
    if (type == AppStringEM.ard) return 1;
    if (type == AppStringEM.mcr) return 2;
    if (type == AppStringEM.capReport) return 3;
    if (type == AppStringEM.qbr) return 4;
    return 0; // AppStringEM.licenses or unknown -> default to Licenses
  }

  @override
  Widget build(BuildContext context) {
    final initialIndex = _initialIndexForType(selectedSubDocType);
    final pageController = PageController(initialPage: initialIndex);

    return ChangeNotifierProvider(
      create: (_) => CICorporateComplianceState(initialIndex: initialIndex),
      child: Consumer<CICorporateComplianceState>(
        builder: (context, corporateState, child) {
          // Sync PageController with selectedIndex
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients &&
                pageController.page?.round() != corporateState.selectedIndex) {
              pageController.jumpToPage(corporateState.selectedIndex);
            }
          });

          return Column(
            children: [
              const SizedBox(height: AppSize.s20),
              SizedBox(
                height: AppSize.s50,
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 6,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Repeatable Tab Item
                          for (int index = 0; index < 5; index++)
                            InkWell(
                              highlightColor: const Color(0xFFF2F9FC),
                              hoverColor: const Color(0xFFF2F9FC),
                              child: Container(
                                height: AppSize.s50,
                                width: index == 4
                                    ? MediaQuery.of(context).size.width / 9
                                    : MediaQuery.of(context).size.width / 10,
                                child: Column(
                                  children: [
                                    Text(
                                      corporateState.getSubDocTypeForIndex(index),
                                      style: TransparentBgTabbar.customTextStyle(
                                        index,
                                        corporateState.selectedIndex,
                                      ),
                                    ),
                                    corporateState.selectedIndex == index
                                        ? Divider(
                                      color: ColorManager.blueprime,
                                      thickness: 2,
                                    )
                                        : const Offstage(),
                                  ],
                                ),
                              ),
                              onTap: () {
                                corporateState.setSelectedIndex(index);
                                onSubDocIdSelected(
                                    corporateState.getSubDocIdForIndex(index));
                                pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                  ],
                ),
              ),
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSize.s10),
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      corporateState.setSelectedIndex(index);
                      onSubDocIdSelected(
                          corporateState.getSubDocIdForIndex(index));
                    },
                    children: [
                      ChangeNotifierProvider(
                        create: (_) => CICcdLicenseProvider(),
                        child: CICcdLicense(subDocID: docID, docID:  FrontendConfigStore.data!.config.subDocId1Licenses,),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CICcdADRProvider(),
                        child: CICcdADR(
                          docID: docID,
                          subDocID: FrontendConfigStore.data!.config.subDocId2Adr,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CiCcdMedicalCostReportProvider(),
                        child: CiCcdMedicalCostReport(
                          docID: docID,
                          subDocID: FrontendConfigStore.data!.config.subDocId3CICCMedicalCR,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CiCcdCapReportsProvider(),
                        child: CiCcdCapReports(
                          docID: docID,
                          subDocId: FrontendConfigStore.data!.config.subDocId4CapReport,
                        ),
                      ),
                      ChangeNotifierProvider(
                        create: (_) => CICcdQuarteryBalanceReportProvider(),
                        child: CICcdQuarteryBalanceReport(
                          docId: docID,
                          subDocID: FrontendConfigStore.data!.config.subDocId5BalReport,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}