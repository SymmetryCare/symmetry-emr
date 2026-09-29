import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/manage_insurance_manager/insurance_vendor_contract_manager.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/header_content_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';

class ContractAddDialog extends StatefulWidget {
  final String title;
  final int selectedVendorId;
  final String officeid;

  const ContractAddDialog({
    Key? key,
    required this.title,
    required this.selectedVendorId,
    required this.officeid,
  }) : super(key: key);

  @override
  State<ContractAddDialog> createState() => _ContractAddDialogState();
}

class _ContractAddDialogState extends State<ContractAddDialog> {
  TextEditingController birthdayController = TextEditingController();

  TextEditingController contractNmaeController = TextEditingController();
  TextEditingController contractIdController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  bool loading = false;
  bool _isFormValid = true;
  String selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
  bool _validateOnSave = false;
  String? _idDocError;
  String? _nameDocError;
  String? _expiryDateError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  bool isDropdownAvailability = false;
  bool showExpiryDateField = false;

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please enter $fieldName.";
    }
    return null;
  }

  DateTime? datePicked;
  void _validateForm() {
    setState(() {
      if (!_validateOnSave) return;
      _isFormValid = true;
      _idDocError = _validateTextField(contractIdController.text, 'ID of the contract');
      _nameDocError = _validateTextField(contractNmaeController.text, 'name of the contract');
      if (selectedExpiryType == FrontendConfigStore.data!.config.issuer && expiryDateController.text.isEmpty) {
        _expiryDateError = 'Please select an expiry date.';
        _isFormValid = false;
      } else {
        _expiryDateError = null; // Clear error if the date is selected
      }
    });
  }
  static const double _kDesignWidth = 855;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return DialogueTemplate(

      width: AppSize.s420,
      height: selectedExpiryType == FrontendConfigStore.data!.config.issuer ? AppSize.s500 : AppSize.s430,
      body: [
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             SMTextfieldAsteric(
               controller: contractNmaeController,
               keyboardType: TextInputType.text,
               text: AppStringEM.contractName,
               onChanged: (value){
                 setState(() {
                   _isFormValid = true;
                   _nameDocError = _validateTextField(contractNmaeController.text, 'Name of the Contract');
                 });
               },
             ),
             _nameDocError != null ?// Display error if any
               Padding(
                 padding: const EdgeInsets.only(top: AppPadding.p2),
                 child: Text(
                   _nameDocError!,
                   style: CommonErrorMsg.customTextStyle(context),
                 ),
               ): const SizedBox(height: AppSize.s12,),

             const SizedBox(height: AppSize.s10),
             SMTextfieldAsteric(
               controller: contractIdController,
               keyboardType: TextInputType.text,
               text: AppStringEM.contractId,
                 onChanged:  (value){
                 setState(() {
                   _isFormValid = true;
                   _idDocError = _validateTextField(contractIdController.text, 'ID of the Contract');
                 });
               },
             ),
             _idDocError != null ?
               Padding(
                 padding: const EdgeInsets.only(top: AppPadding.p2),
                 child: Text(
                   _idDocError!,
                   style: CommonErrorMsg.customTextStyle(context),
                 ),
               ): const SizedBox(height: AppSize.s12,),

             const SizedBox(height: AppSize.s10),
             Row(
               children: [
                 HeaderContentConst(
                   isAsterisk: true,
                   heading: AppString.expiry_type,
                   content: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [

                       CustomRadioListTile(
                         value: FrontendConfigStore.data!.config.scheduled,
                         groupValue: selectedExpiryType,
                         onChanged: (value) {
                           setState(() {
                             selectedExpiryType = value!;
                             _validateForm();
                           });
                         },
                         title: FrontendConfigStore.data!.config.scheduled,
                       ),
                       CustomRadioListTile(
                         value: FrontendConfigStore.data!.config.issuer,
                         groupValue: selectedExpiryType,
                         onChanged: (value) {
                           setState(() {
                             selectedExpiryType = value!;
                             if (_validateOnSave) _validateForm();
                           });
                         },
                         title: FrontendConfigStore.data!.config.issuer,
                       ),
                     ],
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(
                       left: AppPadding.p20,
                       right: AppPadding.p20,
                       bottom: AppPadding.p10
                   ),
                   child: Visibility(
                     visible: selectedExpiryType == FrontendConfigStore.data!.config.scheduled,
                     child: Row(
                       children: [
                         Container(
                           height: AppSize.s30,
                           width: AppSize.s50,
                           child: TextFormField(
                             textAlign: TextAlign.center,
                             controller: daysController, // Use the controller initialized with "1"
                             cursorColor: ColorManager.black,
                             cursorWidth: 1,
                             style:  DocumentTypeDataStyle.customTextStyle(context),
                             decoration: InputDecoration(
                               enabledBorder: OutlineInputBorder(
                                 borderSide: const BorderSide(
                                     color: Colors.grey),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               focusedBorder: OutlineInputBorder(
                                 borderSide: const BorderSide(
                                     color: Colors.grey),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               contentPadding:
                               const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                             ),
                             keyboardType: TextInputType.number,
                             inputFormatters: [
                               FilteringTextInputFormatter
                                   .digitsOnly, // This ensures only digits are accepted
                             ],
                           ),
                         ),
                         const SizedBox(width: AppSize.s10),
                         Container(
                           width: AppSize.s80,
                           height: AppSize.s30,
                           child:CustomDropdownTextFieldwidh(
                             value: FrontendConfigStore.data!.config.year,
                             items: [
                               FrontendConfigStore.data!.config.year,
                               FrontendConfigStore.data!.config.month,
                             ],
                             onChanged: (value) {
                               selectedYear = value;
                               isDropdownAvailability = true;
                               print("Year,month Status :: ${selectedYear}");
                             },
                           ),
                         )
                       ],
                     ),
                   ),
                 ),
               ],
             ),
             Visibility(
               visible: selectedExpiryType == FrontendConfigStore.data!.config.issuer,
               /// Conditionally display expiry date field
               child: HeaderContentConst(
                 isAsterisk: true,
                 heading: AppString.expiry_date,
                 content: FormField<String>(
                   builder: (FormFieldState<String> field) {
                     return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           height: 30,
                           child: TextFormField(
                             controller: expiryDateController,
                             cursorColor: ColorManager.black,
                             style: DocumentTypeDataStyle.customTextStyle(context),
                             decoration: InputDecoration(
                               enabledBorder: OutlineInputBorder(
                                 borderSide: BorderSide(
                                     color: ColorManager.fmediumgrey, width: 1),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               focusedBorder: OutlineInputBorder(
                                 borderSide: BorderSide(
                                     color: ColorManager.fmediumgrey, width: 1),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               hintText: 'yyyy-mm-dd',
                               hintStyle: DocumentTypeDataStyle.customTextStyle(context),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(8),
                                 borderSide: BorderSide(
                                     width: 1, color: ColorManager.fmediumgrey),
                               ),
                               contentPadding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
                               suffixIcon: Icon(Icons.calendar_month_outlined,
                                   color: ColorManager.blueprime),
                             ),
                             onTap: () async {
                               DateTime? pickedDate = await showDatePicker(
                                 context: context,
                                 initialDate: datePicked,
                                 firstDate: DateTime(1901),
                                 lastDate: DateTime(3101),
                               );
                               if (pickedDate != null) {
                                 datePicked = pickedDate;
                                 expiryDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                                 setState(() {
                                   _expiryDateError = null;
                                 });
                               }
                             },
                           ),
                         ),
                        _expiryDateError != null ?// Display the error message if it's not null
                           Padding(
                             padding: const EdgeInsets.only(top: 2.0),
                             child: Text(
                               _expiryDateError!,
                               style: CommonErrorMsg.customTextStyle(context),
                             ),
                           ) : const SizedBox(height: AppSize.s12,),
                       ],
                     );
                   },
                 ),
               ),
             ),
           ],
         ),
       )
      ],
      bottomButtons: CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              isLoading: loading,
              onPressed: () async {
                setState(() {
                  _validateOnSave = true; // Enable validation only when Save is clicked
                });
                _validateForm(); // Validate the form on button press
                if (_isFormValid) {
                  setState(() {
                    loading = true;
                  });
                  int threshold = 0;
                  if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
                      daysController.text.isNotEmpty) {
                    int enteredValue = int.parse(daysController.text);
                    if (selectedYear == FrontendConfigStore.data!.config.year) {
                      threshold = enteredValue * 365;
                    } else if (selectedYear == FrontendConfigStore.data!.config.month) {
                      threshold = enteredValue * 30;
                    }
                  }
                  try {
                    String? expiryDate;
                    expiryDate = expiryDateController == FrontendConfigStore.data!.config.issuer
                        ? datePicked!.toIso8601String() + "Z"
                        : null;
                    var response = await addVendorContract(
                        context,
                        widget.selectedVendorId,
                        contractNmaeController.text,
                        selectedExpiryType!.toString(),
                        threshold,
                        widget.officeid,
                        contractIdController.text,
                        expiryDateController.text);
                    if(response.statusCode == 200 || response.statusCode == 201) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddSuccessPopup(
                            message: 'Added Successfully',
                          );
                        },
                      );
                    }
                    else if(response.statusCode == 400 || response.statusCode == 404){
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => const FourNotFourPopup(),
                      );
                    }
                    else {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => FailedPopup(text: response.message),
                      );
                    }
                  } finally {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              }),
      title: widget.title,
    );
  }
}
