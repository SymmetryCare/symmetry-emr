///zone widget const
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
// removed in extraction: import 'package:prohealth/app/services/api/managers/establishment_manager/pay_rates_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/zone_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/pay_rates/pay_rates_finance_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/zone/zone_model_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/failed_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/four_not_four_popup.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/company_identity_zone/widgets/location_screen.dart';
///add county
class CIZoneAddPopup extends StatefulWidget {
  final TextEditingController countynameController;
  final TextEditingController? zipcodeController;
  final TextEditingController? mapController;
  final TextEditingController? landmarkController;
  final TextEditingController? zoneController;
  final TextEditingController? cityController;
  final TextEditingController? countryController;
  final TextEditingController? stateController;
  final Future<void> Function() onSavePressed;
  final String buttonTitle;
  final String title1;
  final String? title2;
  final String? title3;
  final String? title4;
  final String? title5;
  final String? title6;
  final String title;

  const CIZoneAddPopup({
    Key? key,
    required this.onSavePressed,
    required this.title1,
    this.title2,
    this.title3,
    this.title4,
    this.title5,
    this.title6,
    required this.countynameController,
    this.zipcodeController,
    this.mapController,
    this.landmarkController,
    this.zoneController,
    this.cityController,
    this.countryController,
    this.stateController,
    required this.title,
    required this.buttonTitle,
  }) : super(key: key);

  @override
  State<CIZoneAddPopup> createState() => _CIZoneAddPopupState();
}

class _CIZoneAddPopupState extends State<CIZoneAddPopup> {
  bool isLoading = false;
  String? countyNameError;
  String? zipcodeError;
  String? mapError;
  String? landmarkError;
  bool validateFields() {
    bool isValid = true;

    setState(() {
      countyNameError = widget.countynameController.text.isEmpty
          ? 'County field cannot be empty.'
          : null;
      isValid = countyNameError == null;
    });
    return isValid;
  }
  @override
  void initState() {
    super.initState();
    widget.countynameController.addListener(() {
      if (widget.countynameController.text.isNotEmpty && countyNameError != null) {
        setState(() {
          countyNameError = null;
        });
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
      title: widget.title,
      width: AppSize.s407,
      height: AppSize.s260,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                controller: widget.countynameController,
                keyboardType: TextInputType.text,
                text: widget.title1,
              ),
              countyNameError != null ?
              Text(
                countyNameError!,
                textAlign: TextAlign.start,
                style: CommonErrorMsg.customTextStyle(context),
              ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s10),
              if (widget.title2 != null) ...[
                SMTextfieldAsteric(
                  inputFormated: [UpperCaseTextFormatter()],
                  controller: widget.zipcodeController!,
                  keyboardType: TextInputType.text,
                  text: widget.title2!,
                ),
                if (zipcodeError != null)
                  Text(
                    zipcodeError!,
                    textAlign: TextAlign.start,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
              ],
              if (widget.title3 != null) ...[
                const SizedBox(height: AppSize.s20),
                SMTextfieldAsteric(
                  controller: widget.mapController!,
                  keyboardType: TextInputType.text,
                  text: widget.title3!,
                ),
                if (mapError != null)
                  Text(
                    mapError!,
                    textAlign: TextAlign.start,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
              ],
            ],
          ),
        ),
      ],
      bottomButtons: CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: widget.buttonTitle,
        isLoading: isLoading,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            await widget.onSavePressed();
            setState(() {
              isLoading = false;
            });
          }
        },
      ),
    );
  }
}

///add zipcode
class AddZipCodePopup extends StatefulWidget {
  final int countyId;
  final int zoneId;
  final String title;
  final String officeId;
  final double officeLat;
  final double officeLong;
  final TextEditingController countynameController;
  final TextEditingController zipcodeController;
  final TextEditingController mapController;
  final Widget? locationText;
  final TextEditingController? locationController;
  final Future<void> Function() onSavePressed;
  final VoidCallback? onPickLocation;
  const AddZipCodePopup({
    super.key,
    required this.title,
    required this.countynameController,
    required this.zipcodeController,
    required this.mapController,
    required this.onSavePressed,
    this.onPickLocation,
    this.locationText,
    this.locationController, required this.officeId, required this.officeLat, required this.officeLong, required this.countyId, required this.zoneId,
  });

