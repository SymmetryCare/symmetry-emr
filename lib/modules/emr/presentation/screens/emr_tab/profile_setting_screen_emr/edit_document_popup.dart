import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/add_document_popup.dart' show DocumentOptionBox;

class EditDocumentPopup extends StatefulWidget {
  final int employeeId;
  final int empDocumentId;
  final int docMetaDataId;
  final int docSetupId;
  final String docCategoryName; // shown read-only, e.g. group heading
  final String docTypeName; // kept for callers/patch payload; not displayed
  final String? expiryDate; // existing expiry date; '--' or empty means none
  final String? existingFileName; // current uploaded file's display name
  final String documentUrl; // current file url, sent back unchanged unless replaced

  const EditDocumentPopup({
    super.key,
    required this.employeeId,
    required this.empDocumentId,
    required this.docMetaDataId,
    required this.docSetupId,
    required this.docCategoryName,
    required this.docTypeName,
    required this.expiryDate,
    required this.existingFileName,
    required this.documentUrl,
  });

  @override
  State<EditDocumentPopup> createState() => _EditDocumentPopupState();
}

class _EditDocumentPopupState extends State<EditDocumentPopup> {
  final TextEditingController _expiryController = TextEditingController();
  late DateTime _selectedDate;

  // ── File state (the actual file that will be uploaded) ──
  Uint8List? _fileBytes;
  String? _fileName;
  bool _isSaving = false;

  // ── Upload box display state ─────────────────────────────
  String? _uploadedFileName;

  // ── Capture box display state ────────────────────────────
  Uint8List? _capturedImageBytes;
  String? _capturedFileName;

  // ── Camera state ──────────────────────────────────────────
  List<CameraDescription>? _cameras;
  bool _isPreparingFile = false;

  // ── Max file size: 10 MB ─────────────────────────────────
  static const int _maxFileSizeInBytes = 10 * 1024 * 1024;

  // Set once in initState from the incoming expiryDate; determines whether
  // the date field shows at all for the lifetime of this popup.
  late bool _showDateField;

  @override
  void initState() {
    super.initState();
    _fileName = widget.existingFileName;
    _uploadedFileName = widget.existingFileName;
    final parsed = _parseDate(widget.expiryDate);
    _showDateField = parsed != null;
    _selectedDate = parsed ?? DateTime.now();
    if (_showDateField) {
      _expiryController.text = CalendarDialogHelper.fmt(_selectedDate);
    }
    // Pre-fetch camera list on init (not on tap) so the later camera
    // permission request stays as close as possible to the user's click
    // gesture — required by browsers on Flutter Web (getUserMedia).
    _prefetchCameras();
  }

  Future<void> _prefetchCameras() async {
    try {
      final camList = await availableCameras();
      if (mounted) {
        setState(() => _cameras = camList);
      }
    } catch (e) {
      debugPrint("availableCameras prefetch failed: $e");
    }
  }

  @override
  void dispose() {
    _expiryController.dispose();
    super.dispose();
  }

