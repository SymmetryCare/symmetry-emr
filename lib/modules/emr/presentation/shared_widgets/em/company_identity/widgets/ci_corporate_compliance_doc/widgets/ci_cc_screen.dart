import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/ci_org_doc_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/error_pop_up.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/company_identity_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/upload_add_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/vendor_contract/widgets/ci_cc_vendor_contract_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_adr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_cap_reports.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_licence.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_medical_cost_report.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/ci_cc_quaterly_bal_report.dart';

class CiCorporateComplianceScreen extends StatefulWidget {
  final int docId;
  final String officeId;
  final int companyID;

  const CiCorporateComplianceScreen({
    super.key,
    required this.docId,
    required this.officeId,
    required this.companyID,
  });

  @override
  State<CiCorporateComplianceScreen> createState() =>
      _CiCorporateComplianceScreenState();
}

class _CiCorporateComplianceScreenState
    extends State<CiCorporateComplianceScreen> {
  final PageController _tabPageController = PageController();
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();

  int _selectedIndex = 0;
  // FIX: bumped after a successful Add so the 5 tab widgets below are
  // recreated (via the ValueKey on each) and refetch their own data —
  // previously the Add popup closed with no signal back to any of them.
  int _refreshCounter = 0;
  int docTypeMetaIdCC = FrontendConfigStore.data!.config.corporateAndCompliance;
  int docSubTypeMetaId = 0;
  String? expiryType;
  bool _isLoading = false;
  int docTypeId = 0;
  DateTime? datePicked;
  String? selectedDocTypeValue;
  String? selectedSubDocTypeValue;
  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId1Licenses; // Default value
  String selectedSubDocType = "";
  dynamic filePath;
  late Future<List<DocumentTypeData>> docTypeFuture;
  bool showExpiryDateField = false;
  TextEditingController expiryDateController = TextEditingController();
  String fileName = '';
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
        print('File path ${filePath}');
        print('File name ${fileName}');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDocTypeValue = "Select Document Type";
    selectedSubDocTypeValue = "Select Sub Document";
    docTypeFuture = documentTypeGet(context);
    _updateSelectedSubDocId(selectedSubDocId);
    print("office id ::::::::${widget.officeId}");
  }

  void _selectButton(int index) {
    setState(() {
      _selectedIndex = index;

      _updateSelectedSubDocId(index == 0
          ? FrontendConfigStore.data!.config.subDocId1Licenses
          : index == 1
              ?FrontendConfigStore.data!.config.subDocId2Adr
              : index == 2
                  ? FrontendConfigStore.data!.config.subDocId3CICCMedicalCR
                  : index == 3
                      ? FrontendConfigStore.data!.config.subDocId4CapReport
                      :  FrontendConfigStore.data!.config.subDocId5BalReport);
    });
    _tabPageController.jumpToPage(
      index,);
  }

  void _updateSelectedSubDocId(int subDocId) {
    setState(() {
      selectedSubDocId = subDocId;
      selectedSubDocType = getSubDocTypeText(subDocId);
    });
  }


  String getSubDocTypeText(int subDocId) {
    final cfg = FrontendConfigStore.data!.config;

    switch (subDocId) {
      case _ when subDocId == cfg.subDocId1Licenses:
        return "Licenses";

      case _ when subDocId == cfg.subDocId2Adr:
        return "ADR";

      case _ when subDocId == cfg.subDocId3CICCMedicalCR:
        return "Medical Cost Reports";

      case _ when subDocId == cfg.subDocId4CapReport:
        return "CAP Reports";

      case _ when subDocId == cfg.subDocId5BalReport:
        return "Quarterly Balance Reports";

      default:
        return "Unknown Document Type";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizeConst.A20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                flex: 1,
                child: Container()),
            ///tabbar
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(top: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    EMTabbar(onTap: (int index){
                      _selectButton(0);
                    }, index: 0, grpIndex: _selectedIndex, heading: AppStringEM.licenses),
                    EMTabbar(onTap: (int index){
                      _selectButton(1);
                    }, index: 1, grpIndex: _selectedIndex, heading: AppStringEM.ard),
                    EMTabbar(onTap: (int index){
                      _selectButton(2);
                    }, index: 2, grpIndex: _selectedIndex, heading: AppStringEM.mcr),
                    EMTabbar(onTap: (int index){
                      _selectButton(3);
                    }, index: 3, grpIndex: _selectedIndex, heading: AppStringEM.capReport),
                    EMTabbar(onTap: (int index){
                      _selectButton(4);
                    }, index: 4, grpIndex: _selectedIndex, heading: AppStringEM.qbr),
                  ],
                )
              ),
            ),

           ///button
            Padding(
              padding: const EdgeInsets.only( right: AppSizeConst.A40),
              child: CustomIconButtonConst(
                  icon: Icons.add,
                  text: AppStringEM.addDocument,
                  onPressed: () async {
                    String? selectedExpiryType = expiryType;
                    calenderController.clear();
                    docIdController.clear();
                    docNamecontroller.clear();
                    selectedExpiryType = "";
                    datePicked = null;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _AddDocumentDialogContent(
                            docTypeMetaIdCC: docTypeMetaIdCC,
                            selectedSubDocId: selectedSubDocId,
                            officeId: widget.officeId,
                            isLoading: _isLoading,
                            subDocTypeText: getSubDocTypeText(selectedSubDocId),
                          );
                        }).then((_) {
                      // FIX: refetch after Add so the newly added document
                      // shows up immediately instead of only after leaving
                      // and reopening the tab.
                      if (mounted) setState(() => _refreshCounter++);
                    });
                  }),
            ),
          ],
        ),
        const SizedBox(
          height: AppSize.s10,
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
                // FIX: keyed by _refreshCounter so a successful Add (see
                // showDialog(...).then() above) recreates all 5 tabs and
                // triggers their initState() reload instead of leaving stale
                // lists visible.
                CICCLicense(
                  key: ValueKey('license_$_refreshCounter'),
                  docId: widget.docId,
                  subDocId:  FrontendConfigStore.data!.config.subDocId1Licenses,
                  officeId: widget.officeId,
                ),
                CICCADR(
                  key: ValueKey('adr_$_refreshCounter'),
                  docId: widget.docId,
                  subDocId:  FrontendConfigStore.data!.config.subDocId2Adr,
                  officeId: widget.officeId,
                ),
                CICCMedicalCR(
                  key: ValueKey('mcr_$_refreshCounter'),
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId3CICCMedicalCR,
                  officeId: widget.officeId,
                ),
                CICCCAPReports(
                  key: ValueKey('cap_$_refreshCounter'),
                  docId: widget.docId,
                  subDocId: FrontendConfigStore.data!.config.subDocId4CapReport,
                  officeId: widget.officeId,
                ),
                CICCQuarterlyBalReport(
                  key: ValueKey('qbr_$_refreshCounter'),
                  docId: widget.docId,
                  subDocId:FrontendConfigStore.data!.config.subDocId5BalReport,
                  officeId: widget.officeId,
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
  final int docTypeMetaIdCC;
  final int selectedSubDocId;
  final String officeId;
  final bool isLoading;
  final String subDocTypeText;

  const _AddDocumentDialogContent({
    required this.docTypeMetaIdCC,
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
        getTypeofDoc(context, widget.docTypeMetaIdCC, widget.selectedSubDocId);
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
            print("docTypeMetaIdCC @@@@@@@@@@@ ${widget.docTypeMetaIdCC}");
            print("selectedSubDocId @@@@@@@@@@@ ${widget.selectedSubDocId}");
            print("CC @@@@@@@@@@@ ${AppStringEM.corporateAndComplianceDocuments}");
            print("docTypeMetaIdCC @@@@@@@@@@@ ${widget.subDocTypeText}");
            return UploadDocumentAddPopup(
              loadingDuration: widget.isLoading,
              title: 'Upload Document',
              officeId: widget.officeId,
              docTypeMetaIdCC: widget.docTypeMetaIdCC,
              selectedSubDocId: widget.selectedSubDocId,
              dataList: snapshot.data!,
              docTypeText: AppStringEM.corporateAndComplianceDocuments,
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