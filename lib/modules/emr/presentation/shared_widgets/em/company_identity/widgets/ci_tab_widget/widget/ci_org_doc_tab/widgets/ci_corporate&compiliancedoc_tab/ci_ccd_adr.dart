import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/provider/delete_popup_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/files_constant-widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/heading_constant_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/org_add_popup_const.dart';

class CICcdADRProvider extends ChangeNotifier {
  final TextEditingController docNameController = TextEditingController();
  final TextEditingController docIdController = TextEditingController();
  final TextEditingController calenderController = TextEditingController();
  final TextEditingController idOfDocController = TextEditingController();
  final TextEditingController daysController = TextEditingController(text: "1");

  final StreamController<List<NewOrgDocument>> documentStream =
  StreamController<List<NewOrgDocument>>.broadcast();

  int docTypeMetaIdCC = FrontendConfigStore.data!.config.corporateAndCompliance;
  int docTypeMetaIdCCAdr = FrontendConfigStore.data!.config.subDocId2Adr;
  String? expiryType;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchDocuments(BuildContext context) async {
    try {
      final documents = await getNewOrgDocfetch(
        context,
        FrontendConfigStore.data!.config.corporateAndCompliance,
        FrontendConfigStore.data!.config.subDocId2Adr,
        1,
        50,
      );
      documentStream.add(documents);
    } catch (e) {
      documentStream.addError(e);
    }
  }

  Future<void> onEdit(BuildContext context, NewOrgDocument doc) async {
    try {
      var snapshotPrefill = await getPrefillNewOrgDocument(context, doc.orgDocumentSetupid);
      docNameController.text = snapshotPrefill.docName ?? "";
      expiryType = snapshotPrefill.expiryType;

      showDialog(
        context: context,
        builder: (context) {
          return OrgDocNewEditPopup(
            title: EditPopupString.editAdr,
            orgDocumentSetupid: snapshotPrefill.orgDocumentSetupid,
            docTypeId: snapshotPrefill.documentTypeId,
            subDocTypeId: snapshotPrefill.documentSubTypeId,
            idOfDoc: snapshotPrefill.idOfDocument,
            docName: snapshotPrefill.docName,
            expiryType: snapshotPrefill.expiryType,
            threshhold: snapshotPrefill.threshold,
            expiryDate: snapshotPrefill.expiryDate,
            expiryReminder: snapshotPrefill.expiryReminder,
            docTypeText: AppStringEM.corporateAndComplianceDocuments,
            subDocTypeText: AppStringEM.ard,
          );
        // FIX: reload the list after the edit dialog closes so edits
        // reflect immediately instead of only after leaving and reopening
        // the tab.
        },
      ).then((_) => fetchDocuments(context));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> onDelete(BuildContext context, NewOrgDocument doc) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopupProvider(
          title: DeletePopupString.deleteAdr,
          loadingDuration: _isLoading,
          onCancel: () => Navigator.pop(context),
          onDelete: () async {
            setLoading(true);
            try {
              await deleteNewOrgDoc(context, doc.orgDocumentSetupid);
              Navigator.pop(context); // Close the delete popup
              // FIX: reload the list after a successful delete.
              fetchDocuments(context);
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

class CICcdADR extends StatefulWidget {
  final int subDocID;
  final int docID;

  const CICcdADR({
    super.key,
    required this.subDocID,
    required this.docID,
  });

  @override
  State<CICcdADR> createState() => _CICcdADRState();
}

class _CICcdADRState extends State<CICcdADR> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CICcdADRProvider>(context, listen: false);

    return StreamBuilder<List<NewOrgDocument>>(
      stream: provider.documentStream.stream,
      builder: (context, snapshot) {
        provider.fetchDocuments(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: ColorManager.blueprime));
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text(ErrorMessageString.noADR, style: AllNoDataAvailable.customTextStyle(context)));
        }

        if (snapshot.hasData) {
          const int itemsPerPage = 10;
          int currentPage = 1;
          int totalPages = (snapshot.data!.length / itemsPerPage).ceil();
          List<NewOrgDocument> paginatedData = snapshot.data!
              .skip((currentPage - 1) * itemsPerPage)
              .take(itemsPerPage)
              .toList();

          return Column(
            children: [
              Expanded(
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
                              const TableHeadingConst(),
                              const SizedBox(height: AppSize.s10),
                              Expanded(
                                child: ScrollConfiguration(
                                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                                  child: ListView.builder(
                                    itemCount: paginatedData.length,
                                    itemBuilder: (context, index) {
                                      int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                      String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                      NewOrgDocument policiesdata = paginatedData[index];
                                      return Column(
                                        children: [
                                          const SizedBox(height: AppSize.s5),
                                          Container(
                                            padding: const EdgeInsets.only(bottom: AppPadding.p5),
                                            margin: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
                                            decoration: BoxDecoration(
                                              color: ColorManager.white,
                                              borderRadius: BorderRadius.circular(4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: ColorManager.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            height: AppSize.s56,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Expanded(flex: 2, child: Center(child: Text(formattedSerialNumber, style: DocumentTypeDataStyle.customTextStyle(context), textAlign: TextAlign.start))),
                                                Expanded(flex: 2, child: Text(policiesdata.idOfDocument, style: DocumentTypeDataStyle.customTextStyle(context), textAlign: TextAlign.center)),
                                                Expanded(flex: 2, child: Text(policiesdata.docName, textAlign: TextAlign.center, style: DocumentTypeDataStyle.customTextStyle(context))),
                                                Expanded(flex: 2, child: Padding(
                                                  padding: const EdgeInsets.only(left: AppPadding.p30),
                                                  child: Text(policiesdata.expiryReminder, textAlign: TextAlign.center, style: DocumentTypeDataStyle.customTextStyle(context)),
                                                )),
                                                Expanded(flex: 3, child: Padding(
                                                  padding: const EdgeInsets.only(left: AppPadding.p25),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      IconButton(hoverColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent, onPressed: () => provider.onEdit(context, policiesdata), icon: Icon(Icons.edit_outlined, size: IconSize.I18, color: IconColorManager.blueprime)),
                                                      IconButton(hoverColor: Colors.transparent, splashColor: Colors.transparent, highlightColor: Colors.transparent, onPressed: () => provider.onDelete(context, policiesdata), icon: Icon(Icons.delete_outline, size: IconSize.I18, color: IconColorManager.red)),
                                                    ],
                                                  ),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              PaginationControlsWidget(
                currentPage: currentPage,
                items: snapshot.data!,
                itemsPerPage: itemsPerPage,
                onPreviousPagePressed: () {
                  if (currentPage > 1) currentPage--;
                },
                onPageNumberPressed: (pageNumber) {
                  currentPage = pageNumber;
                },
                onNextPagePressed: () {
                  if (currentPage < totalPages) currentPage++;
                },
              ),
            ],
          );
        }

        return const Offstage();
      },
    );
  }
}