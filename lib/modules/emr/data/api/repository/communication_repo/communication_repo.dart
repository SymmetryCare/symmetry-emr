class CommunicationManagerRepository{
  static String broadcast = "/alert/feed";
  static String patientGroup = "/patient-group";
  static String myGroups = "/my-groups";
  static String groupInfo = "/group-info";
  static String patientGroupChat = "/patient-group-chat";
  static String chatScreen = "/chat-screen";
  static String addAleart = '/alert';
  static String getChipsAleart = '/alert/directory/clinician/search';
  static String aleartByPatientEmr = "/alert/ByPatient";

  /// clinician chat
  static String empChat = '/employees-chat';
  static String empChatList = "chat-list";
  static String empdetails = 'employee-details';
  static String empAllMsgChat = 'chat-screen';


 /// Aleart in EMR
  static String getPatientAleart({required int patientId, required String alertType}) {
    return "/$aleartByPatientEmr/$patientId/$alertType";
  }

  ///broadcast
  static String getAllBroadcast({required int pageNo, required int rows, required String searchName}) {
    return "/$broadcast/$pageNo/$rows/$searchName";
  }

  static String addAleartBroadcast(){
    return "$addAleart";
  }

  static String getAllBroadcastChipsData({ required String searchName}) {
    return "/$getChipsAleart/$searchName";
  }

  ///chats
  ///patient-group/my-groups/{pageNbr}/{NbrofRows}/{searchName}
  static String getAllPatientsChats({required int pageNo, required int rowNo, required String searchName}) {
    return "/$patientGroup/$myGroups/$pageNo/$rowNo/$searchName";
  }

  ///patient-group/group-info/{id}
  static String getGroupInfoPatientsChats({required int id}) {
    return "/$patientGroup/$groupInfo/$id";
  }

  ///patient-group-chat/chat-screen/{ptGroupId}/{pageNbr}/{NbrofRows}
  static String getChatPatientsGroupCommunication({required int grpId, required int pageNo, required int rowNo}) {
    return "/$patientGroupChat/$chatScreen/$grpId/$pageNo/$rowNo";
  }

  ///patient-group-chat
  static String postPatientGroupChat() {
    return "/$patientGroupChat";
  }
  static String patchExitPatientGrp({required int id}) {
    return "$patientGroup/$id/leave";
  }
  static String patchClearPatientGroupChat({required int id}) {
    return "$patientGroupChat/clear-chat/$id";
  }
  static String patientAttachMedia({required int id}) {
    return "$patientGroupChat/$id/attachment";
  }
  static String patientAttachVoiceNoteMedia({required int id}) {
    return "$patientGroupChat/$id/voice-note";
  }




  /// Emp clnician chat
  static String postEmployeeChat() {
    return "/$empChat";
  }
  static String getEmployeeChat({required int pageNo, required int rows, required String selectDepartment, required String searchName}) {
    return "/$empChat/$empChatList/$pageNo/$rows/$selectDepartment/$searchName";
  }
  static String getEmployeeDetailsCom({required int empId}) {
    return "/$empChat/$empdetails/$empId";
  }
  static String getAllEmployeeChat({required int pageNo, required int rows, required int otherEmpid,}) {
    return "/$empChat/$empAllMsgChat/$otherEmpid/$pageNo/$rows";
  }

  static String getEmployeesChatScreen({required int pageNo, required int rows, required int otherEmpid,}) {
    return "/$empChat/$empAllMsgChat/$otherEmpid/$pageNo/$rows";
  }
  static String deleteEmpChat({required int otherEmpId}) {
    return "$empChat/clear-chat/$otherEmpId";
  }
  static String empAttachMedia({required int employeeId}) {
    return "/$empChat/$employeeId/attachment";
  }
  static String empAttachVoiceMedia({required int employeeId}) {
    return "/$empChat/$employeeId/voice-note";
  }

}