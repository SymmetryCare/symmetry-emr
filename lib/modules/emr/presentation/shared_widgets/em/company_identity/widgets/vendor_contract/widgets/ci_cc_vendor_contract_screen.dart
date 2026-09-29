import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/ci_org_doc_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/leasas_services.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/snf.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_clickable_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/company_identity_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/error_pop_up.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/upload_add_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/dme.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/md.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/misc.dart';

class CiCcVendorContractScreen extends StatefulWidget {
  final int docId;
  final int companyID;
  final String officeId;
  const CiCcVendorContractScreen(
      {super.key,
      required this.companyID,
      required this.officeId,
      required this.docId});

  @override
  State<CiCcVendorContractScreen> createState() =>
      _CiCcVendorContractScreenState();
}

class _CiCcVendorContractScreenState extends State<CiCcVendorContractScreen> {
  final PageController _tabPageController = PageController();
  // FIX: keys to reach each vendor-contract sub-tab's state so the Add
  // Document dialog (opened from this screen) can refresh the relevant
  // list after a successful add.
  final GlobalKey<State<CiLeasesAndServices>> _leasesKey = GlobalKey<State<CiLeasesAndServices>>();
  final GlobalKey<State<CiSnf>> _snfKey = GlobalKey<State<CiSnf>>();
  final GlobalKey<State<CiDme>> _dmeKey = GlobalKey<State<CiDme>>();
  final GlobalKey<State<CiMd>> _mdKey = GlobalKey<State<CiMd>>();
  final GlobalKey<State<CiMisc>> _miscKey = GlobalKey<State<CiMisc>>();
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController nameOfDocController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController editnameOfDocController = TextEditingController();
  TextEditingController editidOfDocController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();

  int _selectedIndex = 0;
  int docSubTypeMetaId = 0;
  int docTypeMetaIdVC = FrontendConfigStore.data!.config.vendorContracts;
  String? expiryType;
  bool _isLoading = false;
  String? selectedDocTypeValue;
  String? selectedSubDocTypeValue;
  String selectedSubDocType = "";
  int selectedSubDocIdVC =   FrontendConfigStore.data!.config.subDocId6Leases;
  dynamic filePath;
  late Future<List<DocumentTypeData>> docTypeFuture;
  TextEditingController expiryDateController = TextEditingController();
  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId6Leases;
  bool showExpiryDateField = false;
  int docTypeId = 0;

  @override
  void initState() {
    super.initState();
    selectedDocTypeValue = "Select Document Type";
    selectedSubDocTypeValue = "Select Sub Document";
    docTypeFuture = documentTypeGet(context);
    _updateSelectedSubDocIdVC(selectedSubDocId);
    showExpiryDateField;
  }

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;

