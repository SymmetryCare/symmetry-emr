import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/setting_profile_manager/document_updated_manager.dart';
import 'package:symmetry_emr/app/services/base64/download_file_base64.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/document_uploaded_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/add_document_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/edit_document_popup.dart';

class DocumentUpdateScreen extends StatefulWidget {
  final int employeeId;
  const DocumentUpdateScreen({Key? key, required this.employeeId})
      : super(key: key);

  @override
  State<DocumentUpdateScreen> createState() => _DocumentUpdateScreenState();
}

class _DocumentUpdateScreenState extends State<DocumentUpdateScreen> {
  // ── state ──────────────────────────────────────────────
  bool _isLoading = true;
  EmployeeDocumentData? _documentData;
  String _searchQuery = 'all';
  Timer? _debounce;

  List<DocumentGroup> get _groups => _documentData?.document ?? [];

  // ── lifecycle ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDocuments());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// [showLoader] controls whether the full-list spinner is shown while
  /// fetching. Initial load / search use the loader since there's nothing
  /// on screen yet worth preserving. Post add/edit refreshes pass `false`
  /// so the existing list stays visible and simply swaps in the new data
  /// the instant it arrives — no blank/spinner flash between "Save" and
  /// seeing the updated row.
  Future<void> _fetchDocuments({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    final result = await getEmployeeDocuments(
      context: context,
      employeeId: widget.employeeId,
      searchFilter: _searchQuery,
    );
    if (!mounted) return;
    setState(() {
      _documentData = result;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetchDocuments);
  }

  // ── helpers ────────────────────────────────────────────

  /// Parses ISO 8601 (2026-03-31T18:30:00.000Z) and yyyy-MM-dd formats
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // ISO 8601 full or date-only with dash
      if (dateStr.contains('-')) return DateTime.parse(dateStr);
      // Legacy MM/dd/yyyy
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  /// Source of truth for "expired" comes straight from the API's
  /// docStatus field, so the red styling always matches whatever the
  /// backend considers expired rather than a locally-computed date check.
  bool _isExpired(String? docStatus) {
    return (docStatus ?? '').trim().toLowerCase() == 'expired';
  }

  /// Formats to yyyy-MM-dd for display; returns '—' when null/empty
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    final date = _parseDate(dateStr);
    if (date == null) return dateStr;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ── build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            /// LEFT COLUMN
            Expanded(
              flex: 5,
              child: ScrollConfiguration(
                behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Search + Add button
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 35,
                              child: TextField(
                                style: const TextStyle(fontSize: 14),
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: const TextStyle(fontSize: 14),
                                  prefixIcon:
                                  const Icon(Icons.search, size: 18),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 35, minHeight: 35),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 35,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final uploaded = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AddDocumentPopup(
                                    employeeId: widget.employeeId,
                                  ),
                                );
                                // Refresh list after successful upload —
                                // silent so the list doesn't blank out.
                                if (uploaded == true) {
                                  _fetchDocuments(showLoader: false);
                                }
                              },
                              icon: Icon(Icons.add,
                                  size: 16, color: ColorManager.blueprime),
                              label: Text(
                                "Add new",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: ColorManager.blueprime,
                                    fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: ColorManager.blueprime,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                                side:
                                BorderSide(color: ColorManager.blueprime),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ).copyWith(
                                overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.grey.shade200,
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Licensure & Certifications",
                                  style:
                                  TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Expiry date",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "Updates",
                                  style:
                                  TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Document groups from API ──────────────────
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 100),
                          child: Center(
                              child: CircularProgressIndicator(
                                color: ColorManager.blueprime,
                              )),
                        )
                      else if (_groups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 100),
                          child: Center(
                              child: Text(
                                "No documents found!",
                                style: AllNoDataAvailable.customTextStyle(context),
                              )),
                        )
                      else
                        _buildGroupList(),
                    ],
                  ),
                ),
              ),
            ),

            /// RIGHT EMPTY COLUMN
            const Expanded(flex: 5, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  /// Renders each document group (e.g. "Essential Licensure &
  /// Certifications") as a bold section title, followed by its document
  /// rows, with a light divider between groups.
  Widget _buildGroupList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _groups.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _groups[i].docName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          ..._groups[i].docList.map(
                (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              // Pass the category name down alongside the doc item so the
              // edit popup has everything it needs in one place.
              child: _documentRow(_groups[i].docName, doc),
            ),
          ),
          if (i != _groups.length - 1) ...[
            const SizedBox(height: 6),
            const Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
            const SizedBox(height: 20),
          ],
        ],
      ],
    );
  }

  /// Dynamic document row — docStatus == "Expired" drives the red date +
  /// Update button, otherwise nothing shows in the Updates column.
  ///
  /// [categoryName] is the group heading (e.g. "Essential Licensure &
  /// Certifications") and [doc] is the individual document item, which is
  /// expected to expose: documentName, expiryDate, docStatus, documentUrl,
  /// employeeDocumentId, employeeDocumentTypeMetaDataId,
  /// employeeDocumentTypeSetupId (see DocItem in document_uploaded_data.dart).
  Widget _documentRow(String categoryName, dynamic doc) {
    final String title = doc.documentName;
    final String? expiryDate = doc.expiryDate;
    final String? docStatus = doc.docStatus;
    final String docUrl = doc.documentUrl;

    final expired = _isExpired(docStatus);
    final displayDate = _formatDate(expiryDate);

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () async{
                    await downloadDocument(context: context,
                        fileUrl: docUrl,documentName:title,apiPath: DownloadDocumentRepository.getDocumentByFileName());
                  },
                  child: const Icon(Icons.insert_drive_file_outlined,
                      size: 18)),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            displayDate,
            style: TextStyle(
              color: expired ? ColorManager.red : Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: expired ? _updateButton(categoryName, doc) : const  SizedBox(height: 30),
        ),
      ],
    );
  }

  /// Update button — opens EditDocumentPopup pre-filled with this
  /// document's data. Category/Type are read-only inside the popup;
  /// only the file and (when applicable) the expiry date can change.
  /// After a successful save, the list refreshes silently (no loader
  /// flash) so the change reflects on screen immediately.
  Widget _updateButton(String categoryName, dynamic doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextButton(
          onPressed: () async {
            final updated = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => EditDocumentPopup(
                employeeId: widget.employeeId,
                empDocumentId: doc.employeeDocumentId,
                docMetaDataId: doc.employeeDocumentTypeMetaDataId,
                docSetupId: doc.employeeDocumentTypeSetupId,
                docCategoryName: categoryName,
                docTypeName: doc.documentName,
                expiryDate: doc.expiryDate,
                existingFileName: doc.documentName,
                documentUrl: doc.documentUrl,
              ),
            );
            if (updated == true) {
              await _fetchDocuments(showLoader: false);
            }
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            "Update",
            style: TextStyle(
                color: ColorManager.blueprime,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}