  @override
  State<AddZipCodePopup> createState() => _AddZipCodePopupState();
}

class _AddZipCodePopupState extends State<AddZipCodePopup> {
  bool isLoading = false;
  LatLng _selectedLocation = const LatLng(37.7749, -122.4194); // Default location
  String _location = 'Select Lat/Long'; // Default text
  double? _latitude;
  double? _longitude;
  String? selectedCounty;
  String selectedZipCodeCounty = 'Select County';
  String selectedZipCodeZone ="Select Zone";
  int docZoneId = 0;
  int countyId = 0;
  int countySortId = 0;
  String? countyError;
  String? zoneError;

  final StreamController<List<AllCountyZoneGet>> _zoneController =
  StreamController<List<AllCountyZoneGet>>.broadcast();
  void _pickLocation() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: _selectedLocation,
          onLocationPicked: (location) {
            setState(() {
              _selectedLocation = location;
              _latitude = location.latitude;
              _longitude = location.longitude;

              // Format Lat/Long
              String formatLatLong(double? latitude, double? longitude) {
                if (latitude != null && longitude != null) {
                  return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
                } else {
                  return 'Lat/Long not selected';
                }
              }

              final latlong = formatLatLong(_latitude, _longitude);
              _updateLocation(latlong);
            });
          },
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
        _latitude = pickedLocation.latitude;
        _longitude = pickedLocation.longitude;
      });
    }
  }

  void _updateLocation(String latlong) {
    setState(() {
      _location = latlong;
    });
  }

  String? zipcodeError;

  bool validateFields() {
    bool isValid = true;

    // Validate Zip Code field
    setState(() {
      var val = zipCodes;
      if (val.isEmpty) {
        zipcodeError = 'Zip code field cannot be empty.';
        isValid = false;
      } else {
        zipcodeError = null;
      }
    });

    return isValid;
  }
  @override
  void initState() {
    // TODO: implement initState
    _selectedLocation = LatLng(widget.officeLat, widget.officeLong);
    print('default office lat long ${_selectedLocation}');
    super.initState();
  }
  List<String> zipCodes = [];
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
      width: AppSize.s600,
      height: AppSize.s374,
      title: widget.title,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p10,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: AppPadding.p15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: AppStringEM.zipCode, // Main text
                      style: AllPopupHeadings.customTextStyle(context), // Main style
                      children: [
                        TextSpan(
                          text: ' *', // Asterisk
                          style: AllPopupHeadings.customTextStyle(context).copyWith(
                            color: ColorManager.red, // Asterisk color
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                   constraints: const BoxConstraints(minHeight: 70, maxHeight: 110),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            style: TableSubHeading.customTextStyle(context),
                            keyboardType: TextInputType.number,
                            controller: widget.zipcodeController,
                            decoration: const InputDecoration.collapsed(hintText: "Enter zip and press space"),
                            onChanged: (value) {
                              if (value.endsWith(" ")) {
                                final zip = value.trim();
                                if (zip.isNotEmpty && !zipCodes.contains(zip)) {
                                  setState(() {
                                    zipCodes.add(zip);
                                  });
                                }
                                widget.zipcodeController.clear();
                                validateFields();
                              }
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
                              LengthLimitingTextInputFormatter(10)],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: zipCodes.map((zip) {
                                return  Chip(
                                  label:  Text(
                                    zip,
                                    style: const TextStyle(
                                        fontSize: AppSize.s12,
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: ColorManager.blueprime,
                                  deleteIcon: const Icon(Icons.close, color: Colors.white, size: AppSize.s14),
                                  onDeleted: () {
                                    setState(() {
                                      zipCodes.remove(zip);
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  zipcodeError != null ?
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      zipcodeError!,
                      style: CommonErrorMsg.customTextStyle(context),
                    ),
                  ) : const SizedBox(height: AppSize.s12,),
                  const SizedBox(height: AppSize.s15),
                  // Location Picker Section
                 Opacity(
                   opacity:zipCodes.length > 1 ? 0.2 :  0.9,
                   child: Container(
                     child: IgnorePointer(
                       ignoring: zipCodes.length > 1 ,
                       child: Row(
                          children: [
                            TextButton(
                              onPressed: _pickLocation,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              child: Text(
                                'Pick Location',
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.blueprime,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_on_outlined,
                              color: ColorManager.granitegray,
                              size: AppSize.s18,
                            ),
                            const SizedBox(width: AppSize.s10),
                            Padding(
                              padding: const EdgeInsets.only(left: AppPadding.p10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _location,
                                    style: AllNoDataAvailable.customTextStyle(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                     ),
                   ),
                 ),
                ],
              ),
            ),
          ),
        ),
      ],
      bottomButtons: CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        isLoading: isLoading,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            var response = await addZipCodeSetup(
              context,
              widget.zoneId,
              widget.countyId,
              widget.officeId,
              "",
              zipCodes,
              _selectedLocation.latitude.toString(),
              _selectedLocation.longitude.toString(),
              "",
            );

            if(response.statusCode == 200 || response.statusCode == 201){
              Navigator.pop(context);
              await widget.onSavePressed();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddSuccessPopup(
                    message: 'Save Successfully',
                  );
                },
              );
            }else if(response.statusCode == 400 || response.statusCode == 404){
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

            setState(() {
              isLoading = false;
            });
          }
        },
      ),
    );
  }
}

///edit
class EditZipCodePopup extends StatefulWidget {
  final String title;
  final TextEditingController zipcodeController;
  final TextEditingController? mapController;
  final String officeId;
  final int zoneId;
  final int countyId;
  final int zipCodeSetupId;
  final String zipCodes;
  final String latitude;
  final String longitude;
  final String zoneName;
  final String countyName;
  final String lat;
  final String long;
  final Future<void> Function() onSavePressed;
  const EditZipCodePopup({
    super.key,
    required this.title,
    required this.zipcodeController,
    this.mapController,
    required this.onSavePressed,
    required this.latitude, required this.longitude, required this.zoneId, required this.countyId,
    required this.zipCodes, required this.zipCodeSetupId,
    required this.officeId, required this.zoneName, required this.countyName, required this.lat, required this.long,
  });

  @override
  State<EditZipCodePopup> createState() => _EditZipCodePopupState();
}

class _EditZipCodePopupState extends State<EditZipCodePopup> {
  bool isLoading = false;
  String? fetchedLatitude;
  String? fetchedLng;
  LatLng _selectedLocation = const LatLng(37.7749, -122.4194); // Default location
  String _location = "Lat 37.7749 lng -122.4194"; // Default text
  double? _latitude;
  double? _longitude;
  int docZoneId =0;
  int countyId =0;
  String zoneNameText = '';
  String countyNameText= '';
  final StreamController<List<AllCountyZoneGet>> _zoneController =
  StreamController<List<AllCountyZoneGet>>.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    fetchedLatitude = widget.latitude;
    fetchedLng = widget.longitude;
    docZoneId = widget.zoneId;
    countyId = widget.countyId;
    zoneNameText = widget.zoneName;
    countyNameText = widget.countyName;
    _location = "Lat ${widget.lat} lng ${widget.long}";
    super.initState();
  }
  void _pickLocation() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: _selectedLocation,
          onLocationPicked: (location) {
            setState(() {
              _selectedLocation = location;
              _latitude = location.latitude;
              _longitude = location.longitude;
              String formatLatLong(double? latitude, double? longitude) {
                if (latitude != null && longitude != null) {
                  return 'Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}';
                } else {
                  return 'Lat/Long not selected';
                }
              }

              final latlong = formatLatLong(_latitude, _longitude);

              print("Selected LatLong :: $latlong");

              // Update the location in the UI directly
              _updateLocation(latlong);
            });
          },
        ),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
        _latitude = pickedLocation.latitude;
        _longitude = pickedLocation.longitude;
      });
    }
  }
  void _updateLocation(String latlong) {
    setState(() {
      _location = latlong;
      print("Updated Location: $_location"); // Check this log to see if the value updates
    });
  }
  String? zipcodeError;
  bool validateFields() {
    bool isValid = true;

    setState(() {
      zipcodeError =widget.zipcodeController.text.isEmpty
          ? 'Zip code field cannot be empty.'
          : null;

      isValid = zipcodeError == null;

    });

    return isValid;
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

      title: widget.title,
      width: AppSize.s400,
      height: AppSize.s300,
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p14,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              SMTextfieldAsteric(
                controller: widget.zipcodeController,
                keyboardType: TextInputType.text,
                text: AppStringEM.zipCode,
              ),
              zipcodeError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    zipcodeError!,
                    textAlign: TextAlign.start,
                    style: CommonErrorMsg.customTextStyle(context),
                  ),
                ],
              ) : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s15),
              Row(
                children: [
                  TextButton(
                    onPressed: _pickLocation,
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent),
                    child: Text(
                      'Pick Location',
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.blueprime,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on_outlined,
                    color: ColorManager.granitegray,
                    size: AppSize.s18,
                  ),
                  const SizedBox(width: AppSize.s5,),
                  Text(
                      _location,
                      style: AllNoDataAvailable.customTextStyle(context)
                  ),
                ],
              ),
              const SizedBox(height: AppSize.s15),

            ],
          ),
          ],
        ),
    ),
      ],

      bottomButtons: CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: AppStringEM.save,
        isLoading: isLoading,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            var response = await updateZipCodeSetup(
                context,
                widget.zipCodeSetupId,
                widget.zoneId,
                widget.countyId,
                widget.officeId,
                "",
                widget.zipCodes == widget.zipcodeController.text ? widget.zipCodes
                    .toString() : widget.zipcodeController.text,
                _selectedLocation.latitude.toString(),
                _selectedLocation.longitude.toString(),
                "");

            if(response.statusCode == 200 || response.statusCode == 201){
              Navigator.pop(context);
              await widget.onSavePressed();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddSuccessPopup(
                    message: 'Zipcode Edited Successfully',
                  );
                },
              );
            }else if(response.statusCode == 400 || response.statusCode == 404){
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
            setState(() {
              isLoading = false;
            });
          }
        },
      ),

    );
  }
}


