import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/header_content_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/register/taxtfield_constant.dart';

class AddAlertSubPopup extends StatefulWidget {
  const AddAlertSubPopup({super.key});

  @override
  State<AddAlertSubPopup> createState() => _AddAlertSubPopupState();
}

class _AddAlertSubPopupState extends State<AddAlertSubPopup> {
  TextEditingController fileNameController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  String? startTimeError;
  String? endTimeError;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String displayFileName = "Choose file";
  String? pickedFileName;
  String? filePath;
  Uint8List? fileBytes;
  bool isFilePicked = false;

  bool _attemptedVisit = false;

  String? _fileError;
  Future<void> pickAckFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;

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
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        startTimeController.text = _selectedTime.format(context);
        startTimeError = null; // Hide error when valid time is selected
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        endTimeController.text = _selectedTime.format(context);
        endTimeError = null; // Hide error when valid time is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s700,
      height: AppSize.s420,
      title: "Reschedule",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: HeaderContentConst(
                      isAsterisk: false,
                      heading: "Select Alert Type",
                      content: CICCDropdown(
                        borderRadius: 8,
                        initialValue: "Select Alert Type",
                        onChange: (val) {},
                        items: ['Safety', 'Medication', 'Infection Control', 'Vitals', 'Social', 'Legal', 'Nutrition']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSize.s30),
                  Expanded(
                    child: HeaderContentConst(
                      isAsterisk: false,
                      heading: "Add Alert",
                      content: CICCDropdown(
                        borderRadius: 8,
                        initialValue: "Add Alert",
                        onChange: (val) {},
                        items: ['High', 'Medium', 'Low']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: SMTextfieldAsteric(
                      onChanged: (value){
                        setState(() {
                          if (value.isNotEmpty) {
                            startTimeError = null; // Hide error when valid input
                          }
                        });
                      },
                      onChange: () => _selectStartTime(context),
                      controller: startTimeController,
                      keyboardType: TextInputType.text,
                      text: AddPopupString.startTime,
                      icon: Icon(Icons.timer_outlined, color: ColorManager.blueprime, size: IconSize.I18,),
                    ),
                  ),
                  const SizedBox(width: AppSize.s30),
                  Expanded(
                    child: SMTextfieldAsteric(
                      onChanged: (value){
                        setState(() {
                          if (value.isNotEmpty) {
                            endTimeError = null; // Hide error when valid input
                          }
                        });
                      },
                      onChange: () => _selectEndTime(context),
                      controller: endTimeController,
                      keyboardType: TextInputType.text,
                      text: AddPopupString.endTime,
                      icon: Icon(Icons.timer_outlined, color: ColorManager.blueprime, size: IconSize.I18,),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Checkbox(
                    value: _attemptedVisit,
                    onChanged: (val) => setState(() => _attemptedVisit = val ?? false),
                    activeColor: ColorManager.blueprime,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    "Attempted Visit",
                    style: TextStyle(fontSize: FontSize.s12, color: ColorManager.darkgrey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        pickAckFile();
                      },
                      child: FirstHRTextFConst(
                        controller: fileNameController,
                        keyboardType: TextInputType.text,
                        text: "Upload Photo",
                        readOnly: true,  // ✅ so user cannot type
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
                  ),
                  const Expanded(child: SizedBox())
                ],
              ),
            ],
          ),
        )


      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          CustomElevatedButton(
            onPressed: () => Navigator.pop(context),
            text: "Submit",
          ),
          const SizedBox(width: 40,),
        ],
      ),
    );
  }
}