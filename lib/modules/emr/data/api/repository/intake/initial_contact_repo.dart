class InitialContactRepo{
  static String initialcontact = '/initial-contact/patient';
  static String patchInitialContact = '/initial-contact';

  static  String getInitialContact({required int ptId}){
    return "$initialcontact/$ptId";
  }

  static  String patchInitialContactWithId({required int Id}){
    return "$patchInitialContact/$Id";
  }

  static  String postInitialContactWithId(){
    return "$patchInitialContact";
  }
}