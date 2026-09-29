import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/header_content_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/new_org_doc/new_org_doc.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/constant_textfield/const_textfield.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';

///Add new popup

class AddNewOrgDocButtonProvider extends ChangeNotifier {
  String _selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
  TextEditingController idDocController = TextEditingController();
  TextEditingController nameDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");
  bool loading = false;
  bool _isFormValid = true;
  String? _idDocError;
  String? _nameDocError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  bool isDropdownAvailability = false;
  String get selectedExpiryType => _selectedExpiryType;

  AddNewOrgDocButtonProvider({required int docTypeId, required int subDocTypeId}) {
    debugPrint("Initializing Provider with docTypeId: $docTypeId, subDocTypeId: $subDocTypeId");

    // Set selectedExpiryType based on conditions
    if (docTypeId ==  FrontendConfigStore.data!.config.vendorContracts && subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC) {
      _selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
      debugPrint("Setting expiry type to: Scheduled");
    } else {
      _selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
      debugPrint("Setting expiry type to: Not Applicable");
    }
    notifyListeners();
  }

  void setSelectedExpiryType(String value) {
    if (_selectedExpiryType != value) {
      _selectedExpiryType = value;
      notifyListeners(); // Ensure UI updates
    }
  }

  void validateForm() {
    _isFormValid = true;
    _idDocError = _validateTextField(idDocController.text, 'ID of the document');
    _nameDocError = _validateTextField(nameDocController.text, 'name of the document');
    notifyListeners();
  }

  String? _validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      _isFormValid = false;
      return "Please enter $fieldName.";
    }
    return null;
  }

  void setupTextFieldListeners() {
    idDocController.addListener(() {
      if (idDocController.text.isNotEmpty) {
        _idDocError = null;
        notifyListeners();
      }
    });

    nameDocController.addListener(() {
      if (nameDocController.text.isNotEmpty) {
        _nameDocError = null;
        notifyListeners();
      }
    });
  }
}

