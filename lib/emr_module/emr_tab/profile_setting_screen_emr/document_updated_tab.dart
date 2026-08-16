import 'package:flutter/material.dart';
import '../../../../../app/services/api/managers/emr_module_manager/setting_profile_manager/document_updated_manager.dart';
import '../../../../../data/api_data/emr_module_data/setting_profile_data/document_uploaded_data.dart';
import 'add_document_popup.dart';

class DocumentUpdateScreen extends StatefulWidget {
  final int employeeId;
  const DocumentUpdateScreen(
      {Key? key, required this.employeeId})
      : super(key: key);

  @override
  State<DocumentUpdateScreen> createState() => _DocumentUpdateScreenState();
}

class _DocumentUpdateScreenState extends State<DocumentUpdateScreen> {
  // ── state ──────────────────────────────────────────────
  bool _isLoading = true;
  List<EmployeeDocumentData> _documents = [];
  String _searchQuery = '';

  // ── lifecycle ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchDocuments());
  }

  Future<void> _fetchDocuments() async {
    setState(() => _isLoading = true);
    final docs = await getEmployeeDocuments(
      context: context,
      employeeId: widget.employeeId,
    );
    if (!mounted) return;
    setState(() {
      _documents = docs;
      _isLoading = false;
    });
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

  /// Returns true when the expiry date is non-null and in the past
  bool _isExpired(String? dateStr) {
    final date = _parseDate(dateStr);
    return date != null && date.isBefore(DateTime.now());
  }

  /// Formats to yyyy-MM-dd for display; returns '—' when null/empty
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    final date = _parseDate(dateStr);
    if (date == null) return dateStr;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<EmployeeDocumentData> get _filtered {
    if (_searchQuery.isEmpty) return _documents;
    return _documents
        .where((d) => d.documentNameDefination   // ← fixed: was d.documentName
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ── build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            /// LEFT COLUMN
            Expanded(
              flex: 5,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
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
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle:
                                  const TextStyle(fontSize: 14),
                                  prefixIcon:
                                  const Icon(Icons.search, size: 18),
                                  prefixIconConstraints:
                                  const BoxConstraints(
                                      minWidth: 35, minHeight: 35),
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                      vertical: 5),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 35,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final uploaded = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AddDocumentPopup(
                                    employeeId: widget.employeeId,
                                  ),
                                );
                                // Refresh list after successful upload
                                if (uploaded == true) _fetchDocuments();
                              },
                              icon: const Icon(Icons.add,
                                  size: 16, color: Colors.blue),
                              label: const Text(
                                "Add new",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.blue),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                side: const BorderSide(
                                    color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// Header
                      Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                        color: Colors.grey.shade200,
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                EdgeInsets.only(left: 10),
                                child: Text(
                                  "Licensure & Certifications",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Expiry date",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  "Updates",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ── Document list from API ──────────────────
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_filtered.isEmpty)
                        const Center(
                            child: Text("No documents found."))
                      else
                        ..._filtered.map((doc) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 10),
                            child: _documentRow(
                              doc.documentNameDefination,
                              doc.expiryDate,
                            ),
                          );
                        }),
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

  /// Dynamic document row — expired = red date + Update button, otherwise nothing
  Widget _documentRow(String title, String? expiryDate) {
    final expired = _isExpired(expiryDate);
    final displayDate = _formatDate(expiryDate);

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 18),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            displayDate,
            style: TextStyle(
              color: expired ? Colors.red : Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: expired ? _updateButton() : const SizedBox(),
        ),
      ],
    );
  }

  /// Update button
  Widget _updateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Text(
            "Update",
            style: TextStyle(color: Colors.blue, fontSize: 13),
          ),
        ),
      ),
    );
  }
}