///zone
class AddZonePopup extends StatefulWidget {
  final TextEditingController zoneNumberController;
  final TextEditingController countyNameController;
  final Future<void> Function() onSavePressed;
  final Widget? child;
  final String title;
  final String buttonTitle;
  const AddZonePopup(
      {super.key,
        required this.zoneNumberController,
        this.child,
        required this.title,
        required this.onSavePressed,
        required this.buttonTitle,
        required this.countyNameController});

  @override
  State<AddZonePopup> createState() => _AddZonePopupState();
}

class _AddZonePopupState extends State<AddZonePopup> {
  bool isLoading = false;

  // Variables to hold error messages
  String? zoneNumberError;
  String? countyError;

  // Method to validate the input fields
  bool validateFields() {
    bool isValid = true;

    setState(() {
      // Validate zone number field
      zoneNumberError = widget.zoneNumberController.text.isEmpty
          ? 'Zone name cannot be empty.'
          : null;

      // Validate dropdown (assuming 'Select County' is the default unselected value)
      countyError = widget.child.toString() == 'Select County'
          ? 'Please select a county.'
          : null;

      // If any error message is not null, the form is invalid
      isValid = zoneNumberError == null && countyError == null;
    });

    return isValid;
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
      title: widget.title,
      width: AppSize.s400,
      height: AppSize.s330,
      body: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SMTextfieldAsteric(
                controller: widget.zoneNumberController,
                keyboardType: TextInputType.text,
                text: AppStringEM.zoneName,
                onChanged: (value){
                  setState(() {
                    bool isValid = true;
                    zoneNumberError = widget.zoneNumberController.text.isEmpty
                        ? 'Zone name cannot be empty.'
                        : null;
                  });
                },
              ),
              zoneNumberError != null ?
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      zoneNumberError!,
                      style:CommonErrorMsg.customTextStyle(context)
                  ),
                ],
              )  : const SizedBox(height: AppSize.s12,),
              const SizedBox(height: AppSize.s10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SMTextfieldAsteric(
                    enable: false,
                    controller: widget.countyNameController,
                    keyboardType: TextInputType.text,
                    text: AppString.county,
                  ),
                  if (countyError != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            countyError!,
                            style: CommonErrorMsg.customTextStyle(context)
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),

      ],
      bottomButtons: CustomElevatedButton(
        width: AppSize.s105,
        height: AppSize.s30,
        text: widget.buttonTitle,
        isLoading: isLoading,
        onPressed: () async {
          if (validateFields()) {
            setState(() {
              isLoading = true;
            });
            await widget.onSavePressed();
            setState(() {
              isLoading = false;
            });
          }
        },
      ),

    );
  }
}
