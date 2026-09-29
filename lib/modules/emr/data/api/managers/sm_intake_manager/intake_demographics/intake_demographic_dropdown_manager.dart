import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/demographics_dropdown_data.dart';

import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/services/api/api.dart';
import 'package:symmetry_emr/modules/emr/data/api/repository/intake_repo/inatake_demographic_dropdown_repo.dart';

///Info save Post API
Future<ApiData> postPhysicianInfoScreen(
  BuildContext context,
  int patientId,
  int companyId,
  String primaryPhysician,
  String pr_FirstName,
  String pr_LastName,
  String pr_PECOSStatus,
  String pr_UPINNbr,
  String pr_NPINbr,
  String pr_Street,
  String pr_SuiteApt,
  String pr_City,
  String pr_State,
  String pr_Zipcode,
  String pr_Phone,
  String pr_Fax,
  String pr_Protocol,
  String contractF2FPhysician,
  String f2f_FirstName,
  String f2f_LastName,
  String f2f_PECOSStatus,
  String f2f_UPINNbr,
  String f2f_NPINbr,
  String f2f_Street,
  String f2f_SuiteApt,
  String f2f_City,
  String f2f_State,
  String f2f_Zipcode,
  String f2f_Phone,
  String f2f_Fax,
  String f2f_Protocol,
) async {
  try {
    var response = await Api(context).post(
      path: PhysicianInfo.addPIinfo(),
      data: {
        "patientId": patientId,
        "companyId": companyId,
        "primaryPhysician": primaryPhysician,
        "pr_FirstName": pr_FirstName,
        "pr_LastName": pr_LastName,
        "pr_PECOSStatus": pr_PECOSStatus,
        "pr_UPINNbr": pr_UPINNbr,
        "pr_NPINbr": pr_NPINbr,
        "pr_Street": pr_Street,
        "pr_SuiteApt": pr_SuiteApt,
        "pr_City": pr_City,
        "pr_State": pr_State,
        "pr_Zipcode": pr_Zipcode,
        "pr_Phone": pr_Phone,
        "pr_Fax": pr_Fax,
        "pr_Protocol": pr_Protocol,
        "contractF2FPhysician": contractF2FPhysician,
        "f2f_FirstName": f2f_FirstName,
        "f2f_LastName": f2f_LastName,
        "f2f_PECOSStatus": f2f_PECOSStatus,
        "f2f_UPINNbr": f2f_UPINNbr,
        "f2f_NPINbr": f2f_NPINbr,
        "f2f_Street": f2f_Street,
        "f2f_SuiteApt": f2f_SuiteApt,
        "f2f_City": f2f_City,
        "f2f_State": f2f_State,
        "f2f_Zipcode": f2f_Zipcode,
        "f2f_Phone": f2f_Phone,
        "f2f_Fax": f2f_Fax,
        "f2f_Protocol": f2f_Protocol
      },
    );
    print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("physician info data Saved");
      var patientIdresponse = response.data;
      int idPatient = patientIdresponse["patientId"];

      // orgDocumentGet(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
            ),
            child: Container(
              height: 270,
              width: 300,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0), // Rounded corners
                color: Colors.white, // Background color
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF50B5E5),
                    size: 80.0,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Successfully Add !",
                    style: APIErrorTextConst.customTextStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomButton(
                          height: 30,
                          width: 130,
                          text: 'Continue',
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      ///

      return ApiData(
          statusCode: response.statusCode!,
          success: true,
          message: response.statusMessage!,
          patientId: idPatient);
    } else {
      print("Error 1");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
            ),
            child: Container(
              height: 270,
              width: 300,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0), // Rounded corners
                color: Colors.white, // Background color
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 80.0,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Failed, Please Try Again !",
                    style: APIErrorTextConst.customTextStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomButton(
                          height: 30,
                          width: 130,
                          text: 'Back',
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      return ApiData(
          statusCode: response.statusCode!,
          success: false,
          message: response.data['message']);
    }
  } catch (e) {
    print("Error $e");
    // Show error dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          child: Container(
            height: 270,
            width: 300,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
              color: Colors.white, // Background color
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 80.0,
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Please Try Again !",
                  style: APIErrorTextConst.customTextStyle(context),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomButton(
                        height: 30,
                        width: 130,
                        text: 'Back',
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return ApiData(
        statusCode: 404, success: false, message: AppString.somethingWentWrong);
  }
}
///////////

