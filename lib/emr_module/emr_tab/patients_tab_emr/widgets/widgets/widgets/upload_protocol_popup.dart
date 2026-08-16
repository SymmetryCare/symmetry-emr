import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import 'package:prohealth/presentation/screens/hr_module/register/taxtfield_constant.dart';

import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/services/api/managers/emr_module_manager/emr_patient_manager/patient_protocol_manager.dart';
import '../../../../../../../../data/api_data/emr_module_data/patient_tab_data/patient_protocol_model.dart';
import '../../../../../../em_module/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import '../../../../../../em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import '../../../../../../em_module/widgets/header_content_const.dart';


class UploadProtocolPopup extends StatefulWidget {
  final int ptId;
  final VoidCallback onRefresh; // ✅ required to post
  const UploadProtocolPopup({super.key, required this.ptId, required this.onRefresh});

  @override
  State<UploadProtocolPopup> createState() => _UploadProtocolPopupState();
}

class _UploadProtocolPopupState extends State<UploadProtocolPopup> {
  String displayFileName = "Choose file";
  String? pickedFileName;
  String? filePath;
  Uint8List? fileBytes;
  bool isFilePicked = false;
  TextEditingController fileNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  String? _fileError;
  String? _dropdownError;        // ✅ inline error for protocol type dropdown
  int? _selectedProtocolTypeId;  // ✅ store selected protocolTypeId
  bool _isSubmitting = false;    // ✅ loading state for submit button

  static const int _maxFileSizeBytes = 20 * 1024 * 1024; // 20 MB

  Future<void> pickAckFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;

    // ✅ Validate file size — reject files larger than 20 MB
    final int fileSize = picked.bytes?.length ?? 0;
    if (fileSize > _maxFileSizeBytes) {
      setState(() {
        _fileError = "File size exceeds 20MB. Please choose a smaller file.";
        isFilePicked = false;
        displayFileName = "Choose file";
        pickedFileName = null;
        filePath = null;
        fileBytes = null;
        fileNameController.clear();
      });
      return;
    }

    setState(() {
      displayFileName = picked.name;
      pickedFileName = picked.name;
      fileNameController.text = picked.name;
      _fileError = null;

      if (kIsWeb) {
        filePath = null;
        fileBytes = picked.bytes;
      } else {
        filePath = picked.path;
        fileBytes = picked.bytes;
      }

      isFilePicked = (fileBytes != null) || (!kIsWeb && filePath != null);
    });
  }

  // ✅ Submit handler with uploadPatientProtocolDocument API integrated
  Future<void> _handleSubmit() async {
    print("_handleSubmit called");
    print("isFilePicked: $isFilePicked | fileBytes: ${fileBytes != null} | _selectedProtocolTypeId: $_selectedProtocolTypeId");

    // Validate file
    if (!isFilePicked || fileBytes == null || _selectedProtocolTypeId == null) {
      print("Validation failed — missing file or protocol type");
      setState(() {
        _fileError = "Please select a file";
        _dropdownError = _selectedProtocolTypeId != null ? "" : "Please select a protocol type";
      });
      return;
    }

    setState(() => _isSubmitting = true);

    // ✅ Step 1: Post protocol entry
    print("Step 1: Posting protocol entry — ptId: ${widget.ptId}, protocolTypeId: $_selectedProtocolTypeId");
    final protocolResult = await postPatientProtocol(
      context: context,
      ptId: widget.ptId,
      protocolTypeId: _selectedProtocolTypeId!,
    );
    print("Step 1 result — success: ${protocolResult.success}, message: ${protocolResult.message}, statusCode: ${protocolResult.statusCode}, protocolId: ${protocolResult.protocolId}");

    if (!protocolResult.success) {
      print("Step 1 failed — aborting upload");
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddErrorPopup(message: 'Something went wrong!');
        },
      );
      return;
    }

    // ✅ Step 2: Upload the PDF document
    print("Step 2: Uploading PDF — protocolId: ${protocolResult.protocolId}, fileName: ${pickedFileName ?? 'protocol_document.pdf'}, fileBytes null: ${fileBytes == null}");
    final uploadResult = await uploadPatientProtocolDocument(
      context: context,
      protocolId: protocolResult.protocolId!,
      base64: fileBytes,
      documentName: pickedFileName ?? "protocol_document.pdf",
    );
    print("Step 2 result — success: ${uploadResult.success}, message: ${uploadResult.message}, statusCode: ${uploadResult.statusCode}");

    setState(() => _isSubmitting = false);

    if (uploadResult.success) {
      print("Upload successful — refreshing and closing");
      widget.onRefresh();
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddSuccessPopup(
            message: 'Protocol Uploaded Successfully',
          );
        },
      );
    } else {
      print("Upload failed — showing error popup");
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddErrorPopup(message: 'Something went wrong!');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s350,
      height: AppSize.s350,
      body: [
        Padding(
          padding:const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  pickAckFile();
                },
                child: FirstHRTextFConst(
                  controller: fileNameController,
                  keyboardType: TextInputType.text,
                  text: "Upload Logo File",
                  readOnly: true,
                  icon: Icon(
                    Icons.file_upload_outlined,
                    color: ColorManager.mediumgrey,
                    size: 17,
                  ),
                  onChange: () async {
                    await pickAckFile();
                  },
                ),
              ),
              // ✅ Show file size error below the file picker
              _fileError != null ?
                Padding(
                  padding: const EdgeInsets.only(left: 2.0,),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _fileError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ) :  SizedBox(height: 15,),
            ],
          ),
        ),

        SizedBox(height: AppSize.s10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: HeaderContentConst(
            isAsterisk: false,
            heading: "Select Protocol Type",
            content: FutureBuilder<List<PatientProtocolModule>>(
              future: getProtocolDropDown(context: context),
              builder: (context, snapshot) {
                final List<DropdownMenuItem<String>> dropdownItems =
                snapshot.hasData
                    ? snapshot.data!
                    .map((e) => DropdownMenuItem<String>(
                  value: e.typeName,
                  child: Text(e.typeName),
                ))
                    .toList()
                    : [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CICCDropdown(
                      borderRadius: 8,
                      initialValue: "Select Document",
                      onChange: (val) {
                        if (snapshot.hasData) {
                          final selected = snapshot.data!.firstWhere(
                                (e) => e.typeName == val,
                            orElse: () => snapshot.data!.first,
                          );
                          // ✅ save selected protocolTypeId and clear error
                          setState(() {
                            _selectedProtocolTypeId = selected.protocolTypeId;
                            _dropdownError = null;
                          });
                        }
                      },
                      items: dropdownItems,
                    ),
                    // ✅ Show dropdown error below, same style as file error
                    _dropdownError != null ?
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0,top: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _dropdownError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ) : SizedBox(height: 9,),
                  ],
                );
              },
            ),
          ),
        ),
      ],
      // ✅ Submit button with loading state
      bottomButtons: _isSubmitting
          ? Center(
        child: CircularProgressIndicator(
          color: ColorManager.blueprime,
        ),
      )
          : CustomElevatedButton(
        onPressed: _handleSubmit,
        text: "Submit",
      ),
      title: "Add Protocol",
    );
  }
}