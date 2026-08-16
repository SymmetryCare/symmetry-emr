import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../../app/services/api/managers/emr_module_manager/setting_profile_manager/document_updated_manager.dart';
import '../../../../../data/api_data/emr_module_data/setting_profile_data/document_uploaded_data.dart';
import '../emr_const/calender_popup_const.dart';
import '../emr_const/dropdown_const.dart';
import '../emr_const/sucess_failed_popup_const.dart';


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

  // ── File state ──────────────────────────────────────────
  String? _base64File;
  String? _fileName;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _essentialDocsFuture = getEssentialDocs(context: context);
  }

  @override
  void dispose() {
    _expiryController.dispose();
    super.dispose();
  }

  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await CalendarDialogHelper.show(
      context: context,
      selectedDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _expiryController.text = CalendarDialogHelper.fmt(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _base64File = base64Encode(result.files.single.bytes!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _save() async {
    if (_base64File == null || _fileName == null) {
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

    setState(() => _isSaving = true);

    final result = await uploadEmployeeDocument(
      context: context,
      employeeDocumentTypeMetaDataId: _selectedMetaDataId!,
      employeeDocumentTypeSetupId: _selectedSetupId!,
      employeeId: widget.employeeId,
      base64: _base64File!,
      documentName: _fileName!,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

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
                    child: _DocumentOptionBox(
                      icon: Icons.image_outlined,
                      label: _fileName != null ? _fileName! : 'Upload here',
                      onTap: _pickFile,
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
                    child: _DocumentOptionBox(
                      icon: Icons.camera_alt_outlined,
                      label: 'Capture here',
                      onTap: _pickFile,
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
                          color: Color(0xFFBBBBBB), fontSize: 13),
                      suffixIcon: GestureDetector(
                        onTap: _pickDate,
                        child: const Icon(Icons.calendar_today_outlined,
                            size: 16, color: Color(0xFFBBBBBB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                        const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                        const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                        const BorderSide(color: Color(0xFFDDDDDD)),
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
                          side: const BorderSide(color: Color(0xFF00BCD4)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Color(0xFF00BCD4),
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
                          backgroundColor: const Color(0xFF00BCD4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
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
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  const _DottedBorderPainter({
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
class _DocumentOptionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DocumentOptionBox({
    required this.icon,
    required this.label,
    required this.onTap,
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
        GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            painter: const _DottedBorderPainter(
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
                    child: Icon(icon, size: 26, color: const Color(0xFFAAAAAA)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF00BCD4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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