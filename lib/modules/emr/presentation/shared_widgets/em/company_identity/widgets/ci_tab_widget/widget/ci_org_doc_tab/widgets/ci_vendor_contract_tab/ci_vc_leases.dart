import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/provider/delete_popup_provider.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/files_constant-widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';

class VendorContractLeasesProvider with ChangeNotifier {
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController docIdController = TextEditingController();
  final TextEditingController calenderController = TextEditingController();
  final TextEditingController idOfDocController = TextEditingController();
  final TextEditingController daysController = TextEditingController(text: "1");

  final StreamController<List<NewOrgDocument>> documentStream =
  StreamController<List<NewOrgDocument>>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchDocuments(BuildContext context, int docTypeId, int subDocTypeId) async {
    try {
      final documents = await getNewOrgDocfetch(
        context,
        docTypeId,
        subDocTypeId,
        1,
        50,
      );
      documentStream.add(documents);
    } catch (e) {
      documentStream.addError(e);
    }
  }

  Future<void> onEdit(NewOrgDocument doc, BuildContext context) async {
    final snapshotPrefill = await getPrefillNewOrgDocument(context, doc.orgDocumentSetupid);
    docNameController.text = snapshotPrefill.docName ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return OrgDocNewEditPopup(
          title: EditPopupString.editLeases,
          orgDocumentSetupid: snapshotPrefill.orgDocumentSetupid,
          docTypeId: snapshotPrefill.documentTypeId,
          subDocTypeId: snapshotPrefill.documentSubTypeId,
          idOfDoc: snapshotPrefill.idOfDocument,
          docName: snapshotPrefill.docName,
          expiryType: snapshotPrefill.expiryType,
          threshhold: snapshotPrefill.threshold,
          expiryDate: snapshotPrefill.expiryDate,
          expiryReminder: snapshotPrefill.expiryReminder,
          docTypeText: AppStringEM.vendorContracts,
          subDocTypeText: AppStringEM.leases,
          // FIX: without this, a successful edit had no way to tell this
          // screen to refetch. org_add_popup_const.dart now calls this
          // after a 200/201 response.
          onSave: () {
            fetchDocuments(
              context,
              FrontendConfigStore.data!.config.vendorContracts,
              FrontendConfigStore.data!.config.subDocId6Leases,
            );
          },
        );
      },
    ).then((_) => fetchDocuments(
        // FIX: reload list so edits reflect immediately
        context,
        FrontendConfigStore.data!.config.vendorContracts,
        FrontendConfigStore.data!.config.subDocId6Leases));
  }

  Future<void> onDelete(NewOrgDocument doc, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteLeases,
          loadingDuration: _isLoading,
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            setLoading(true);
            try {
              await deleteNewOrgDoc(context, doc.orgDocumentSetupid);
              // FIX: this used to just close the dialogs with no refetch,
              // so a deleted row stayed visible until the tab was reopened.
              await fetchDocuments(
                context,
                FrontendConfigStore.data!.config.vendorContracts,
                FrontendConfigStore.data!.config.subDocId6Leases,
              );
              Navigator.pop(context); // Close confirmation dialog
              await fetchDocuments(
                  // FIX: reload list so deleted row disappears immediately
                  context,
                  FrontendConfigStore.data!.config.vendorContracts,
                  FrontendConfigStore.data!.config.subDocId6Leases);
              showDialog(
                context: context,
                builder: (context) => const DeleteSuccessPopup(),
              );
            } finally {
              setLoading(false);
            }
          },
        );
      },
    );
  }

  void disposeControllers() {
    docNameController.dispose();
    docIdController.dispose();
    calenderController.dispose();
    idOfDocController.dispose();
    daysController.dispose();
    documentStream.close();
  }
}
class VendorContractLeases extends StatelessWidget {
  final int docId;
  final int subDocID;

  const VendorContractLeases({
    super.key,
    required this.docId,
    required this.subDocID,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VendorContractLeasesProvider(),
      child: _VendorContractLeasesBody(docId: docId, subDocID: subDocID),
    );
  }
}

// FIX: split into a Stateful body so we can register a listener on the
// shared CiOrgDocumentProvider (the "something was saved" signal fired by
// the top-level Add button) in initState - saved via addPostFrameCallback,
// removed in dispose, per project convention (never call context.read<>()
// inside dispose directly).
class _VendorContractLeasesBody extends StatefulWidget {
  final int docId;
  final int subDocID;

  const _VendorContractLeasesBody({
    required this.docId,
    required this.subDocID,
  });

  @override
  State<_VendorContractLeasesBody> createState() => _VendorContractLeasesBodyState();
}

class _VendorContractLeasesBodyState extends State<_VendorContractLeasesBody> {
  CiOrgDocumentProvider? _orgDocProvider;

  void _onDocumentSavedElsewhere() {
    final provider = context.read<VendorContractLeasesProvider>();
    provider.fetchDocuments(
      context,
      FrontendConfigStore.data!.config.vendorContracts,
      FrontendConfigStore.data!.config.subDocId6Leases,
    );
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
    final provider = Provider.of<VendorContractLeasesProvider>(context);
    return Column(
      children: [
        PoliciesProcedureList(
          controller: provider.documentStream,
          fetchDocuments: (context) => getNewOrgDocfetch(
            context,
            FrontendConfigStore.data!.config.vendorContracts,
            FrontendConfigStore.data!.config.subDocId6Leases,
            1,
            50,
          ),
          emptyMessage: ErrorMessageString.noLeases,
          onEdit: (NewOrgDocument doc) async {
            await provider.onEdit(doc, context);
          },
          onDelete: (NewOrgDocument doc) async {
            await provider.onDelete(doc, context);
          },
        ),
      ],
    );
  }
}