class AddNewOrgDocButton extends StatelessWidget {
  final double? height;
  final String docTypeText;
  final int docTypeId;
  final int subDocTypeId;
  final String subDocTypeText;
  final String title;
  final String? selectedSubDocType;
  // FIX: added so callers can be notified after a successful add and
  // refetch their list (e.g. CiOrgDocumentProvider.notifyDocumentSaved()).
  final VoidCallback? onSave;
  const AddNewOrgDocButton({super.key, this.height, required this.docTypeText, required this.docTypeId, required this.subDocTypeId, required this.subDocTypeText, required this.title, this.selectedSubDocType, this.onSave});
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
    return Consumer<AddNewOrgDocButtonProvider>(
      builder: (context, provider, child) {
        return DialogueTemplate(
          width: AppSize.s420,
          height: subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC
              ? height ?? AppSize.s530
              : docTypeId == FrontendConfigStore.data!.config.policiesAndProcedure
              ? height ??AppSize.s540
              : height ??AppSize.s610,
          body: [ Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// ID of the Document
                SMTextfieldAsteric(
                  controller: provider.idDocController,
                  keyboardType: TextInputType.text,
                  text: AppString.id_of_the_document,
                  onChange: (){provider.setupTextFieldListeners();},
                ),
                provider._idDocError != null ? // Display error if any
                Text(
                  provider._idDocError!,
                  style:CommonErrorMsg.customTextStyle(context),
                ) : const SizedBox(height: AppSize.s12,),
                const SizedBox(height: AppSize.s3,),
                /// Name of the Document
                SMTextfieldAsteric(
                  controller: provider.nameDocController,
                  keyboardType: TextInputType.text,
                  text: AppString.name_of_the_document,
                  onChange: (){provider.setupTextFieldListeners();},
                ),
                provider._nameDocError != null ? // Display error if any
                Text(
                  provider. _nameDocError!,
                  style:CommonErrorMsg.customTextStyle(context),
                ) :const SizedBox(height: AppSize.s12,),
                const SizedBox(height: AppSize.s3,),
                /// Type of the Document
                HeaderContentConst(
                  heading: AppString.type_of_the_document,
                  content: Container(
                    width: AppSize.s354,
                    height: AppSize.s30,
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          docTypeText,
                          style: TableSubHeading.customTextStyle(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s10,),
                /// Sub Type of the Document
                docTypeId == FrontendConfigStore.data!.config.policiesAndProcedure
                    ? const SizedBox(
                  height: 1,
                )
                    : Column(
                  children: [
                    HeaderContentConst(
                      heading: AppString.sub_type_of_the_document,
                      content: Container(
                        width: AppSize.s354,
                        height: AppSize.s30,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: ColorManager.fmediumgrey, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subDocTypeText,
                              style: TableSubHeading.customTextStyle(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.s10,),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      HeaderContentConst(
                          isAsterisk: true,
                          heading: AppString.expiry_type,
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC
                                  ? const Offstage()
                                  : Row(
                                children: [
                                  Radio<String>(
                                    splashRadius: 0,
                                    activeColor: ColorManager.blueprime,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    value: FrontendConfigStore.data!.config.notApplicable,
                                    groupValue: provider.selectedExpiryType,
                                    onChanged: (String? value) {
                                      provider.setSelectedExpiryType(value!);
                                    },
                                  ),
                                  Text("Not Applicable",
                                      style: DocumentTypeDataStyle.customTextStyle(context)),
                                ],
                              ),

                              // Scheduled
                              Row(
                                children: [
                                  Radio<String>(
                                    splashRadius: 0,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    activeColor: ColorManager.blueprime,
                                    value: FrontendConfigStore.data!.config.scheduled,
                                    groupValue: provider.selectedExpiryType,
                                    onChanged: (String? value) {
                                      provider.setSelectedExpiryType(value!);
                                    },
                                  ),
                                  Text("Scheduled",
                                      style: DocumentTypeDataStyle.customTextStyle(context)),
                                ],
                              ),

                              subDocTypeId == FrontendConfigStore.data!.config.subDocId10MISC
                                  ? const Offstage()
                                  : Row(
                                children: [
                                  Radio<String>(
                                    splashRadius: 0,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    activeColor: ColorManager.blueprime,
                                    value: FrontendConfigStore.data!.config.issuer,
                                    groupValue: provider.selectedExpiryType,
                                    onChanged: (String? value) {
                                      provider.setSelectedExpiryType(value!);
                                    },
                                  ),
                                  Text("Issuer",
                                      style: DocumentTypeDataStyle.customTextStyle(context)),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppPadding.p20,
                          right: AppPadding.p20,
                        ),
                        child: Visibility(
                          visible: provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled,
                          child: Column(
                            children: [
                              const SizedBox(height: AppSize.s20,),
                              Row(
                                children: [
                                  Container(
                                    width: AppSize.s50,
                                    height: AppSize.s30,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      controller: provider.daysController, // Use the controller initialized with "1"
                                      cursorColor: ColorManager.black,
                                      cursorWidth: 1,
                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly, // This ensures only digits are accepted
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.s10,),
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
                                        provider.selectedYear = value;
                                        provider.isDropdownAvailability = true;
                                        provider.notifyListeners();
                                        print("Year,month Status :: ${provider.selectedYear}");
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          ],
          bottomButtons: CustomElevatedButton(
            width: AppSize.s105,
            height: AppSize.s30,
            text: AppStringEM.add,
            isLoading: provider.loading == true,
            onPressed: () async {
              provider.validateForm();
              if (provider._isFormValid) {
                provider.loading = true;
                int threshold = 0;
                if (provider.selectedExpiryType == FrontendConfigStore.data!.config.scheduled &&
                    provider.daysController.text.isNotEmpty) {
                  int enteredValue = int.parse(provider.daysController.text);
                  if (provider.selectedYear == FrontendConfigStore.data!.config.year) {
                    threshold = enteredValue * 365;
                  } else if (provider.selectedYear == FrontendConfigStore.data!.config.month) {
                    threshold = enteredValue * 30;
                  }
                }
                try {
                  var response =  await addNewOrgDocumentPost(
                      context: context,
                      docName: provider.nameDocController.text,
                      docTypeID: docTypeId,
                      docSubTypeID: subDocTypeId,
                      threshold: threshold,
                      expiryType: provider.selectedExpiryType.toString(),
                      expiryDate: null, //expiryTypeToSend,
                      expiryReminder: provider.selectedExpiryType.toString(),
                      idOfDoc: provider.idDocController.text);
                  if(response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context);
                    // FIX: notify the caller a document was successfully added
                    // so it can refetch its list.
                    onSave?.call();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddSuccessPopup(
                          message: 'Added Successfully.',
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
                  provider.loading = false;
                  provider.notifyListeners();
                }
              }
            },
          ),
          title: title,
        );
      },
    );
  }
}

///edit
class OrgDocNewEditPopupProvider extends ChangeNotifier {
  bool isFormValid = true;
  String selectedExpiryType = "";
  bool loading = false;
  TextEditingController idDocController = TextEditingController();
  TextEditingController nameDocController = TextEditingController();
  TextEditingController daysController = TextEditingController(text: "1");

  String? nameDocError;
  String? selectedYear = FrontendConfigStore.data!.config.year;
  OrgDocNewEditPopupProvider() {
    // Adding listeners to the text fields to clear error dynamically.
    nameDocController.addListener(() {
      if (nameDocError != null && nameDocController.text.isNotEmpty) {
        nameDocError = null;  // Clear error when user starts typing.
        notifyListeners();
      }
    });
  }

  void initialize({
    required String docName,
    String? expiryType,
    int? threshold,
  }) {
    nameDocController.text = docName;
    if (expiryType == FrontendConfigStore.data!.config.scheduled) {
      selectedExpiryType = FrontendConfigStore.data!.config.scheduled;
    } else if (expiryType == FrontendConfigStore.data!.config.notApplicable) {
      selectedExpiryType = FrontendConfigStore.data!.config.notApplicable;
    } else if (expiryType == FrontendConfigStore.data!.config.issuer) {
      selectedExpiryType = FrontendConfigStore.data!.config.issuer;
    }

    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled && threshold != null) {
      if (threshold >= 365) {
        daysController.text = (threshold ~/ 365).toString(); // Set years
        selectedYear = FrontendConfigStore.data!.config.year;
      } else {
        daysController.text = (threshold ~/ 30).toString(); // Set months
        selectedYear = FrontendConfigStore.data!.config.month;
      }
    }
  }

  void validateForm() {
    isFormValid = true;
    nameDocError = validateTextField(nameDocController.text, 'name of the document');
    notifyListeners();
  }

  String? validateTextField(String value, String fieldName) {
    if (value.isEmpty) {
      isFormValid = false;
      return "Please enter $fieldName.";
    }
    return null;
  }

  void updateSelectedExpiryType(String value) {
    selectedExpiryType = value;
    notifyListeners();
  }

  Future<void> saveDocument({
    required BuildContext context,
    required int orgDocumentSetupid,
    required int docTypeID,
    required int docSubTypeID,
    required String docName,
    required String expiryReminder,
    required String idOfDoc,
    String? expiryType,
    // FIX: added so the caller can be notified after a successful edit and
    // refetch its list.
    VoidCallback? onSave,
  }) async {
    validateForm();
    if (!isFormValid) return;

    loading = true;
    notifyListeners();

    int threshold = 0;
    String? expiryDateToSend = "";
    if (selectedExpiryType == FrontendConfigStore.data!.config.scheduled && daysController.text.isNotEmpty) {
      int enteredValue = int.parse(daysController.text);
      if (selectedYear == FrontendConfigStore.data!.config.year) {
        threshold = enteredValue * 365;
      } else if (selectedYear == FrontendConfigStore.data!.config.month) {
        threshold = enteredValue * 30;
      }
      expiryDateToSend = daysController.text;
    } else if (selectedExpiryType == FrontendConfigStore.data!.config.notApplicable || selectedExpiryType == FrontendConfigStore.data!.config.issuer) {
      threshold = 0;
      expiryDateToSend = null;
    }

    try {
      String finalDocName = nameDocController.text.isNotEmpty
          ? nameDocController.text
          : docName;

      var response = await updateNewOrgDocumentPatch(
        context: context,
        orgDocumentSetupid: orgDocumentSetupid,
        docTypeID: docTypeID,
        docSubTypeID: docSubTypeID,
        docName: finalDocName,
        expiryType: selectedExpiryType,
        threshold: threshold,
        expiryDate: null,
        expiryReminder: expiryReminder,
        idOfDoc: idOfDoc,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        // FIX: notify the caller a document was successfully edited so it
        // can refetch its list.
        onSave?.call();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AddSuccessPopup(
              message: 'Edited Successfully.',
            );
          },
        );
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) => const FourNotFourPopup(),
        );
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) => FailedPopup(text: response.message),
        );
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class OrgDocNewEditPopup extends StatelessWidget {
  final double? height;
  final String docTypeText;
  final int docTypeId;
  final int subDocTypeId;
  final String subDocTypeText;
  final String title;
  final String? selectedSubDocType;
  final int orgDocumentSetupid;
  final String docName;
  final String? expiryType;
  final int? threshhold;
  final String? expiryDate;
  final String expiryReminder;
  final String idOfDoc;
  // FIX: added so callers (the 5 vendor-contract sub-tab providers, etc.)
  // can be notified after a successful edit and refetch their list.
  final VoidCallback? onSave;

  const OrgDocNewEditPopup({
    super.key,
    required this.title,
    this.height,
    this.selectedSubDocType,
    required this.docTypeText,
    required this.docTypeId,
    required this.subDocTypeId,
    required this.subDocTypeText,
    required this.orgDocumentSetupid,
    required this.docName,
    this.expiryType,
    this.threshhold,
    this.expiryDate,
    required this.expiryReminder,
    required this.idOfDoc,
    this.onSave,
  });
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
    return ChangeNotifierProvider(
      create: (_) {
        final provider = OrgDocNewEditPopupProvider();
        provider.initialize(
          docName: docName,
          expiryType: expiryType,
          threshold: threshhold,
        );
        return provider;
      },
      child: Consumer<OrgDocNewEditPopupProvider>(
        builder: (context, provider, _) {
          return DialogueTemplate(
            width: AppSize.s420,
            height: height ?? AppSize.s450,
            body: [
              /// ID of the Document
              HeaderContentConst(
                heading: AppString.id_of_the_document,
                content: Container(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        idOfDoc,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSize.s12,),
              /// Name of the Document
              SMTextfieldAsteric(
                controller: provider.nameDocController,
                keyboardType: TextInputType.text,
                text: AppString.name_of_the_document,
              ),
              provider.nameDocError != null ? // Display error if any
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.p15),
                    child: Text(
                        provider.nameDocError!,
                        style: CommonErrorMsg.customTextStyle(context)
                    ),
                  ),
                ],
              ) : const SizedBox(height: AppSize.s12,),

              /// Type of the Document
              HeaderContentConst(
                heading: AppString.type_of_the_document,
                content: Container(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        docTypeText,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSize.s12,),

              /// Sub Type of the Document
              docTypeId ==FrontendConfigStore.data!.config.policiesAndProcedure
                  ? const SizedBox(height: 1)
                  : HeaderContentConst(
                heading: AppString.sub_type_of_the_document,
                content: Container(
                  width: AppSize.s354,
                  height: AppSize.s30,
                  padding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: ColorManager.fmediumgrey, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subDocTypeText,
                        style: TableSubHeading.customTextStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottomButtons: CustomElevatedButton(
              width: AppSize.s105,
              height: AppSize.s30,
              text: AppStringEM.save,
              isLoading: provider.loading,
              onPressed: () => provider.saveDocument(
                context: context,
                orgDocumentSetupid: orgDocumentSetupid,
                docTypeID: docTypeId,
                docSubTypeID: subDocTypeId,
                docName: docName,
                expiryReminder: expiryReminder,
                idOfDoc: idOfDoc,
                expiryType: expiryType,
                // FIX: thread the widget's onSave down into the actual
                // save call so it fires after a real 200/201 response.
                onSave: onSave,
              ),
            ), title: title,
          );
        },
      ),
    );
  }
}