      _updateSelectedSubDocIdVC(index == 0
          ? FrontendConfigStore.data!.config.subDocId6Leases
          : index == 1
              ? FrontendConfigStore.data!.config.subDocId7SNF
              : index == 2
                  ?FrontendConfigStore.data!.config.subDocId8DME
                  : index == 3
                      ? FrontendConfigStore.data!.config.subDocId9MD
                      : FrontendConfigStore.data!.config.subDocId10MISC);
    });
    _tabPageController.jumpToPage(
      index, );
  }

  String fileName = '';
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  void _updateSelectedSubDocIdVC(int subDocIdVC) {
    setState(() {
      selectedSubDocId = subDocIdVC;
      selectedSubDocType = getSubDocTypeTextVC(subDocIdVC);
    });
  }


  String getSubDocTypeTextVC(int subDocIdVC) {
    final cfg = FrontendConfigStore.data!.config;

    switch (subDocIdVC) {
      case _ when subDocIdVC == cfg.subDocId6Leases:
        return "Leases & Services";

      case  _ when subDocIdVC == cfg.subDocId7SNF:
        return "SNF";

      case  _ when subDocIdVC == cfg.subDocId8DME:
        return "DME";

      case _ when subDocIdVC == cfg.subDocId9MD:
        return "MD";

      case _ when subDocIdVC == cfg.subDocId10MISC:
        return "MISC";

      default:
        return "Unknown Document Type";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppPadding.p40,top: AppSizeConst.A20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             Expanded(
                 flex: 2,
                 child: Container()),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppPadding.p8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EMTabbar(onTap: (int index){
                        _selectButton(0);
                      }, index: 0, grpIndex: _selectedIndex, heading: AppStringEM.leases),
                      EMTabbar(onTap: (int index){
                        _selectButton(1);
                      }, index: 1, grpIndex: _selectedIndex, heading: AppStringEM.snf),
                      EMTabbar(onTap: (int index){
                        _selectButton(2);
                      }, index: 2, grpIndex: _selectedIndex, heading: AppStringEM.dme),
                      EMTabbar(onTap: (int index){
                        _selectButton(3);
                      }, index: 3, grpIndex: _selectedIndex, heading: AppStringEM.md),
                      EMTabbar(onTap: (int index){
                        _selectButton(4);
                      }, index: 4, grpIndex: _selectedIndex, heading: AppStringEM.misc),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container()),
              CustomIconButtonConst(
                  icon: Icons.add,
                  text: AppStringEM.addDocument,
                  onPressed: () async {
                    String? selectedExpiryType = expiryType;
                    calenderController.clear();
                    docIdController.clear();
                    docNamecontroller.clear();
                    selectedExpiryType = "";
                    int? selectedDocTypeId;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _AddDocumentDialogContent(
                            docTypeMetaIdVC: docTypeMetaIdVC,
                            selectedSubDocId: selectedSubDocId,
                            officeId: widget.officeId,
                            isLoading: _isLoading,
                            subDocTypeText: getSubDocTypeTextVC(selectedSubDocId),
                          );
                        }).then((_) {
                      // FIX: reload the currently active sub-tab's list so a
                      // newly added document reflects immediately without
                      // needing to reopen the tab.
                      (_leasesKey.currentState as dynamic)?.reloadLeasesData();
                      (_snfKey.currentState as dynamic)?.reloadSnfData();
                      (_dmeKey.currentState as dynamic)?.reloadDmeData();
                      (_mdKey.currentState as dynamic)?.reloadMdData();
                      (_miscKey.currentState as dynamic)?.reloadMiscData();
                    });
                  }),
            ],
          ),
        ),
        const SizedBox(
          height: AppSize.s14,
        ),
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
                CiLeasesAndServices(
                  key: _leasesKey,
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                  docId: widget.docId,
                  subDocId:FrontendConfigStore.data!.config.subDocId6Leases,
                ),
                CiSnf(
                  key: _snfKey,
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId7SNF,
                ),
                CiDme(
                  key: _dmeKey,
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId8DME,
                ),
                CiMd(
                  key: _mdKey,
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId9MD,
                ),
                CiMisc(
                  key: _miscKey,
                  companyID: widget.companyID,
                  officeId: widget.officeId,
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId10MISC,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

// FIX: wraps the Add Document dialog content so getTypeofDoc() is fetched
// exactly once (in initState) instead of being called inline in a
// FutureBuilder, which re-fired the API call on every rebuild of the dialog.
class _AddDocumentDialogContent extends StatefulWidget {
  final int docTypeMetaIdVC;
  final int selectedSubDocId;
  final String officeId;
  final bool isLoading;
  final String subDocTypeText;

  const _AddDocumentDialogContent({
    required this.docTypeMetaIdVC,
    required this.selectedSubDocId,
    required this.officeId,
    required this.isLoading,
    required this.subDocTypeText,
  });

  @override
  State<_AddDocumentDialogContent> createState() =>
      _AddDocumentDialogContentState();
}

class _AddDocumentDialogContentState extends State<_AddDocumentDialogContent> {
  late Future<List<TypeofDocpopup>> _typeOfDocFuture;

  @override
  void initState() {
    super.initState();
    _typeOfDocFuture =
        getTypeofDoc(context, widget.docTypeMetaIdVC, widget.selectedSubDocId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TypeofDocpopup>>(
        future: _typeOfDocFuture,
        builder: (contex, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return UploadDocumentAddPopup(
              loadingDuration: widget.isLoading,
              title: 'Upload Document',
              officeId: widget.officeId,
              docTypeMetaIdCC: widget.docTypeMetaIdVC,
              selectedSubDocId: widget.selectedSubDocId,
              dataList: snapshot.data!,
              docTypeText: AppStringEM.vendorContracts,
              subDocTypeText: widget.subDocTypeText,
            );
          } else {
            return ErrorPopUp(
                title: "Received Error",
                text: snapshot.error.toString());
          }
        });
  }
}

///
///
///
typedef void OnManuButtonTapCallBack(int index);

class EMTabbar extends StatelessWidget {
  const EMTabbar({
    super.key,
    required this.onTap,
    required this.index,
    required this.grpIndex,
    required this.heading,
  });

  final OnManuButtonTapCallBack onTap;
  final int index;
  final int grpIndex;
  final String heading;

  @override
  Widget build(BuildContext context) {
    return AppClickableWidget(
      onTap: () {
        onTap(index);
      },
      onHover: (bool val) {},
      child: Column(
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: FontSize.s14,
              fontWeight: grpIndex == index
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: grpIndex == index
                  ? ColorManager.blueprime
                  : ColorManager.mediumgrey,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: heading,
                  style: const TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              final textWidth = textPainter.size.width;

              return Container(
                margin: const EdgeInsets.only(top: AppPadding.p5),
                height: 2,
                width: textWidth + 20, // Adjust padding around text
                color: grpIndex == index
                    ? ColorManager.blueprime
                    : Colors.transparent,
              );
            },
          ),
        ],
      ),
    );
  }
}


