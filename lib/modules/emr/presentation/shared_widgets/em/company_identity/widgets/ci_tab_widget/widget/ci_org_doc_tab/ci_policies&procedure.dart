import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/provider/delete_popup_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/files_constant-widget.dart';

///provide
class CIPoliciesProcedureProvider extends ChangeNotifier {
  // Controllers
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  // StreamControllers
  final StreamController<List<NewOrgDocument>> policiesAndProcedureController =
  StreamController<List<NewOrgDocument>>();

  // State Variables
  int currentPage = 1;
  bool isLoading = false;

  final int itemsPerPage = 10;
  final int totalPages = 5;

  String? selectedValue;
  String? selectedYear = FrontendConfigStore.data!.config.year;

  // Methods
  void setCurrentPage(int pageNumber) {
    currentPage = pageNumber;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // FIX: this provider had no fetch method at all - policiesAndProcedureController
  // was only ever fed by PoliciesProcedureList's own initial load, so nothing
  // could push a refreshed list into it after an add/edit/delete.
  Future<void> fetchDocuments(BuildContext context) async {
    try {
      final documents = await getNewOrgDocfetch(
        context,
        FrontendConfigStore.data!.config.policiesAndProcedure,
        FrontendConfigStore.data!.config.subDocId0,
        1,
        50,
      );
      policiesAndProcedureController.add(documents);
    } catch (e) {
      policiesAndProcedureController.addError(e);
    }
  }

  Future<void> onDelete(NewOrgDocument doc, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deletePolicy,
          loadingDuration: isLoading,
          onCancel: () {
            Navigator.pop(context);
          },
          onDelete: () async {
            setLoading(true); // Set loading state
            try {
              await deleteNewOrgDoc(context, doc.orgDocumentSetupid);
              // FIX: previously deleted then just closed the dialogs -
              // nothing refetched the list.
              await fetchDocuments(context);
              Navigator.pop(context); // Close the confirmation dialog
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

  Future<void> onEdit(NewOrgDocument doc, BuildContext context) async {
    var snapshotPrefill = await getPrefillNewOrgDocument(context, doc.orgDocumentSetupid);

    docNameController.text = snapshotPrefill.docName ?? "";

    showDialog(
      context: context,
      builder: (context) {
        return OrgDocNewEditPopup(
          height: AppSize.s383,
          title: EditPopupString.editPolicy,
          orgDocumentSetupid: snapshotPrefill.orgDocumentSetupid ?? 0,
          docTypeId: snapshotPrefill.documentTypeId ?? 0,
          subDocTypeId: snapshotPrefill.documentSubTypeId ?? 0,
          idOfDoc: snapshotPrefill.idOfDocument ?? "",
          docName: snapshotPrefill.docName ?? "",
          expiryType: snapshotPrefill.expiryType,
          threshhold: snapshotPrefill.threshold ?? 0,
          expiryDate: snapshotPrefill.expiryDate,
          expiryReminder: snapshotPrefill.expiryReminder,
          docTypeText: AppStringEM.policiesAndProcedures,
          subDocTypeText: '',
          // FIX: wire refetch after a successful edit - previously nothing
          // told this screen the edit succeeded.
          onSave: () {
            fetchDocuments(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    docNameController.dispose();
    docIdController.dispose();
    calenderController.dispose();
    idOfDocController.dispose();
    daysController.dispose();
    policiesAndProcedureController.close();
    super.dispose();
  }
}

class CIPoliciesProcedure extends StatelessWidget {
  final int docId;
  final int subDocId;

  const CIPoliciesProcedure({
    super.key,
    required this.docId,
    required this.subDocId,
  });

  @override
  Widget build(BuildContext context) {
    return _CIPoliciesProcedureBody(docId: docId, subDocId: subDocId);
  }
}

// FIX: added a Stateful body to register a listener on the shared
// CiOrgDocumentProvider "something was saved" signal (fired by the
// top-level Add button) in initState - saved via addPostFrameCallback,
// removed in dispose, per project convention.
class _CIPoliciesProcedureBody extends StatefulWidget {
  final int docId;
  final int subDocId;

  const _CIPoliciesProcedureBody({
    required this.docId,
    required this.subDocId,
  });

  @override
  State<_CIPoliciesProcedureBody> createState() => _CIPoliciesProcedureBodyState();
}

class _CIPoliciesProcedureBodyState extends State<_CIPoliciesProcedureBody> {
  CiOrgDocumentProvider? _orgDocProvider;

  void _onDocumentSavedElsewhere() {
    context.read<CIPoliciesProcedureProvider>().fetchDocuments(context);
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
    // Get the provider instance
    final provider = Provider.of<CIPoliciesProcedureProvider>(context);

    return Column(
      children: [
        PoliciesProcedureList(
          controller: provider.policiesAndProcedureController,
          fetchDocuments: (context) => getNewOrgDocfetch(
            context,
            FrontendConfigStore.data!.config.policiesAndProcedure,
            FrontendConfigStore.data!.config.subDocId0,
            1,
            50,
          ),
          emptyMessage: ErrorMessageString.noPolicyProcedure,
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