Future<List<StateData>> getStateDropDown(
  BuildContext context,
) async {
  List<StateData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.stateDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(StateData(
          stateId: item['stateId'],
          name: item['name'],
          short: item['short'],
          countryId: item['countryId'],
          country: item['country'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

//////

Future<List<CityData>> getCityDropDown(
  BuildContext context,
) async {
  List<CityData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.cityDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(CityData(
          city_id: item['city_id'],
          cityName: item['cityName'],
          state: item['state'],
          Country: item['Country'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///////

Future<List<RelationshipData>> getRelationshipDropDown(
  BuildContext context,
) async {
  List<RelationshipData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.relationshipDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(RelationshipData(
          relationshipId: item['relationshipId'],
          relationship: item['relationship'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


///


Future<List<LanguageSpokenData>> getlanguageSpokenDropDown(
    BuildContext context,
    ) async {
  List<LanguageSpokenData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.languageSpokenDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(LanguageSpokenData(
          languageSpokenId: item['languageSpokenId'],
          languageSpoken: item['languageSpoken'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}



///

Future<List<MetrialStatusData>> getMaritalStatusDropDown(
    BuildContext context,
    ) async {
  List<MetrialStatusData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.metrialstatusDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(MetrialStatusData(
          maritalStatusId: item['maritalStatusId'],
          maritalStatus: item['maritalStatus'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///

Future<List<RaceData>> getRaceDropDown(
    BuildContext context,
    ) async {
  List<RaceData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.raceDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(RaceData(
          raceId: item['raceId'],
          race: item['race'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}




///
Future<List<ReligionData>> getReligionDropDown(
    BuildContext context,
    ) async {
  List<ReligionData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.religionDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(ReligionData(
          religionId: item['religionId'],
          religion: item['religion'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


///

Future<List<PriorityDisasterData>> getPiorityDisastorDropDown(
    BuildContext context,
    ) async {
  List<PriorityDisasterData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.piorityDisastorDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PriorityDisasterData(
          Id: item['Id'],
          idText: item['idText'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}
///


Future<List<EligiblityStatusData>> getEligiblityStatusDropDown(
    BuildContext context,
    ) async {
  List<EligiblityStatusData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.eligibilityStatusDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(EligiblityStatusData(
          Id: item['Id'],
          idText: item['idText'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}



///
Future<List<CategoryData>> getCategoryDropDown(
    BuildContext context,
    ) async {
  List<CategoryData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.categoryDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(CategoryData(
          Id: item['Id'],
          idText: item['idText'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///
Future<List<SuppliesData>> getSuppliesDMEDropDown(
    BuildContext context,
    ) async {
  List<SuppliesData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.suppliesDMEDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(SuppliesData(
          Id: item['Id'],
          idText: item['idText'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///
Future<List<PharmacyData>> getPharmacyDropDown(
    BuildContext context,
    ) async {
  List<PharmacyData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.pharmacyDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(PharmacyData(
          Id: item['Id'],
          idText: item['idText'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

///
Future<List<FacilityData>> getFacilityDropDown(
    BuildContext context,
    ) async {
  List<FacilityData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.facilityDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(FacilityData(
          Id: item['Id'],
          idText: item['idText'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}


//////

Future<List<CountryData>> getCountryDropDown(
    BuildContext context,
    ) async {
  List<CountryData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.countryDD());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(CountryData(
          countryId: item['countryId'],
          name: item['name'],
          short: item['short'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}

/// residence dropdown
Future <List<ResidenceTypeData>> getResidenceDropdown(
BuildContext context,) async {
  List<ResidenceTypeData> itemsList = [];
  try {
    final response = await Api(context).get(path: PhysicianInfo.getResidence());
    if (response.statusCode == 200 || response.statusCode == 201) {
      for (var item in response.data) {
        itemsList.add(ResidenceTypeData(
          id: item['id'],
          detail: item['detail'],
          description: item['description'],
        ));
      }
    } else {
      print('Api Error');
    }
    print("Response:::::${response}");
    return itemsList;
  } catch (e) {
    print("Error $e");
    return itemsList;
  }
}