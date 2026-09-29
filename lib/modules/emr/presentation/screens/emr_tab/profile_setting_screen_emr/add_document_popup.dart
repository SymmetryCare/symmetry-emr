import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/setting_profile_manager/document_updated_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/manage_emp/uploadData_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/document_uploaded_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';



class AddDocumentPopup extends StatefulWidget {
  final int employeeId;

  const AddDocumentPopup({
    super.key,
    required this.employeeId,
  });

  @override
  State<AddDocumentPopup> createState() => _AddDocumentPopupState();
}

class _AddDocumentPopupState extends State<AddDocumentPopup> {
  final TextEditingController _expiryController = TextEditingController();

  // ── Dropdown 1: Essential Docs ──────────────────────────
  late Future<List<EssentialDocData>> _essentialDocsFuture;
  int? _selectedMetaDataId;
  String? _selectedEssentialDocName;

  // ── Dropdown 2: Document Type Setup ────────────────────
  Future<List<EmployeeDocumentTypeSetupData>>? _docTypeSetupFuture;
  int? _selectedSetupId;
  String? _selectedSetupName;
  String? _selectedExpiryType;

  // ── File state (the actual file that will be uploaded) ──
  // uploadDocuments() encodes to base64 internally, so we only keep raw bytes here.
  dynamic _fileBytes;
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

