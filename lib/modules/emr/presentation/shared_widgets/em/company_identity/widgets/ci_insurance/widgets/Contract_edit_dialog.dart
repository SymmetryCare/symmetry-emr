import 'package:flutter/material.dart';
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
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/header_content_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';

class ContractEditDialog extends StatefulWidget {
  final String title;
  final int insuranceVendorContracId;
  final int selectedVendorId;
  final String contractName;
  final String contractId;
  final String? expiryType;
  final int? threshhold;
  final String officeid;
  final String? expiryDate;

  const ContractEditDialog({
    Key? key,
    required this.title,
    required this.selectedVendorId,
    required this.officeid,
    required this.contractName,
    required this.contractId,
    this.expiryType,
    this.threshhold,
    this.expiryDate, required this.insuranceVendorContracId,
  }) : super(key: key);

  @override
  State<ContractEditDialog> createState() => _ContractEditDialogState();
}

class _ContractEditDialogState extends State<ContractEditDialog> {
  TextEditingController birthdayController = TextEditingController();

  TextEditingController nameDocController = TextEditingController();
  TextEditingController idDocController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  bool loading = false;
  bool _isFormValid = true;
  String selectedExpiryType = "";
  String? _nameDocError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  bool showExpiryDateField = false;

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please enter $fieldName.";
    }
    return null;
  }
  void _validateForm() {
    setState(() {
      _isFormValid = true;
      _nameDocError = _validateTextField(nameDocController.text, 'name of the document');
    });
  }
  @override
  void initState() {
    super.initState();
    expiryDateController.text = widget.expiryDate!;
    nameDocController.text = widget.contractName;
    if (widget.expiryType == FrontendConfigStore.data!.config.scheduled) {
      selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
    } else if (widget.expiryType == FrontendConfigStore.data!.config.notApplicable) {
      selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
    } else if (widget.expiryType == FrontendConfigStore.data!.config.issuer) {
      selectedExpiryType = FrontendConfigStore.data!.config.issuer;
    }

    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
        widget.threshhold != null) {
      int threshold = widget.threshhold!;

      if (threshold >= 365) {
        daysController.text = (threshold ~/ 365).toString(); // Set years
        selectedYear = FrontendConfigStore.data!.config.year;
      } else {
        daysController.text = (threshold ~/ 30).toString(); // Set months
        selectedYear = FrontendConfigStore.data!.config.month;
      }
    }
  }

  DateTime? datePicked;
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
      height: AppSize.s330,
      body: [
        HeaderContentConst(
          heading: AppString.id_of_the_document,
          content: Container(
            height: AppSize.s30,
            width: AppSize.s354,
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p5, horizontal: AppPadding.p12),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorManager.fmediumgrey, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.contractId,
                  style: DocumentTypeDataStyle.customTextStyle(context)
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSize.s20,),
        /// Name of the Document
        SMTextfieldAsteric(
          controller: nameDocController,
          keyboardType: TextInputType.text,
          text: AppString.name_of_the_document,
          onChanged: (value) {
            setState(() {
              _nameDocError = null;
            });
          },
        ),
        _nameDocError != null ?
          Padding(
            padding: const EdgeInsets.only(left: AppPadding.p12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameDocError!,
                  style: CommonErrorMsg.customTextStyle(context),
                ),
              ],
            ),
          ): const SizedBox(height: AppSize.s12,),
      ],
      bottomButtons: CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              isLoading: loading,
              onPressed: () async {
                _validateForm(); // Validate the form on button press
                if (_isFormValid) {
                  setState(() {
                    loading = true;
                  });
                  int threshold = 0;
                  String? expiryDateToSend = "";
                  if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
                      daysController.text.isNotEmpty) {
                    int enteredValue = int.parse(daysController.text);
                    if (selectedYear == FrontendConfigStore.data!.config.year) {
                      threshold = enteredValue * 365;
                    } else if (selectedYear == FrontendConfigStore.data!.config.month) {
                      threshold = enteredValue * 30;
                    }
                    expiryDateToSend = daysController.text;
                  } else if (selectedExpiryType == FrontendConfigStore.data!.config.notApplicable ||
                      selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
                    threshold = 0;
                    expiryDateToSend = null;
                  }
                  try {
                    ///docname
                    String contractName;
                    if (nameDocController.text.isNotEmpty && nameDocController.text != widget.contractName) {
                      contractName = nameDocController.text;
                    } else {
                      contractName = widget.contractName;
                    }
                   var response = await patchCompanyContract(context,
                        widget.insuranceVendorContracId,
                        widget.selectedVendorId,
                        threshold,
                        widget.officeid,
                        contractName,
                        selectedExpiryType == selectedExpiryType.toString() ? selectedExpiryType.toString(): widget.expiryType!,
                        widget.contractId,
                       expiryDateController.text );
                    if(response.statusCode == 200 || response.statusCode == 201){
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddSuccessPopup(message:'Added Successfully');
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
                    nameDocController.clear();
                    idDocController.clear();
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