  /// Returns null for missing/placeholder values ('--', empty, unparsable)
  /// so callers can treat "no real date" as a single case.
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr.trim() == '--') {
      return null;
    }
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await CalendarDialogHelperFeturedate.show(
      context: context,
      selectedDate: _selectedDate,
      firstDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _expiryController.text = CalendarDialogHelperFeturedate.fmt(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final fileSizeInBytes = result.files.single.size;

        if (fileSizeInBytes > _maxFileSizeInBytes) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AddErrorPopup(
                  message: 'File is too large!',
                );
              },
            );
          }
          return;
        }

        setState(() {
          _fileBytes = result.files.single.bytes;
          _fileName = result.files.single.name;

          // this becomes the active file → show it in upload box, clear capture box
          _uploadedFileName = result.files.single.name;
          _capturedImageBytes = null;
          _capturedFileName = null;
        });
      }
    } catch (e) {
      debugPrint("File pick failed: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AddErrorPopup(
            message: 'Unable to pick file.\nPlease try again.',
          ),
        );
      }
    }
  }

  // ── Camera capture ─────────────────────────────────────────
  Future<void> _pickCamera() async {
    setState(() => _isPreparingFile = true);

    try {
      List<CameraDescription> camList = _cameras ?? [];
      if (camList.isEmpty) {
        try {
          camList = await availableCameras();
          _cameras = camList;
        } catch (e) {
          debugPrint("availableCameras failed: $e");
        }
      }

      if (camList.isEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const AddErrorPopup(
                message: 'No camera found on this device.'),
          );
        }
        return;
      }

      final picture = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebCameraScreen(cameras: camList),
        ),
      );

      if (picture != null) {
        final Uint8List imageBytes =
        Uint8List.fromList(await picture.readAsBytes());

        if (imageBytes.length > _maxFileSizeInBytes) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => const AddErrorPopup(
                message: 'File is too large!',
              ),
            );
          }
          return;
        }

        final fileName =
            "captured_${DateTime.now().millisecondsSinceEpoch}.jpg";

        setState(() {
          _fileBytes = imageBytes;
          _fileName = fileName;

          // this becomes the active file → show it in capture box, clear upload box
          _capturedImageBytes = imageBytes;
          _capturedFileName = fileName;
          _uploadedFileName = null;
        });

        debugPrint("Captured image converted successfully.");
      }
    } catch (e) {
      // Previously missing — any exception from Navigator.push/WebCameraScreen
      // (e.g. getUserMedia permission denied on Flutter Web) propagated
      // uncaught out of this widget, which could force the app back to Login.
      debugPrint("Camera capture failed: $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AddErrorPopup(
            message:
            'Unable to access camera.\nPlease allow camera permission and try again.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPreparingFile = false);
    }
  }

  Future<void> _save() async {
    if (_showDateField && _expiryController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          title: 'Failed',
          message: 'Please select an\nexpiry date.',
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // NOTE: patchEmployeeDocuments / patchEmployeeBase64Documents build
    // the final ISO datetime themselves via "${expiryDate}T00:00:00Z", so
    // this must stay a plain yyyy-MM-dd date — NOT a full ISO datetime.
    // Sending toIso8601String() here produced a malformed double-timestamp
    // string ("...ZT00:00:00Z") that the backend rejected with a 400.
    final String? expiryDateToSend = _showDateField
        ? "${_selectedDate.year.toString().padLeft(4, '0')}-"
        "${_selectedDate.month.toString().padLeft(2, '0')}-"
        "${_selectedDate.day.toString().padLeft(2, '0')}"
        : null;

    print("=== EditDocumentPopup._save start ===");
    print(
        "empDocumentId: ${widget.empDocumentId}, docMetaDataId: ${widget.docMetaDataId}, docSetupId: ${widget.docSetupId}, employeeId: ${widget.employeeId}");
    print(
        "showDateField: $_showDateField, expiryDateToSend: $expiryDateToSend");
    print(
        "file picked: ${_fileBytes != null}, fileName: $_fileName, documentUrl: ${widget.documentUrl}");

    try {
      // 1. Always patch the metadata (setup id, meta id, expiry date).
      final patchResult = await patchEmployeeDocuments(
        context: context,
        empDocumentId: widget.empDocumentId,
        employeeDocumentMetaId: widget.docMetaDataId,
        employeeDocumentTypeSetupId: widget.docSetupId,
        employeeId: widget.employeeId,
        documentUrl: widget.documentUrl,
        uploadDate: DateTime.now().toUtc().toIso8601String(),
        expiryDate: expiryDateToSend,
      );

      print(
          "patchEmployeeDocuments response -> statusCode: ${patchResult.statusCode}, success: ${patchResult.success}, message: ${patchResult.message}");

      if (!mounted) return;

      if (patchResult.statusCode == 200 || patchResult.statusCode == 201) {
        // 2. Only push a new file if the user actually picked/captured one.
        if (_fileBytes != null && _fileName != null) {
          print(
              "New file detected, calling patchEmployeeBase64Documents for employeeDocumentId: ${widget.empDocumentId}, documentName: $_fileName");

          final fileResult = await patchEmployeeBase64Documents(
            context: context,
            employeeDocumentId: widget.empDocumentId,
            employeeDocumentMetaId: widget.docMetaDataId,
            employeeDocumentTypeSetupId: widget.docSetupId,
            employeeId: widget.employeeId,
            documentFile: _fileBytes!,
            documentName: _fileName!,
            expiryDate: expiryDateToSend,
          );

          print(
              "patchEmployeeBase64Documents response -> statusCode: ${fileResult.statusCode}, success: ${fileResult.success}, message: ${fileResult.message}");

          if (!mounted) return;
          setState(() => _isSaving = false);

          if (fileResult.statusCode == 200 || fileResult.statusCode == 201) {
            print("Document updated successfully (with new file).");
            await showDialog(
              context: context,
              builder: (_) => const EMRSuccessPopup(
                title: 'Success',
                message: 'Document updated\nsuccessfully.',
              ),
            );
            if (mounted) Navigator.of(context).pop(true);
          } else {
            print("File patch failed: ${fileResult.message}");
            showDialog(
              context: context,
              builder: (_) => EMRFailedPopup(
                title: 'Failed',
                message: fileResult.message,
              ),
            );
          }
        } else {
          print("No new file picked; metadata-only update successful.");
          setState(() => _isSaving = false);
          await showDialog(
            context: context,
            builder: (_) => const EMRSuccessPopup(
              title: 'Success',
              message: 'Document updated\nsuccessfully.',
            ),
          );
          if (mounted) Navigator.of(context).pop(true);
        }
      } else {
        print("Metadata patch failed: ${patchResult.message}");
        setState(() => _isSaving = false);
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(
            title: 'Failed',
            message: patchResult.message,
          ),
        );
      }
    } catch (e) {
      print("Error $e");
      if (mounted) setState(() => _isSaving = false);
    }
    print("=== EditDocumentPopup._save end ===");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title Row ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => Navigator.of(context).pop(false),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.red, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Upload / Capture Row (editable) ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DocumentOptionBox(
                      icon: Icons.image_outlined,
                      label: (_uploadedFileName != null &&
                          _uploadedFileName!.isNotEmpty)
                          ? _uploadedFileName!
                          : 'Upload here',
                      onTap: _isPreparingFile ? () {} : _pickFile,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: DocumentOptionBox(
                      icon: Icons.camera_alt_outlined,
                      label: _isPreparingFile
                          ? 'Preparing...'
                          : (_capturedFileName ?? 'Capture here'),
                      previewBytes: _capturedImageBytes,
                      onTap: _isPreparingFile ? () {} : _pickCamera,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Document Category (read-only) ─────────────────────
              const Text(
                'Document Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _ReadOnlyField(text: widget.docCategoryName),

              // ── Expiry Date (editable, only when applicable) ──────
              if (_showDateField) ...[
                const SizedBox(height: 16),
                const Text(
                  'Expiry date of document',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller: _expiryController,
                    readOnly: true,
                    onTap: _pickDate,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter Expiry date of document',
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                      suffixIcon: GestureDetector(
                        onTap: _pickDate,
                        child: const Icon(Icons.calendar_today_outlined,
                            size: 16, color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                        const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                        const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                        const BorderSide(color:Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Action Buttons ────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorManager.blueprime),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ).copyWith(
                          overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: ColorManager.blueprime,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.blueprime,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          disabledBackgroundColor: const Color(0xFFBFBFBF),
                          disabledForegroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Read-only display box (same footprint as a dropdown field) ───────────────
class _ReadOnlyField extends StatelessWidget {
  final String text;
  const _ReadOnlyField({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text.isNotEmpty ? text : '—',
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      ),
    );
  }
}