  @override
  void initState() {
    super.initState();
    _essentialDocsFuture = getEssentialDocs(context: context);
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

  DateTime _selectedDate = DateTime.now();

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
          _fileBytes = result.files.single.bytes!;
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
      // Previously this branch didn't exist — any exception thrown by
      // Navigator.push/WebCameraScreen (e.g. getUserMedia permission
      // denied on Flutter Web) propagated uncaught out of this widget,
      // which is what was forcing the app back to the login screen.
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
    final bool showDateField = _selectedExpiryType == 'Issuer Expiry';

    if (_fileBytes == null || _fileName == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          title: 'Failed',
          message: 'Please select a\ndocument first.',
        ),
      );
      return;
    }
    if (_selectedMetaDataId == null || _selectedSetupId == null) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          title: 'Failed',
          message: 'Please select\ndocument type.',
        ),
      );
      return;
    }
    if (showDateField && _expiryController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const EMRFailedPopup(
          title: 'Failed',
          message: 'Please select\nexpiry date.',
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await uploadDocuments(
        context: context,
        employeeDocumentMetaId: _selectedMetaDataId!,
        employeeDocumentTypeSetupId: _selectedSetupId!,
        employeeId: widget.employeeId,
        documentFile: _fileBytes!,
        documentName: _fileName!,
        expiryDate: showDateField
            ? _selectedDate.toUtc().toIso8601String()
            : null,
      );

      if (!mounted) return;

      if (result.success) {
        await showDialog(
          context: context,
          builder: (_) => const EMRSuccessPopup(
            title: 'Success',
            message: 'Document uploaded\nsuccessfully.',
          ),
        );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        showDialog(
          context: context,
          builder: (_) => EMRFailedPopup(
            title: 'Failed',
            message: result.message,
          ),
        );
      }
    } catch (e) {
      print("Error $e");
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const EMRFailedPopup(
            title: 'Failed',
            message: 'Something went wrong.\nPlease try again.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showDateField = _selectedExpiryType == 'Issuer Expiry';

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
                    'Add New Document',
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

              // ── Upload / Capture Row ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DocumentOptionBox(
                      icon: Icons.image_outlined,
                      label: _uploadedFileName ?? 'Upload here',
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

              // ── Dropdown 1: Essential Docs ────────────────────────
              const Text(
                'Document Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<EssentialDocData>>(
                future: _essentialDocsFuture,
                builder: (context, snapshot) {
                  final List<EssentialDocData> list = snapshot.data ?? [];
                  return EmrDropdownConst(
                    dropDownMenuList: list
                        .map((e) => DropdownMenuItem<String>(
                      value: e.documentName,
                      child: Text(e.documentName ?? ''),
                    ))
                        .toList(),
                    hintText: _selectedEssentialDocName ?? 'Select',
                    height: 35,
                    onChanged: (newValue) {
                      if (newValue == null) return;
                      final match = list.firstWhere(
                            (e) => e.documentName == newValue,
                        orElse: () =>
                            EssentialDocData(documentName: newValue),
                      );
                      setState(() {
                        _selectedMetaDataId =
                            match.employeeDocumentTypeMetaDataId;
                        _selectedEssentialDocName = match.documentName;
                        _selectedSetupId = null;
                        _selectedSetupName = null;
                        _selectedExpiryType = null;
                        _expiryController.clear();
                        if (_selectedMetaDataId != null) {
                          _docTypeSetupFuture = getEmployeeDocumentTypeSetup(
                            context: context,
                            employeeDocumentTypeMetaDataId:
                            _selectedMetaDataId!,
                          );
                        }
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── Dropdown 2: Document Type Setup ──────────────────
              const Text(
                'Document Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<EmployeeDocumentTypeSetupData>>(
                future: _docTypeSetupFuture,
                builder: (context, snapshot) {
                  final List<EmployeeDocumentTypeSetupData> list =
                      snapshot.data ?? [];
                  return EmrDropdownConst(
                    dropDownMenuList: list
                        .map((e) => DropdownMenuItem<String>(
                      value: e.documentName,
                      child: Text(e.documentName ?? ''),
                    ))
                        .toList(),
                    hintText: _selectedMetaDataId == null
                        ? 'Select category first'
                        : (_selectedSetupName ?? 'Select'),
                    height: 35,
                    onChanged: _selectedMetaDataId == null
                        ? null
                        : (newValue) {
                      if (newValue == null) return;
                      final match = list.firstWhere(
                            (e) => e.documentName == newValue,
                        orElse: () => EmployeeDocumentTypeSetupData(
                            documentName: newValue),
                      );
                      setState(() {
                        _selectedSetupId =
                            match.employeeDocumentTypeSetupId;
                        _selectedSetupName = match.documentName;
                        _selectedExpiryType = match.expiryType;
                        if (_selectedExpiryType != 'Issuer Expiry') {
                          _expiryController.clear();
                        }
                      });
                    },
                  );
                },
              ),

              // ── Expiry Date (only for "Issuer Expiry") ────────────
              if (showDateField) ...[
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
                          color:Colors.grey, fontSize: 13),
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
                        const BorderSide(color: Colors.grey),
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
                          side:  BorderSide(color: ColorManager.blueprime),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child:  Text(
                          'Cancel',
                          style: TextStyle(
                              color:  ColorManager.blueprime,
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
                          backgroundColor:  ColorManager.blueprime,
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

// ── Dotted Border Painter ─────────────────────────────────────────────────────
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  const DottedBorderPainter({
    this.color = const Color(0xFFCCCCCC),
    this.strokeWidth = 1.5,
    this.gap = 5,
    this.radius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(radius)));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? strokeWidth * 2 : gap;
        if (draw) {
          canvas.drawPath(
              metric.extractPath(distance, distance + len), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Document Option Box ───────────────────────────────────────────────────────
class DocumentOptionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Uint8List? previewBytes;

  const DocumentOptionBox({
    required this.icon,
    required this.label,
    required this.onTap,
    this.previewBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon == Icons.image_outlined
              ? 'Upload document'
              : 'Capture document',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: CustomPaint(
            painter: const DottedBorderPainter(
              color: Color(0xFFCCCCCC),
              strokeWidth: 1.5,
              gap: 5,
              radius: 8,
            ),
            child: SizedBox(
              height: 115,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: previewBytes != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        previewBytes!,
                        width: 60,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          icon,
                          size: 26,
                          color: const Color(0xFFAAAAAA),
                        ),
                      ),
                    )
                        : Icon(icon, size: 26, color: const Color(0xFFAAAAAA)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        color: ColorManager.blueprime,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}