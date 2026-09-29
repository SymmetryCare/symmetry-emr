import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/provider/delete_popup_provider.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/files_constant-widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';


class VendorContractSNFProvider with ChangeNotifier {
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController docIdController = TextEditingController();
  final TextEditingController calenderController = TextEditingController();
  final TextEditingController idOfDocController = TextEditingController();
  final TextEditingController daysController = TextEditingController(text: "1");
  final StreamController<List<NewOrgDocument>> documentStream = StreamController<List<NewOrgDocument>>();

  int docTypeMetaIdVC =  FrontendConfigStore.data!.config.vendorContracts;
  int docTypeMetaIdVCSnf = FrontendConfigStore.data!.config.subDocId7SNF;
  String? expiryType;
  String? selectedValue;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  bool _isLoading = false;

  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void setPageNumber(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  Future<void> fetchDocuments(BuildContext context) async {
    try {
      final documents = await getNewOrgDocfetch(
        context,  FrontendConfigStore.data!.config.vendorContracts, FrontendConfigStore.data!.config.subDocId7SNF, 1, 50,
      );
      documentStream.add(documents);
    } catch (e) {
      documentStream.addError(e);
    }
  }

  Future<NewOrgDocument?> fetchPrefillDocument(BuildContext context, int orgDocumentSetupid) async {
    return await getPrefillNewOrgDocument(context, orgDocumentSetupid);
  }

  Future<void> deleteDocument(BuildContext context, int orgDocumentSetupid) async {
    _isLoading = true;
    notifyListeners();

    try {
      await deleteNewOrgDoc(context, orgDocumentSetupid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void disposeControllers() {
    docNameController.dispose();
    docIdController.dispose();
    calenderController.dispose();
    idOfDocController.dispose();
    daysController.dispose();
    documentStream.close();
  }
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> onEdit(NewOrgDocument doc, BuildContext context) async{
    var snaphotPrefill = await getPrefillNewOrgDocument(context, doc.orgDocumentSetupid);
    docNameController.text = snaphotPrefill.docName ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return OrgDocNewEditPopup(
          title: EditPopupString.editSNF,
          orgDocumentSetupid: snaphotPrefill.orgDocumentSetupid,
          docTypeId: snaphotPrefill.documentTypeId,
          subDocTypeId: snaphotPrefill.documentSubTypeId,
          idOfDoc: snaphotPrefill.idOfDocument,
          docName: snaphotPrefill.docName,
          expiryType: snaphotPrefill.expiryType,
          threshhold: snaphotPrefill.threshold,
          expiryDate: snaphotPrefill.expiryDate,
          expiryReminder: snaphotPrefill.expiryReminder,
          docTypeText: AppStringEM.vendorContracts,
          subDocTypeText: AppStringEM.snf,
          // FIX: wire refetch after a successful edit - previously
          // nothing told this screen the edit succeeded.
          onSave: () {
            fetchDocuments(context);
          },
        );
      },
    ).then((_) => fetchDocuments(context)); // FIX: reload list so edits reflect immediately
  }

  Future<void> onDelete(NewOrgDocument doc, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteSNF,
          loadingDuration: _isLoading,
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            setLoading(true); // Set loading state
            try {
              await deleteDocument(context, doc.orgDocumentSetupid);
              // FIX: previously deleted then just closed the dialogs - the
              // row stayed in the list until the tab was reopened.
              await fetchDocuments(context);
              Navigator.pop(context); // Close the confirmation dialog
              await fetchDocuments(context); // FIX: reload list so deleted row disappears immediately
              showDialog(
                context: context,
                builder: (context) => const DeleteSuccessPopup(),
              );
            } finally {
              setLoading(false); // Reset loading state
            }
          },
        );
      },
    );
  }
}

class VendorContractSNF extends StatelessWidget {
  final int docId;
  final int subDocId;

  const VendorContractSNF({
    Key? key,
    required this.docId,
    required this.subDocId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _VendorContractSNFBody(docId: docId, subDocId: subDocId);
  }
}

// FIX: added a Stateful body so we can register a listener on the shared
// CiOrgDocumentProvider "something was saved" signal (fired by the
// top-level Add button) in initState - saved via addPostFrameCallback,
// removed in dispose, per project convention.
class _VendorContractSNFBody extends StatefulWidget {
  final int docId;
  final int subDocId;

  const _VendorContractSNFBody({
    required this.docId,
    required this.subDocId,
  });

  @override
  State<_VendorContractSNFBody> createState() => _VendorContractSNFBodyState();
}

class _VendorContractSNFBodyState extends State<_VendorContractSNFBody> {
  CiOrgDocumentProvider? _orgDocProvider;

  void _onDocumentSavedElsewhere() {
    context.read<VendorContractSNFProvider>().fetchDocuments(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _orgDocProvider = context.read<CiOrgDocumentProvider>();
      _orgDocProvider?.addListener(_onDocumentSavedElsewhere);
    });
  }

  @override
  void dispose() {
    _orgDocProvider?.removeListener(_onDocumentSavedElsewhere);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorContractSNFProvider>(context, listen: false);

    return Column(
      children: [
        PoliciesProcedureList(
          controller: provider.documentStream,
          fetchDocuments: (context) => getNewOrgDocfetch(
            context,
            FrontendConfigStore.data!.config.vendorContracts,
            FrontendConfigStore.data!.config.subDocId7SNF,
            1,
            50,
          ),
          emptyMessage: ErrorMessageString.noSNF,
          onEdit: (NewOrgDocument doc) {
            provider.onEdit(doc, context);
          },
          onDelete: (NewOrgDocument doc) {
            provider.onDelete(doc, context);
          },
        ),
      ],
    );
  }
}