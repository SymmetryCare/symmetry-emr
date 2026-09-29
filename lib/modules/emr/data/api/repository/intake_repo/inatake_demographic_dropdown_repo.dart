class PhysicianInfo{

  static String physicianinfopost ="/intake-physician-info/add";

static String piftof ="/intake-physician-f2-f/add";


static String  firstrd ="/intake-physician-rdignosis/add";
static String  pdrd ="/intake-physician-rdignosis-pd/add";
static String  pdrdlisi ="/intake-physician-rdignosis-lisi/add";

static String stateDropdown ="/state";
static String cityDropdown ="/city";
static String relationshipDropdown ="/relationship";
static String languageSpokenDropdown ="/language-spoken";
static String metrialStatusDropdown ="/marital-status";
static String raceDropdown ="/race";
static String religionDropdown ="/religion";
static String priorityDisasterDropdown="/dropdown-priority-disaster-code";
static String eligibilityStatusDropdown="/dropdown-eligibility-status";
static String categoryDropdown="/dropdown-refferals_manager-category";
static String suppliesDropdown="/dropdown-supplies-dme";
static String pharmacyDropdown="/dropdown-pharmacy";
static String facilityDropdown="/dropdown-facility";
static String countryDropdown="/country";
static String getreferringDiagnosis = '/intake-physician-rdignosis-pd';
static String getResidenceType = '/residence-type';







  static  String addPIinfo(){
    return "$physicianinfopost";
  }

  ////
  static  String addPIftof(){
    return "$piftof";
  }

  ////
static String addfirstRD(){
    return "$firstrd";
}

  static String addThreeRD(){
    return "$pdrdlisi";
  }

  static String addpdrd(){
    return "$pdrd";
  }

  static String stateDD(){
    return "$stateDropdown";
  }


  static String cityDD(){
    return "$cityDropdown";
  }

  static String relationshipDD(){
    return "$relationshipDropdown";
  }

  static String languageSpokenDD(){
    return "$languageSpokenDropdown";
  }

  static String metrialstatusDD(){
    return "$metrialStatusDropdown";
  }

  static String raceDD(){
    return "$raceDropdown";
  }


  static String religionDD(){
    return "$religionDropdown";
  }


  static String piorityDisastorDD(){
    return"$priorityDisasterDropdown";
  }


  static String eligibilityStatusDD(){
    return"$eligibilityStatusDropdown";
  }

  static String categoryDD(){
    return"$categoryDropdown";
  }


  static String suppliesDMEDD(){
    return"$suppliesDropdown";
  }


  static String pharmacyDD(){
    return"$pharmacyDropdown";
  }



  static String facilityDD(){
    return"$facilityDropdown";
  }


  static String countryDD(){
    return"$countryDropdown";
  }

  static String getRD(){
    return "$getreferringDiagnosis";
  }

  static String getResidence(){
    return "$getResidenceType";
  }
}