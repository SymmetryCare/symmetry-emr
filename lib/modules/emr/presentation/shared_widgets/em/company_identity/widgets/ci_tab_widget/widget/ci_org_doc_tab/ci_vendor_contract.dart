import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_snf.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_leases.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_dme.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vc_misc.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/ci_vendor_contract_tab/ci_vd_md.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';

class VendorContractState with ChangeNotifier {
  late int _selectedIndex;
  late String _selectedSubDocType;

  // FIX: accept the index this state should boot up on instead of always
  // starting at 0 (Leases). This widget gets fully recreated (new key)
  // after a successful Add, and would otherwise lose whichever sub-tab
  // the user was actually on.
  VendorContractState({int initialIndex = 0}) {
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
        return AppStringEM.leases;
      case 1:
        return AppStringEM.snf;
      case 2:
        return AppStringEM.dme;
      case 3:
        return AppStringEM.md;
      case 4:
        return AppStringEM.misc;
      default:
        return "";
    }
  }

  int getSubDocIdForIndex(int index) {
    switch (index) {
      case 0:
        return   FrontendConfigStore.data!.config.subDocId6Leases;
      case 1:
        return FrontendConfigStore.data!.config.subDocId7SNF;
      case 2:
        return FrontendConfigStore.data!.config.subDocId8DME;
      case 3:
        return FrontendConfigStore.data!.config.subDocId9MD;
      case 4:
        return FrontendConfigStore.data!.config.subDocId10MISC;
      default:
        return 0;
    }
  }
}

class CIVendorContract extends StatelessWidget {
  final int docId;
  final Function(int) onSubDocIdSelected;
  final String selectedSubDocType;

  const CIVendorContract({
    Key? key,
    required this.docId,
    required this.onSubDocIdSelected,
    required this.selectedSubDocType,
  }) : super(key: key);

  // FIX: reverse-map the incoming selectedSubDocType (the tab the user was
  // actually on, tracked by the parent CiOrgDocumentProvider) back into a
  // tab index, so a remount (new ValueKey after Add) boots on the same tab
  // instead of resetting to Leases.
  int _initialIndexForType(String type) {
    if (type == AppStringEM.snf) return 1;
    if (type == AppStringEM.dme) return 2;
    if (type == AppStringEM.md) return 3;
    if (type == AppStringEM.misc) return 4;
    return 0; // AppStringEM.leases or unknown -> default to Leases
  }

  @override
  Widget build(BuildContext context) {
    final initialIndex = _initialIndexForType(selectedSubDocType);
    final pageController = PageController(initialPage: initialIndex);

    return ChangeNotifierProvider(
      create: (_) => VendorContractState(initialIndex: initialIndex),
      child: Consumer<VendorContractState>(
        builder: (context, vendorContractState, child) {
          // Sync PageController with selectedIndex
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients &&
                pageController.page?.round() != vendorContractState.selectedIndex) {
              pageController.jumpToPage(vendorContractState.selectedIndex);
            }
          });

          return Column(
            children: [
              const SizedBox(height: AppSizeConst.A20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: AppSize.s50,
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
                              width: MediaQuery.of(context).size.width / 10,
                              child: Column(
                                children: [
                                  Text(
                                    vendorContractState.getSubDocTypeForIndex(index),
                                    style: TransparentBgTabbar.customTextStyle(
                                      index,
                                      vendorContractState.selectedIndex,
                                    ),
                                  ),
                                  vendorContractState.selectedIndex == index
                                      ?  Divider(
                                    color: ColorManager.blueprime,
                                    thickness: 2,
                                  )
                                      : const Offstage(),
                                ],
                              ),
                            ),
                            onTap: () {
                              vendorContractState.setSelectedIndex(index);
                              onSubDocIdSelected(
                                  vendorContractState.getSubDocIdForIndex(index));
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
                ],
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    vendorContractState.setSelectedIndex(index);
                    onSubDocIdSelected(
                        vendorContractState.getSubDocIdForIndex(index));
                  },
                  children: [
                    VendorContractLeases(
                      docId: docId,
                      subDocID:  FrontendConfigStore.data!.config.subDocId6Leases,
                    ),
                    ChangeNotifierProvider(
                      create: (_) => VendorContractSNFProvider(),
                      child: VendorContractSNF(docId: docId, subDocId:FrontendConfigStore.data!.config.subDocId7SNF),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => VendorContractDMEProvider(),
                      child: VendorContractDME(
                        docId: docId,
                        subDocId: FrontendConfigStore.data!.config.subDocId8DME,
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => VendorContractMDProvider(),
                      child: VendorContractMD(
                        docId: docId,
                        subDocId: FrontendConfigStore.data!.config.subDocId9MD,
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => VendorContractMISCProvider(),
                      child: VendorContractMISC(
                        docId: docId,
                        subDocId: FrontendConfigStore.data!.config.subDocId10MISC,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}