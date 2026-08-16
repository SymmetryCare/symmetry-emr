import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/establishment_resources/establishment_string_manager.dart';
import '../../../../../../em_module/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import '../../../../../../em_module/widgets/header_content_const.dart';
import '../../../../../../em_module/widgets/text_form_field_const.dart';
import '../../../../../../hr_module/register/taxtfield_constant.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0,horizontal: 240),
      child: DialogueTemplate(
        width: double.infinity,
        height: double.infinity,
        title: "Reschedule",
        body: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HeaderContentConst(
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
                    const SizedBox(width: AppSize.s30),
                    HeaderContentConst(
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
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    SMTextfieldAsteric(
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
                    const SizedBox(width: AppSize.s30),
                    SMTextfieldAsteric(
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
                  ],
                ),
                SizedBox(height: 10,),
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
                SizedBox(height: 10,),
                InkWell(
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
            SizedBox(width: 40,),
          ],
        ),
      ),
    );
  }
}